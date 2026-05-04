enum FinanceType { income, expense }

extension FinanceTypeExt on FinanceType {
  String get label {
    switch (this) {
      case FinanceType.income: return 'Pemasukan';
      case FinanceType.expense: return 'Pengeluaran';
    }
  }

  String get apiValue {
    switch (this) {
      case FinanceType.income: return 'income';
      case FinanceType.expense: return 'expense';
    }
  }
}

enum IncomeCategory { project, service, product, other }

extension IncomeCategoryExt on IncomeCategory {
  String get categoryLabel {
    switch (this) {
      case IncomeCategory.project: return 'Proyek';
      case IncomeCategory.service: return 'Jasa';
      case IncomeCategory.product: return 'Produk';
      case IncomeCategory.other: return 'Lainnya';
    }
  }
}

class Income {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final IncomeCategory category;
  final FinanceType type;

  const Income({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    this.type = FinanceType.income,
  });

  // Convenience accessor
  String get categoryLabel => category.categoryLabel;
  bool get isIncome => type == FinanceType.income;
  bool get isExpense => type == FinanceType.expense;

  factory Income.fromJson(Map<String, dynamic> json) {
    IncomeCategory getCat(String? c) {
      if (c == 'project') return IncomeCategory.project;
      if (c == 'service') return IncomeCategory.service;
      if (c == 'product') return IncomeCategory.product;
      return IncomeCategory.other;
    }
    FinanceType getType(String? t) {
      if (t == 'expense') return FinanceType.expense;
      return FinanceType.income;
    }
    return Income(
      id: json['id']?.toString() ?? '',
      description: json['description'] ?? '',
      amount: json['amount'] != null ? double.parse(json['amount'].toString()) : 0.0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      category: getCat(json['category']),
      type: getType(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.apiValue,
      'amount': amount,
      'date': date.toIso8601String().split('T').first,
      'category': category.name,
      'description': description,
    };
  }
}
