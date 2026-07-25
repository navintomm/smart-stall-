#ifndef MOTOR_CONTROLLER_H
#define MOTOR_CONTROLLER_H

class MotorController {
public:
    static void init();
    static void moveForward(int speed);
    static void moveBackward(int speed);
    static void turnLeft(int speed);
    static void turnRight(int speed);
    static void stop();
    
    static int getCurrentSpeed();
    static const char* getCurrentDirection();

private:
    static int _currentSpeed;
    static const char* _currentDirection;
    static void writeMotors(int leftPwm, bool leftFwd, int rightPwm, bool rightFwd);
};

#endif // MOTOR_CONTROLLER_H
