import 'package:flutter/material.dart';
import 'data/models/receiptpayment.dart';

import 'data/databasehelper.dart';

class ReceiptsPaymentsComponent extends StatefulWidget {
  @override
  _ReceiptsPaymentsComponentState createState() => _ReceiptsPaymentsComponentState();
}

class _ReceiptsPaymentsComponentState extends State<ReceiptsPaymentsComponent> {
  List<Receipt> receipts = [];
  List<Payment> payments = [];
  bool showReceipts = true; // This toggles between showing receipts and payments

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedReceipts = await DatabaseHelper.instance.getReceipts();
    final loadedPayments = await DatabaseHelper.instance.getPayments();
    setState(() {
      receipts = loadedReceipts;
      payments = loadedPayments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showReceipts = true;
                      });
                    },
                    child: Text(
                      'Receipts',
                      style: TextStyle(
                        color: showReceipts ? Colors.black : Colors.grey,
                        fontWeight: showReceipts ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showReceipts = false;
                      });
                    },
                    child: Text(
                      'Payments',
                      style: TextStyle(
                        color: !showReceipts ? Colors.black : Colors.grey,
                        fontWeight: !showReceipts ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: showReceipts ? receipts.length : payments.length,
              itemBuilder: (context, index) {
                if (showReceipts) {
                  return ReceiptCard(receipt: receipts[index]);
                } else {
                  return PaymentCard(payment: payments[index]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReceiptCard extends StatelessWidget {
  final Receipt receipt;

  const ReceiptCard({Key? key, required this.receipt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text('Receipt #${receipt.receiptNumber}'),
        subtitle: Text('Date: ${receipt.date}\nAmount: \$${receipt.amount.toStringAsFixed(2)}'),
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  final Payment payment;

  const PaymentCard({Key? key, required this.payment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text('Payment #${payment.paymentNumber}'),
        subtitle: Text('Date: ${payment.date}\nAmount: \$${payment.amount.toStringAsFixed(2)}'),
      ),
    );
  }
}
