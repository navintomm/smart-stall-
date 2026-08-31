# Dataset Plan

To transition from the Mock AI to a real, functional Dirt Detection model, a comprehensive dataset must be collected.

## Data Collection Strategy
1. **Representative Images:** Capture images of toilet surfaces (porcelain, tile, stainless steel) under various lighting conditions (fluorescent, natural, low light).
2. **Camera Consistency:** Use the exact same Android phone camera and resolution that will be used in production to avoid domain shift.
3. **Data Logging:** Utilize the SmartStall application's future data collection pipeline to save frames, along with ArUco alignment data, to ensure images match the robot's actual viewing angle.

## Labeling
- Images must be manually annotated to label dirt regions.
- Annotations should include bounding boxes (for object detection) or polygons (for semantic segmentation).
- Each image must be assigned a global `DirtSeverity` label for the entire surface to train the severity estimation.

## Privacy and Security
- Do not collect images containing personally identifiable information (PII).
- Implement strict access controls for the collected dataset.
