import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/auth_repository.dart';
import 'data/course_repository.dart';
import 'data/firestore_course_repository.dart';
import 'data/local_store.dart';
import 'firebase_options.dart';
import 'state/auth_state.dart';
import 'state/course_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fonts ship in google_fonts/, so never fetch them over the network.
  GoogleFonts.config.allowRuntimeFetching = false;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final db = FirebaseFirestore.instance;
  // Data saved on this phone before accounts moved online, if any.
  final local = LocalCourseRepository(await LocalStore.open());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthState(AuthRepository(FirebaseAuth.instance, db)),
        ),
        ChangeNotifierProxyProvider<AuthState, CourseState>(
          create: (_) => CourseState(FirestoreCourseRepository(db, local)),
          // Data loads only once the email is verified; the security
          // rules refuse it before that.
          update: (_, auth, courses) => courses!
            ..setUser(
              auth.needsVerification ? null : auth.user?.uid,
              email: auth.user?.email,
            ),
        ),
      ],
      child: const HilcoeGoApp(),
    ),
  );
}
