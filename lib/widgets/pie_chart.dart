import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatefulWidget {
  const PieChartWidget({super.key});

  @override
  _PieChartWidgetState createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  String _selectedYear = '2024';

  final List<String> _years = ['2021', '2022', '2023', '2024'];

  /// Mock data per year (replace with API later)
  final Map<String, List<double>> _yearlyData = {
    '2021': [120, 90, 150, 80, 110, 140],
    '2022': [160, 130, 170, 140, 150, 180],
    '2023': [200, 180, 220, 190, 210, 230],
    '2024': [250, 220, 260, 240, 270, 300],
  };

  @override
  Widget build(BuildContext context) {
    return _card(
      title: 'Expense by Category',
      leftChild: Align(
        alignment: Alignment.centerRight,
        child: DropdownButton<String>(
          value: _selectedYear,
          underline: const SizedBox(),
          items: _years.map((year) {
            return DropdownMenuItem(
              value: year,
              child: Text(year),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedYear = value!;
            });
          },
        ),
      ),
      child: SizedBox(
        height: 260,
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(value: 40, color: Colors.blue, title: 'High'),
              PieChartSectionData(value: 30, color: Colors.orange, title: 'Mid'),
              PieChartSectionData(value: 30, color: Colors.green, title: 'Low'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    required Widget child,
    required Widget leftChild,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 0.8, color: Colors.grey.shade200)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              leftChild,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
