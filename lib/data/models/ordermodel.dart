import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class Order {
  int? id; // Local ID
  String uuid; // Unique identifier across local and server
  String? serverId; // Server ID (e.g., MongoDB _id)
  String bakerName;
  String status;
  DateTime deliveryDate;
  double totalAmount;
  bool isSynced;

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Order({
    this.id,
    String? uuid,
    this.serverId,
    required this.bakerName,
    required this.status,
    required this.deliveryDate,
    required this.totalAmount,
    this.isSynced = false,
  }) : uuid = uuid ?? Uuid().v4();

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int?,
      uuid: map['uuid'] as String? ?? Uuid().v4(),
      serverId: map['_id'] as String? ?? map['serverId'] as String?,
      bakerName: map['bakerName'] as String? ?? '',
      status: map['status'] as String? ?? '',
      deliveryDate: _parseDateFromString(map['deliveryDate'] as String?),
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      isSynced: (map['isSynced'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'serverId': serverId,
      'bakerName': bakerName,
      'status': status,
      'deliveryDate': _dateFormat.format(deliveryDate),
      'totalAmount': totalAmount,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  static DateTime _parseDateFromString(String? dateString) {
    if (dateString == null) return DateTime.now();
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      return _dateFormat.parse(dateString);
    }
  }
}