import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

List<DiscoveredDevice> mockDevicesData = [
    DiscoveredDevice(
      id: 'MiBand6',
      name: 'Mi Band 6',
      connectable: Connectable.available,
      serviceUuids: [
        Uuid.parse('0000180d-0000-1000-8000-00805f9b34fb'),
        Uuid.parse('0000180f-0000-1000-8000-00805f9b34fb'),
      ],
      serviceData: {
        Uuid.parse('0000180d-0000-1000-8000-00805f9b34fb'): Uint8List.fromList([
          0x01,
        ]),
      },
      manufacturerData: Uint8List.fromList([
        0x12,
        0x34,
        0x01,
        0x02,
        0x03,
        0x04,
      ]),
      rssi: -60,
    ),
    DiscoveredDevice(
      id: 'AppleWatch',
      name: 'Apple Watch',
      connectable: Connectable.available,
      serviceUuids: [Uuid.parse('0000180f-0000-1000-8000-00805f9b34fb')],
      serviceData: {
        Uuid.parse('0000180f-0000-1000-8000-00805f9b34fb'): Uint8List.fromList([
          0x02,
        ]),
      },
      manufacturerData: Uint8List.fromList([
        0x56,
        0x78,
        0x05,
        0x06,
        0x07,
        0x08,
      ]),
      rssi: -55,
    ),
    DiscoveredDevice(
      id: 'GalaxyWatch',
      name: 'Samsung Galaxy Watch',
      connectable: Connectable.available,
      serviceUuids: [Uuid.parse('0000180a-0000-1000-8000-00805f9b34fb')],
      serviceData: {
        Uuid.parse('0000180a-0000-1000-8000-00805f9b34fb'): Uint8List.fromList([
          0x03,
        ]),
      },
      manufacturerData: Uint8List.fromList([
        0x43,
        0x21,
        0x09,
        0x0a,
        0x0b,
        0x0c,
      ]),
      rssi: -70,
    ),
    DiscoveredDevice(
      id: 'RedmiWatch3',
      name: 'Redmi Watch 3 Active',
      connectable: Connectable.available,
      serviceUuids: [
        Uuid.parse('0000180d-0000-1000-8000-00805f9b34fb'),
        Uuid.parse('0000180f-0000-1000-8000-00805f9b34fb'),
      ],
      serviceData: {
        Uuid.parse('0000180d-0000-1000-8000-00805f9b34fb'): Uint8List.fromList([
          0x04,
        ]),
      },
      manufacturerData: Uint8List.fromList([
        0x11,
        0x22,
        0x33,
        0x44,
        0x55,
        0x66,
      ]),
      rssi: -65,
    ),
    DiscoveredDevice(
      id: 'XiaomiBand4',
      name: 'Xiaomi SmartBand 4',
      connectable: Connectable.available,
      serviceUuids: [
        Uuid.parse('0000180d-0000-1000-8000-00805f9b34fb'),
        Uuid.parse('0000180f-0000-1000-8000-00805f9b34fb'),
      ],
      serviceData: {
        Uuid.parse('0000180d-0000-1000-8000-00805f9b34fb'): Uint8List.fromList([
          0x05,
        ]),
      },
      manufacturerData: Uint8List.fromList([
        0x99,
        0x88,
        0x77,
        0x66,
        0x55,
        0x44,
      ]),
      rssi: -75,
    ),
  ];