extension NumExtension on num {
  double get asPct => this * 100;

  String get pctString => '${(this * 100).toStringAsFixed(1)}%';

  bool get isPositive => this > 0;
  bool get isNegative => this < 0;
  bool get isZero => this == 0;

  String get signedString {
    if (this > 0) return '+${toStringAsFixed(2)}';
    return toStringAsFixed(2);
  }
}
