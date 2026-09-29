import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/auth/auth_screen.dart';
import 'screens/home/home_shell.dart';
import 'state/auth_state.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class HilcoeGoApp extends StatelessWidget {
  const HilcoeGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ready = context.select<AuthState, bool>((a) => a.ready);
    final signedIn = context.select<AuthState, bool>((a) => a.signedIn);
    return MaterialApp(
      title: 'HiLCoE Go',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // A new key per state drops any pushed routes on log in / log out.
      home: !ready
          ? const _Starting()
          : signedIn
              ? const HomeShell(key: ValueKey('home'))
              : const AuthScreen(key: ValueKey('auth')),
    );
  }
}

/// Shown for a moment while Firebase checks whether someone is signed in.
/// Matches the launch screen so there's no flash.
class _Starting extends StatelessWidget {
  const _Starting();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue,
      body: Center(
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.school_outlined,
              size: 48, color: AppColors.blue),
        ),
      ),
    );
  }
}
