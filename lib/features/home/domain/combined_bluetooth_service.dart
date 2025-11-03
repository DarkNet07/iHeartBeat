import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:iheartbeat/features/home/data/mock_devices.dart';
import 'package:rxdart/rxdart.dart';
import 'advanced_bluetooth_service.dart';

class CombinedBluetoothService implements AdvancedBluetoothService {
  final BehaviorSubject<int> _heartRateController = BehaviorSubject<int>.seeded(
    0,
  );
  final BehaviorSubject<int> _stepsController = BehaviorSubject<int>.seeded(0);
  final BehaviorSubject<int> _batteryController = BehaviorSubject<int>.seeded(
    0,
  );
  final BehaviorSubject<int> _caloriesController = BehaviorSubject<int>.seeded(
    0,
  );
  final BehaviorSubject<int> _distanceController = BehaviorSubject<int>.seeded(
    0,
  );
  final BehaviorSubject<bool> _connectionStatusController =
      BehaviorSubject<bool>.seeded(false);
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;

  final StreamController<List<DiscoveredDevice>> _scanController =
      StreamController.broadcast();
  final StreamController<SleepData> _sleepDataController =
      StreamController.broadcast();

  String? _connectedDeviceId;
  String? _connectedDeviceName;

  bool _scanning = false;
  bool _connected = false;
  StreamSubscription? _realScanSubscription;
  final Map<String, StreamSubscription<List<int>>>
  _characteristicSubscriptions = {};
  Timer? _mockDataTimer;

  static Uuid heartRateService = Uuid.parse(
    "0000180d-0000-1000-8000-00805f9b34fb",
  );
  static Uuid batteryService = Uuid.parse(
    "0000180f-0000-1000-8000-00805f9b34fb",
  );
  static Uuid deviceInfoService = Uuid.parse(
    "0000180a-0000-1000-8000-00805f9b34fb",
  );
  static Uuid fitnessMachineService = Uuid.parse(
    "00001826-0000-1000-8000-00805f9b34fb",
  );

  static Uuid heartRateMeasurement = Uuid.parse(
    "00002a37-0000-1000-8000-00805f9b34fb",
  );
  static Uuid batteryLevel = Uuid.parse("00002a19-0000-1000-8000-00805f9b34fb");
  static Uuid stepsCharacteristic = Uuid.parse(
    "00002a53-0000-1000-8000-00805f9b34fb",
  );
  static Uuid caloriesCharacteristic = Uuid.parse(
    "00002a5e-0000-1000-8000-00805f9b34fb",
  );
  static Uuid distanceCharacteristic = Uuid.parse(
    "00002a57-0000-1000-8000-00805f9b34fb",
  );

  static Uuid xiaomiService = Uuid.parse(
    "0000fe95-0000-1000-8000-00805f9b34fb",
  );
  static Uuid xiaomiDataCharacteristic = Uuid.parse(
    "00000001-0000-1000-8000-00805f9b34fb",
  );

  static final List<DiscoveredDevice> mockDevices = mockDevicesData;

  final FlutterReactiveBle _ble = FlutterReactiveBle();
  final List<DiscoveredDevice> _realDevices = [];

  @override
  Stream<List<DiscoveredDevice>> scanResultsStream() => _scanController.stream;

  @override
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  @override
  Future<void> startScan() async {
    await stopScan();
    _scanning = true;
    _realDevices.clear();

    _scanController.add([...mockDevices]);

    _realScanSubscription = _ble
        .scanForDevices(withServices: [])
        .listen(
          (device) {
            if (_scanning) {
              if (!_realDevices.any((d) => d.id == device.id) &&
                  !mockDevices.any((d) => d.id == device.id)) {
                _realDevices.add(device);
                _realDevices.sort((a, b) {
                  final aIsAvailable = a.connectable.name == 'available';
                  final bIsAvailable = b.connectable.name == 'available';

                  if (aIsAvailable && !bIsAvailable) return -1;
                  if (!aIsAvailable && bIsAvailable) return 1;
                  return 0;
                });
                if (device.connectable.name == 'available') {
                  if (device.name.isNotEmpty) {
                    log('Real device found: ${device.name}');
                  }
                }
                _scanController.add([...mockDevices, ..._realDevices]);
              }
            }
          },
          onError: (error) {
            log('Scan error: $error');
          },
        );
  }

  @override
  Future<void> stopScan() async {
    _scanning = false;
    await _realScanSubscription?.cancel();
    _realScanSubscription = null;
  }

  @override
  Future<void> connect(String deviceId) async {
    if (_connected && _connectedDeviceId == deviceId) {
      log('Already connected to device: $deviceId');
      return;
    }

    if (_connected && _connectedDeviceId != deviceId) {
      log('Disconnecting from current device before new connection');
      await disconnect();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _connected = false;
    final isMockDevice = mockDevices.any((device) => device.id == deviceId);

    if (isMockDevice) {
      _connected = true;
      _connectedDeviceId = deviceId;
      final mockDevice = mockDevices.firstWhere(
        (device) => device.id == deviceId,
      );
      _connectedDeviceName = mockDevice.name;

      _connectionStatusController.add(true);
      _startMockData();
    } else {
      await _connectToRealDevice(deviceId);
    }
  }

  void _startMockData() {
    _mockDataTimer?.cancel();
    int tick = 0;
    _mockDataTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_connected) {
        timer.cancel();
        return;
      }

      tick++;
      final heartRate = 60 + (tick % 40);
      final steps = tick * 3;
      final battery = 100 - (tick % 100);
      final calories = tick * 2;
      final distance = tick * 10;

      _heartRateController.add(heartRate);
      _stepsController.add(steps);
      _batteryController.add(battery);
      _caloriesController.add(calories);
      _distanceController.add(distance);

      log('Mock Data - HR: $heartRate, Steps: $steps, Battery: $battery%');
    });
  }

  Future<void> _connectToRealDevice(String deviceId) async {
    try {
      log('Connecting to device: $deviceId');
      await _cleanupConnection();
      await Future.delayed(const Duration(milliseconds: 500));

      _connectionSubscription = _ble
          .connectToDevice(
            id: deviceId,
            connectionTimeout: const Duration(seconds: 15),
          )
          .listen(
            (connectionState) async {
              log('Connection state: ${connectionState.connectionState}');
              if (connectionState.connectionState ==
                  DeviceConnectionState.connected) {
                _connected = true;
                _connectedDeviceId = deviceId;
                _connectionStatusController.add(true);
                log('Successfully connected to device: $deviceId');
                await _discoverServicesAndSubscribe(deviceId);
              } else if (connectionState.connectionState ==
                  DeviceConnectionState.disconnected) {
                log('Device disconnected');
                _connectionStatusController.add(false);
                await _cleanupConnection();
              } else if (connectionState.connectionState ==
                  DeviceConnectionState.connecting) {
                log('Device connecting...');
              }
            },
            onError: (error) {
              log('Connection error: $error');
              _connectionStatusController.add(false);
              _cleanupConnection();
            },
            cancelOnError: true,
          );
    } catch (e) {
      log('Failed to connect: $e');
      _connectionStatusController.add(false);
      await _cleanupConnection();
      throw Exception('Connection failed: $e');
    }
  }

  Future<void> _subscribeToCharacteristic(
    String deviceId,
    Uuid serviceUuid,
    Uuid characteristicUuid,
  ) async {
    try {
      final characteristic = QualifiedCharacteristic(
        serviceId: serviceUuid,
        characteristicId: characteristicUuid,
        deviceId: deviceId,
      );

      final subscription = _ble
          .subscribeToCharacteristic(characteristic)
          .listen(
            (data) {
              _processCharacteristicData(serviceUuid, characteristicUuid, data);
            },
            onError: (error) {
              log(
                'Characteristic subscription error for $characteristicUuid: $error',
              );
            },
            cancelOnError: true,
          );

      _characteristicSubscriptions['$serviceUuid-$characteristicUuid'] =
          subscription;
      log('Successfully subscribed to characteristic: $characteristicUuid');
    } catch (e) {
      log('Failed to subscribe to characteristic $characteristicUuid: $e');
    }
  }

  void _processCharacteristicData(
    Uuid serviceUuid,
    Uuid characteristicUuid,
    List<int> data,
  ) {
    if (data.isEmpty) return;

    try {
      log(
        'Data received from $characteristicUuid: ${data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':')}',
      );

      if (serviceUuid == heartRateService &&
          characteristicUuid == heartRateMeasurement) {
        final heartRate = _parseHeartRateMeasurement(data);
        _heartRateController.add(heartRate);
        log('Heart rate: $heartRate bpm');
      }
      else if (serviceUuid == batteryService &&
          characteristicUuid == batteryLevel) {
        final batteryLevel = data[0];
        _batteryController.add(batteryLevel);
        log('Battery level: $batteryLevel%');
      }
      else if (serviceUuid == xiaomiService) {
        _parseXiaomiData(data);
      }
      else {
        _parseGenericHealthData(serviceUuid, characteristicUuid, data);
      }
    } catch (e) {
      log('Error processing characteristic data: $e');
    }
  }

  void _parseXiaomiData(List<int> data) {
    try {
      log(
        'Xiaomi data: ${data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':')}',
      );

      _parseXiaomiStandardFormat(data);
      _parseXiaomiCustomFormat(data);
    } catch (e) {
      log('Error parsing Xiaomi data: $e');
    }
  }

  void _parseXiaomiStandardFormat(List<int> data) {
    if (data.length < 5) return;

    try {
      int frameControl = (data[1] << 8) | data[0];

      if ((frameControl & 0x1000) != 0 && data.length >= 10) {
        int batteryLevel = data[9] & 0x7F;
        if (batteryLevel <= 100) {
          _batteryController.add(batteryLevel);
          log('Xiaomi Battery: $batteryLevel%');
        }
      }

      if ((frameControl & 0x2000) != 0 && data.length >= 7) {
        int steps = (data[6] << 8) | data[5];
        _stepsController.add(steps);
        log('Xiaomi Steps: $steps');
      }

      if ((frameControl & 0x4000) != 0 && data.length >= 10) {
        int heartRate = data[10];
        if (heartRate >= 40 && heartRate <= 240) {
          _heartRateController.add(heartRate);
          log('Xiaomi Heart Rate: $heartRate bpm');
        }
      }
    } catch (e) {
      log('Error in Xiaomi standard format parsing: $e');
    }
  }

  void _parseXiaomiCustomFormat(List<int> data) {
    try {
      for (int i = 0; i < data.length - 1; i++) {
        int value = data[i];
        if (value >= 40 && value <= 240) {
          if (i == 0 || data[i - 1] == 0x06 || data[i - 1] == 0x16) {
            _heartRateController.add(value);
            log('Xiaomi HR (custom): $value bpm');
            break;
          }
        }
      }

      for (int i = 0; i < data.length; i++) {
        int value = data[i];
        if (value <= 100 && value > 0) {
          if (i > 0 && (data[i - 1] == 0x0A || data[i - 1] == 0x1A)) {
            _batteryController.add(value);
            log('Xiaomi Battery (custom): $value%');
            break;
          }
        }
      }
    } catch (e) {
      log('Error in Xiaomi custom format parsing: $e');
    }
  }

  void _parseGenericHealthData(
    Uuid serviceUuid,
    Uuid characteristicUuid,
    List<int> data,
  ) {
    try {
      if (data.length == 1) {
        int value = data[0];
        if (value >= 40 && value <= 240) {
          _heartRateController.add(value);
          log('Generic Heart Rate: $value bpm');
          return;
        }
      }

      if (data.length == 1) {
        int value = data[0];
        if (value <= 100) {
          _batteryController.add(value);
          log('Generic Battery: $value%');
          return;
        }
      }

      if (data.length >= 2 && data.length <= 4) {
        int steps = 0;
        for (int i = 0; i < data.length; i++) {
          steps |= (data[i] << (8 * i));
        }
        if (steps <= 50000) {
          _stepsController.add(steps);
          log('Generic Steps: $steps');
        }
      }
    } catch (e) {
      log('Error parsing generic health data: $e');
    }
  }

  int _parseHeartRateMeasurement(List<int> data) {
    try {
      if (data.isEmpty) return 0;

      int offset = 0;
      int flags = data[offset++];
      bool is16Bit = (flags & 0x01) != 0;

      if (is16Bit && data.length >= offset + 2) {
        return (data[offset] | (data[offset + 1] << 8)) & 0xFFFF;
      } else if (data.length >= offset + 1) {
        return data[offset] & 0xFF;
      }

      return 0;
    } catch (e) {
      log('Error parsing heart rate: $e');
      return 0;
    }
  }

  Future<void> _discoverServicesAndSubscribe(String deviceId) async {
    try {
      final services = await _ble.getDiscoveredServices(deviceId);
      await _subscribeToSelectedCharacteristics(deviceId, services);
    } catch (e) {
      log('Service discovery error: $e');
    }
  }

  Future<void> _subscribeToSelectedCharacteristics(
    String deviceId,
    List<Service> services,
  ) async {
    int successfulSubscriptions = 0;

    for (final service in services) {
      for (final characteristic in service.characteristics) {
        try {
          if (characteristic.isNotifiable || characteristic.isIndicatable) {
            if (_isHealthCharacteristic(service.id, characteristic.id)) {
              await _subscribeToCharacteristic(
                deviceId,
                service.id,
                characteristic.id,
              );
              successfulSubscriptions++;
            }
          }
        } catch (e) {
          log('Failed to process characteristic ${characteristic.id}: $e');
        }
      }
    }

    log('Successfully subscribed to $successfulSubscriptions characteristics');
  }

  bool _isHealthCharacteristic(Uuid serviceUuid, Uuid characteristicUuid) {
    if (serviceUuid == batteryService && characteristicUuid == batteryLevel) {
      return true;
    }
    if (serviceUuid == heartRateService &&
        characteristicUuid == heartRateMeasurement) {
      return true;
    }
    if (serviceUuid == xiaomiService) {
      return true;
    }
    if (serviceUuid == fitnessMachineService) {
      return characteristicUuid == stepsCharacteristic ||
          characteristicUuid == caloriesCharacteristic ||
          characteristicUuid == distanceCharacteristic;
    }

    return false;
  }

  Future<void> _cleanupConnection() async {
    _connected = false;
    _connectedDeviceId = null;
    _connectedDeviceName = null;

    log('Starting connection cleanup...');

    _mockDataTimer?.cancel();
    _mockDataTimer = null;

    for (var entry in _characteristicSubscriptions.entries) {
      try {
        await entry.value.cancel();
        log('Canceled subscription: ${entry.key}');
      } catch (e) {
        log('Error canceling characteristic subscription: $e');
      }
    }
    _characteristicSubscriptions.clear();

    try {
      await _connectionSubscription?.cancel();
      _connectionSubscription = null;
    } catch (e) {
      log('Error canceling connection subscription: $e');
    }

    if (_heartRateController.hasListener) {
      _heartRateController.add(0);
    }
    if (_stepsController.hasListener) {
      _stepsController.add(0);
    }
    if (_batteryController.hasListener) {
      _batteryController.add(0);
    }
    if (_caloriesController.hasListener) {
      _caloriesController.add(0);
    }
    if (_distanceController.hasListener) {
      _distanceController.add(0);
    }

    log('Connection cleanup completed');
  }

  @override
  Stream<int> get heartRateStream => _heartRateController.stream;

  @override
  Stream<int> get stepsStream => _stepsController.stream;

  @override
  Stream<int> get batteryStream => _batteryController.stream;

  @override
  Stream<int> get caloriesStream => _caloriesController.stream;

  @override
  Stream<int> get distanceStream => _distanceController.stream;

  @override
  Stream<SleepData> get sleepDataStream => _sleepDataController.stream;

  @override
  String? get connectedDeviceName => _connectedDeviceName;

  @override
  String? get connectedDeviceId => _connectedDeviceId;

  @override
  Future<void> disconnect() async {
    log('Disconnecting from device');
    _connectionStatusController.add(false);
    await _cleanupConnection();
  }

  @override
  void dispose() {
    _cleanupConnection();
    _realScanSubscription?.cancel();
    _scanController.close();
    _connectionStatusController.close();
    _heartRateController.close();
    _stepsController.close();
    _batteryController.close();
    _caloriesController.close();
    _distanceController.close();
    _sleepDataController.close();
  }
}
