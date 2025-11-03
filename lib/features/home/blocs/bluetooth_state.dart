part of 'bluetooth_bloc.dart';

enum BluetoothStatus {
  initial,
  scanning,
  connecting,
  connected,
  error,
  disconnected,
}

class BluetoothState extends Equatable {
  const BluetoothState({
    this.status = BluetoothStatus.initial,
    this.scannedDevices = const [],
    this.connectedDevice,
    this.errorMessage,
    this.connectedDeviceId,
  });

  final BluetoothStatus status;
  final List<DiscoveredDevice> scannedDevices;
  final DiscoveredDevice? connectedDevice;
  final String? errorMessage;
  final String? connectedDeviceId;

  @override
  List<Object?> get props => [
    status,
    scannedDevices,
    connectedDevice,
    errorMessage,
    connectedDeviceId,
  ];

  BluetoothState copyWith({
    BluetoothStatus? status,
    List<DiscoveredDevice>? scannedDevices,
    DiscoveredDevice? connectedDevice,
    String? errorMessage,
    String? connectedDeviceId,
  }) {
    return BluetoothState(
      status: status ?? this.status,
      scannedDevices: scannedDevices ?? this.scannedDevices,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      errorMessage: errorMessage ?? this.errorMessage,
      connectedDeviceId: connectedDeviceId ?? this.connectedDeviceId,
    );
  }
}
