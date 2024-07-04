// // receiptspayments.dart
// import 'package:flutter/material.dart';
// import 'data/models/receiptpayment.dart';
// import 'data/databasehelper.dart';

// class ReceiptsPaymentsComponent extends StatefulWidget {
//   @override
//   _ReceiptsPaymentsComponentState createState() => _ReceiptsPaymentsComponentState();
// }

// class _ReceiptsPaymentsComponentState extends State<ReceiptsPaymentsComponent> {
//   List<Receipt> receipts = [];
//   List<Payment> payments = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     final loadedReceipts = await DatabaseHelper.instance.getReceipts();
//     final loadedPayments = await DatabaseHelper.instance.getPayments();
//     setState(() {
//       receipts = loadedReceipts;
//       payments = loadedPayments;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Receipts and Payments')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Expanded(
//               child: Column(
//                 children: [
//                   Text('Receipts', style: Theme.of(context).textTheme.titleLarge),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: receipts.length,
//                       itemBuilder: (context, index) {
//                         return ReceiptCard(receipt: receipts[index]);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Column(
//                 children: [
//                   Text('Payments', style: Theme.of(context).textTheme.titleLarge),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: payments.length,
//                       itemBuilder: (context, index) {
//                         return PaymentCard(payment: payments[index]);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ReceiptCard extends StatelessWidget {
//   final Receipt receipt;

//   const ReceiptCard({Key? key, required this.receipt}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 4.0),
//       child: ListTile(
//         title: Text('Receipt #${receipt.receiptNumber}'),
//         subtitle: Text('Date: ${receipt.date}\nAmount: \$${receipt.amount.toStringAsFixed(2)}'),
//       ),
//     );
//   }
// }

// class PaymentCard extends StatelessWidget {
//   final Payment payment;

//   const PaymentCard({Key? key, required this.payment}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 4.0),
//       child: ListTile(
//         title: Text('Payment #${payment.paymentNumber}'),
//         subtitle: Text('Date: ${payment.date}\nAmount: \$${payment.amount.toStringAsFixed(2)}'),
//       ),
//     );
//   }
// }
