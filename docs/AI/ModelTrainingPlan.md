# Model Training Plan

Once the dataset is collected and labeled, the following training pipeline will be executed.

## Workflow

1. **Preprocessing:** Normalize images, resize to the target model input resolution (e.g., 224x224 or 320x320), and apply data augmentation (rotation, brightness, contrast adjustments).
2. **Dataset Split:** Divide the dataset into Training (70%), Validation (15%), and Test (15%) sets.
3. **Model Selection:** Select a lightweight mobile architecture suitable for Android deployment (e.g., MobileNetV2, EfficientNet-Lite, or YOLOv8-nano).
4. **Training:** Train the model to classify `DirtSeverity` or detect specific dirt regions.
5. **Evaluation:** Evaluate using standard metrics (Precision, Recall, F1-Score, Confusion Matrix).
6. **Conversion:** Export the trained model to TensorFlow Lite (`.tflite`) or ONNX format for mobile inference.
7. **Integration:** Replace the `MockDirtDetectionModel` with the actual TFLite/ONNX runner in the Flutter application.

## Closed-Loop Verification (Future)
Future iterations will support closed-loop verification:
- AI scans before cleaning.
- Robot cleans based on recommendation.
- AI scans again after cleaning to verify the surface is clean.
- If dirt remains, trigger an additional targeted cleaning cycle.
