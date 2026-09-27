import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../models/app_user.dart';

class AuthState extends ChangeNotifier {
  AuthState(this._repo) : _user = _repo.currentUser();

  final AuthRepository _repo;
  AppUser? _user;

  AppUser? get user => _user;
  bool get signedIn => _user != null;

  Future<void> logIn({required String email, required String password}) async {
    _user = await _repo.logIn(email: email, password: password);
    notifyListeners();
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String batch,
    String? studentId,
    required String password,
  }) async {
    _user = await _repo.signUp(
      name: name,
      email: email,
      batch: batch,
      studentId: studentId,
      password: password,
    );
    notifyListeners();
  }

  Future<void> logOut() async {
    await _repo.logOut();
    _user = null;
    notifyListeners();
  }
}
