class Profile {
  final String id;
  final String fullName;
  final String? businessName;
  final String email;
  final String? avatarUrl;
  final String currency;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.fullName,
    this.businessName,
    required this.email,
    this.avatarUrl,
    this.currency = 'INR',
    this.timezone = 'UTC',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        fullName: json['full_name'] as String,
        businessName: json['business_name'] as String?,
        email: json['email'] as String,
        avatarUrl: json['avatar_url'] as String?,
        currency: json['currency'] as String? ?? 'USD',
        timezone: json['timezone'] as String? ?? 'UTC',
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'business_name': businessName,
        'email': email,
        'avatar_url': avatarUrl,
        'currency': currency,
        'timezone': timezone,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Profile copyWith({
    String? fullName,
    String? businessName,
    String? email,
    String? avatarUrl,
    String? currency,
    String? timezone,
  }) =>
      Profile(
        id: id,
        fullName: fullName ?? this.fullName,
        businessName: businessName ?? this.businessName,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        currency: currency ?? this.currency,
        timezone: timezone ?? this.timezone,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  String get displayName => businessName ?? fullName;
}
