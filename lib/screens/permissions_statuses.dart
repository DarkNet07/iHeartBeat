import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsStatuses extends StatefulWidget {
  const PermissionsStatuses({super.key});

  @override
  _PermissionsStatusesState createState() => _PermissionsStatusesState();
}

class _PermissionsStatusesState extends State<PermissionsStatuses> {
  bool _bluetoothGranted = false;
  bool _locationGranted = false;
  String _statusMessage = 'Проверяем разрешения...';

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    PermissionStatus bluetoothStatus = await Permission.bluetooth.status;
    PermissionStatus bluetoothScanStatus =
        await Permission.bluetoothScan.status;
    PermissionStatus bluetoothConnectStatus =
        await Permission.bluetoothConnect.status;
    PermissionStatus locationStatus = await Permission.location.status;

    debugPrint('Bluetooth: $bluetoothStatus');
    debugPrint('Bluetooth сканирование: $bluetoothScanStatus');
    debugPrint('Bluetooth подключение: $bluetoothConnectStatus');
    debugPrint('Местоположение: $locationStatus');

    if (!bluetoothStatus.isGranted) {
      bluetoothStatus = await Permission.bluetooth.request();
      debugPrint('Запрошено bluetooth: $bluetoothStatus');
    }

    if (!bluetoothScanStatus.isGranted) {
      bluetoothScanStatus = await Permission.bluetoothScan.request();
      debugPrint('Запрос bluetooth сканирование: $bluetoothScanStatus');
    }

    if (!bluetoothConnectStatus.isGranted) {
      bluetoothConnectStatus = await Permission.bluetoothConnect.request();
      debugPrint('Запрос bluetooth подключение: $bluetoothConnectStatus');
    }

    if (!locationStatus.isGranted) {
      locationStatus = await Permission.location.request();
      debugPrint('Запрошено местоположение: $locationStatus');
    }

    setState(() {
      _bluetoothGranted =
          bluetoothStatus.isGranted &&
          bluetoothScanStatus.isGranted &&
          bluetoothConnectStatus.isGranted;
      _locationGranted = locationStatus.isGranted;
      _statusMessage = _buildStatusMessage(
        bluetoothStatus,
        bluetoothScanStatus,
        bluetoothConnectStatus,
        locationStatus,
      );
    });

    if (_bluetoothGranted && _locationGranted) {
      debugPrint('все разрешения доступны.');
    } else if (bluetoothScanStatus.isPermanentlyDenied ||
        bluetoothConnectStatus.isPermanentlyDenied) {
      debugPrint('разрешения отклонены.');
      await openAppSettings();
    }
  }

  String _buildStatusMessage(
    PermissionStatus bt,
    PermissionStatus scan,
    PermissionStatus connect,
    PermissionStatus loc,
  ) {
    return 'Bluetooth: ${bt.isGranted ? "ОК" : "НЕТ"}\nСканирование: ${scan.isGranted ? "ОК" : "НЕТ"}\nПодключение: ${connect.isGranted ? "ОК" : "НЕТ"}\nМестоположение: ${loc.isGranted ? "ОК" : "НЕТ"}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Проверки доступов bluetooth', maxLines: 2)),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Статус: $_statusMessage', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text('Bluetooth разрешен: $_bluetoothGranted'),
            Text('местоположение разрешено: $_locationGranted'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAndRequestPermissions,
              child: Text('Повторить запрос разрешений'),
            ),
            if (!_bluetoothGranted)
              ElevatedButton(
                onPressed: openAppSettings,
                child: Text('Открыть настройки приложения'),
              ),
          ],
        ),
      ),
    );
  }
}
