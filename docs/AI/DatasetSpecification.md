# Dataset Specification

## 1. AI Objective
The objective is to train a machine-learning model capable of analyzing a camera frame of a toilet surface, identifying the presence of contamination, estimating its severity (Clean, Light, Moderate, Heavy, Severe), and determining the approximate affected area to inform an adaptive robotic water-dosing cleaning cycle.

## 2. Selected ML Task: Object Detection
**Recommendation:** Object Detection (Bounding Boxes).
**Why:** While Image Classification is simpler, it only outputs a single label per image and struggles to provide a defensible "Approximate Affected Area". Image Segmentation provides exact pixel-level area but is excessively tedious to label and computationally heavy for mobile devices. Object Detection (e.g., using a lightweight architecture like YOLOv8-nano or MobileNet SSD) offers the best balance:
- **Area Calculation:** The total affected area can be mathematically estimated by summing the area of the predicted bounding boxes relative to the frame.
- **Severity Derivation:** Severity can be objectively calculated based on the count and total area of the detected bounding boxes, removing subjective human bias from the "Severity" definition during labeling.
- **Performance:** Extremely fast inference on Android devices.

## 3. Required Classes (Labeling)
Instead of subjectively labeling entire images as "SEVERE" or "MODERATE", annotators will draw bounding boxes around visible contamination.

**Label:** `dirt` (or specific types like `spot`, `streak`, `stain` if needed, but a single `dirt` class is recommended for Phase 1).

**Derived Severity (Post-Processing Rule):**
- **CLEAN:** 0 detections.
- **LIGHT:** Total bounding box area < 5% of the target zone.
- **MODERATE:** Total bounding box area 5% - 15%.
- **HEAVY:** Total bounding box area 15% - 30%.
- **SEVERE:** Total bounding box area > 30% OR a single massive bounding box.

## 4. Image Capture Requirements
- **Camera:** MUST use the exact Android smartphone model (e.g., Samsung Galaxy S22) mounted on the robot.
- **Resolution:** Native resolution or standardized scaled resolution matching the ArUco pipeline (e.g., 640x480 or 1280x720).
- **Format:** JPEG.
- **Lighting Variations:** 
  - Bright overhead fluorescent light.
  - Dim/low light.
  - Shadows cast by the robot itself.
  - Reflections from wet porcelain/stainless steel.
- **Angles and Distances:** 
  - Images should be captured at the working distance of the robot (e.g., 20 cm - 60 cm).
  - Include variations in pitch and yaw mimicking slight alignment imperfections.
- **Surface Variations:**
  - White porcelain.
  - Stainless steel (if applicable).
  - Dry and wet surfaces.

## 5. Dataset Size Target
**Initial Phase Target:** 1,000 - 2,000 annotated images.
- **CLEAN:** ~300 images (Empty backgrounds are crucial to reduce false positives).
- **DIRTY:** ~1,200 images (Spread across varying degrees of actual dirt/stains).

## 6. Train / Validation / Test Strategy
- **Training Set (70%):** Used to train the model weights.
- **Validation Set (15%):** Used during training to tune hyperparameters and prevent overfitting.
- **Test Set (15%):** A strictly held-out set of images from completely different physical locations/stalls than the training set to prove real-world generalization. 
*CRITICAL:* Ensure images from the exact same physical scene/stain taken milliseconds apart do not leak across these splits.

## 7. Data Augmentation
To increase model robustness without collecting tens of thousands of images, the following augmentations will be applied during training:
- **Random Brightness & Contrast:** To simulate varying restroom lighting.
- **Gaussian Blur & Noise:** To simulate camera motion blur and sensor noise.
- **Random Crop & Resize:** To simulate varying distances.
- **Horizontal/Vertical Flip:** To increase spatial diversity.
- **Perspective Transform:** To simulate slight alignment variations.

## 8. Evaluation Metrics
- **mAP (Mean Average Precision):** The standard metric for object detection to measure bounding box accuracy.
- **Confusion Matrix:** Evaluated on the *derived* severity classes (Clean, Light, Mod, Heavy, Severe) to ensure the business logic translates bounding boxes into correct categories.
- **Inference Time (Latency):** Measured in milliseconds (ms) on the target Android device. Target: < 100ms.
- **Model Size:** Target: < 15 MB to ensure fast loading and minimal RAM footprint.

## 9. Mobile Deployment Requirements
- **Format:** TensorFlow Lite (`.tflite`) or ONNX.
- **Quantization:** INT8 or FP16 quantization to reduce model size and increase inference speed with negligible accuracy loss.
- **Integration:** The `.tflite` model will be bundled into the Flutter assets and executed via the `tflite_flutter` plugin, replacing the `MockDirtDetectionModel`.
