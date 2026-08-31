# Dirt Detection

The Dirt Detection module aims to visually assess the contamination level of the target surface.

## Current State (Phase 21)
Currently, dirt detection is implemented via `MockDirtDetectionModel`. This model generates deterministic or randomized plausible results (severity, confidence, affected area) to test the application's data flow, UI, and decision engine. 

**This is not real AI.**

## Future State
A future phase will replace the mock model with a trained neural network capable of semantic segmentation or object detection to accurately identify dirt on porcelain or tile surfaces.

## Severity Levels
- **Clean:** No visible dirt.
- **Light:** Minor spotting.
- **Moderate:** Visible contamination requiring standard cleaning.
- **Heavy:** Significant contamination.
- **Severe:** Extreme contamination requiring maximum safe dosage.
