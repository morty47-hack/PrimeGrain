class CartItem {
  final int cartId;
  final int productId;
  final String name;
  final String image;
  final String description;
  final String segmentLabel;
  final double unitPrice;
  final double kg;
  final double lineTotal;
  final bool isSelected;

  CartItem({
    required this.cartId,
    required this.productId,
    required this.name,
    required this.image,
    required this.description,
    required this.segmentLabel,
    required this.unitPrice,
    required this.kg,
    required this.lineTotal,
    this.isSelected = true,
  });

  double get total => lineTotal > 0 ? lineTotal : unitPrice * kg;

  CartItem copyWith({
    int? cartId,
    int? productId,
    String? name,
    String? image,
    String? description,
    String? segmentLabel,
    double? unitPrice,
    double? kg,
    double? lineTotal,
    bool? isSelected,
  }) {
    return CartItem(
      cartId: cartId ?? this.cartId,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      image: image ?? this.image,
      description: description ?? this.description,
      segmentLabel: segmentLabel ?? this.segmentLabel,
      unitPrice: unitPrice ?? this.unitPrice,
      kg: kg ?? this.kg,
      lineTotal: lineTotal ?? this.lineTotal,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_id': cartId,
      'product_id': productId,
      'name': name,
      'image': image,
      'description': description,
      'segment_label': segmentLabel,
      'unit_price': unitPrice,
      'kg': kg,
      'line_total': lineTotal,
      'is_selected': isSelected,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> m) {
    int asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    double asDouble(dynamic value) {
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return CartItem(
      cartId: asInt(m['cart_id'] ?? m['id']),
      productId: asInt(m['product_id'] ?? m['id']),
      name: (m['name'] as String?) ?? '',
      image: (m['image'] as String?) ?? '',
      description: (m['description'] as String?) ?? '',
      segmentLabel: (m['segment_label'] as String?) ??
          (m['segment'] as String?) ??
          'Customer',
      unitPrice: asDouble(m['unit_price']),
      kg: asDouble(m['kg']),
      lineTotal: asDouble(m['line_total']),
      isSelected: m['is_selected'] != false,
    );
  }
}

