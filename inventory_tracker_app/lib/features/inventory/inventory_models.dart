class InventoryItem {
  final int id;
  final String name;
  final String unit;
  final String quantity; // viene como string (Decimal) desde DRF

  InventoryItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json["id"],
      name: json["name"],
      unit: json["unit"],
      quantity: json["quantity"].toString(),
    );
  }
}
