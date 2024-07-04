import 'package:flutter/material.dart';

class SalesSummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;
  final Color color;

  SalesSummaryCard({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      child: SizedBox(
        width: 180,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pie_chart, color: color),
              SizedBox(height: 8.0),
              Text(
                title,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 4.0),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
              SizedBox(height: 8.0),
              Text(
                amount.toStringAsFixed(2),
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
