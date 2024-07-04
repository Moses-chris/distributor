class OrderItem {
  final int? id;
  final int orderId;
  final String itemName;
  int quantity;
  final double price;

  OrderItem({
    this.id,
    required this.orderId,
    required this.itemName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'itemName': itemName,
      'quantity': quantity,
      'price': price,
    };
  }

  static OrderItem fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'],
      orderId: map['orderId'],
      itemName: map['itemName'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}
