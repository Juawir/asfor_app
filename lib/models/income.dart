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

  const Income({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });

  // Convenience accessor
  String get categoryLabel => category.categoryLabel;

  factory Income.fromJson(Map<String, dynamic> json) {
    IncomeCategory getCat(String? c) {
      if (c == 'project') return IncomeCategory.project;
      if (c == 'service') return IncomeCategory.service;
      if (c == 'product') return IncomeCategory.product;
      return IncomeCategory.other;
    }
    return Income(
      id: json['id']?.toString() ?? '',
      description: json['description'] ?? '',
      amount: json['amount'] != null ? double.parse(json['amount'].toString()) : 0.0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      category: getCat(json['category']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.name,
    };
  }
}
