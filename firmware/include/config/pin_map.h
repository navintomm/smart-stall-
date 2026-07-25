#ifndef PIN_MAP_H
#define PIN_MAP_H

namespace Pins {
    // Servos
    const int SERVO_BASE = 15;
    const int SERVO_SHOULDER = 2;
    const int SERVO_ELBOW = 4;
    const int SERVO_WRIST = 16;
    const int SERVO_GRIPPER = 17;

    // Pumps (Relays or Mosfets)
    const int PUMP_WATER = 12;
    const int PUMP_SOAP = 13;

    // Brush Motor
    const int MOTOR_BRUSH = 14;

    // Sensors
    const int SENSOR_WATER_LVL = 34; // ADC
    const int SENSOR_SOAP_LVL = 35;  // ADC
    const int SENSOR_BATTERY = 36;   // ADC
    
    // System
    const int EMERGENCY_SWITCH = 32; // Digital In
}

#endif // PIN_MAP_H
