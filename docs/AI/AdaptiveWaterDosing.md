# Adaptive Water Dosing

The SmartStall system supports adaptive water dosing, adjusting the water output based on the AI's estimation of dirt severity.

## Dosing Calibration
Currently, dosing values (e.g., 350 mL, 70 mL/s, 5 seconds) are **configurable development values** and are not yet physically validated.

Future iterations must involve physical calibration:
1. Measure the exact flow rate of the installed water pump (mL per second).
2. Experimentally determine the minimum water volume required to clear specific severity levels.
3. Update the `CleaningDecisionService` configuration to use these experimentally validated constants.

## Safety Limits
The dosing system is constrained by hardware-level safety checks:
- **Maximum pump runtime:** Limits how long the pump can run, regardless of AI request.
- **Low water cutoff:** Prevents the pump from running if the tank is empty.
