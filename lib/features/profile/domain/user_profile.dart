/// Pure profile model. Money is stored in minor units (cents/paisa) as ints.
class UserProfile {
  const UserProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.avatarPath,
    this.currencyCode = 'USD',
    this.monthlyIncomeMinor = 0,
    this.monthlyBudgetMinor = 0,
  });

  final String name;
  final String email;
  final String phone;
  final String? avatarPath;
  final String currencyCode;
  final int monthlyIncomeMinor;
  final int monthlyBudgetMinor;

  String get displayName => name.trim().isEmpty ? 'Guest' : name.trim();

  /// Fields the user has not filled in yet, in friendly words.
  List<String> get missingFields => [
        if (name.trim().isEmpty) 'your name',
        if (avatarPath == null) 'a photo',
        if (email.trim().isEmpty) 'email',
        if (phone.trim().isEmpty) 'phone',
        if (monthlyIncomeMinor <= 0) 'monthly income',
        if (monthlyBudgetMinor <= 0) 'monthly budget',
      ];

  /// 0.0 to 1.0, across the six optional/required fields above.
  double get completion => (6 - missingFields.length) / 6;

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarPath,
    bool clearAvatar = false,
    String? currencyCode,
    int? monthlyIncomeMinor,
    int? monthlyBudgetMinor,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
      currencyCode: currencyCode ?? this.currencyCode,
      monthlyIncomeMinor: monthlyIncomeMinor ?? this.monthlyIncomeMinor,
      monthlyBudgetMinor: monthlyBudgetMinor ?? this.monthlyBudgetMinor,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'avatarPath': avatarPath,
        'currencyCode': currencyCode,
        'monthlyIncomeMinor': monthlyIncomeMinor,
        'monthlyBudgetMinor': monthlyBudgetMinor,
      };

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        name: (m['name'] as String?) ?? '',
        email: (m['email'] as String?) ?? '',
        phone: (m['phone'] as String?) ?? '',
        avatarPath: m['avatarPath'] as String?,
        currencyCode: (m['currencyCode'] as String?) ?? 'USD',
        monthlyIncomeMinor: (m['monthlyIncomeMinor'] as int?) ?? 0,
        monthlyBudgetMinor: (m['monthlyBudgetMinor'] as int?) ?? 0,
      );
}
