import 'package:flutter/material.dart';

class DevicesTab extends StatelessWidget {
  const DevicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bluetooth, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text('Устройства', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 16),
              const Text(
                'Здесь будут подключенные фитнес-браслеты',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mock: Сканирование устройств')),
                ),
                child: const Text('Сканировать устройства'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
