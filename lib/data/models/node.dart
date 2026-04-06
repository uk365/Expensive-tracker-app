class Node {
  final String id;
  final String userId;
  final String? parentId;
  final String? clientId;
  final String name;
  final String nodeType;
  final String icon;
  final String color;
  final int sortOrder;
  final double? amount;
  final String currency;
  final String? billingCycle;
  final DateTime? startDate;
  final DateTime? renewalDate;
  final DateTime? endDate;
  final String status;
  final String? notes;
  final List<String> tags;
  final bool isArchived;
  final int depth;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed: loaded from children
  double? aggregatedAmount;
  List<Node> children;

  Node({
    required this.id,
    required this.userId,
    this.parentId,
    this.clientId,
    required this.name,
    required this.nodeType,
    this.icon = '📁',
    this.color = '#6366F1',
    this.sortOrder = 0,
    this.amount,
    this.currency = 'USD',
    this.billingCycle,
    this.startDate,
    this.renewalDate,
    this.endDate,
    this.status = 'active',
    this.notes,
    this.tags = const [],
    this.isArchived = false,
    this.depth = 0,
    required this.createdAt,
    required this.updatedAt,
    this.aggregatedAmount,
    this.children = const [],
  });

  factory Node.fromJson(Map<String, dynamic> json) => Node(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        parentId: json['parent_id'] as String?,
        clientId: json['client_id'] as String?,
        name: json['name'] as String,
        nodeType: json['node_type'] as String,
        icon: json['icon'] as String? ?? '📁',
        color: json['color'] as String? ?? '#6366F1',
        sortOrder: json['sort_order'] as int? ?? 0,
        amount: (json['amount'] as num?)?.toDouble(),
        currency: json['currency'] as String? ?? 'USD',
        billingCycle: json['billing_cycle'] as String?,
        startDate: json['start_date'] != null
            ? DateTime.parse(json['start_date'] as String)
            : null,
        renewalDate: json['renewal_date'] != null
            ? DateTime.parse(json['renewal_date'] as String)
            : null,
        endDate: json['end_date'] != null
            ? DateTime.parse(json['end_date'] as String)
            : null,
        status: json['status'] as String? ?? 'active',
        notes: json['notes'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        isArchived: json['is_archived'] as bool? ?? false,
        depth: json['depth'] as int? ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'parent_id': parentId,
        'client_id': clientId,
        'name': name,
        'node_type': nodeType,
        'icon': icon,
        'color': color,
        'sort_order': sortOrder,
        'amount': amount,
        'currency': currency,
        'billing_cycle': billingCycle,
        'start_date': startDate?.toIso8601String().substring(0, 10),
        'renewal_date': renewalDate?.toIso8601String().substring(0, 10),
        'end_date': endDate?.toIso8601String().substring(0, 10),
        'status': status,
        'notes': notes,
        'tags': tags,
        'is_archived': isArchived,
        'depth': depth,
      };

  bool get isLeaf => amount != null;

  bool get hasRenewalSoon {
    if (renewalDate == null) return false;
    final days = renewalDate!.difference(DateTime.now()).inDays;
    return days >= 0 && days <= 7;
  }

  bool get isRenewalOverdue {
    if (renewalDate == null) return false;
    return renewalDate!.isBefore(DateTime.now());
  }

  String get billingCycleLabel {
    const labels = {
      'one_time': '/once',
      'daily': '/day',
      'weekly': '/wk',
      'monthly': '/mo',
      'quarterly': '/qtr',
      'yearly': '/yr',
    };
    return labels[billingCycle] ?? '';
  }

  Node copyWith({
    String? name,
    String? nodeType,
    String? icon,
    String? color,
    int? sortOrder,
    double? amount,
    String? currency,
    String? billingCycle,
    DateTime? startDate,
    DateTime? renewalDate,
    DateTime? endDate,
    String? status,
    String? notes,
    List<String>? tags,
    bool? isArchived,
    String? clientId,
  }) =>
      Node(
        id: id,
        userId: userId,
        parentId: parentId,
        clientId: clientId ?? this.clientId,
        name: name ?? this.name,
        nodeType: nodeType ?? this.nodeType,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        sortOrder: sortOrder ?? this.sortOrder,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        billingCycle: billingCycle ?? this.billingCycle,
        startDate: startDate ?? this.startDate,
        renewalDate: renewalDate ?? this.renewalDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        notes: notes ?? this.notes,
        tags: tags ?? this.tags,
        isArchived: isArchived ?? this.isArchived,
        depth: depth,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        children: children,
      );
}
