import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'bottomnavbar.dart';
import 'data/authentication/authentication.dart';
import 'data/authentication/login_page.dart';
import 'data/authentication/registration_page.dart';
import 'data/databasehelper.dart';
import 'data/synchdatabasehelper.dart';
import 'homepage.dart';
import 'analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   
  Logger.root.level = Level.ALL; // Or another appropriate level
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database; // Ensure the database is initialized

  final dataSyncService = DataSyncService();
  dataSyncService.initialize(dbHelper);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      title: 'Order Management',
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _auth = AuthService();
  bool showSignIn = true;

  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool isAuthenticated = snapshot.data ?? false;
          if (!isAuthenticated) {
            return showSignIn
                ? LoginPage(toggleView: toggleView)
                : RegisterPage(toggleView: toggleView);
          }
          return const MainScreen();
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    AnalyticsPage(),
  ];
  
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _initialSync();
    _startPeriodicSync();
  }

  Future<void> _initialSync() async {
    final dataSyncService = DataSyncService();
    await dataSyncService.syncData();
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (timer) async {
      final dataSyncService = DataSyncService();
      await dataSyncService.syncData();
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Modern3DBottomNavBar(
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}