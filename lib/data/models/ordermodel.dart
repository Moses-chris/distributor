import 'package:intl/intl.dart';

class Order {
  int? id; // Local ID
  String? serverId; // Server ID (e.g., MongoDB _id)
  String bakerName;
  String status;
  DateTime deliveryDate;
  double totalAmount;
  bool isSynced;

  // static final List<DateFormat> _dateFormat = [
  //   DateFormat('yyyy-MM-dd'),
  //   DateFormat('dd/MM/yyyy'),
  //   DateFormat('dd-MM-yyyy'),
  //   ];
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Order({
    this.id,
    this.serverId,
    required this.bakerName,
    required this.status,
    required this.deliveryDate,
    required this.totalAmount,
    this.isSynced = false,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int?,
      serverId: map['_id'] as String? ?? map['serverId'] as String?,
      bakerName: map['bakerName'] as String,
      status: map['status'] as String,
      deliveryDate: _dateFormat.parse(map['deliveryDate'] as String),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      isSynced: (map['isSynced'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serverId': serverId,
      'bakerName': bakerName,
      'status': status,
      'deliveryDate': _dateFormat.format(deliveryDate),
      'totalAmount': totalAmount,
      'isSynced': isSynced ? 1 : 0,
    };
  }
}
