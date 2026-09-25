import os
import sys
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.metrics import mean_squared_error, mean_absolute_error
from preprocessing import TrajectoryPreprocessor
from dmp_model import MultiDMP

def calculate_smoothness(trajectory):
    """Calculate smoothness using sum of squared jerk (3rd derivative)."""
    if len(trajectory) < 4:
        return 0.0
    jerk = np.diff(trajectory, n=3)
    return np.sum(jerk**2)

def run_dmp_pipeline(csv_path, time_col='timestamp_ms', is_synthetic=False, save_output=False):
    title = "DMP SYNTHETIC TEST" if is_synthetic else "REAL SCARA EXPERIMENT"
    print(f"\n{title}")
    print("-" * len(title))
    
    # Load and preprocess
    df_raw = pd.read_csv(csv_path)
    
    # Check for NaN or Inf in raw data
    has_nan = df_raw.isna().any().any()
    has_inf = np.isinf(df_raw.select_dtypes(include=np.number)).any().any()
    
    # For real data, we expect servo1_angle, servo2_angle
    # For synthetic, we might have joint1, joint2, etc.
    joint_cols = [c for c in df_raw.columns if c != time_col]
    
    preprocessor = TrajectoryPreprocessor(time_col=time_col, joint_cols=joint_cols)
    t, pos, vel, acc = preprocessor.load_and_preprocess(csv_path)
    
    dt = t[1] - t[0]
    n_dofs = len(joint_cols)
    tau = t[-1]
    
    print(f"Input samples: {len(t)}")
    
    dmp = MultiDMP(n_dofs=n_dofs, n_bfs=50, dt=dt)
    dmp.imitate(t, pos, vel, acc)
    
    # Generate trajectory
    gen_pos = dmp.generate_trajectory(tau=tau, steps=len(t))
    gen_t = np.linspace(0, tau, len(t))
    
    print(f"Generated samples: {len(gen_t)}\n")
    
    start_preserved = True
    goal_preserved = True
    gen_has_nan = False
    gen_has_inf = False
    
    for j in joint_cols:
        orig = pos[j]
        gen = gen_pos[j]
        
        if np.isnan(gen).any(): gen_has_nan = True
        if np.isinf(gen).any(): gen_has_inf = True
        
        if abs(orig[0] - gen[0]) > 0.1: start_preserved = False
        if abs(orig[-1] - gen[-1]) > 1.5: goal_preserved = False
        
        mae = mean_absolute_error(orig, gen)
        rmse = np.sqrt(mean_squared_error(orig, gen))
        max_err = np.max(np.abs(orig - gen))
        
        sm_orig = calculate_smoothness(orig)
        sm_gen = calculate_smoothness(gen)
        
        print(f"{j}:")
        print(f"MAE: {mae:.4f}")
        print(f"RMSE: {rmse:.4f}")
        print(f"Maximum Error: {max_err:.4f}\n")
        
        print("Smoothness:")
        print(f"Original: {sm_orig:.4f}")
        print(f"Generated: {sm_gen:.4f}\n")
        
    print(f"Start position preserved: {'YES' if start_preserved else 'NO'}")
    print(f"Goal position preserved: {'YES' if goal_preserved else 'NO'}")
    print(f"NaN values: {'YES' if gen_has_nan or has_nan else 'NO'}")
    print(f"Infinite values: {'YES' if gen_has_inf or has_inf else 'NO'}\n")
    
    if save_output:
        base_name = os.path.basename(csv_path)
        name, ext = os.path.splitext(base_name)
        out_name = f"generated_dmp_{name}.csv"
        
        out_dict = {time_col: df_raw[time_col].values[:len(gen_t)]}
        for j in joint_cols:
            out_dict[j] = gen_pos[j]
            
        pd.DataFrame(out_dict).to_csv(out_name, index=False)
        print(f"Saved generated trajectory to {out_name}")
        
    return t, pos, gen_t, gen_pos, joint_cols, df_raw

def plot_results(t, pos, gen_t, gen_pos, joint_cols, df_raw, time_col='timestamp_ms'):
    # Plot 1 & 2: Original vs Generated for first two servos
    for i, j in enumerate(joint_cols[:2]):
        plt.figure(figsize=(8, 4))
        plt.plot(t, pos[j], 'k--', label='Original Preprocessed', linewidth=2)
        plt.plot(gen_t, gen_pos[j], 'r-', label='Generated DMP', linewidth=1.5)
        plt.title(f"Original vs Generated {j}")
        plt.xlabel("Time (s)")
        plt.ylabel("Angle (deg)")
        plt.legend()
        plt.grid(True)
        plt.savefig(f'plot_{i+1}_original_vs_generated_{j}.png')
        plt.close()

    # Plot 3: Joint Space (Servo 1 vs Servo 2)
    if len(joint_cols) >= 2:
        j1, j2 = joint_cols[0], joint_cols[1]
        plt.figure(figsize=(6, 6))
        plt.plot(pos[j1], pos[j2], 'k--', label='Original Path', linewidth=2)
        plt.plot(gen_pos[j1], gen_pos[j2], 'r-', label='Generated Path', linewidth=1.5)
        plt.title(f"Joint Space: {j1} vs {j2}")
        plt.xlabel(f"{j1} (deg)")
        plt.ylabel(f"{j2} (deg)")
        plt.legend()
        plt.grid(True)
        plt.savefig('plot_3_joint_space.png')
        plt.close()

    # Compare Raw vs Preprocessed
    for j in joint_cols[:2]:
        plt.figure(figsize=(8, 4))
        # Map time properly. df_raw might have milliseconds
        raw_t = df_raw[time_col].values
        raw_t = raw_t - raw_t[0]
        if max(raw_t) > 1000: # Assuming it's in ms
            raw_t = raw_t / 1000.0
            
        plt.plot(raw_t, df_raw[j], 'b-', alpha=0.5, label=f'Raw {j}')
        plt.plot(t, pos[j], 'k--', label=f'Preprocessed {j}')
        plt.title(f"Raw vs Preprocessed {j}")
        plt.xlabel("Time (s)")
        plt.ylabel("Angle (deg)")
        plt.legend()
        plt.grid(True)
        plt.savefig(f'plot_raw_vs_preprocessed_{j}.png')
        plt.close()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        csv_file = sys.argv[1]
        t, pos, gen_t, gen_pos, joint_cols, df_raw = run_dmp_pipeline(csv_file, time_col='timestamp_ms', is_synthetic=False, save_output=True)
        plot_results(t, pos, gen_t, gen_pos, joint_cols, df_raw, time_col='timestamp_ms')
    else:
        print("Please provide a CSV file path. Example: python dmp_pipeline.py real_recording.csv")
