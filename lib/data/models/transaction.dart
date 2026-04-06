class Transaction {
  final String id;
  final String userId;
  final String? nodeId;
  final String? clientId;
  final String type;
  final double amount;
  final String currency;
  final double exchangeRate;
  final double? amountBase;
  final String? category;
  final String? subCategory;
  final String description;
  final String paymentMethod;
  final String? referenceNo;
  final DateTime transactionDate;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final String status;
  final String? receiptUrl;
  final String? invoiceUrl;
  final bool isTaxable;
  final double taxRate;
  final double taxAmount;
  final bool isRecurring;
  final String? recurrenceId;
  final String? notes;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields (not in DB)
  final String? clientName;
  final String? nodeName;

  const Transaction({
    required this.id,
    required this.userId,
    this.nodeId,
    this.clientId,
    required this.type,
    required this.amount,
    this.currency = 'USD',
    this.exchangeRate = 1.0,
    this.amountBase,
    this.category,
    this.subCategory,
    required this.description,
    this.paymentMethod = 'bank_transfer',
    this.referenceNo,
    required this.transactionDate,
    this.dueDate,
    this.paidDate,
    this.status = 'completed',
    this.receiptUrl,
    this.invoiceUrl,
    this.isTaxable = false,
    this.taxRate = 0,
    this.taxAmount = 0,
    this.isRecurring = false,
    this.recurrenceId,
    this.notes,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.clientName,
    this.nodeName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        nodeId: json['node_id'] as String?,
        clientId: json['client_id'] as String?,
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'USD',
        exchangeRate: (json['exchange_rate'] as num?)?.toDouble() ?? 1.0,
        amountBase: (json['amount_base'] as num?)?.toDouble(),
        category: json['category'] as String?,
        subCategory: json['sub_category'] as String?,
        description: json['description'] as String,
        paymentMethod: json['payment_method'] as String? ?? 'bank_transfer',
        referenceNo: json['reference_no'] as String?,
        transactionDate: DateTime.parse(json['transaction_date'] as String),
        dueDate: json['due_date'] != null
            ? DateTime.parse(json['due_date'] as String)
            : null,
        paidDate: json['paid_date'] != null
            ? DateTime.parse(json['paid_date'] as String)
            : null,
        status: json['status'] as String? ?? 'completed',
        receiptUrl: json['receipt_url'] as String?,
        invoiceUrl: json['invoice_url'] as String?,
        isTaxable: json['is_taxable'] as bool? ?? false,
        taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0,
        taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0,
        isRecurring: json['is_recurring'] as bool? ?? false,
        recurrenceId: json['recurrence_id'] as String?,
        notes: json['notes'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        clientName: json['client_name'] as String?,
        nodeName: json['node_name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'node_id': nodeId,
        'client_id': clientId,
        'type': type,
        'amount': amount,
        'currency': currency,
        'exchange_rate': exchangeRate,
        'amount_base': amountBase,
        'category': category,
        'sub_category': subCategory,
        'description': description,
        'payment_method': paymentMethod,
        'reference_no': referenceNo,
        'transaction_date': transactionDate.toIso8601String().substring(0, 10),
        'due_date': dueDate?.toIso8601String().substring(0, 10),
        'paid_date': paidDate?.toIso8601String().substring(0, 10),
        'status': status,
        'receipt_url': receiptUrl,
        'invoice_url': invoiceUrl,
        'is_taxable': isTaxable,
        'tax_rate': taxRate,
        'tax_amount': taxAmount,
        'is_recurring': isRecurring,
        'recurrence_id': recurrenceId,
        'notes': notes,
        'tags': tags,
      };

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
  bool get isDonation => type == 'donation';
  bool get isPending => status == 'pending';
  bool get isOverdue =>
      isPending && dueDate != null && dueDate!.isBefore(DateTime.now());
}
