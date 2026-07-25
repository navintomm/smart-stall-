#ifndef BRUSH_CONTROLLER_H
#define BRUSH_CONTROLLER_H

class BrushController {
public:
    static void init();
    static void start();
    static void stop();
    static void setSpeed(int speed);
    static bool getStatus();
    static void tick(); // For safety timeouts

private:
    static bool _isRunning;
    static int _speed;
    static unsigned long _startTime;
};

#endif // BRUSH_CONTROLLER_H
