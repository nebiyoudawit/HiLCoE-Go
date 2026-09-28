import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/auth_repository.dart';
import 'data/course_repository.dart';
import 'data/local_store.dart';
import 'state/auth_state.dart';
import 'state/course_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fonts ship in google_fonts/, so never fetch them over the network.
  GoogleFonts.config.allowRuntimeFetching = false;
  final store = await LocalStore.open();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState(AuthRepository(store))),
        ChangeNotifierProxyProvider<AuthState, CourseState>(
          create: (_) => CourseState(CourseRepository(store)),
          update: (_, auth, courses) => courses!..setUser(auth.user?.email),
        ),
      ],
      child: const HilcoeGoApp(),
    ),
  );
}
