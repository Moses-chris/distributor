import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'data/models/ordermodel.dart';
import 'data/databasehelper.dart';

class RecentOrdersComponent extends StatelessWidget {
  final List<Order> orders;
  final VoidCallback onNewOrder;
  final Function(Order) onOrderTap;

  const RecentOrdersComponent({
    Key? key,
    required this.orders,
    required this.onNewOrder,
    required this.onOrderTap,
  }) : super(key: key);

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context, int orderId, int index) {
    return showDialog<bool>(
      context: context,
   builder: (BuildContext context) {
  return AlertDialog(
    backgroundColor: Colors.grey[850],
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Text(
      'Delete Order',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    content: Text(
      'Are you sure you want to delete this order?',
      style: TextStyle(color: Colors.white70),
    ),
    actions: <Widget>[
      TextButton(
        child: Text(
          'Cancel',
          style: TextStyle(color: Colors.grey[400]),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          Navigator.of(context).pop(false); // Return false
        },
      ),
      ElevatedButton(
        child: Text(
          'Delete',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () async {
          await DatabaseHelper.instance.deleteOrder(orderId);
          orders.removeAt(index);
          Navigator.of(context).pop(true); // Return true
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order #$orderId deleted'),
              backgroundColor: Colors.red[700],
              ),
            );
          },
        ),
      ],
    );
  },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      height: 400,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
             const Text(
                'Recent Orders',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: onNewOrder,
                child: const Text('+ Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(orders[index].id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await _showDeleteConfirmationDialog(
                        context, orders[index].id!, index);
                  },
                  onDismissed: (direction) {
                    // The order will be deleted in the dialog, so no need to do anything here
                  },
                  child: OrderCard(
                    order: orders[index],
                    onTap: () => onOrderTap(orders[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd/MM').format(order.deliveryDate);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:const Color.fromARGB(255, 31, 97, 33),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.bakerName,
                  style:const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status,
                    style: const TextStyle(color: Colors.black,)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${order.id}', style: TextStyle(color: Colors.amber),),
                // Text('Delivery ${order.deliveryDate}', style: TextStyle(color: Colors.amber, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.amber, fontSize: 16),
                ),
                Text('Delivery $formattedDate', style: TextStyle(color: Colors.amber, fontSize: 16)),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'delivered':
        return Colors.purple;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
