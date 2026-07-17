import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';

enum TimeFrame { daily, weekly, monthly }

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  TimeFrame _currentTimeFrame = TimeFrame.monthly;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Analytics',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track revenue, subscription growth, and marketplace monetization',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                _buildTimeFrameToggle(),
              ],
            ),
            const SizedBox(height: 40),
            _buildSectionHeader('Revenue Performance', Icons.account_balance_wallet_rounded),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard('Total Revenue', _getStatValue('total'), Icons.payments_rounded, AppColors.success),
                const SizedBox(width: 20),
                _buildStatCard('Product Sales', _getStatValue('sales'), Icons.shopping_bag_rounded, AppColors.warning),
                const SizedBox(width: 20),
                _buildStatCard('Subscriptions', _getStatValue('subs'), Icons.verified_rounded, AppColors.primary),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Revenue Trend', Icons.show_chart_rounded),
                      const SizedBox(height: 16),
                      _buildMainChart(),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Revenue Source', Icons.pie_chart_rounded),
                      const SizedBox(height: 16),
                      _buildPieChart(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildSectionHeader('Detailed Statistics', Icons.table_chart_rounded),
            const SizedBox(height: 16),
            _buildBreakdownTable(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFrameToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TimeFrame.values.map((tf) {
          final isSelected = _currentTimeFrame == tf;
          return GestureDetector(
            onTap: () => setState(() => _currentTimeFrame = tf),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                tf.toString().split('.').last.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getStatValue(String type) {
    // Mock data based on timeframe
    switch (_currentTimeFrame) {
      case TimeFrame.daily:
        if (type == 'total') return 'QAR 12,400';
        if (type == 'sales') return 'QAR 8,200';
        return 'QAR 4,200';
      case TimeFrame.weekly:
        if (type == 'total') return 'QAR 85,000';
        if (type == 'sales') return 'QAR 55,000';
        return 'QAR 30,000';
      case TimeFrame.monthly:
        if (type == 'total') return 'QAR 340,000';
        if (type == 'sales') return 'QAR 210,000';
        return 'QAR 130,000';
    }
  }

  Widget _buildMainChart() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.divider.withValues(alpha: 0.5),
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _getChartSpots(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getChartSpots() {
    switch (_currentTimeFrame) {
      case TimeFrame.daily:
        return [FlSpot(0, 1), FlSpot(6, 4), FlSpot(12, 3), FlSpot(18, 5), FlSpot(23, 2)];
      case TimeFrame.weekly:
        return [FlSpot(0, 2), FlSpot(1, 3), FlSpot(2, 2.5), FlSpot(3, 4), FlSpot(4, 3.5), FlSpot(5, 5), FlSpot(6, 4.5)];
      case TimeFrame.monthly:
        return [FlSpot(0, 3), FlSpot(2, 2.5), FlSpot(4, 5), FlSpot(6, 3.8), FlSpot(8, 4.2), FlSpot(10, 3.5), FlSpot(12, 7)];
    }
  }

  Widget _buildPieChart() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 60,
                sections: [
                  PieChartSectionData(
                    value: 65,
                    title: '65%',
                    color: AppColors.primary,
                    radius: 25,
                    titleStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                  ),
                  PieChartSectionData(
                    value: 35,
                    title: '35%',
                    color: AppColors.accentGold,
                    radius: 25,
                    titleStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLegendItem('Product Sales', AppColors.primary),
          const SizedBox(height: 12),
          _buildLegendItem('Subscriptions', AppColors.accentGold),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
        const Spacer(),
        Text(
          label == 'Product Sales' ? 'QAR 221k' : 'QAR 119k',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBreakdownTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'REVENUE BREAKDOWN BY CHANNEL',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.primary),
            ),
          ),
          const Divider(height: 1),
          DataTable(
            horizontalMargin: 24,
            columnSpacing: 40,
            headingRowColor: WidgetStateProperty.all(AppColors.background.withValues(alpha: 0.3)),
            columns: [
              DataColumn(label: Text('TIME PERIOD', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('SALES REVENUE', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('SUBSCRIPTIONS', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('TOTAL', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('GROWTH', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
            ],
            rows: [
              _buildDataRow('May 2026', 'QAR 145,000', 'QAR 85,000', 'QAR 230,000', '+12.5%'),
              _buildDataRow('April 2026', 'QAR 132,000', 'QAR 78,000', 'QAR 210,000', '+8.2%'),
              _buildDataRow('March 2026', 'QAR 128,000', 'QAR 72,000', 'QAR 200,000', '+15.1%'),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String period, String sales, String subs, String total, String growth) {
    return DataRow(cells: [
      DataCell(Text(period, style: GoogleFonts.inter(fontWeight: FontWeight.w500))),
      DataCell(Text(sales)),
      DataCell(Text(subs)),
      DataCell(Text(total, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primary))),
      DataCell(Text(growth, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
    ]);
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.accentGold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

