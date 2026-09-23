import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../core/constants/app_colors.dart';
import 'dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        // Single top-level Obx — all reactive reads happen here.
        // No nested Obx widgets anywhere below this point.
        child: Obx(() {
          final isLoading   = controller.isLoading.value;
          final total       = controller.totalScans.value;
          final premium     = controller.premiumCount.value;
          final longberry   = controller.longberryCount.value;
          final peaberry    = controller.peaberryCount.value;
          final defect      = controller.defectCount.value;
          final ood         = controller.oodCount.value;
          final avgConf     = controller.avgConfidence.value;
          final lastDate    = controller.lastScanDate.value;
          final topClass    = controller.topClass;
          final qualityPct  = controller.qualityPercentage;
          final defectPct   = controller.defectPercentage;

          if (isLoading && total == 0) {
            return const Center(child: CircularProgressIndicator());
          }

          if (total == 0) {
            return _buildEmptyState(context);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildOverviewCards(context, total, avgConf),
              const SizedBox(height: 24),
              _buildClassDistributionSection(
                context, total, premium, longberry, peaberry, defect),
              const SizedBox(height: 24),
              _buildQualityMetricsSection(context, qualityPct, defectPct),
              const SizedBox(height: 24),
              _buildInsightsSection(
                context, topClass, ood, lastDate),
            ],
          );
        }),
      ),
    );
  }

  //  Overview cards 

  Widget _buildOverviewCards(
      BuildContext context, int total, double avgConf) {
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            context,
            icon: Icons.coffee,
            label: 'Total Scans',
            value: total.toString(),
            color: AppColors.coffeeBrown,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            context,
            icon: Icons.speed,
            label: 'Avg Confidence',
            value: '${(avgConf * 100).toStringAsFixed(1)}%',
            color: AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  //  Class distribution 

  Widget _buildClassDistributionSection(
    BuildContext context,
    int total,
    int premium,
    int longberry,
    int peaberry,
    int defect,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Class Distribution',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: total == 0
                      ? const Center(child: Text('No data'))
                      : CustomPaint(
                          size: const Size(200, 200),
                          painter: _PieChartPainter(
                            premiumCount: premium,
                            longberryCount: longberry,
                            peaberryCount: peaberry,
                            defectCount: defect,
                            total: total,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                _buildLegendItem('Premium',  premium,  total, AppColors.premium),
                const SizedBox(height: 8),
                _buildLegendItem('Longberry', longberry, total, AppColors.longberry),
                const SizedBox(height: 8),
                _buildLegendItem('Peaberry', peaberry, total, AppColors.peaberry),
                const SizedBox(height: 8),
                _buildLegendItem('Defect',   defect,   total, AppColors.defect),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(
      String label, int count, int total, Color color) {
    // All values passed as plain ints — no .value reads here.
    final pct = total > 0
        ? (count / total * 100).toStringAsFixed(1)
        : '0.0';
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        Text(
          '$count ($pct%)',
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray),
        ),
      ],
    );
  }

  //  Quality metrics 

  Widget _buildQualityMetricsSection(
      BuildContext context, double qualityPct, double defectPct) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quality Metrics',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                label: 'Quality Beans',
                value: '${qualityPct.toStringAsFixed(1)}%',
                icon: Icons.verified,
                color: AppColors.success,
                subtitle: 'Premium + Longberry + Peaberry',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                label: 'Defects',
                value: '${defectPct.toStringAsFixed(1)}%',
                icon: Icons.warning_amber_rounded,
                color: AppColors.warning,
                subtitle: 'Defective beans detected',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(label, style: theme.textTheme.titleSmall),
            ]),
            const SizedBox(height: 12),
            Text(value,
                style: theme.textTheme.headlineSmall?.copyWith(
                    color: color, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  //   Insights ────────────────────────────────────────────────────────────────

  Widget _buildInsightsSection(BuildContext context, String topClass,
      int oodCount, DateTime? lastDate) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Insights',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildInsightCard(context,
            icon: Icons.trending_up,
            title: 'Top Class',
            value: topClass,
            color: AppColors.premium),
        if (oodCount > 0) ...[
          const SizedBox(height: 12),
          _buildInsightCard(context,
              icon: Icons.help_outline,
              title: 'Out of Distribution',
              value: '$oodCount scans',
              color: AppColors.ood),
        ],
        if (lastDate != null) ...[
          const SizedBox(height: 12),
          _buildInsightCard(context,
              icon: Icons.schedule,
              title: 'Last Scan',
              value: _formatLastScanDate(lastDate),
              color: AppColors.info),
        ],
      ],
    );
  }

  Widget _buildInsightCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(value,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  Empty state 

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard_outlined,
                size: 64, color: AppColors.gray.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No data yet',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: AppColors.darkGray)),
            const SizedBox(height: 8),
            Text(
              'Scan some coffee beans to see your dashboard statistics',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  //   Helpers 

  String _formatLastScanDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today at ${DateFormat('HH:mm').format(date)}';
    if (diff.inDays == 1) return 'Yesterday at ${DateFormat('HH:mm').format(date)}';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('MMM d, yyyy').format(date);
  }
}

//  Pie chart painter 

class _PieChartPainter extends CustomPainter {
  final int premiumCount;
  final int longberryCount;
  final int peaberryCount;
  final int defectCount;
  final int total;

  _PieChartPainter({
    required this.premiumCount,
    required this.longberryCount,
    required this.peaberryCount,
    required this.defectCount,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    double startAngle = -math.pi / 2;

    void drawSlice(int count, Color color) {
      if (count <= 0) return;
      final sweep = (count / total) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
      startAngle += sweep;
    }

    drawSlice(premiumCount,  AppColors.premium);
    drawSlice(longberryCount, AppColors.longberry);
    drawSlice(peaberryCount, AppColors.peaberry);
    drawSlice(defectCount,   AppColors.defect);

    // Donut hole
    canvas.drawCircle(
      center,
      radius * 0.5,
      Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_PieChartPainter old) =>
      premiumCount  != old.premiumCount  ||
      longberryCount != old.longberryCount ||
      peaberryCount != old.peaberryCount ||
      defectCount   != old.defectCount   ||
      total         != old.total;
}
