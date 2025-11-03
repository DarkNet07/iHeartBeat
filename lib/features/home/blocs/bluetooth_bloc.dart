import 'dart:async';
import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:iheartbeat/features/home/domain/advanced_bluetooth_service.dart';
import 'package:permission_handler/permission_handler.dart';

part 'bluetooth_state.dart';

class BluetoothCubit extends Cubit<BluetoothState> {
  final AdvancedBluetoothService _bluetoothService;
  StreamSubscription<List<DiscoveredDevice>>? _scanSubscription;
  StreamSubscription<bool>? _connectionStatusSubscription;

  Stream<int> get heartRateStream => _bluetoothService.heartRateStream;
  Stream<int> get stepsStream => _bluetoothService.stepsStream;
  Stream<int> get batteryStream => _bluetoothService.batteryStream;
  Stream<int> get caloriesStream => _bluetoothService.caloriesStream;
  Stream<int> get distanceStream => _bluetoothService.distanceStream;
  Stream<SleepData> get sleepDataStream => _bluetoothService.sleepDataStream;

  BluetoothCubit(this._bluetoothService) : super(BluetoothState()) {
    _connectionStatusSubscription = _bluetoothService.connectionStatusStream
        .listen(
          (isConnected) {
            log('Connection status changed: $isConnected');
            if (isConnected) {
              _stopScanningOnly();
              emit(state.copyWith(status: BluetoothStatus.connected));
            } else {
              emit(
                state.copyWith(
                  status: BluetoothStatus.disconnected,
                  connectedDevice: null,
                  connectedDeviceId: null,
                ),
              );
            }
          },
          onError: (error) {
            log('Connection status stream error: $error');
            emit(
              state.copyWith(
                status: BluetoothStatus.error,
                errorMessage: 'Connection error: $error',
              ),
            );
          },
        );
  }

  Future<bool> requestPermissions() async {
    var statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    return statuses.values.every((status) => status.isGranted);
  }

  void startScan() async {
    if (state.status == BluetoothStatus.connected) {
      log('Already connected to device, ignoring scan request');
      return;
    }

    final permissionsGranted = await requestPermissions();
    if (!permissionsGranted) {
      emit(
        state.copyWith(
          status: BluetoothStatus.error,
          errorMessage: 'Необходимы разрешения для сканирования устройств',
        ),
      );
      return;
    }

    await _stopScanningOnly();

    emit(
      state.copyWith(
        status: BluetoothStatus.scanning,
        scannedDevices: [],
        errorMessage: null,
      ),
    );

    try {
      await _bluetoothService.startScan();
      _scanSubscription = _bluetoothService.scanResultsStream().listen(
        (devices) {
          if (state.status == BluetoothStatus.scanning) {
            emit(state.copyWith(scannedDevices: devices));
          }
        },
        onError: (error) {
          emit(
            state.copyWith(
              status: BluetoothStatus.error,
              errorMessage: 'Ошибка сканирования: $error',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BluetoothStatus.error,
          errorMessage: 'Ошибка запуска сканирования: $e',
        ),
      );
    }
  }

  void connectToDevice(String deviceId) async {
    try {
      final device = state.scannedDevices.firstWhere((d) => d.id == deviceId);

      debugPrint('Connecting to device: ${device.name}');

      await _stopScanningOnly();

      await _bluetoothService.connect(deviceId);
      emit(
        state.copyWith(
          status: BluetoothStatus.connecting,
          connectedDevice: device,
          connectedDeviceId: deviceId,
          errorMessage: null,
        ),
      );
    } catch (e) {
      debugPrint('Connection error: ${e.toString()}');
      emit(
        state.copyWith(
          status: BluetoothStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void disconnect() async {
    try {
      await _bluetoothService.disconnect();
    } catch (e) {
      emit(
        state.copyWith(
          status: BluetoothStatus.error,
          errorMessage: 'Ошибка отключения: $e',
        ),
      );
    }
  }

  Future<void> _stopScanningOnly() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    try {
      await _bluetoothService.stopScan();
    } catch (e) {
      log('Error stopping scan: $e');
    }
  }

  void stopScan() async {
    await _stopScanningOnly();
    if (state.status == BluetoothStatus.scanning) {
      emit(state.copyWith(status: BluetoothStatus.initial));
    }
  }

  void cancelScan() async {
    await _bluetoothService.disconnect();
    if (state.status == BluetoothStatus.connecting) {
      emit(
        state.copyWith(
          status: BluetoothStatus.initial,
          connectedDevice: null,
          connectedDeviceId: null,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    _bluetoothService.stopScan();
    _bluetoothService.disconnect();
    return super.close();
  }
}
