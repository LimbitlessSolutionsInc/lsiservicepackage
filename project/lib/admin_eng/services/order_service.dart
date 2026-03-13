import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../models/data.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  List<NewOrder> _orders = [];
  List<NewOrder> get orders => _orders;

  // The key used to store data in the browser/phone storage
  static const String _storageKey = 'user_orders_data';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // check if already saved data in the browser
    final String? savedJson = prefs.getString(_storageKey);

    if (savedJson != null && savedJson.isNotEmpty) {
      // Load the existing saved data
      final List<dynamic> jsonList = jsonDecode(savedJson);
      _orders = jsonList.map((e) => NewOrder.fromJson(e)).toList();
    } else {
      // first time run: Load the default data from your assets
      try {
        final String assetData = await rootBundle.loadString('assets/data.json');
        final List<dynamic> jsonList = jsonDecode(assetData);
        _orders = jsonList.map((e) => NewOrder.fromJson(e)).toList();
        
        // Save the asset data to SharedPreferences immediately so it's "local"
        await _saveToDisk();
      } catch (e) {
        print("ERROR loading asset: $e");
        _orders = []; // Fallback if asset is missing
      }
    }
  }

  Future<void> addOrder(NewOrder newOrder) async {
    _orders.add(newOrder);
    await _saveToDisk(); // Triggers the save
  }

  // This replaces all the file/directory logic
  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    
    // convert list of objects to a single JSON String
    final String jsonString = jsonEncode(_orders.map((o) => o.toJson()).toList());
    
    // save the string to the browser's local storage
    await prefs.setString(_storageKey, jsonString);
  }

  Future<void> updateOrder(NewOrder updatedOrder) async {
    int index = _orders.indexWhere((o) => o.orderNumber == updatedOrder.orderNumber);
    
    if (index != -1) {
      _orders[index] = updatedOrder;
      await _saveToDisk(); // saves the updated list
    }
  }

  Future<void> deleteOrder(String orderNumber) async {
    _orders.removeWhere((o) => o.orderNumber == orderNumber);
    await _saveToDisk(); // saves the updated list
  }
}