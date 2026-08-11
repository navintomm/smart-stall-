class MarkerConfig {
  final int id;
  final String label;
  final double physicalSizeMeters;

  const MarkerConfig({
    required this.id,
    required this.label,
    required this.physicalSizeMeters,
  });
}

class MarkerRegistry {
  static const Map<int, MarkerConfig> _registry = {
    1: MarkerConfig(
      id: 1,
      label: 'Toilet Target',
      physicalSizeMeters: 0.150,
    ),
    10: MarkerConfig(
      id: 10,
      label: 'Charging Dock',
      physicalSizeMeters: 0.100,
    ),
    20: MarkerConfig(
      id: 20,
      label: 'Zone A Marker',
      physicalSizeMeters: 0.150,
    ),
    // Add more predefined markers here
  };

  /// Returns the configuration for a given marker ID.
  /// If the marker is not in the registry, returns a default configuration
  /// with an unknown label and a size of 0.0 (indicating size not configured).
  static MarkerConfig getConfig(int id) {
    return _registry[id] ??
        MarkerConfig(
          id: id,
          label: 'Unknown Marker — ID $id',
          physicalSizeMeters: 0.0, // Indicates unknown size
        );
  }

  /// Returns true if the marker ID is registered.
  static bool isRegistered(int id) {
    return _registry.containsKey(id);
  }

  /// Returns a map of all registered marker IDs and their physical sizes in meters.
  static Map<int, double> get knownMarkerSizes {
    return _registry.map((id, config) => MapEntry(id, config.physicalSizeMeters));
  }
}
