#ifndef EMERGENCY_CONTROLLER_H
#define EMERGENCY_CONTROLLER_H

class EmergencyController {
public:
    static void init();
    static void triggerEmergencyStop();
    static void reset();
    static bool isEmergency();
    static void tick(); // Hardware polling

private:
    static bool _isEmergency;
};

#endif // EMERGENCY_CONTROLLER_H
