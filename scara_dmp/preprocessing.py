import pandas as pd
import numpy as np
from scipy.signal import savgol_filter

class TrajectoryPreprocessor:
    def __init__(self, time_col='time', joint_cols=None):
        """
        :param time_col: Name of the time column in the CSV
        :param joint_cols: List of column names for the joints (e.g., ['j1', 'j2', 'j3']). 
                           If None, will use all columns except time.
        """
        self.time_col = time_col
        self.joint_cols = joint_cols

    def load_and_preprocess(self, filepath, window_length=11, polyorder=3):
        """
        Loads the CSV and computes smoothed position, velocity, and acceleration.
        """
        df = pd.read_csv(filepath)
        
        # Ensure time starts at 0
        df[self.time_col] = df[self.time_col] - df[self.time_col].iloc[0]
        t = df[self.time_col].values
        
        if self.joint_cols is None:
            self.joint_cols = [c for c in df.columns if c != self.time_col]
            
        dt = np.mean(np.diff(t))
        if dt == 0:
            raise ValueError("Time step dt is zero!")

        # Create dictionaries to store the processed data
        pos = {}
        vel = {}
        acc = {}
        
        for col in self.joint_cols:
            y = df[col].values
            
            wl = window_length if window_length % 2 != 0 else window_length + 1
            if len(y) < wl:
                wl = len(y) if len(y) % 2 != 0 else len(y) - 1
            if wl <= polyorder:
                polyorder = wl - 1
                
            y_smooth = savgol_filter(y, wl, polyorder)
            dy = savgol_filter(y_smooth, wl, polyorder, deriv=1, delta=dt)
            ddy = savgol_filter(y_smooth, wl, polyorder, deriv=2, delta=dt)
            
            # Force steady state at the boundaries to prevent DMP weight explosion
            y_smooth[:10] = y_smooth[10]
            y_smooth[-10:] = y_smooth[-11]
            dy[:10] = 0.0
            dy[-10:] = 0.0
            ddy[:10] = 0.0
            ddy[-10:] = 0.0
            
            pos[col] = y_smooth
            vel[col] = dy
            acc[col] = ddy
            
        return t, pos, vel, acc
