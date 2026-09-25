import numpy as np
import pandas as pd
import os
from dmp_pipeline import run_dmp_pipeline, plot_results

def generate_synthetic_data(csv_path):
    """
    Simulates a 2-DOF SCARA demonstration.
    """
    t = np.linspace(0, 5.0, 500) # 5 seconds, 100Hz
    
    # Servo 1: Base rotation (smooth move from 0 to 90 degrees in 4 seconds, then hold)
    s1 = np.piecewise(t, [t <= 4.0, t > 4.0],
                      [lambda t: 90 * (1 - np.cos(np.pi * t / 4.0)) / 2.0,
                       90.0])
    
    # Servo 2: Arm extension (sinusoidal motion finishing at 4 seconds)
    s2 = np.piecewise(t, [t <= 4.0, t > 4.0],
                      [lambda t: 30 * np.sin(np.pi * t / 2.0),
                       0.0])
    
    # Add a tiny bit of noise to simulate real sensors
    s1 += np.random.normal(0, 0.5, len(t))
    s2 += np.random.normal(0, 0.5, len(t))
    
    df = pd.DataFrame({
        'timestamp_ms': t * 1000,
        'servo1_angle': s1,
        'servo2_angle': s2
    })
    
    df.to_csv(csv_path, index=False)
    print(f"Synthetic data saved to {csv_path}")

if __name__ == "__main__":
    csv_file = "scara_demo.csv"
    if not os.path.exists(csv_file):
        generate_synthetic_data(csv_file)
        
    t, pos, gen_t, gen_pos, joint_cols, df_raw = run_dmp_pipeline(csv_file, time_col='timestamp_ms', is_synthetic=True, save_output=False)
    plot_results(t, pos, gen_t, gen_pos, joint_cols, df_raw, time_col='timestamp_ms')
