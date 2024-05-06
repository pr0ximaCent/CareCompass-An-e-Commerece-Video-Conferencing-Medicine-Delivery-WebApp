import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:carecompass/features/admin/models/sales.dart';

class CategoryProductsChart extends StatelessWidget {
  final List<Sales> salesData;

  const CategoryProductsChart({Key? key, required this.salesData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: salesData
            .asMap()
            .map((index, sales) => MapEntry(
                index,
                BarChartGroupData(
                  x: index, // Using the index as the x value
                  barRods: [BarChartRodData(toY: sales.earning.toDouble())],
                  // You can add more customization here
                )))
            .values
            .toList(),
        // Further customization: titles, grid, border, etc.
      ),
    );
  }
}
