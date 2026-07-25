#ifndef BRUSH_CONTROLLER_H
#define BRUSH_CONTROLLER_H

class BrushController {
public:
    static void init();
    static void start();
    static void stop();
    static void setSpeed(int speed);
    static bool getStatus();

private:
    static bool _isRunning;
    static int _speed;
};

#endif // BRUSH_CONTROLLER_H
