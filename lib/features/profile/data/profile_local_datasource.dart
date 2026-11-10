import 'dart:io';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:expense_tracker/features/profile/domain/user_profile.dart';

/// Stores the profile as a plain map in the app_prefs box (no codegen needed)
/// and keeps avatar images inside the app's documents directory.
class ProfileLocalDataSource {
  ProfileLocalDataSource(this._box);

  static const _key = 'user_profile';
  final Box _box;

  UserProfile? read() {
    final raw = _box.get(_key);
    if (raw is! Map) return null;
    return UserProfile.fromMap(Map<String, dynamic>.from(raw));
  }

  Future<void> write(UserProfile profile) => _box.put(_key, profile.toMap());

  Future<void> clear() => _box.delete(_key);

  /// Copies a picked image into app storage so it survives cache clears.
  Future<String> saveAvatar(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final name =
        'avatar_${DateTime.now().millisecondsSinceEpoch}${p.extension(sourcePath)}';
    final dest = p.join(dir.path, name);
    await File(sourcePath).copy(dest);
    return dest;
  }

  Future<void> deleteAvatar(String? avatarPath) async {
    if (avatarPath == null) return;
    final file = File(avatarPath);
    if (await file.exists()) await file.delete();
  }
}
