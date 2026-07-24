import 'package:flutter/material.dart';

class ConnectionMethod {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String status;

  const ConnectionMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.status,
  });

  static List<ConnectionMethod> get placeholders => [
    const ConnectionMethod(id: 'cm1', name: 'Wi-Fi', description: 'Local Network Link', icon: Icons.wifi, status: 'Connected'),
    const ConnectionMethod(id: 'cm2', name: 'Bluetooth', description: 'Direct BLE Link', icon: Icons.bluetooth, status: 'Available'),
    const ConnectionMethod(id: 'cm3', name: 'USB', description: 'Serial Debug Link', icon: Icons.usb, status: 'Disconnected'),
    const ConnectionMethod(id: 'cm4', name: 'Ethernet', description: 'Hardwired Dock Link', icon: Icons.settings_ethernet, status: 'Disconnected'),
  ];
}
