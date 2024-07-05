import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import '../analytics/saleschart.dart';
import '../analytics/itemsalechart.dart';
import 'models/receiptpayment.dart';
import 'orderitem.dart';
import 'models/ordermodel.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;
  static final Logger _logger = Logger('DatabaseHelper');

  static final DateFormat _dbDateFormat = DateFormat('yyyy-MM-dd');
  static final List<DateFormat> _readDateFormats = [
    DateFormat('yyyy-MM-dd'),
    DateFormat('dd/MM/yyyy'),
    DateFormat('dd-MM-yyyy'),
    DateFormat('dd/MM'),
    DateFormat('dd-MM'),
  ];

  String? _currentUserPhone;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pos_database.db');
    return _database!;
  }

  Future<Database> getDatabaseForUser(String phone) async {
    _currentUserPhone = phone;
    return await database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 6, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
     CREATE TABLE orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE,
        serverId TEXT,
        userPhone TEXT,
        bakerName TEXT,
        status TEXT,
        deliveryDate TEXT,
        totalAmount REAL,
        isSynced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER,
        itemName TEXT,
        quantity INTEGER,
        price REAL,
        FOREIGN KEY (orderId) REFERENCES orders (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE receipts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER,
        amount REAL,
        date TEXT,
        FOREIGN KEY (orderId) REFERENCES orders (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER,
        amount REAL,
        date TEXT,
        FOREIGN KEY (orderId) REFERENCES orders (id)
      )
    ''');
  }

 Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 4) {
    await db.execute('ALTER TABLE orders ADD COLUMN userPhone TEXT');
  }
  if (oldVersion < 5) {
    await db.execute('ALTER TABLE orders ADD COLUMN serverId TEXT');
  }
  if (oldVersion < 6) {
    // Create a temporary table with the new schema
    await db.execute('''
      CREATE TABLE orders_temp (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE,
        serverId TEXT,
        userPhone TEXT,
        bakerName TEXT,
        status TEXT,
        deliveryDate TEXT,
        totalAmount REAL,
        isSynced INTEGER DEFAULT 0
      )
    ''');

    // Copy data from the old table to the new one, generating UUIDs for existing records
    await db.execute('''
      INSERT INTO orders_temp (id, serverId, userPhone, bakerName, status, deliveryDate, totalAmount, isSynced, uuid)
      SELECT 
        id, 
        serverId, 
        userPhone, 
        bakerName, 
        status, 
        deliveryDate, 
        totalAmount, 
        isSynced, 
        lower(hex(id || randomblob(4))) || '-' || 
        lower(hex(randomblob(2))) || '-4' || 
        substr(lower(hex(randomblob(2))),2) || '-' || 
        substr('89ab',abs(random()) % 4 + 1, 1) || 
        substr(lower(hex(randomblob(2))),2) || '-' || 
        lower(hex(randomblob(6)))
      FROM orders
    ''');

    // Drop the old table
    await db.execute('DROP TABLE orders');

    // Rename the new table to the original name
    await db.execute('ALTER TABLE orders_temp RENAME TO orders');

    // Create an index on the uuid column for better query performance
    await db.execute('CREATE INDEX idx_orders_uuid ON orders (uuid)');
    }
  } 
 
  Future<void> closeDatabase() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }

  Future<void> setCurrentUser(String phone) async {
    _currentUserPhone = phone;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', phone);
  }

  Future<String?> getCurrentUser() async {
    if (_currentUserPhone != null) return _currentUserPhone;
    final prefs = await SharedPreferences.getInstance();
    _currentUserPhone = prefs.getString('current_user');
    return _currentUserPhone;
  }

  // Future<int> insertOrder(Order order) async {
  //   final db = await instance.database;
  //   final formattedDate = _dbDateFormat.format(order.deliveryDate);
  //   final orderMap = order.toMap()
  //     ..['deliveryDate'] = formattedDate
  //     ..['userPhone'] = _currentUserPhone;
  //   return await db.insert('orders', orderMap);
  // }
  Future<int> insertOrder(Order order) async {
  final db = await database;
  
  // Check if the UUID already exists
  final List<Map<String, dynamic>> result = await db.query(
    'orders',
    where: 'uuid = ?',
    whereArgs: [order.uuid],
  );

  if (result.isNotEmpty) {
    // UUID already exists, generate a new one
    order.uuid = Uuid().v4();
  }

  final orderMap = order.toMap()
    ..['userPhone'] = _currentUserPhone;
  return await db.insert('orders', orderMap);
}
   Future<void> updateOrder(Order order) async {
    final db = await database;
    await db.update(
      'orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> insertOrderItem(OrderItem item) async {
    final db = await instance.database;
    return await db.insert('order_items', item.toMap());
  }

  Future<List<OrderItem>> getOrderItems(int orderId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'order_items',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
    return List.generate(maps.length, (i) => OrderItem.fromMap(maps[i]));
  }

  Future<void> deleteOrder(int orderId) async {
    final db = await instance.database;
    await db.delete('order_items', where: 'orderId = ?', whereArgs: [orderId]);
    await db.delete('orders', where: 'id = ? AND userPhone = ?', whereArgs: [orderId, _currentUserPhone]);
  }

  Future<List<Receipt>> getReceipts() async {
    final db = await instance.database;
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT r.*
        FROM receipts r
        JOIN orders o ON r.orderId = o.id
        WHERE o.userPhone = ?
        ORDER BY r.id DESC
      ''', [_currentUserPhone]);
      return List.generate(maps.length, (i) => Receipt.fromMap(maps[i]));
    } catch (e) {
      _logger.warning('Error fetching receipts: $e');
      return [];
    }
  }

  Future<List<Payment>> getPayments() async {
    final db = await instance.database;
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT p.*
        FROM payments p
        JOIN orders o ON p.orderId = o.id
        WHERE o.userPhone = ?
        ORDER BY p.id DESC
      ''', [_currentUserPhone]);
      return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
    } catch (e) {
      _logger.warning('Error fetching payments: $e');
      return [];
    }
  }

  Future<List<Order>> getRecentOrders() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'userPhone = ?',
      whereArgs: [_currentUserPhone],
      orderBy: 'id DESC',
      limit: 10
    );
    _logger.info('Recent orders: ${maps.length}');
    return List.generate(maps.length, (i) => _parseOrderFromMap(maps[i]));
  }

  Future<List<Order>> getTodayOrders() async {
    final db = await instance.database;
    final now = DateTime.now();
    final today = _dbDateFormat.format(now);

    _logger.info('Fetching orders for date: $today');

    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'deliveryDate = ? AND userPhone = ?',
      whereArgs: [today, _currentUserPhone],
    );
    
    _logger.info('Found ${maps.length} orders for today');
    return List.generate(maps.length, (i) => _parseOrderFromMap(maps[i]));
  }

  Future<void> insertTestOrderForToday() async {
    final db = await instance.database;
    final now = DateTime.now();
    final todayFormatted = _dbDateFormat.format(now);
    
    await db.insert('orders', {
      'bakerName': 'Test Baker',
      'status': 'Pending',
      'deliveryDate': todayFormatted,
      'totalAmount': 100.0,
      'userPhone': _currentUserPhone,
    });
    
    _logger.info('Inserted test order for today: $todayFormatted');
  }

  DateTime _parseDate(String dateString) {
    for (var format in _readDateFormats) {
      try {
        return format.parse(dateString);
      } catch (_) {
        // If parsing fails, try the next format
      }
    }
    _logger.warning('Failed to parse date: $dateString');
    return DateTime.now();
  }

  Order _parseOrderFromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      bakerName: map['bakerName'],
      status: map['status'],
      deliveryDate: _parseDate(map['deliveryDate']),
      totalAmount: map['totalAmount'],
    );
  }

  Future<List<SalesData>> fetchSalesData(int days) async {
    final db = await instance.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final formattedStartDate = _dbDateFormat.format(startDate);
    final formattedEndDate = _dbDateFormat.format(endDate);

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT deliveryDate, SUM(totalAmount) as totalSales
      FROM orders
      WHERE deliveryDate BETWEEN ? AND ? AND userPhone = ?
      GROUP BY deliveryDate
      ORDER BY deliveryDate
    ''', [formattedStartDate, formattedEndDate, _currentUserPhone]);

    final Map<String, double> salesMap = {};
    for (int i = 0; i < days; i++) {
      final date = endDate.subtract(Duration(days: i));
      final formattedDate = _dbDateFormat.format(date);
      salesMap[formattedDate] = 0.0;
    }

    for (var row in result) {
      final date = row['deliveryDate'] as String;
      final sales = row['totalSales'] as double;
      salesMap[date] = sales;
    }

    return salesMap.entries.map((entry) {
      return SalesData(
        _dbDateFormat.parse(entry.key),
        entry.value,
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<Map<String, List<ItemQuantityData>>> fetchItemQuantitySalesData(int days) async {
    final db = await instance.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final formattedStartDate = _dbDateFormat.format(startDate);
    final formattedEndDate = _dbDateFormat.format(endDate);

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT o.deliveryDate, oi.itemName, SUM(oi.quantity) as totalQuantity
      FROM orders o
      JOIN order_items oi ON o.id = oi.orderId
      WHERE o.deliveryDate BETWEEN ? AND ? AND o.userPhone = ?
      GROUP BY o.deliveryDate, oi.itemName
      ORDER BY o.deliveryDate, oi.itemName
    ''', [formattedStartDate, formattedEndDate, _currentUserPhone]);

    _logger.info('Fetched ${result.length} rows of item quantity sales data');

    final Map<String, Map<String, int>> itemQuantityMap = {};

    for (var row in result) {
      final date = row['deliveryDate'] as String;
      final itemName = row['itemName'] as String;
      final quantity = row['totalQuantity'] as int;

      itemQuantityMap.putIfAbsent(itemName, () => {})[date] = quantity;
    }

    final Map<String, List<ItemQuantityData>> finalData = {};
    for (var itemName in itemQuantityMap.keys) {
      finalData[itemName] = [];
      var currentDate = startDate;

      while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
        final formattedDate = _dbDateFormat.format(currentDate);
        final quantity = itemQuantityMap[itemName]![formattedDate] ?? 0;
        finalData[itemName]!.add(ItemQuantityData(currentDate, quantity));
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }

    _logger.info('Processed data for ${finalData.length} items');

    return finalData;
  }
}