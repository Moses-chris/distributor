import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:crypto/crypto.dart';
import '../databasehelper.dart';

class AuthService {
  final String baseUrl = 'https://6bc6-35-195-141-44.ngrok-free.app'; // Replace with your actual API URL
  final String tokenKey = 'auth_token';
  final String userIdKey = 'user_id';
  final String phoneKey = 'phone_number';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  final RegExp _phoneRegex = RegExp(r'^(?:\+254|0)([17]\d{8})$');

  bool isValidPhoneNumber(String phone) {
    return _phoneRegex.hasMatch(phone);
  }

  String formatPhoneNumber(String phone) {
    final match = _phoneRegex.firstMatch(phone);
    if (match != null) {
      return '+254${match.group(1)}';
    }
    return phone;
  }

  Future<Map<String, dynamic>> signIn(String phone, String password) async {
    if (!isValidPhoneNumber(phone)) {
      return {'success': false, 'message': 'Invalid phone number format'};
    }

    phone = formatPhoneNumber(phone);

    try {
      // Check if the user exists in local storage
      final storedHash = await _secureStorage.read(key: phone);
      if (storedHash == null) {
        return {'success': false, 'message': 'User not found. Please register.'};
      }



      // Authenticate user
      final inputHash = sha256.convert(utf8.encode(password)).toString();
      if (inputHash == storedHash) {
        await _databaseHelper.setCurrentUser(phone);
        return {'success': true, 'message': 'Login successful'};
      } else {
        return {'success': false, 'message': 'Invalid password'};
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> register(String name, String phone, String password) async {
    if (!isValidPhoneNumber(phone)) {
      return {'success': false, 'message': 'Invalid phone number format'};
    }

    phone = formatPhoneNumber(phone);

    try {
      // Check if the user already exists
      final storedHash = await _secureStorage.read(key: phone);
      if (storedHash != null) {
        return {'success': false, 'message': 'User already exists. Please login.'};
      }

      // Register the new user
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      await _secureStorage.write(key: phone, value: hashedPassword);
      await _databaseHelper.setCurrentUser(phone);
      
      // Create a new database for the user
      await _databaseHelper.getDatabaseForUser(phone);

      return {'success': true, 'message': 'Registration successful'};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Future<void> signOut() async {
  //   final currentUser = await _databaseHelper.getCurrentUser();
  //   if (currentUser != null) {
  //     await _databaseHelper.closeDatabase(currentUser);
  //   }
  //   await _databaseHelper.setCurrentUser('');
  // }
 Future<void> signOut() async {
    final currentUser = await getCurrentUser();
    if (currentUser != null) {
      await _databaseHelper.closeDatabase();
    }
    await setCurrentUser('');
  }

  Future<void> setCurrentUser(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', phone);
  }

  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_user');
  }

 Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey) != null || prefs.getString(userIdKey) != null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<void> _saveAuthData(String token, String userId, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setString(userIdKey, userId);
    await prefs.setString(phoneKey, phone);
  }

  Future<void> _saveCredentials(String phone, String password) async {
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();
    await _secureStorage.write(key: phone, value: hashedPassword);
  }

  Future<Map<String, dynamic>> _authenticateOffline(String phone, String password) async {
    final storedHash = await _secureStorage.read(key: phone);
    if (storedHash != null) {
      final inputHash = sha256.convert(utf8.encode(password)).toString();
      if (inputHash == storedHash) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(phoneKey, phone);
        return {'success': true, 'message': 'Offline login successful'};
      }
    }
    return {'success': false, 'message': 'Offline authentication failed'};
  }


  Stream<bool> get authStateChanges {
    return Stream.periodic(Duration(seconds: 1)).asyncMap((_) => isAuthenticated());
  }

}