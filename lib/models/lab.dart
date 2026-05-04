import 'dart:convert';

class UserBasic {
  final String id;
  final String name;
  final String division;

  UserBasic({required this.id, required this.name, required this.division});

  factory UserBasic.fromJson(Map<String, dynamic> json) {
    return UserBasic(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      division: json['division'] ?? '',
    );
  }
}

class Lab {
  final String id;
  final String name;
  final String description;
  final int inventoryItemsCount;
  final List<UserBasic> pics;

  Lab({
    required this.id,
    required this.name,
    required this.description,
    required this.inventoryItemsCount,
    required this.pics,
  });

  factory Lab.fromJson(Map<String, dynamic> json) {
    return Lab(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      inventoryItemsCount: json['inventory_items_count'] ?? 0,
      pics: (json['pics'] as List?)?.map((e) => UserBasic.fromJson(e)).toList() ?? [],
    );
  }
}

class InventoryItem {
  final String id;
  final String labId;
  final String name;
  final int quantity;
  final String condition;
  final String notes;

  InventoryItem({
    required this.id,
    required this.labId,
    required this.name,
    required this.quantity,
    required this.condition,
    required this.notes,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'].toString(),
      labId: json['lab_id'].toString(),
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      condition: json['condition'] ?? 'Baik',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'condition': condition,
      'notes': notes,
    };
  }
}
