# Marker Registry

The `MarkerRegistry` maps integer IDs detected by ArUco to semantic locations.

## Current Definitions
| ID | Semantic Location | Target Distance |
|----|-------------------|-----------------|
| 1  | Western Toilet    | 0.5m            |
| 2  | Indian Toilet     | 0.5m            |
| 3  | Urinal            | 0.4m            |
| 10 | Docking Station   | 0.0m            |
| 20 | Maintenance Area  | N/A             |

Any marker detected outside of these definitions will be classified as `MARKER_UNKNOWN` and rejected by the pipeline to prevent false localization.
