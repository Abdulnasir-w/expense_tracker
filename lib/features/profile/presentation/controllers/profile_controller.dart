import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker/core/storage/app_prefs.dart';
import 'package:expense_tracker/features/profile/data/profile_local_datasource.dart';
import 'package:expense_tracker/features/profile/domain/user_profile.dart';

final profileDataSourceProvider = Provider<ProfileLocalDataSource>(
  (ref) => ProfileLocalDataSource(ref.watch(appPrefsProvider).box),
);

/// State is null until the user has saved a profile (e.g. skipped setup).
class ProfileController extends Notifier<UserProfile?> {
  @override
  UserProfile? build() => ref.read(profileDataSourceProvider).read();

  Future<void> save(UserProfile profile) async {
    final ds = ref.read(profileDataSourceProvider);
    final oldAvatar = state?.avatarPath;
    if (oldAvatar != null && oldAvatar != profile.avatarPath) {
      await ds.deleteAvatar(oldAvatar);
    }
    await ds.write(profile);
    state = profile;
  }

  Future<void> clear() async {
    final ds = ref.read(profileDataSourceProvider);
    await ds.deleteAvatar(state?.avatarPath);
    await ds.clear();
    state = null;
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, UserProfile?>(ProfileController.new);
