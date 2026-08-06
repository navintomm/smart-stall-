# Localization Engine

The Localization Engine maintains the state machine for robot position awareness.

## States
- `SEARCHING`: Scanning for markers.
- `MARKER_DETECTED`: Initial detection, waiting for pose stability.
- `ALIGNMENT_REQUIRED`: Pose is known, but offsets are too high. Robot must adjust.
- `READY`: Score > 95%. Cleaning can begin.
- `LOST`: Marker vanished.
- `ERROR`: Camera failure.

## Integration with Cleaning
The `CleaningController` requires the Localization Engine to be in the `READY` state before starting. If the marker is lost during cleaning, the motor will halt to prevent collisions, but scrubbing/pumping will continue until localization is regained.
