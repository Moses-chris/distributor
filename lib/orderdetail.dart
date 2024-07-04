import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'data/databasehelper.dart';
import 'data/models/ordermodel.dart';
import 'data/orderitem.dart';

class OrderDetailsPage extends StatefulWidget {
  final Order order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  List<OrderItem> orderItems = [];

  @override
  void initState() {
    super.initState();
    _loadOrderItems();
  }

  Future<void> _loadOrderItems() async {
    final items = await DatabaseHelper.instance.getOrderItems(widget.order.id!);
    setState(() {
      orderItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Order #${widget.order.id} Details'),
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            const Text(
              'Order Items',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _buildOrderItemsList(),
            ),
            const SizedBox(height: 16),
            _buildTotalAmount(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.grey[850],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Baker', widget.order.bakerName),
            const SizedBox(height: 8),
            _buildInfoRow('Status', widget.order.status),
            const SizedBox(height: 8),
            _buildInfoRow('Delivery Date', DateFormat('dd/MM/yyyy').format(widget.order.deliveryDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemsList() {
    return Card(
      color: Colors.grey[850],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        itemCount: orderItems.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey[700], height: 1),
        itemBuilder: (context, index) {
          final item = orderItems[index];
          return ListTile(
            title: Text(
              item.itemName,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Quantity: ${item.quantity}',
              style: TextStyle(color: Colors.grey[400]),
            ),
            trailing: Text(
              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
              style: TextStyle(color: Colors.green[300], fontSize: 16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalAmount() {
    return Card(
      color: Colors.blue,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Amount',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '\$${widget.order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}