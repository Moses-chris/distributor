import 'package:flutter/material.dart';

import 'analytics/itemsalechart.dart';
import 'analytics/saleschart.dart';
import 'data/databasehelper.dart';

class AnalyticsPage extends StatelessWidget {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<List<SalesData>> fetchSalesData(int days) async {
    return await dbHelper.fetchSalesData(days);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title:const Text('Analytics', 
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          ),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SalesLineChart(fetchSalesData: fetchSalesData),
              const SizedBox(height: 16),
              ItemQuantitySalesChart(
                fetchItemQuantitySalesData: (int days) => dbHelper.fetchItemQuantitySalesData(days),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
