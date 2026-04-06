class RecurringRule {
  final String id;
  final String userId;
  final String? nodeId;
  final String? clientId;
  final String name;
  final String type;
  final double amount;
  final String currency;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextRunDate;
  final DateTime? lastRunDate;
  final bool isActive;
  final bool autoCreate;
  final DateTime createdAt;

  const RecurringRule({
    required this.id,
    required this.userId,
    this.nodeId,
    this.clientId,
    required this.name,
    required this.type,
    required this.amount,
    this.currency = 'USD',
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.nextRunDate,
    this.lastRunDate,
    this.isActive = true,
    this.autoCreate = true,
    required this.createdAt,
  });

  factory RecurringRule.fromJson(Map<String, dynamic> json) => RecurringRule(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        nodeId: json['node_id'] as String?,
        clientId: json['client_id'] as String?,
        name: json['name'] as String,
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'USD',
        frequency: json['frequency'] as String,
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: json['end_date'] != null
            ? DateTime.parse(json['end_date'] as String)
            : null,
        nextRunDate: DateTime.parse(json['next_run_date'] as String),
        lastRunDate: json['last_run_date'] != null
            ? DateTime.parse(json['last_run_date'] as String)
            : null,
        isActive: json['is_active'] as bool? ?? true,
        autoCreate: json['auto_create'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'node_id': nodeId,
        'client_id': clientId,
        'name': name,
        'type': type,
        'amount': amount,
        'currency': currency,
        'frequency': frequency,
        'start_date': startDate.toIso8601String().substring(0, 10),
        'end_date': endDate?.toIso8601String().substring(0, 10),
        'next_run_date': nextRunDate.toIso8601String().substring(0, 10),
        'last_run_date': lastRunDate?.toIso8601String().substring(0, 10),
        'is_active': isActive,
        'auto_create': autoCreate,
      };
}
