# ArUco Guide

We use **ArUco DICT_4X4_50** for marker generation.

## Marker Specification
- **Size:** 10cm x 10cm physical markers.
- **Dictionary:** 4x4 bits, 50 markers max. This provides robust edge detection with minimal false positives.

## Placement
- **Western Toilet:** Placed on the wall 50cm above the toilet bowl center.
- **Indian Toilet:** Placed on the rear wall, 30cm above the flush tank.
- **Urinal:** Placed directly above the urinal, centered.

Markers must be printed on matte paper to avoid specular highlights which degrade OpenCV detection performance.
