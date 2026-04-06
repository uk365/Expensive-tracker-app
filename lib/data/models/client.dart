class Client {
  final String id;
  final String userId;
  final String displayName;
  final String fullName;
  final String? businessName;
  final String? businessType;
  final String? industry;
  final String? email;
  final String? phone;
  final String? website;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final DateTime? clientSince;
  final String status;
  final String tier;
  final String paymentTerms;
  final String? taxId;
  final String currency;
  final double? creditLimit;
  final String? notes;
  final List<String> tags;
  final String avatarColor;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Client({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.fullName,
    this.businessName,
    this.businessType,
    this.industry,
    this.email,
    this.phone,
    this.website,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.clientSince,
    this.status = 'active',
    this.tier = 'standard',
    this.paymentTerms = 'net30',
    this.taxId,
    this.currency = 'USD',
    this.creditLimit,
    this.notes,
    this.tags = const [],
    this.avatarColor = '#6366F1',
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) => Client(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        displayName: json['display_name'] as String,
        fullName: json['full_name'] as String,
        businessName: json['business_name'] as String?,
        businessType: json['business_type'] as String?,
        industry: json['industry'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        website: json['website'] as String?,
        addressLine1: json['address_line1'] as String?,
        addressLine2: json['address_line2'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        postalCode: json['postal_code'] as String?,
        country: json['country'] as String?,
        clientSince: json['client_since'] != null
            ? DateTime.parse(json['client_since'] as String)
            : null,
        status: json['status'] as String? ?? 'active',
        tier: json['tier'] as String? ?? 'standard',
        paymentTerms: json['payment_terms'] as String? ?? 'net30',
        taxId: json['tax_id'] as String?,
        currency: json['currency'] as String? ?? 'USD',
        creditLimit: (json['credit_limit'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        avatarColor: json['avatar_color'] as String? ?? '#6366F1',
        isArchived: json['is_archived'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'display_name': displayName,
        'full_name': fullName,
        'business_name': businessName,
        'business_type': businessType,
        'industry': industry,
        'email': email,
        'phone': phone,
        'website': website,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
        'client_since': clientSince?.toIso8601String().substring(0, 10),
        'status': status,
        'tier': tier,
        'payment_terms': paymentTerms,
        'tax_id': taxId,
        'currency': currency,
        'credit_limit': creditLimit,
        'notes': notes,
        'tags': tags,
        'avatar_color': avatarColor,
        'is_archived': isArchived,
      };

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  Client copyWith({
    String? displayName,
    String? fullName,
    String? businessName,
    String? businessType,
    String? industry,
    String? email,
    String? phone,
    String? website,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    DateTime? clientSince,
    String? status,
    String? tier,
    String? paymentTerms,
    String? taxId,
    String? currency,
    double? creditLimit,
    String? notes,
    List<String>? tags,
    String? avatarColor,
    bool? isArchived,
  }) =>
      Client(
        id: id,
        userId: userId,
        displayName: displayName ?? this.displayName,
        fullName: fullName ?? this.fullName,
        businessName: businessName ?? this.businessName,
        businessType: businessType ?? this.businessType,
        industry: industry ?? this.industry,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        website: website ?? this.website,
        addressLine1: addressLine1 ?? this.addressLine1,
        addressLine2: addressLine2 ?? this.addressLine2,
        city: city ?? this.city,
        state: state ?? this.state,
        postalCode: postalCode ?? this.postalCode,
        country: country ?? this.country,
        clientSince: clientSince ?? this.clientSince,
        status: status ?? this.status,
        tier: tier ?? this.tier,
        paymentTerms: paymentTerms ?? this.paymentTerms,
        taxId: taxId ?? this.taxId,
        currency: currency ?? this.currency,
        creditLimit: creditLimit ?? this.creditLimit,
        notes: notes ?? this.notes,
        tags: tags ?? this.tags,
        avatarColor: avatarColor ?? this.avatarColor,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
