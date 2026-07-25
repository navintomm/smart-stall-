#ifndef SERVO_CONTROLLER_H
#define SERVO_CONTROLLER_H

#include <ESP32Servo.h>

class ServoController {
public:
    static void init();
    static void setAngle(int servoId, int angle);
    static int getAngle(int servoId);
    static void home();
    static void stop();
    static void tick(); // For smooth interpolation

private:
    static Servo _base;
    static Servo _shoulder;
    static Servo _elbow;
    static Servo _wrist;
    static Servo _gripper;
    
    static int _angles[5]; // Current angles
    static int _targetAngles[5]; // Target angles
    static unsigned long _lastTickTime;
};

#endif // SERVO_CONTROLLER_H
