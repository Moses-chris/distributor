import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' show max;

class SalesLineChart extends StatefulWidget {
  final Future<List<SalesData>> Function(int) fetchSalesData;

  const SalesLineChart({Key? key, required this.fetchSalesData}) : super(key: key);

  @override
  _SalesLineChartState createState() => _SalesLineChartState();
}

class _SalesLineChartState extends State<SalesLineChart> {
  int _selectedTimeRange = 7;
  List<SalesData> _salesData = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await widget.fetchSalesData(_selectedTimeRange);
      setState(() {
        if (data.isEmpty) {
          _error = 'No data available for the selected time range 😕';
          _salesData = [];
        } else {
          _salesData = data;
          _error = null;
        }
      });
      // Debug: Print out the sales data
      print('Sales Data:');
      for (var sale in _salesData) {
        print('Date: ${sale.date}, Sales: ${sale.totalSales}');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch sales data 😞';
        _salesData = [];
      });
      print('Error fetching sales data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the maximum sales value for Y-axis scaling
    final maxSales = _salesData.isEmpty ? 0.0 : _salesData.map((d) => d.totalSales).reduce(max);
    final yAxisMax = maxSales * 1.2; // Add 20% padding to the top

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
                Text(
                  'Sales Overview',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<int>(
                  value: _selectedTimeRange,
                  dropdownColor: Colors.grey[800],
                  style: TextStyle(color: Colors.white),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedTimeRange = newValue;
                        _fetchData();
                      });
                    }
                  },
                  items: [
                    DropdownMenuItem(value: 7, child: Text('Last 7 days')),
                    DropdownMenuItem(value: 30, child: Text('Last 30 days')),
                    DropdownMenuItem(value: 180, child: Text('Last 6 months')),
                    DropdownMenuItem(value: 365, child: Text('Last year')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: _error != null
                  ? Center(
                      child: Text(_error!, style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                    )
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: yAxisMax,
                        clipData: FlClipData.all(), // Clip the chart to prevent drawing outside bounds
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) => Text(
                                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(value),
                                style: TextStyle(color: Colors.white60, fontSize: 10),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 && value.toInt() < _salesData.length) {
                                  return Text(
                                    DateFormat('M/d').format(_salesData[value.toInt()].date),
                                    style: TextStyle(color: Colors.white60, fontSize: 10),
                                  );
                                }
                                return Text('');
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _salesData.asMap().entries.map((entry) {
                              // Debug: Print out each data point
                              print('Data point: x=${entry.key}, y=${entry.value.totalSales}');
                              return FlSpot(entry.key.toDouble(), max(0, entry.value.totalSales));
                            }).toList(),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class SalesData {
  final DateTime date;
  final double totalSales;

  SalesData(this.date, this.totalSales);
}