import numpy as np

class CanonicalSystem:
    def __init__(self, alpha_s=np.log(100), dt=0.01):
        self.alpha_s = alpha_s
        self.dt = dt
        self.s = 1.0

    def step(self, tau=1.0):
        self.s += (-self.alpha_s * self.s) * (self.dt / tau)
        return self.s

    def reset(self):
        self.s = 1.0

    def rollout(self, steps, tau=1.0):
        self.reset()
        s_track = np.zeros(steps)
        for i in range(steps):
            s_track[i] = self.s
            self.step(tau)
        return s_track


class DMP1D:
    def __init__(self, n_bfs=50, alpha_z=25.0, beta_z=6.25, alpha_s=np.log(100), dt=0.01):
        self.n_bfs = n_bfs
        self.alpha_z = alpha_z
        self.beta_z = beta_z
        self.cs = CanonicalSystem(alpha_s=alpha_s, dt=dt)
        self.dt = dt

        # Set up basis functions
        # Centers exponentially spaced in phase space [0, 1]
        self.c = np.exp(-self.cs.alpha_s * np.linspace(0, 1, self.n_bfs))
        # Widths of the Gaussians
        self.h = np.ones(self.n_bfs) * self.n_bfs**1.5 / self.c / self.cs.alpha_s

        self.w = np.zeros(self.n_bfs)
        self.x0 = 0.0
        self.g = 0.0

    def _forcing_term(self, s):
        psi = np.exp(-self.h * (s - self.c)**2)
        f = np.sum(self.w * psi) / (np.sum(psi) + 1e-10) * s
        return f

    def imitate(self, t, y, dy, ddy):
        """
        Learn the weights from a demonstration.
        """
        tau = t[-1] - t[0]
        self.x0 = y[0]
        self.g = y[-1]

        # Generate phase variable for the demonstration
        steps = len(t)
        s_track = self.cs.rollout(steps, tau)

        # Calculate the target forcing term
        # f_target = tau^2 * ddy - alpha_z * (beta_z * (g - y) - tau * dy)
        f_target = np.zeros(steps)
        for i in range(steps):
            f_target[i] = (tau**2 * ddy[i]) - self.alpha_z * (self.beta_z * (self.g - y[i]) - tau * dy[i])
            # To avoid the forcing term pushing the system away from the goal at the start,
            # some formulations add: + self.alpha_z * self.beta_z * (self.g - self.x0) * s_track[i]
            # But the standard Schaal formulation handles the start by setting x0 correctly.
        
        # Locally Weighted Regression (LWR) to find weights
        for i in range(self.n_bfs):
            psi = np.exp(-self.h[i] * (s_track - self.c[i])**2)
            # w_i = sum(s * psi * f_target) / sum(s^2 * psi)
            num = np.sum(s_track * psi * f_target)
            den = np.sum((s_track**2) * psi)
            self.w[i] = num / (den + 1e-10)

        return s_track, f_target

    def generate_trajectory(self, tau=None, goal=None, initial_y=None, steps=None):
        """
        Generate a trajectory using the learned weights.
        """
        if tau is None:
            tau = 1.0 # Default time scaling
        if goal is not None:
            self.g = goal
        if initial_y is not None:
            self.x0 = initial_y

        if steps is None:
            steps = int(tau / self.dt)

        self.cs.reset()
        
        y = self.x0
        z = 0.0 # scaled velocity
        
        y_track = np.zeros(steps)
        dy_track = np.zeros(steps)
        ddy_track = np.zeros(steps)

        for i in range(steps):
            s = self.cs.s
            
            f = self._forcing_term(s)
            
            # Transformation system equations
            dz = self.alpha_z * (self.beta_z * (self.g - y) - z) + f
            dy = z
            
            # Step forward
            z += dz * (self.dt / tau)
            y += dy * (self.dt / tau)
            self.cs.step(tau)
            
            y_track[i] = y
            dy_track[i] = dy / tau
            ddy_track[i] = dz / (tau**2)

        return y_track, dy_track, ddy_track

class MultiDMP:
    def __init__(self, n_dofs, n_bfs=50, dt=0.01):
        self.n_dofs = n_dofs
        self.dmps = [DMP1D(n_bfs=n_bfs, dt=dt) for _ in range(n_dofs)]
        self.dt = dt

    def imitate(self, t, pos_dict, vel_dict, acc_dict):
        """
        pos_dict: dict of joint_name -> numpy array
        """
        self.joint_names = list(pos_dict.keys())
        for i, joint in enumerate(self.joint_names):
            self.dmps[i].imitate(t, pos_dict[joint], vel_dict[joint], acc_dict[joint])

    def generate_trajectory(self, tau=1.0, goals=None, initial_ys=None, steps=None):
        """
        goals: dict of joint_name -> goal_value
        initial_ys: dict of joint_name -> initial_value
        """
        if steps is None:
            steps = int(tau / self.dt)

        pos_track = {j: np.zeros(steps) for j in self.joint_names}
        
        for i, joint in enumerate(self.joint_names):
            g = goals[joint] if goals and joint in goals else None
            y0 = initial_ys[joint] if initial_ys and joint in initial_ys else None
            
            y, _, _ = self.dmps[i].generate_trajectory(tau=tau, goal=g, initial_y=y0, steps=steps)
            pos_track[joint] = y
            
        return pos_track
