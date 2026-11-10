import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Small key-value store for app flags (onboarding, tour) and the profile map.
///
/// Open the box once in main():
///   await Hive.openBox(AppPrefs.boxName);
class AppPrefs {
  AppPrefs(this._box);

  static const boxName = 'app_prefs';
  static const _kOnboardingDone = 'onboarding_done';
  static const _kTourDone = 'tour_done';

  final Box _box;

  Box get box => _box;

  bool get onboardingDone =>
      _box.get(_kOnboardingDone, defaultValue: false) as bool;

  bool get tourDone => _box.get(_kTourDone, defaultValue: false) as bool;

  Future<void> setOnboardingDone() => _box.put(_kOnboardingDone, true);
  Future<void> resetOnboarding() => _box.put(_kOnboardingDone, false);
  Future<void> setTourDone() => _box.put(_kTourDone, true);
  Future<void> resetTour() => _box.put(_kTourDone, false);
}

final appPrefsProvider =
    Provider<AppPrefs>((ref) => AppPrefs(Hive.box(AppPrefs.boxName)));
