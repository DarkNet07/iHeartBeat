import 'package:flutter/material.dart';
import 'package:iheartbeat/core/injection_container.dart';
import 'package:iheartbeat/features/auth/domain/biometric_service.dart';

class SetupSecurityScreen extends StatefulWidget {
  const SetupSecurityScreen({super.key});

  @override
  State<SetupSecurityScreen> createState() => _SetupSecurityScreenState();
}

class _SetupSecurityScreenState extends State<SetupSecurityScreen> {
  final BiometricService _bioService = BiometricService();
  final _authService = authService;

  bool _isBiometricEnabled = false;
  bool _hasPin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final biometricEnabled = await _authService.isBiometricEnabled();
    final hasPin = await _authService.hasPin();

    setState(() {
      _isBiometricEnabled = biometricEnabled;
      _hasPin = hasPin;
      _isLoading = false;
    });
  }

  Future<void> _toggleBiometric() async {
    if (_isBiometricEnabled) {
      await _authService.enableBiometric(false);
      setState(() {
        _isBiometricEnabled = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Биометрия отключена')));
      }
    } else {
      final available = await _bioService.isBiometricAvailable();
      if (available) {
        final success = await _bioService.authenticate();
        if (success) {
          await _authService.enableBiometric(true);
          setState(() {
            _isBiometricEnabled = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Биометрия включена')));
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Биометрическая аутентификация не удалась'),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Биометрия недоступна на этом устройстве'),
            ),
          );
        }
      }
    }
  }

  Future<void> _managePin() async {
    if (_hasPin) {
      await _showPinManagementDialog();
    } else {
      await _setupNewPin();
    }
  }

  Future<void> _setupNewPin() async {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();

    final result = await showDialog<bool>(
      useSafeArea: true,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создание PIN-кода'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              maxLength: 4,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Введите 4 цифры',
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPinController,
              maxLength: 4,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Повторите PIN-код',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (pinController.text.length == 4 &&
                  pinController.text == confirmPinController.text) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'PIN-коды не совпадают или недостаточно цифр',
                    ),
                  ),
                );
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _authService.setPin(pinController.text);
      setState(() {
        _hasPin = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('PIN-код сохранён')));
      }
    }
  }

  Future<void> _showPinManagementDialog() async {
    final result = await showDialog<String>(
      context: context,
      useSafeArea: true,
      builder: (context) => SimpleDialog(
        title: const Text('Управление PIN-кодом'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'change'),
            child: const Text('Изменить PIN-код'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'remove'),
            child: const Text(
              'Удалить PIN-код',
              style: TextStyle(color: Colors.red),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );

    switch (result) {
      case 'change':
        await _changePin();
        break;
      case 'remove':
        await _removePin();
        break;
    }
  }

  Future<void> _changePin() async {
    final currentPinController = TextEditingController();

    final verified = await showDialog<bool>(
      context: context,
      useSafeArea: true,
      builder: (context) => AlertDialog(
        title: const Text('Подтвердите текущий PIN'),
        content: TextField(
          controller: currentPinController,
          maxLength: 4,
          keyboardType: TextInputType.number,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Текущий PIN',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final isValid = await _authService.validatePin(
                currentPinController.text,
              );
              Navigator.pop(context, isValid);
            },
            child: const Text('Продолжить'),
          ),
        ],
      ),
    );

    if (verified == true) {
      await _setupNewPin();
    } else if (verified == false) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Неверный PIN-код')));
      }
    }
  }

  Future<void> _removePin() async {
    final confirmed = await showDialog<bool>(
      context: context,
      useSafeArea: true,
      builder: (context) => AlertDialog(
        title: const Text('Удалить PIN-код?'),
        content: const Text('Вы уверены, что хотите удалить PIN-код?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.setPin('');
      setState(() {
        _hasPin = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('PIN-код удалён')));
      }
    }
  }

  String _getBiometricButtonText() {
    if (_isBiometricEnabled) {
      return 'Отключить биометрию';
    } else {
      return 'Включить биометрию';
    }
  }

  String _getPinButtonText() {
    if (_hasPin) {
      return 'Управление PIN-кодом';
    } else {
      return 'Установить PIN-код';
    }
  }

  IconData _getBiometricIcon() {
    return _isBiometricEnabled ? Icons.fingerprint : Icons.fingerprint_outlined;
  }

  IconData _getPinIcon() {
    return _hasPin ? Icons.lock : Icons.lock_open;
  }

  Color _getBiometricColor() {
    return _isBiometricEnabled
        ? Colors.green
        : Theme.of(context).colorScheme.primary;
  }

  Color _getPinColor() {
    return _hasPin ? Colors.green : Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Биометрия и вход'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Способы быстрого входа',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Настройте дополнительные методы входа для удобства и безопасности',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              Card(
                child: ListTile(
                  leading: Icon(
                    _getBiometricIcon(),
                    color: _getBiometricColor(),
                  ),
                  title: const Text('Биометрическая аутентификация'),
                  subtitle: Text(
                    _isBiometricEnabled
                        ? 'Включена'
                        : 'Используйте отпечаток пальца или лицо для входа',
                  ),
                  trailing: Switch(
                    value: _isBiometricEnabled,
                    onChanged: (value) => _toggleBiometric(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: ListTile(
                  leading: Icon(_getPinIcon(), color: _getPinColor()),
                  title: const Text('PIN-код'),
                  subtitle: Text(
                    _hasPin
                        ? 'Установлен'
                        : 'Используйте 4-значный код для входа',
                  ),
                  trailing: _hasPin
                      ? IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: _managePin,
                          tooltip: 'Управление PIN-кодом',
                        )
                      : IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _managePin,
                          tooltip: 'Добавить PIN-код',
                        ),
                ),
              ),

              const SizedBox(height: 32),

              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Быстрые действия:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(_getBiometricIcon()),
                  label: Text(_getBiometricButtonText()),
                  onPressed: _toggleBiometric,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getBiometricColor(),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(_getPinIcon()),
                  label: Text(_getPinButtonText()),
                  onPressed: _managePin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPinColor(),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '💡 Совет: Вы можете включить оба способа для максимальной безопасности',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
