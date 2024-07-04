// data/receiptmodel.dart
class Receipt {
  final int id;
  final String receiptNumber;
  final double amount;
  final String date;

  Receipt({required this.id, required this.receiptNumber, required this.amount, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receiptNumber': receiptNumber,
      'amount': amount,
      'date': date,
    };
  }

  static Receipt fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id'],
      receiptNumber: map['receiptNumber'],
      amount: map['amount'],
      date: map['date'],
    );
  }
}

// data/paymentmodel.dart
class Payment {
  final int id;
  final String paymentNumber;
  final double amount;
  final String date;

  Payment({required this.id, required this.paymentNumber, required this.amount, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'paymentNumber': paymentNumber,
      'amount': amount,
      'date': date,
    };
  }

  static Payment fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      paymentNumber: map['paymentNumber'],
      amount: map['amount'],
      date: map['date'],
    );
  }
}
