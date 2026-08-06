#ifndef CAMERA_MANAGER_H
#define CAMERA_MANAGER_H

#include <Arduino.h>

class CameraManager {
public:
    static void init();
    static void tick();
    static bool acquireFrame();
    static int getFPS();
    static bool isHealthy();
    static unsigned long getLastFrameTimestamp();

private:
    static bool _healthy;
    static int _fps;
    static unsigned long _lastFrameTime;
    static int _frameCount;
    static unsigned long _fpsCalculateTime;
};

#endif
