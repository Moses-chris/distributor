import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/authentication/authentication.dart';
import 'data/authentication/login_page.dart';
import 'data/databasehelper.dart';
import 'data/models/ordermodel.dart';
import 'orderdetail.dart';
import 'orderentryform.dart';
import 'profile.dart';
import 'receiptpayments.dart';
import 'recentorders.dart';
import 'summary.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Order> orders = [];
  double todayTotalAmount = 0.0;
  AuthService _authService = AuthService();

  final List<String> companies = ['Pejoma Bakers', 'Other Bakery'];
  final List<MenuItem> menuItems = [
    MenuItem(name: 'Bread -200gm', price: 25.50),
    MenuItem(name: 'Bread -400gm', price: 50.00),
    MenuItem(name: 'Bandika', price: 45.00),
    MenuItem(name: 'Scones', price: 45.50),
    MenuItem(name: 'Sweet cake', price: 45.00),
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _loadTodayTotalAmount();
  }

  Future<void> _loadOrders() async {
    final loadedOrders = await DatabaseHelper.instance.getRecentOrders();
    setState(() {
      orders = loadedOrders;
    });
  }

  Future<void> _loadTodayTotalAmount() async {
    final todayOrders = await DatabaseHelper.instance.getTodayOrders();
    double total = todayOrders.fold(0, (sum, order) => sum + order.totalAmount);
    setState(() {
      todayTotalAmount = total;
    });
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      // Clear any stored user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Navigate to login screen and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage(toggleView: () {})),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error during logout: $e');
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(160, 19, 10, 10),
        title: const Text(
          'Recent Orders',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: Colors.black87,
        child: Column(
          children: [
            const DrawerHeader(
                child: Icon(Icons.favorite, color: Colors.white)),
            ListTile(
              title: const Text(
                'Home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final name = prefs.getString('name') ?? 'Unknown';
                final phone = prefs.getString('phone') ?? 'Unknown';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserProfilePage(name: name, phone: phone),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SalesSummaryCard(
                      title: "Today's Order",
                      subtitle: "Total order made today",
                      amount: todayTotalAmount,
                      color: Colors.green,
                    ),
                    SalesSummaryCard(
                      title: " Balance",
                      subtitle: "Total balance",
                      amount: todayTotalAmount,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                width: 300,
                child: ElevatedButton(onPressed: (){}, 
                child: Text('Pay with M-pesa', style: TextStyle(color: Colors.white, fontSize: 20)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[500]),
                ),
              ),
              RecentOrdersComponent(
                orders: orders,
                onNewOrder: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderEntryForm(
                        companies: companies,
                        menuItems: menuItems,
                      ),
                    ),
                  );
                  if (result == true) {
                    await _loadOrders();
                    await _loadTodayTotalAmount();
                  }
                },
                onOrderTap: (order) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsPage(order: order),
                    ),
                  );
                },
              ),
              ReceiptsPaymentsComponent()
            ],
          ),
        ),
      ),
    );
  }
}