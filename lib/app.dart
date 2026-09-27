import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/auth/auth_screen.dart';
import 'screens/home/home_shell.dart';
import 'state/auth_state.dart';
import 'theme/app_theme.dart';

class HilcoeGoApp extends StatelessWidget {
  const HilcoeGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final signedIn = context.select<AuthState, bool>((a) => a.signedIn);
    return MaterialApp(
      title: 'HiLCoE Go',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // A new key per state drops any pushed routes on log in / log out.
      home: signedIn
          ? const HomeShell(key: ValueKey('home'))
          : const AuthScreen(key: ValueKey('auth')),
    );
  }
}
