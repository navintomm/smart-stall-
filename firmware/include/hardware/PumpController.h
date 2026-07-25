#ifndef PUMP_CONTROLLER_H
#define PUMP_CONTROLLER_H

class PumpController {
public:
    static void init();
    static void start(int pumpId);
    static void stop(int pumpId);
    static void setFlowRate(int pumpId, int rate);
    static bool getStatus(int pumpId);

private:
    static bool _waterPumpState;
    static bool _soapPumpState;
};

#endif // PUMP_CONTROLLER_H
