import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../db/models/user_model.dart';
import '../../db/firebase/user.dart';

final userDatabaseProvider = Provider<UserDatabase>((ref) => UserDatabase());

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<AppUser?>>((ref) {
  final db = ref.watch(userDatabaseProvider);
  return UserNotifier(db);
});

class UserNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  final UserDatabase _db;
  UserNotifier(this._db) : super(const AsyncValue.loading());

  Future<void> loadUser(String uid) async {
    state = const AsyncValue.loading();
    try {
      final user = await _db.getUser(uid);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createUser(AppUser user) async {
    state = const AsyncValue.loading();
    try {
      // Check if user already exists
      final existingUser = await _db.getUser(user.uid);
      if (existingUser != null) {
        state = AsyncValue.data(existingUser);
        return;
      }
      // Create new user
      await _db.createUser(user);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateUser(AppUser user) async {
    state = const AsyncValue.loading();
    try {
      await _db.updateUser(user);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteUser(String uid) async {
    state = const AsyncValue.loading();
    try {
      await _db.deleteUser(uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void listenToUser(String uid) {
    state = const AsyncValue.loading();
    _db.streamUser(uid).listen((user) {
      state = AsyncValue.data(user);
    }, onError: (e, st) {
      state = AsyncValue.error(e, st);
    });
  }
}
