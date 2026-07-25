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

private:
    static Servo _base;
    static Servo _shoulder;
    static Servo _elbow;
    static Servo _wrist;
    static Servo _gripper;
    
    static int _angles[5]; // 0:Base, 1:Shoulder, 2:Elbow, 3:Wrist, 4:Gripper
};

#endif // SERVO_CONTROLLER_H
