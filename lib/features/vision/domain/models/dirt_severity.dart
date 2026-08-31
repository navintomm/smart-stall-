enum DirtSeverity {
  clean,
  light,
  moderate,
  heavy,
  severe,
}

extension DirtSeverityExtension on DirtSeverity {
  String get displayName {
    switch (this) {
      case DirtSeverity.clean:
        return 'Clean';
      case DirtSeverity.light:
        return 'Light';
      case DirtSeverity.moderate:
        return 'Moderate';
      case DirtSeverity.heavy:
        return 'Heavy';
      case DirtSeverity.severe:
        return 'Severe';
    }
  }
}
