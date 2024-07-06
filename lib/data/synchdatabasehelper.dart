import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logging/logging.dart';
// import 'package:sqflite/sqlite_api.dart';
import 'databasehelper.dart';
import 'models/ordermodel.dart';

class DataSyncService {
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  
  late final DatabaseHelper _dbHelper;
  final Logger _logger = Logger('DataSyncService');
  final String serverUrl = 'https://6bc6-35-195-141-44.ngrok-free.app'; // Update with your server URL

  bool _debugMode = true;

  DataSyncService._internal();

  void initialize(DatabaseHelper dbHelper) {
    _dbHelper = dbHelper;
    _initializeLogging();
  }

  void _initializeLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  void setDebugMode(bool enabled) {
    _debugMode = enabled;
  }

  Future<bool> isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> syncData() async {
    if (await isOnline()) {
      await _syncOrders();
    } else {
      _logger.warning('Device is offline. Sync aborted.');
    }
  }

  Future<void> _syncOrders() async {
    try {
      final db = await _dbHelper.database;
      
      // Upload local changes
      final List<Map<String, dynamic>> unsyncedOrders = await db.query(
        'orders',
        where: 'isSynced = ?',
        whereArgs: [0]
      );
      
      _logger.info('Syncing ${unsyncedOrders.length} unsynced local orders');
      
      for (var orderMap in unsyncedOrders) {
        Order localOrder = Order.fromMap(orderMap);
        await _syncOrderToServer(localOrder);
      }

      // Fetch updates from server, but don't overwrite local data
      await _fetchOrderUpdatesFromServer();
    } catch (e) {
      _logger.severe('Error syncing orders: $e');
    }
  }

  Future<void> _syncOrderToServer(Order order) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/api/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(order.toMap()),
      );
      if (_debugMode) {
        _logger.fine('Server response for order ${order.uuid}: ${response.body}');
      }
      if (response.statusCode == 201 || response.statusCode == 200) {
        _logger.info('Order synced successfully: ${order.uuid}');
        // Mark the order as synced in the local database
        await _markOrderAsSynced(order.uuid);
      } else {
        _logger.warning('Failed to sync order ${order.uuid}: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error syncing order ${order.uuid}: $e');
    }
  }

  Future<void> _markOrderAsSynced(String uuid) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'orders',
        {'isSynced': 1},
        where: 'uuid = ?',
        whereArgs: [uuid],
      );
      _logger.fine('Marked order $uuid as synced in local database');
    } catch (e) {
      _logger.severe('Error marking order $uuid as synced: $e');
    }
  }

  Future<void> _fetchOrderUpdatesFromServer() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/api/orders'));
      if (response.statusCode == 200) {
        final List serverOrders = json.decode(response.body);
        _logger.info('Received ${serverOrders.length} orders from server');
        final db = await _dbHelper.database;
        for (var serverOrderMap in serverOrders) {
          try {
            Order serverOrder = Order.fromMap(serverOrderMap);
            // Check if the order exists locally
            var localOrder = await db.query('orders', where: 'uuid = ?', whereArgs: [serverOrder.uuid]);
            if (localOrder.isEmpty) {
              // If the order doesn't exist locally, insert it
              await db.insert('orders', {...serverOrder.toMap(), 'isSynced': 1});
              _logger.fine('Inserted new order from server: ${serverOrder.uuid}');
            }
            // If the order exists locally, we don't update it to preserve local changes
          } catch (e) {
            _logger.warning('Error processing server order: $e');
          }
        }
      } else {
        _logger.warning('Failed to fetch order updates: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error fetching order updates: $e');
    }
  }
}