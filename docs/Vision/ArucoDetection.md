# ArUco Detection

## Pipeline
The ESP32 processes frames directly from the camera buffer using OpenCV's `aruco` module.

1. **Grayscale Conversion**: The frame is converted to grayscale to improve contrast.
2. **Thresholding**: Adaptive thresholding creates a binary image.
3. **Contour Extraction**: OpenCV finds square contours in the image.
4. **Dictionary Matching**: The interior of the square is sampled and matched against `DICT_4X4_50`.

## C++ Implementation
The `ArucoDetector` encapsulates `cv::aruco::detectMarkers()`. It returns a list of detected corners and IDs. For the presentation mock, it generates synthetic corner points simulating a perfect marker detection.
