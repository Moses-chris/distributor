import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' show max;

class ItemQuantitySalesChart extends StatefulWidget {
  final Future<Map<String, List<ItemQuantityData>>> Function(int) fetchItemQuantitySalesData;

  const ItemQuantitySalesChart({Key? key, required this.fetchItemQuantitySalesData}) : super(key: key);

  @override
  _ItemQuantitySalesChartState createState() => _ItemQuantitySalesChartState();
}

class _ItemQuantitySalesChartState extends State<ItemQuantitySalesChart> {
  int _selectedTimeRange = 7;
  Map<String, List<ItemQuantityData>> _itemQuantityData = {};
  String? _error;
  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await widget.fetchItemQuantitySalesData(_selectedTimeRange);
      print('Received data in ItemQuantitySalesChart:');
    data.forEach((itemName, dataList) {
      print('Item: $itemName');
      for (var data in dataList) {
        print('  Date: ${data.date}, Quantity: ${data.quantity}');
      }
    });
      setState(() {
        if (data.isEmpty) {
          _error = 'No data available for the selected time range 😕';
          _itemQuantityData = {};
        } else {
          _itemQuantityData = data;
          _error = null;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch item quantity data 😞';
        _itemQuantityData = {};
      });
      print('Error fetching item quantity data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Item Quantity Sales',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<int>(
                  value: _selectedTimeRange,
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedTimeRange = newValue;
                        _fetchData();
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 7, child: Text('Last 7 days')),
                    DropdownMenuItem(value: 30, child: Text('Last 30 days')),
                    DropdownMenuItem(value: 180, child: Text('Last 6 months')),
                    DropdownMenuItem(value: 365, child: Text('Last year')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _error != null
                  ? Center(
                      child: Text(_error!, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                    )
                  : _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_itemQuantityData.isEmpty) {
      return const Center(child: Text('No data available', style: TextStyle(color: Colors.white70)));
    }

    final maxQuantity = _itemQuantityData.values
        .expand((list) => list)
        .map((data) => data.quantity)
        .reduce(max)
        .toDouble();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxQuantity * 1.2,
        clipData: const FlClipData.all(),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.white60, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final itemData = _itemQuantityData.values.first;
                if (value.toInt() >= 0 && value.toInt() < itemData.length) {
                  return Text(
                    DateFormat('M/d').format(itemData[value.toInt()].date),
                    style: const TextStyle(color: Colors.white60, fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: _getLineBarsData(),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // tooltipStyle: FlTooltipStyle(
            //   backgroundColor: Colors.blueGrey.withOpacity(0.8),
            // ),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final itemName = _itemQuantityData.keys.elementAt(touchedSpot.barIndex);
                return LineTooltipItem(
                  '$itemName: ${touchedSpot.y.toInt()}',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> _getLineBarsData() {
    return _itemQuantityData.entries.map((entry) {
      final index = _itemQuantityData.keys.toList().indexOf(entry.key);
      final data = entry.value;
      return LineChartBarData(
        spots: data.asMap().entries.map((dataEntry) {
          return FlSpot(dataEntry.key.toDouble(), dataEntry.value.quantity.toDouble());
        }).toList(),
        isCurved: true,
        color: _colors[index % _colors.length],
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      );
    }).toList();
  }
}

class ItemQuantityData {
  final DateTime date;
  final int quantity;

  ItemQuantityData(this.date, this.quantity);
}