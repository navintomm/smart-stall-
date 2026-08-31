# Phase 21: AI-Based Dirt Detection & Adaptive Water Dosing

## Changes Made
1. **Core Models & Enums:** Created `DirtSeverity`, `DirtDetectionResult`, and `CleaningProfile` to standardize AI vision output and cleaning parameter encapsulation.
2. **AI Service Layer:** Introduced an abstract `DirtDetectionModel` and a temporary `MockDirtDetectionModel` (clearly labeled for DEVELOPMENT). `DirtDetectionService` now intercepts frames from the existing camera pipeline without disrupting ArUco alignment.
3. **Cleaning Decision Layer:** Created `CleaningDecisionService` to map AI severity output to practical cleaning profiles and configurable water dosage parameters.
4. **Robot Repository:** Extended the `RobotRepository`, `HardwareRobotRepository`, and `MockRobotRepository` to support `startCleaningWithProfile` while maintaining backward compatibility with the original `startCleaning()`.
5. **UI Integration:** 
   - Replaced "START CLEANING" on the Home Screen with "ANALYZE DIRT". 
   - Added a scanning dialog that processes the frame.
   - Added the `CleaningDecisionSummaryWidget` to require operator confirmation before starting the pump.
   - Added `AiDiagnosticsCard` to the Developer Center to monitor AI inference metrics.
6. **Documentation:** Created comprehensive documentation in `docs/AI/` mapping the architecture, dosing calibration strategy, dataset planning, and model training workflow for future phases.

## What Was Tested
- Simulated dirt detection flow in development mode.
- Verification of deterministic simulation values.
- AI state management in `HomeScreen`.
- Fallbacks for AI unavailability.

## Validation Results
- [x] AI analysis runs independently of ArUco without freezing the camera stream.
- [x] Operator confirmation is strictly enforced before cleaning begins.
- [x] Existing safety architecture (Emergency Stop, connection state) remains authoritative.

---

# Presentation Demonstration Flow

To demonstrate the AI integration, follow this clean flow:

1. **Initialization:** Open the SmartStall Operator app. The live camera activates automatically.
2. **Alignment:** Place the ArUco marker in the camera view. The system calculates distance and alignment score.
3. **Trigger AI:** Once alignment reaches the required threshold (>95%), the primary action button becomes active as **ANALYZE DIRT**. Click it.
4. **Scanning:** A scanning indicator appears while the AI processes the frame.
5. **Decision Engine:** The AI identifies the dirt severity (e.g., *Moderate*) and calculates the required water (e.g., *300 mL*) and pump duration.
6. **Confirmation:** The **AI Cleaning Analysis** dialog appears, explaining *why* a specific profile was selected.
7. **Execution:** The Operator clicks **CONFIRM & START CLEANING**. The robot executes the safe, deterministic cleaning routine using the calculated profile.
