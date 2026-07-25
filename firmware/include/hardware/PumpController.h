#ifndef PUMP_CONTROLLER_H
#define PUMP_CONTROLLER_H

class PumpController {
public:
    static void init();
    static void start(int pumpId);
    static void stop(int pumpId);
    static void setFlowRate(int pumpId, int rate);
    static bool getStatus(int pumpId);
    static void tick(); // For safety timeouts

private:
    static bool _waterPumpState;
    static bool _soapPumpState;
    static unsigned long _waterPumpStartTime;
    static unsigned long _soapPumpStartTime;
};

#endif // PUMP_CONTROLLER_H
