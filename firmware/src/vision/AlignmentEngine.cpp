#include "vision/AlignmentEngine.h"

AlignmentData AlignmentEngine::_currentAlignment = {0.0f, 0.0f, 0.0f, 0.0f, 0};

void AlignmentEngine::calculateAlignment(const Pose& currentPose) {
    // Math is handled by external Python Vision Processor
}

void AlignmentEngine::setAlignmentScore(int score) {
    _currentAlignment.alignmentScore = score;
    // In external mode, the Python processor calculates the score,
    // so we don't strictly need to track individual offsets here anymore,
    // but we can set them to 0 or derive them if needed.
}

AlignmentData AlignmentEngine::getAlignment() { return _currentAlignment; }

bool AlignmentEngine::isAligned() { return _currentAlignment.alignmentScore > 90; }
