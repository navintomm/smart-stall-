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
            self.aruco_params = cv2.aruco.DetectorParameters()
            self.detector = cv2.aruco.ArucoDetector(self.aruco_dict, self.aruco_params)
        except AttributeError:
            self.aruco_dict = cv2.aruco.Dictionary_get(cv2.aruco.DICT_4X4_50)
            self.aruco_params = cv2.aruco.DetectorParameters_create()
            self.detector = None
            
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
            if hasattr(self, 'detector') and self.detector is not None:
                corners, ids, rejected = self.detector.detectMarkers(gray)
            else:
                corners, ids, rejected = cv2.aruco.detectMarkers(gray, self.aruco_dict, parameters=self.aruco_params)
            
            if ids is not None and len(ids) > 0:
                cv2.aruco.drawDetectedMarkers(frame, corners, ids)
                
                # Estimate pose for the first detected marker using solvePnP
                # Marker corners are assumed to be in this order: top-left, top-right, bottom-right, bottom-left
                half_size = MARKER_SIZE / 2.0
                obj_points = np.array([
                    [-half_size,  half_size, 0],
                    [ half_size,  half_size, 0],
                    [ half_size, -half_size, 0],
                    [-half_size, -half_size, 0]
                ], dtype=np.float32)

                for i in range(len(ids)):
                    # Get corners for this marker
                    img_points = corners[i][0]
                    
                    # Solve PnP
                    success, rvec, tvec = cv2.solvePnP(
                        obj_points, img_points, self.camera_matrix, self.dist_coeffs, flags=cv2.SOLVEPNP_IPPE_SQUARE
                    )
                    
                    if success:
                        cv2.drawFrameAxes(frame, self.camera_matrix, self.dist_coeffs, rvec, tvec, 0.1)
                        
                        x, y, z = tvec[0][0], tvec[1][0], tvec[2][0]
                        dist = math.sqrt(x**2 + y**2 + z**2)
                        
                        R, _ = cv2.Rodrigues(rvec)
                        # Simplified Euler conversion for demonstration
                        yaw = math.atan2(R[1,0], R[0,0])
                        pitch = math.atan2(-R[2,0], math.sqrt(R[2,1]**2 + R[2,2]**2))
                        roll = math.atan2(R[2,1], R[2,2])
                    
                        # Display Distance and Pose on the screen
                        overlay_text = f"ID: {int(ids[i][0])} | Dist: {dist:.2f}m"
                        cv2.putText(frame, overlay_text, (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2)
                        
                        pose_text = f"X:{x:.2f} Y:{y:.2f} Z:{z:.2f} Yaw:{math.degrees(yaw):.0f}"
                        cv2.putText(frame, pose_text, (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 0), 2)
                        
                        print(f"Marker Detected: {overlay_text} | {pose_text}")
                        
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
