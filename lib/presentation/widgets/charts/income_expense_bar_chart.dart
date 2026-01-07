import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../theme/app_colors.dart';
import '../../helpers/currency_formatter.dart';

class DailyIncomeExpenseData {
  final DateTime date;
  final double income;
  final double expense;

  DailyIncomeExpenseData({
    required this.date,
    required this.income,
    required this.expense,
  });
}

class IncomeExpenseBarChart extends StatelessWidget {
  final List<DailyIncomeExpenseData> data;
  final String currencyCode;

  const IncomeExpenseBarChart({
    super.key,
    required this.data,
    this.currencyCode = 'VND',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (data.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Chưa có dữ liệu',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final maxY = _calculateMaxY();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7 ngày gần nhất',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              Row(
                children: [
                  _buildLegendItem('Thu', AppColors.income),
                  const SizedBox(width: 12),
                  _buildLegendItem('Chi', AppColors.expense),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) =>
                        isDark ? AppColors.cardDark : Colors.white,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final dayData = data[groupIndex];
                      final isIncome = rodIndex == 0;
                      final amount = isIncome ? dayData.income : dayData.expense;
                      return BarTooltipItem(
                        '${isIncome ? 'Thu' : 'Chi'}: ${CurrencyFormatter.formatCompact(amount)}',
                        TextStyle(
                          color: isIncome ? AppColors.income : AppColors.expense,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) =>
                          _buildBottomTitle(value.toInt(), isDark),
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) =>
                          _buildLeftTitle(value, isDark),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateMaxY() {
    double max = 0;
    for (final d in data) {
      if (d.income > max) max = d.income;
      if (d.expense > max) max = d.expense;
    }
    return max == 0 ? 100000 : max * 1.2;
  }

  List<BarChartGroupData> _buildBarGroups() {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final d = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: d.income,
            color: AppColors.income,
            width: 10,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: d.expense,
            color: AppColors.expense,
            width: 10,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildBottomTitle(int index, bool isDark) {
    if (index >= data.length) return const SizedBox.shrink();

    final weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    final dayOfWeek = data[index].date.weekday % 7;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        weekdays[dayOfWeek],
        style: TextStyle(
          fontSize: 11,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildLeftTitle(double value, bool isDark) {
    return Text(
      CurrencyFormatter.formatCompact(value),
      style: TextStyle(
        fontSize: 10,
        color:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
