import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Accounts via Firebase Auth (email and password). The student's name,
/// batch and ID live in the Firestore document `users/{uid}`.
class AuthRepository {
  AuthRepository(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _profile(String uid) =>
      _db.collection('users').doc(uid);

  /// The signed-in account's id, or null when signed out.
  Stream<String?> authChanges() => _auth.authStateChanges().map((u) => u?.uid);

  /// Live profile for [uid]. Until the profile document exists (just after
  /// sign up) it falls back to what Firebase Auth knows.
  Stream<AppUser> watchProfile(String uid) =>
      _profile(uid).snapshots().map((snap) {
        final data = snap.data();
        if (data != null) return AppUser.fromJson(uid, data);
        final email = _auth.currentUser?.email ?? '';
        return AppUser(
          uid: uid,
          name: email.split('@').first,
          email: email,
          batch: '',
        );
      });

  Future<void> signUp({
    required String name,
    required String email,
    required String batch,
    String? studentId,
    required String password,
  }) =>
      _guard(() async {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final uid = cred.user!.uid;
        await _profile(uid).set(AppUser(
          uid: uid,
          name: name.trim(),
          email: email.trim().toLowerCase(),
          batch: batch.trim(),
          studentId: _clean(studentId),
        ).toJson());
        await cred.user!.sendEmailVerification();
      });

  /// Whether the signed-in account has clicked its verification link.
  bool get emailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<void> resendVerification() =>
      _guard(() async => _signedIn().sendEmailVerification());

  /// Asks Firebase for the latest account state (e.g. after the student
  /// clicks the link) and returns whether the email is verified now.
  /// Refreshes the ID token too, so the security rules see the change.
  Future<bool> refreshVerified() async {
    var verified = false;
    await _guard(() async {
      final user = _signedIn();
      await user.reload();
      await user.getIdToken(true);
      verified = _auth.currentUser?.emailVerified ?? false;
    });
    return verified;
  }

  /// Deletes the student's data and profile from Firestore, then the
  /// account itself. Needs the password, because Firebase only allows
  /// deleting an account right after a fresh login.
  Future<void> deleteAccount(String password) => _guard(() async {
        final user = _signedIn();
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: user.email!, password: password),
        );
        final data = _profile(user.uid).collection('data');
        final batch = _db.batch()
          ..delete(data.doc('courses'))
          ..delete(data.doc('exams'))
          ..delete(data.doc('schedule'))
          ..delete(_profile(user.uid));
        await batch.commit();
        await user.delete();
      });

  Future<void> logIn({required String email, required String password}) =>
      _guard(() async {
        await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      });

  Future<void> logOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  /// Saves new profile details. Email stays the same because it's the
  /// login.
  Future<void> updateProfile({
    required String name,
    required String batch,
    String? studentId,
  }) =>
      _guard(() async {
        final user = _signedIn();
        await _profile(user.uid).set({
          'name': name.trim(),
          'email': user.email,
          'batch': batch.trim(),
          'studentId': _clean(studentId),
        }, SetOptions(merge: true));
      });

  Future<void> changePassword({
    required String current,
    required String next,
  }) =>
      _guard(() async {
        final user = _signedIn();
        // Firebase asks for a fresh login before a password change.
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: user.email!, password: current),
        );
        await user.updatePassword(next);
      });

  User _signedIn() {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('You are signed out. Log in again.');
    }
    return user;
  }

  static String? _clean(String? value) =>
      (value == null || value.trim().isEmpty) ? null : value.trim();

  /// Runs [action], turning Firebase errors into plain messages.
  static Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      throw AuthException(messageFor(e.code));
    } on FirebaseException catch (e) {
      throw AuthException(e.code == 'unavailable'
          ? 'No internet connection. Try again when you\'re online.'
          : 'Something went wrong (${e.code}). Try again.');
    }
  }

  static String messageFor(String code) => switch (code) {
        'email-already-in-use' =>
          'An account with this email already exists. Log in instead.',
        'invalid-email' => 'That doesn\'t look like an email.',
        'weak-password' => 'Choose a stronger password.',
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' =>
          'That email and password don\'t match.',
        'user-disabled' => 'This account has been disabled.',
        'too-many-requests' =>
          'Too many tries. Wait a few minutes and try again.',
        'network-request-failed' =>
          'No internet connection. Try again when you\'re online.',
        'requires-recent-login' => 'Log out and back in, then try again.',
        _ => 'Something went wrong ($code). Try again.',
      };
}
