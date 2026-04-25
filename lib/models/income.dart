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
}
