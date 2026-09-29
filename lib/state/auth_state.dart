import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../models/app_user.dart';

class AuthState extends ChangeNotifier {
  AuthState(this._repo) {
    _authSub = _repo.authChanges().listen(_onAuth);
  }

  final AuthRepository _repo;
  late final StreamSubscription<String?> _authSub;
  StreamSubscription<AppUser>? _profileSub;
  AppUser? _user;
  bool _ready = false;

  AppUser? get user => _user;
  bool get signedIn => _user != null;

  /// False until Firebase has said whether someone is signed in.
  bool get ready => _ready;

  void _onAuth(String? uid) {
    _profileSub?.cancel();
    _profileSub = null;
    if (uid == null) {
      _user = null;
      _ready = true;
      notifyListeners();
      return;
    }
    _profileSub = _repo.watchProfile(uid).listen((user) {
      _user = user;
      _ready = true;
      notifyListeners();
    });
  }

  Future<void> logIn({required String email, required String password}) =>
      _repo.logIn(email: email, password: password);

  Future<void> signUp({
    required String name,
    required String email,
    required String batch,
    String? studentId,
    required String password,
  }) =>
      _repo.signUp(
        name: name,
        email: email,
        batch: batch,
        studentId: studentId,
        password: password,
      );

  Future<void> sendPasswordReset(String email) =>
      _repo.sendPasswordReset(email);

  Future<void> updateProfile({
    required String name,
    required String batch,
    String? studentId,
  }) =>
      _repo.updateProfile(name: name, batch: batch, studentId: studentId);

  Future<void> changePassword({
    required String current,
    required String next,
  }) =>
      _repo.changePassword(current: current, next: next);

  Future<void> deleteAccount(String password) => _repo.deleteAccount(password);

  Future<void> logOut() => _repo.logOut();

  @override
  void dispose() {
    _authSub.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
