import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iheartbeat/features/home/blocs/bluetooth_bloc.dart';

class DataTab extends StatelessWidget {
  const DataTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BluetoothCubit>();

    return BlocBuilder<BluetoothCubit, BluetoothState>(
      builder: (context, state) {
        final isConnected = state.status == BluetoothStatus.connected;

        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isConnected
                        ? Icons.timeline
                        : Icons.bluetooth_disabled_rounded,
                    size: 80,
                    color: isConnected ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isConnected ? 'Данные с устройства' : 'Данные',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 16),
                  if (isConnected) ...[
                    StreamBuilder<int>(
                      stream: cubit.heartRateStream,
                      builder: (context, snapshot) {
                        return _buildDataCard(
                          '❤️ Пульс',
                          '${snapshot.data ?? 0} уд/мин',
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<int>(
                      stream: cubit.stepsStream,
                      builder: (context, snapshot) {
                        return _buildDataCard(
                          '👣 Шаги',
                          '${snapshot.data ?? 0}',
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<int>(
                      stream: cubit.batteryStream,
                      builder: (context, snapshot) {
                        return _buildDataCard(
                          '🔋 Батарея',
                          '${snapshot.data ?? 0}%',
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<int>(
                      stream: cubit.caloriesStream,
                      builder: (context, snapshot) {
                        return _buildDataCard(
                          '🔥 Калории',
                          '${snapshot.data ?? 0} ккал',
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<int>(
                      stream: cubit.distanceStream,
                      builder: (context, snapshot) {
                        final distance = snapshot.data ?? 0;
                        return _buildDataCard(
                          '📏 Дистанция',
                          '${(distance / 1000).toStringAsFixed(2)} км',
                        );
                      },
                    ),
                  ] else ...[
                    const Text(
                      'Подключите устройство для отображения данных',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataCard(String title, String value) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
