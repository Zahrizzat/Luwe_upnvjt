import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const LuweCampusApp());
}

class LuweCampusApp extends StatefulWidget {
  const LuweCampusApp({super.key});

  @override
  State<LuweCampusApp> createState() => _LuweCampusAppState();
}

class _LuweCampusAppState extends State<LuweCampusApp> {
  final AppState _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'LuWe! Platform Promosi & Kuliner Kampus UPN "Veteran" Jatim',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: MainShell(state: _appState),
        );
      },
    );
  }
}
