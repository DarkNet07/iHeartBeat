import 'package:flutter/material.dart';

class DataTab extends StatelessWidget {
  const DataTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timeline, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              const Text('Данные', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 16),
              const Text(
                'Здесь будут графики пульса и активности',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              const Icon(Icons.show_chart, size: 48, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
