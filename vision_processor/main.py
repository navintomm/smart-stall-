import cv2
import numpy as np
import socket
import json
import time
import math

# --- CONFIGURATION ---
ESP32_IP = "192.168.4.1" # Change to actual ESP32 IP or let it connect to a specific local IP
ESP32_PORT = 8888
MARKER_SIZE = 0.15 # meters (150mm)

class VisionProcessor:
    def __init__(self):
        self.camera_matrix = np.array([[800, 0, 320], [0, 800, 240]], dtype=float)
        self.dist_coeffs = np.zeros((4, 1))
        
        # In newer OpenCV versions, aruco is part of cv2.aruco directly or cv2.objdetect
        try:
            self.aruco_dict = cv2.aruco.getPredefinedDictionary(cv2.aruco.DICT_4X4_50)
            self.aruco_params = cv2.aruco.DetectorParameters_create()
        except AttributeError:
            self.aruco_dict = cv2.aruco.Dictionary_get(cv2.aruco.DICT_4X4_50)
            self.aruco_params = cv2.aruco.DetectorParameters_create()
            
        self.sock = None
        self.connect_to_robot()

    def connect_to_robot(self):
        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.sock.settimeout(2.0)
            print(f"Connecting to ESP32 at {ESP32_IP}:{ESP32_PORT}...")
            self.sock.connect((ESP32_IP, ESP32_PORT))
            print("Connected!")
        except Exception as e:
            print(f"Failed to connect: {e}")
            self.sock = None

    def send_telemetry(self, x, y, z, roll, pitch, yaw, dist, score, m_id, conf):
        if not self.sock:
            return

        payload = {
            "type": "command",
            "protocolVersion": "1.0",
            "commandId": 701,
            "sequenceNumber": int(time.time()),
            "payload": {
                "marker_id": m_id,
                "marker_conf": conf,
                "pose_x": round(x, 3),
                "pose_y": round(y, 3),
                "pose_z": round(z, 3),
                "pose_roll": round(roll, 3),
                "pose_pitch": round(pitch, 3),
                "pose_yaw": round(yaw, 3),
                "marker_dist": round(dist, 3),
                "align_score": int(score),
                "cam_calibrated": True
            }
        }
        
        try:
            msg = json.dumps(payload) + "\n"
            self.sock.sendall(msg.encode('utf-8'))
        except Exception as e:
            print(f"Socket error: {e}")
            self.sock = None
            self.connect_to_robot()

    def calculate_alignment_score(self, x, y, yaw, dist):
        max_horiz = 0.2
        max_rot = 0.3
        max_dist = 0.3
        
        dist_err = dist - 0.5
        
        h_pen = min((abs(x) / max_horiz) * 33.3, 33.3)
        r_pen = min((abs(yaw) / max_rot) * 33.3, 33.3)
        d_pen = min((abs(dist_err) / max_dist) * 33.3, 33.3)
        
        score = 100 - int(h_pen + r_pen + d_pen)
        return max(0, min(100, score))

    def run(self):
        cap = cv2.VideoCapture(0)
        
        print("Starting Vision Processor... Press 'q' to quit.")
        
        while True:
            ret, frame = cap.read()
            if not ret:
                break
                
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            corners, ids, rejected = cv2.aruco.detectMarkers(gray, self.aruco_dict, parameters=self.aruco_params)
            
            if ids is not None and len(ids) > 0:
                cv2.aruco.drawDetectedMarkers(frame, corners, ids)
                
                # Estimate pose for the first detected marker
                rvecs, tvecs, _ = cv2.aruco.estimatePoseSingleMarkers(corners, MARKER_SIZE, self.camera_matrix, self.dist_coeffs)
                
                for i in range(len(ids)):
                    rvec = rvecs[i][0]
                    tvec = tvecs[i][0]
                    
                    cv2.drawFrameAxes(frame, self.camera_matrix, self.dist_coeffs, rvec, tvec, 0.1)
                    
                    x, y, z = tvec[0], tvec[1], tvec[2]
                    dist = math.sqrt(x**2 + y**2 + z**2)
                    
                    R, _ = cv2.Rodrigues(rvec)
                    # Simplified Euler conversion for demonstration
                    yaw = math.atan2(R[1,0], R[0,0])
                    pitch = math.atan2(-R[2,0], math.sqrt(R[2,1]**2 + R[2,2]**2))
                    roll = math.atan2(R[2,1], R[2,2])
                    
                    score = self.calculate_alignment_score(x, y, yaw, dist)
                    
                    self.send_telemetry(x, y, z, roll, pitch, yaw, dist, score, int(ids[i][0]), 0.95)
                    break # Just process the first one for the robot
                    
            cv2.imshow("SmartStall Vision Processor", frame)
            
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
                
        cap.release()
        cv2.destroyAllWindows()
        if self.sock:
            self.sock.close()

if __name__ == "__main__":
    vp = VisionProcessor()
    vp.run()
