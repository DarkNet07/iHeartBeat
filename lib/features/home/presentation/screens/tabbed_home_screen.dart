import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iheartbeat/features/auth/blocs/auth/auth_bloc.dart';
import 'package:iheartbeat/features/home/blocs/bluetooth_bloc.dart';
import 'package:iheartbeat/features/home/data/bluetooth_service_factory.dart';
import 'package:iheartbeat/features/home/presentation/tabs/data_tab.dart';
import 'package:iheartbeat/features/home/presentation/tabs/devices_tab.dart';
import 'package:iheartbeat/features/home/presentation/tabs/profile_tab.dart';

class TabbedHomeScreen extends StatefulWidget {
  const TabbedHomeScreen({super.key});

  @override
  State<TabbedHomeScreen> createState() => _TabbedHomeScreenState();
}

class _TabbedHomeScreenState extends State<TabbedHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _tabs;
  late final List<BottomNavigationBarItem> _bottomNavItems;
  late final BluetoothCubit _bluetoothCubit;

  @override
  void initState() {
    super.initState();

    _bluetoothCubit = BluetoothCubit(BluetoothServiceFactory.createService());

    _tabs = [
      const DevicesTab(),
      const DataTab(),
      const ProfileTab(),
    ];

    _bottomNavItems = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.bluetooth),
        activeIcon: const Icon(Icons.bluetooth_connected),
        label: 'Устройства',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.timeline),
        activeIcon: const Icon(Icons.timeline),
        label: 'Данные',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person),
        activeIcon: const Icon(Icons.person),
        label: 'Профиль',
      ),
    ];
  }

  @override
  void dispose() {
    _bluetoothCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bluetoothCubit,
      child: Scaffold(
        body: _tabs[_currentIndex],
        bottomNavigationBar: Platform.isIOS
            ? CupertinoTabBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                activeColor: Theme.of(context).colorScheme.primary,
                inactiveColor: Colors.grey,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(CupertinoIcons.bluetooth),
                    activeIcon: const Icon(
                      CupertinoIcons.bluetooth,
                      color: Colors.blue,
                    ),
                    label: 'Устройства',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(CupertinoIcons.chart_bar),
                    activeIcon: const Icon(
                      CupertinoIcons.chart_bar,
                      color: Colors.green,
                    ),
                    label: 'Данные',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(CupertinoIcons.person),
                    activeIcon: const Icon(
                      CupertinoIcons.person,
                      color: Colors.red,
                    ),
                    label: 'Профиль',
                  ),
                ],
                onTap: (index) {
                  if (_currentIndex != index) {
                    _checkAuthAndNavigate(index);
                  }
                },
              )
            : BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Colors.grey,
                currentIndex: _currentIndex,
                items: _bottomNavItems,
                onTap: (index) {
                  if (_currentIndex != index) {
                    _checkAuthAndNavigate(index);
                  }
                },
              ),
      ),
    );
  }

  void _checkAuthAndNavigate(int index) {
    final authBloc = context.read<AuthBloc>();
    final currentState = authBloc.state;

    if (currentState.status != AuthStatus.authenticated) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}
