import 'dart:math';

class PasswordStrength {
  const PasswordStrength({
    required this.score,
    required this.label,
    required this.entropyBits,
  });

  final int score;
  final String label;
  final double entropyBits;

  bool get isWeak => score <= 1;
}

class PasswordGenerator {
  static const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String digits = '0123456789';
  static const String symbols = r'!@#$%^&*()-_=+[]{};:,.<>?/';

  static const List<String> commonPasswords = <String>[
    'password',
    'password123',
    '123456',
    '12345678',
    'qwerty',
    'admin',
    'letmein',
    'welcome',
    'iloveyou',
    'abc123',
  ];

  static String generate({
    int length = 20,
    bool useUppercase = true,
    bool useLowercase = true,
    bool useDigits = true,
    bool useSymbols = true,
  }) {
    final pools = <String>[
      if (useUppercase) uppercase,
      if (useLowercase) lowercase,
      if (useDigits) digits,
      if (useSymbols) symbols,
    ];
    if (pools.isEmpty) {
      throw ArgumentError('Minimal satu jenis karakter harus dipilih');
    }

    final safeLength = length.clamp(4, 128);
    final random = Random.secure();
    final characters = <String>[];

    for (final pool in pools) {
      characters.add(pool[random.nextInt(pool.length)]);
    }

    final combined = pools.join();
    while (characters.length < safeLength) {
      characters.add(combined[random.nextInt(combined.length)]);
    }

    for (var i = characters.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = characters[i];
      characters[i] = characters[j];
      characters[j] = temp;
    }

    return characters.join();
  }

  static PasswordStrength analyze(String password) {
    if (password.isEmpty) {
      return const PasswordStrength(
        score: 0,
        label: 'Sangat Lemah',
        entropyBits: 0,
      );
    }

    var poolSize = 0;
    if (RegExp(r'[a-z]').hasMatch(password)) poolSize += lowercase.length;
    if (RegExp(r'[A-Z]').hasMatch(password)) poolSize += uppercase.length;
    if (RegExp(r'[0-9]').hasMatch(password)) poolSize += digits.length;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) poolSize += symbols.length;
    if (poolSize == 0) poolSize = 1;

    final uniqueRatio =
        password.split('').toSet().length / password.length;
    final entropy =
        password.length * (log(poolSize) / ln2) * uniqueRatio;

    final lower = password.toLowerCase();
    final isCommon = commonPasswords.any(
      (item) => lower == item || lower.contains(item),
    );

    int score;
    if (isCommon || password.length < 6) {
      score = 0;
    } else if (entropy >= 100) {
      score = 4;
    } else if (entropy >= 75) {
      score = 3;
    } else if (entropy >= 50) {
      score = 2;
    } else if (entropy >= 30) {
      score = 1;
    } else {
      score = 0;
    }

    if (password.length < 8 && score > 1) score = 1;
    if (isCommon) score = 0;

    const labels = <String>[
      'Sangat Lemah',
      'Lemah',
      'Sedang',
      'Kuat',
      'Sangat Kuat',
    ];

    return PasswordStrength(
      score: score,
      label: labels[score],
      entropyBits: entropy,
    );
  }
}
