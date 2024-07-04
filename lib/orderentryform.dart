import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'data/databasehelper.dart';
import 'data/orderitem.dart';
import 'data/models/ordermodel.dart';

class OrderEntryForm extends StatefulWidget {
  final List<String> companies;
  final List<MenuItem> menuItems;

  const OrderEntryForm({
    Key? key,
    required this.companies,
    required this.menuItems,
  }) : super(key: key);

  @override
  State<OrderEntryForm> createState() => _OrderEntryFormState();
}

class _OrderEntryFormState extends State<OrderEntryForm> {
  late String selectedCompany;
  late DateTime selectedDate;
  late List<OrderItem> orderItems;
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    selectedCompany = widget.companies.first;
    selectedDate = DateTime.now();
    orderItems = widget.menuItems
        .map((item) => OrderItem(
              id: null,
              orderId: 0,
              itemName: item.name,
              quantity: 0,
              price: item.price,
            ))
        .toList();
    controllers = orderItems
        .map((item) => TextEditingController(text: item.quantity.toString()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xFF0E050F),
      appBar: AppBar(
        title: const Text('Order Entry', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF170B3B),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            _buildItemTable(),
            SizedBox(height: 20),
            _buildTotal(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _placeOrder,
              child: const Text('Place Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: selectedCompany,
            items: widget.companies
                .map((company) => DropdownMenuItem(
                      value: company,
                      child: Text(company, style: TextStyle(color: Colors.white)),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedCompany = value!;
              });
            },
            dropdownColor: Colors.grey[800],
            style: TextStyle(color: Colors.white),
            underline: SizedBox(),
          ),
        ),
        TextButton(
          onPressed: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                      surface: Colors.grey[850]!,
                      onSurface: Colors.white,
                    ),
                    dialogBackgroundColor: Colors.grey[900],
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              setState(() {
                selectedDate = pickedDate;
              });
            }
          },
          child: Text(
            DateFormat('dd/MM/yyyy').format(selectedDate),
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildItemTable() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
            },
            border: TableBorder.all(color: Colors.grey[700]!),
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[800]),
                children: [
                  TableCell(child: Center(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ))),
                  TableCell(child: Center(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Quantity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ))),
                  TableCell(child: Center(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ))),
                ],
              ),
              ...orderItems.asMap().entries.map((entry) {
                final index = entry.key;
                final orderItem = entry.value;
                final controller = controllers[index];
                return _buildItemRow(orderItem, controller, index);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildItemRow(OrderItem orderItem, TextEditingController controller, int index) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(orderItem.itemName, style: TextStyle(color: Colors.white)),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 50,
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[600]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                      fillColor: Colors.grey[700],
                      filled: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        orderItem.quantity = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            orderItem.quantity = (orderItem.quantity + 1).clamp(0, 999);
                            controller.text = orderItem.quantity.toString();
                          });
                        },
                        child: Container(
                          height: 25,
                          width: 25,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[600]!),
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey[700],
                          ),
                          child: Icon(Icons.add, size: 18, color: Colors.white),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            orderItem.quantity = (orderItem.quantity - 1).clamp(0, 999);
                            controller.text = orderItem.quantity.toString();
                          });
                        },
                        child: Container(
                          height: 25,
                          width: 25,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[600]!),
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey[700],
                          ),
                          child: Icon(Icons.remove, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        TableCell(
          child: Center(
            child: Text(
              '\$${(orderItem.quantity * orderItem.price).toStringAsFixed(2)}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotal() {
    final totalQuantity = orderItems.fold(0, (sum, item) => sum + item.quantity);
    final totalAmount = orderItems.fold(
      0.0,
      (sum, item) => sum + (item.quantity * item.price),
    );

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total Quantity: $totalQuantity', style: TextStyle(color: Colors.white, fontSize: 16)),
          Text('Total Amount: \$${totalAmount.toStringAsFixed(2)}', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _placeOrder() async {
    final totalAmount = orderItems.fold(
      0.0,
      (sum, item) => sum + (item.quantity * item.price),
    );

    final newOrder = Order(
      id: null,
      bakerName: selectedCompany,
      status: 'Received',
      deliveryDate: selectedDate,
      totalAmount: totalAmount,
    );

    final orderId = await DatabaseHelper.instance.insertOrder(newOrder);
    if (orderId != 0) {
      for (var item in orderItems) {
        if (item.quantity > 0) {
          await DatabaseHelper.instance.insertOrderItem(OrderItem(
            id: null,
            orderId: orderId,
            itemName: item.itemName,
            quantity: item.quantity,
            price: item.price,
          ));
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class MenuItem {
  final String name;
  final double price;

  MenuItem({required this.name, required this.price});
}