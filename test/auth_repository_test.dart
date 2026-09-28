import 'package:flutter_test/flutter_test.dart';
import 'package:hilcoe_go/data/auth_repository.dart';
import 'package:hilcoe_go/data/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AuthRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = AuthRepository(await LocalStore.open());
    await repo.signUp(
      name: 'Abebe Kebede',
      email: 'Abebe@Example.com',
      batch: 'DRB2301',
      password: 'firstpass1',
    );
  });

  test('updates profile but keeps email and password', () async {
    final user = await repo.updateProfile(
      name: 'Abebe K.',
      batch: 'DRB2302',
      studentId: ' 1234 ',
    );
    expect(user.email, 'abebe@example.com');
    expect(user.studentId, '1234');
    expect(repo.currentUser()!.batch, 'DRB2302');

    await repo.logOut();
    final back =
        await repo.logIn(email: 'abebe@example.com', password: 'firstpass1');
    expect(back.name, 'Abebe K.');
  });

  test('changes password only with the right current one', () async {
    expect(
      () => repo.changePassword(current: 'wrong', next: 'secondpass2'),
      throwsA(isA<AuthException>()),
    );
    await repo.changePassword(current: 'firstpass1', next: 'secondpass2');
    await repo.logOut();
    expect(
      () => repo.logIn(email: 'abebe@example.com', password: 'firstpass1'),
      throwsA(isA<AuthException>()),
    );
    final user =
        await repo.logIn(email: 'abebe@example.com', password: 'secondpass2');
    expect(user.name, 'Abebe Kebede');
  });
}
