import 'package:iheartbeat/features/home/domain/advanced_bluetooth_service.dart';
import 'package:flutter/foundation.dart';

import '../domain/combined_bluetooth_service.dart'; // Новый объединенный сервис

class BluetoothServiceFactory {
  static AdvancedBluetoothService createService() {
    return CombinedBluetoothService();
  }

  static AdvancedBluetoothService createAuto() {
    return CombinedBluetoothService();
  }
}
