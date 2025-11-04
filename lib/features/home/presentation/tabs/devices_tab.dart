import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iheartbeat/features/home/blocs/bluetooth_bloc.dart';

class DevicesTab extends StatelessWidget {
  const DevicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothCubit, BluetoothState>(
      builder: (context, state) {
        return Scaffold(
          body: _buildBody(context, state),
          floatingActionButton: state.connectedDevice == null
              ? _buildFloatingActionButton(context, state)
              : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, BluetoothState state) {
    final cubit = context.read<BluetoothCubit>();
    if (state.status == BluetoothStatus.scanning &&
        state.scannedDevices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Идет поиск устройств...'),
          ],
        ),
      );
    }

    if (state.status == BluetoothStatus.error && state.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<BluetoothCubit>().startScan(),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.status == BluetoothStatus.connecting) {
      final device = state.connectedDevice!;
      final deviceName = device.name.isEmpty
          ? 'Неизвестное устройство'
          : device.name;
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Подключение к устройству...'),
              const SizedBox(height: 16),
              if (state.connectedDevice != null)
                Text(
                  'Устройство: $deviceName',
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<BluetoothCubit>().disconnect(),
                child: const Text('Сбросить статус'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.status == BluetoothStatus.connected &&
        state.connectedDevice != null) {
      final device = state.connectedDevice!;
      final deviceName = device.name.isEmpty
          ? 'Неизвестное устройство'
          : device.name;
      return Padding(
        padding: EdgeInsetsGeometry.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.bluetooth_connected,
                color: Colors.blue,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text('Подключено к:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                deviceName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.read<BluetoothCubit>().disconnect(),
                child: const Text('Отключиться'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.status == BluetoothStatus.disconnected &&
        state.scannedDevices.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.bluetooth_disabled,
                color: Colors.orange,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Соединение разорвано',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.read<BluetoothCubit>().startScan(),
                child: const Text('Поиск устройств'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.status == BluetoothStatus.initial &&
        state.scannedDevices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bluetooth, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Для поиска новых устройств нажмите "Сканировать устройства"',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.read<BluetoothCubit>().startScan(),
                child: const Text('Сканировать устройства'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        cubit.startScan();
      },
      displacement: 40,
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        children: [
          if (state.status == BluetoothStatus.scanning)
            const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: 24),
              itemCount: state.scannedDevices.length,
              itemBuilder: (context, index) {
                final device = state.scannedDevices[index];
                final isConnectable = device.connectable.name == 'available';
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.devices, color: Colors.blue),
                    title: Text(
                      maxLines: 2,
                      device.name.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MAC: ${device.id}'),
                        const SizedBox(height: 2),
                        Text(
                          'RSSI: ${device.rssi}',
                          style: const TextStyle(fontSize: 10),
                        ),
                        Row(
                          children: [
                            Icon(
                              isConnectable ? Icons.link : Icons.link_off,
                              size: 12,
                              color: isConnectable ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isConnectable
                                  ? 'Доступно для подключения'
                                  : 'Недоступно',
                              style: TextStyle(
                                fontSize: 10,
                                color: isConnectable
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.bluetooth,
                      color: isConnectable ? Colors.blue : Colors.grey,
                    ),
                    onTap: isConnectable
                        ? () {
                            context.read<BluetoothCubit>().connectToDevice(
                              device.id,
                            );
                          }
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(
    BuildContext context,
    BluetoothState state,
  ) {
    if (state.status == BluetoothStatus.connected) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: () {
        if (state.status != BluetoothStatus.connected) {
          context.read<BluetoothCubit>().startScan();
        }
      },
      child: state.scannedDevices.isEmpty
          ? const Icon(Icons.search)
          : const Icon(Icons.replay_rounded),
    );
  }
}
