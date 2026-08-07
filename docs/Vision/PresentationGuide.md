# Presentation Guide: Milestone M1 (External Vision)

This guide covers the demonstration of the Real-Time ArUco Vision System using the Python Companion Processor architecture.

## Pre-Flight Checklist
1. Ensure the ESP32 is powered on and running the `WifiServerHandler` on TCP Port 8888.
2. Open the Flutter Operator App on a tablet. Ensure it connects to the ESP32.
3. On your laptop, navigate to the `vision_processor/` directory.
4. Install requirements if needed: `pip install opencv-contrib-python numpy`
5. Run the vision script: `python main.py`. Ensure your laptop is on the same network as the ESP32.

## Demonstration Steps
1. **Show Raw Diagnostics**: Open the Developer Tools -> Vision Diagnostics panel on the Flutter app. Show the audience that the Translation and Rotation vectors are currently zero.
2. **Trigger Detection**: Present the physical ArUco marker (ID 1) to the laptop webcam. The Python script will draw a 3D axis on the marker, and the Flutter UI will instantly update showing live `X, Y, Z` tracking.
3. **Alignment Engine**: Show the main Dashboard. Observe the `Alignment Score` metric fluctuate as you move the marker around the webcam.
4. **Safety Halt Demonstration**: Rapidly pull the marker away or close the Python script. Count to 2 seconds. The Localization State will flip to `LOST` and the `NavigationController` will halt all movement commands, demonstrating the real-time safety loop.
