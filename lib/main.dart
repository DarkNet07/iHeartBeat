import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iheartbeat/core/navigation/route_generator.dart';
import 'package:iheartbeat/core/ui/theme/app_theme.dart';
import 'package:iheartbeat/core/injection_container.dart' as di;
import 'package:iheartbeat/features/auth/blocs/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const IHeartBeatApp());
}

class IHeartBeatApp extends StatelessWidget {
  const IHeartBeatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>()..add(AppStarted()),
        ),
      ],
      child: MaterialApp(
        title: 'iHeartBeat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/login',
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
