class AlertConfig {
  final String id;
  final String productId;
  final String productTitle;
  final double targetPrice;
  final DateTime createdAt;

  const AlertConfig({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.targetPrice,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productTitle': productTitle,
      'targetPrice': targetPrice,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AlertConfig.fromMap(Map<String, dynamic> map) {
    return AlertConfig(
      id: map['id'] as String,
      productId: map['productId'] as String,
      productTitle: map['productTitle'] as String,
      targetPrice: (map['targetPrice'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
