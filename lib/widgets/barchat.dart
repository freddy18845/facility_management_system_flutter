import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatefulWidget {
  const BarChartWidget({Key? key}) : super(key: key);

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
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
      title: 'Incidents Report by Month',
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
      child:    SizedBox(
        height: 260,
        child: BarChart(
          BarChartData(
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const months = [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun'
                    ];
                    return Text(months[value.toInt()]);
                  },
                ),
              ),
            ),
            barGroups: _buildBarGroups(),
          ),
        ),
      ),
    );
  }

  /// Generate bars based on selected year
  List<BarChartGroupData> _buildBarGroups() {
    final data = _yearlyData[_selectedYear]!;

    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index],
            color: Colors.blue,
            width: 18,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });
  }

  Widget _card({required String title, required Widget child ,required Widget leftChild,}) {
    return Container(
      padding: const EdgeInsets.all(14),
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
             leftChild
           ],
         ),
          const SizedBox(height: 12),
          child,
         
        ],
      ),
    );
  }
}
