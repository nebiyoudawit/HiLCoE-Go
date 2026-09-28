import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../models/app_user.dart';
import 'local_store.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// On-device accounts. Passwords are stored as salted SHA-256 hashes,
/// never in plain text. Swap this class out when a real backend exists.
class AuthRepository {
  AuthRepository(this._store);

  final LocalStore _store;

  static const _usersKey = 'auth.users';
  static const _sessionKey = 'auth.session';

  Map<String, dynamic> _users() =>
      (_store.readJson(_usersKey) as Map<String, dynamic>?) ?? {};

  static String _key(String email) => email.trim().toLowerCase();

  AppUser? currentUser() {
    final email = _store.getString(_sessionKey);
    if (email == null) return null;
    final record = _users()[email] as Map<String, dynamic>?;
    return record == null ? null : AppUser.fromJson(record);
  }

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String batch,
    String? studentId,
    required String password,
  }) async {
    final key = _key(email);
    final users = _users();
    if (users.containsKey(key)) {
      throw const AuthException(
          'An account with this email already exists. Log in instead.');
    }
    final user = AppUser(
      name: name.trim(),
      email: key,
      batch: batch.trim(),
      studentId: (studentId == null || studentId.trim().isEmpty)
          ? null
          : studentId.trim(),
    );
    final salt = _newSalt();
    users[key] = {
      ...user.toJson(),
      'salt': salt,
      'hash': _hash(password, salt),
    };
    await _store.writeJson(_usersKey, users);
    await _store.setString(_sessionKey, key);
    return user;
  }

  Future<AppUser> logIn({
    required String email,
    required String password,
  }) async {
    final key = _key(email);
    final record = _users()[key] as Map<String, dynamic>?;
    if (record == null ||
        record['hash'] != _hash(password, record['salt'] as String)) {
      throw const AuthException('That email and password don\'t match.');
    }
    await _store.setString(_sessionKey, key);
    return AppUser.fromJson(record);
  }

  Future<void> logOut() => _store.remove(_sessionKey);

  /// Saves new profile details for the signed-in account. Email stays
  /// the same because it identifies the account.
  Future<AppUser> updateProfile({
    required String name,
    required String batch,
    String? studentId,
  }) async {
    final key = _store.getString(_sessionKey);
    final users = _users();
    final record = users[key] as Map<String, dynamic>?;
    if (key == null || record == null) {
      throw const AuthException('You are signed out. Log in again.');
    }
    final user = AppUser(
      name: name.trim(),
      email: key,
      batch: batch.trim(),
      studentId: (studentId == null || studentId.trim().isEmpty)
          ? null
          : studentId.trim(),
    );
    users[key] = {
      ...user.toJson(),
      'salt': record['salt'],
      'hash': record['hash'],
    };
    await _store.writeJson(_usersKey, users);
    return user;
  }

  Future<void> changePassword({
    required String current,
    required String next,
  }) async {
    final key = _store.getString(_sessionKey);
    final users = _users();
    final record = users[key] as Map<String, dynamic>?;
    if (key == null || record == null) {
      throw const AuthException('You are signed out. Log in again.');
    }
    if (record['hash'] != _hash(current, record['salt'] as String)) {
      throw const AuthException('Your current password is wrong.');
    }
    final salt = _newSalt();
    users[key] = {...record, 'salt': salt, 'hash': _hash(next, salt)};
    await _store.writeJson(_usersKey, users);
  }

  static String _newSalt() {
    final random = Random.secure();
    return base64Url.encode(List.generate(16, (_) => random.nextInt(256)));
  }

  static String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();
}
