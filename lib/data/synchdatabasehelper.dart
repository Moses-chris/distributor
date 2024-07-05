import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logging/logging.dart';
import 'package:sqflite/sqlite_api.dart';
import 'databasehelper.dart';
import 'models/ordermodel.dart';

class DataSyncService {
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  
  late final DatabaseHelper _dbHelper;
  final Logger _logger = Logger('DataSyncService');
  final String serverUrl = 'https://87b0-35-195-141-44.ngrok-free.app';

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

//   Future<void> _syncOrders() async {
//     try {
//       final db = await _dbHelper.database;
//       final List<Map<String, dynamic>> unsyncedOrders = await db.query(
//         'orders',
//         where: 'isSynced = ?',
//         whereArgs: [0]
//       );
      
//       _logger.info('Syncing ${unsyncedOrders.length} unsynced local orders');
      
//       for (var orderMap in unsyncedOrders) {
//         Order localOrder = Order.fromMap(orderMap);
//         await _syncOrderToServer(localOrder);
//       }

//       await _fetchOrderUpdatesFromServer();
//     } catch (e) {
//       _logger.severe('Error syncing orders: $e');
//     }
//   }

 
//  Future<void> _syncOrderToServer(Order order) async {
//   try {
//     final response = await http.post(
//       Uri.parse('$serverUrl/api/orders'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(order.toMap()),
//     );
//     if (_debugMode) {
//       _logger.fine('Server response for order ${order.id}: ${response.body}');
//     }
//     if (response.statusCode == 201 || response.statusCode == 200) {
//       _logger.info('Order synced successfully: ${order.id}');
//       final serverOrder = Order.fromMap(json.decode(response.body));
//       await _updateLocalOrderWithServerData(order.id!, serverOrder);
//     } else {
//       _logger.warning('Failed to sync order ${order.id}: ${response.body}');
//     }
//   } catch (e) {
//     _logger.severe('Error syncing order ${order.id}: $e');
//   }
// }

// Future<void> _updateLocalOrderWithServerData(int localId, Order serverOrder) async {
//   final db = await _dbHelper.database;
//   await db.update(
//     'orders',
//     {...serverOrder.toMap(), 'isSynced': 1},
//     where: 'id = ?',
//     whereArgs: [localId],
//   );
//   if (_debugMode) {
//     _logger.fine('Updated local order $localId with server data and marked as synced: ${json.encode(serverOrder.toMap())}');
//   }
// }


 
//  Future<void> _fetchOrderUpdatesFromServer() async {
//   try {
//     final response = await http.get(Uri.parse('$serverUrl/api/orders'));
//     if (response.statusCode == 200) {
//       final List serverOrders = json.decode(response.body);
//       _logger.info('Received ${serverOrders.length} orders from server');
//       final db = await _dbHelper.database;
//       for (var serverOrderMap in serverOrders) {
//         Order serverOrder = Order.fromMap(serverOrderMap);
//         await db.insert('orders', {...serverOrder.toMap(), 'isSynced': 1},
//             conflictAlgorithm: ConflictAlgorithm.replace);
//         if (_debugMode) {
//           _logger.fine('Inserted/Updated order from server: ${json.encode(serverOrder.toMap())}');
//         }
//       }
//     } else {
//       _logger.warning('Failed to fetch order updates: ${response.body}');
//     }
//   } catch (e) {
//     _logger.severe('Error fetching order updates: $e');
//   }
// }
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

      // Download server changes
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
        body: json.encode({...order.toMap(), 'uuid': order.uuid}),
      );
      if (_debugMode) {
        _logger.fine('Server response for order ${order.uuid}: ${response.body}');
      }
      if (response.statusCode == 201 || response.statusCode == 200) {
        _logger.info('Order synced successfully: ${order.uuid}');
        final serverOrder = Order.fromMap(json.decode(response.body));
        await _updateLocalOrderWithServerData(order.uuid, serverOrder);
      } else {
        _logger.warning('Failed to sync order ${order.uuid}: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error syncing order ${order.uuid}: $e');
    }
  }

  Future<void> _updateLocalOrderWithServerData(String uuid, Order serverOrder) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'orders',
        {...serverOrder.toMap(), 'isSynced': 1},
        where: 'uuid = ?',
        whereArgs: [uuid],
      );
      if (_debugMode) {
        _logger.fine('Updated local order $uuid with server data and marked as synced: ${json.encode(serverOrder.toMap())}');
      }
    } catch (e) {
      _logger.severe('Error updating local order $uuid: $e');
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
            await db.insert('orders', {...serverOrder.toMap(), 'isSynced': 1},
                conflictAlgorithm: ConflictAlgorithm.replace);
            if (_debugMode) {
              _logger.fine('Inserted/Updated order from server: ${json.encode(serverOrder.toMap())}');
            }
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