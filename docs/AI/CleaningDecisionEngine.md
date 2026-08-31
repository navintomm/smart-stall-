# Cleaning Decision Engine

The Cleaning Decision Engine (`CleaningDecisionService`) acts as a bridge between abstract AI results (e.g., "Heavy Dirt") and deterministic hardware commands (e.g., "Run pump for 15 seconds").

## Logic
The engine takes a `DirtDetectionResult` and generates a `CleaningProfile`.

1. **Mapping Severity to Action:**
   - Clean -> Quick Rinse (50 mL)
   - Light -> Light Clean (150 mL)
   - Moderate -> Standard Clean (300 mL)
   - Heavy -> Heavy Clean (500 mL)
   - Severe -> Intensive Clean (800 mL)

2. **Dosing Calculation:**
   The required water volume is converted to a pump duration using a configurable flow rate (e.g., 70 mL/s).

## Safety Restraints
The Decision Engine does NOT bypass the ESP32 safety systems. If the requested water volume exceeds the tank capacity, or if the pump duration exceeds the safety timeout, the ESP32 firmware will automatically clamp the values or abort the operation.
