import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

abstract class AdvancedBluetoothService {
  Stream<List<DiscoveredDevice>> scanResultsStream();
  Future<void> startScan();
  Future<void> stopScan();
  Future<void> connect(String deviceId);
  Future<void> disconnect();
  void dispose();

  Stream<int> get heartRateStream;
  Stream<int> get stepsStream;
  Stream<int> get batteryStream;
  Stream<int> get caloriesStream;
  Stream<int> get distanceStream;
  Stream<SleepData> get sleepDataStream;
  Stream<bool> get connectionStatusStream;

  String? get connectedDeviceName;
  String? get connectedDeviceId;
}

class SleepData {
  final SleepStage stage;
  final DateTime timestamp;
  final int durationMinutes;

  SleepData({
    required this.stage,
    required this.timestamp,
    required this.durationMinutes,
  });
}

enum SleepStage { awake, light, deep, rem }
