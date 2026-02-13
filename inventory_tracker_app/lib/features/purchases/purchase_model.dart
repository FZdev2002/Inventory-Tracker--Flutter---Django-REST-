class Purchase {
  final int id;
  final String name;
  final String unit;
  final String quantity; // string para evitar líos con decimales
  final DateTime createdAt;

  Purchase({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.createdAt,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json["id"] as int,
      name: (json["name"] ?? "").toString(),
      unit: (json["unit"] ?? "").toString(),
      quantity: (json["quantity"] ?? "").toString(),
      createdAt: DateTime.parse(json["created_at"].toString()),
    );
  }
}
