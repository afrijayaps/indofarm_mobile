import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/core/storage/database_factory_initializer.dart';
import 'src/core/theme/app_theme.dart';
import 'src/presentation/common/widgets/custom_text_field.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDatabaseFactory();

  // For the design preview below, swap the next line with:
  // runApp(const DynamicThemePreviewApp());
  runApp(const ProviderScope(child: IndoFarmApp()));
}

class DynamicThemePreviewApp extends StatelessWidget {
  const DynamicThemePreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.dynamicDarkTheme,
      themeMode: ThemeMode.dark,
      home: const _DynamicThemePreviewScreen(),
    );
  }
}

class _DynamicThemePreviewScreen extends StatelessWidget {
  const _DynamicThemePreviewScreen();

  static const _eggTrend = <double>[82, 88, 86, 94, 97, 103, 108];
  static const _feedConsumption = <double>[42, 55, 48, 61, 58, 45, 52];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IndoFarm Dynamic Dark'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: _IconBubble(
              icon: Icons.notifications_none_rounded,
              color: colorScheme.tertiary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            _HeroDashboardCard(colorScheme: colorScheme, textTheme: textTheme),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Input Cepat',
              style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _IconBubble(
                          icon: Icons.smartphone_rounded,
                          color: colorScheme.tertiary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CustomTextField Fokus-Aware',
                                style: textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                'Hint akan hilang saat fokus, sementara styling input tetap mengikuti theme.',
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const CustomTextField(
                      labelText: 'Nomor HP',
                      hintText: '82212345678',
                      prefixText: '+62 ',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Lanjut'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Dashboard Dinamis',
              style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
            ),
            const SizedBox(height: AppSpacing.sm),
            _TrendMetricCard(
              title: 'Produksi Telur',
              subtitle: 'Sparkline mingguan untuk total butir dan ritme panen.',
              value: '1.248 butir',
              changeLabel: '+8.4% dari minggu lalu',
              icon: Icons.egg_alt_outlined,
              accentColor: colorScheme.secondary,
              chart: _SparklineChart(
                points: _eggTrend,
                lineColor: colorScheme.primary,
                fillColor: colorScheme.primary.withValues(alpha: 0.14),
                gridColor: colorScheme.outlineVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _TrendMetricCard(
              title: 'Konsumsi Pakan',
              subtitle: 'Bar chart mini agar beban harian lebih mudah terbaca.',
              value: '361 kg',
              changeLabel: '2 silo masuk ambang restock',
              icon: Icons.inventory_2_outlined,
              accentColor: colorScheme.error,
              chart: _MiniBarChart(
                values: _feedConsumption,
                barColor: colorScheme.primary,
                mutedBarColor: colorScheme.tertiary.withValues(alpha: 0.7),
                alertBarColor: colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                SizedBox(
                  width: 176,
                  child: _SnapshotCard(
                    title: 'Gudang',
                    value: '16 karung',
                    subtitle: 'Stok pakan premium menipis',
                    icon: Icons.warehouse_outlined,
                    color: colorScheme.error,
                  ),
                ),
                SizedBox(
                  width: 176,
                  child: _SnapshotCard(
                    title: 'Kandang Aktif',
                    value: '3 lokasi',
                    subtitle: '2 kandang perform di atas target',
                    icon: Icons.agriculture_outlined,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroDashboardCard extends StatelessWidget {
  const _HeroDashboardCard({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: AppCorners.xl,
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppCorners.xl,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _FarmBackdropPainter(
                    strokeColor: colorScheme.primary.withValues(alpha: 0.18),
                    accentColor: colorScheme.tertiary.withValues(alpha: 0.20),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _IconBubble(
                        icon: Icons.agriculture_outlined,
                        color: colorScheme.primary,
                        backgroundColor: colorScheme.primary.withValues(
                          alpha: 0.14,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat datang, Pak Budi',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Pantau produksi, pakan, dan pergerakan gudang dari satu dashboard yang lebih hidup.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      _HeroStatPill(
                        icon: Icons.egg_alt_outlined,
                        label: 'Panen Hari Ini',
                        value: '184 butir',
                        color: colorScheme.primary,
                      ),
                      _HeroStatPill(
                        icon: Icons.grass_outlined,
                        label: 'Konsumsi Pakan',
                        value: '52 kg',
                        color: colorScheme.secondary,
                      ),
                      _HeroStatPill(
                        icon: Icons.warehouse_outlined,
                        label: 'Gudang Aktif',
                        value: '2 lokasi',
                        color: colorScheme.tertiary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendMetricCard extends StatelessWidget {
  const _TrendMetricCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.changeLabel,
    required this.icon,
    required this.accentColor,
    required this.chart,
  });

  final String title;
  final String subtitle;
  final String value;
  final String changeLabel;
  final IconData icon;
  final Color accentColor;
  final Widget chart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _IconBubble(icon: icon, color: accentColor),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(subtitle, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    changeLabel,
                    style: textTheme.labelMedium?.copyWith(color: accentColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(value, style: textTheme.displayMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Visual diprioritaskan untuk membaca arah data, bukan hanya angka statis.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(width: 132, height: 92, child: chart),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  const _SnapshotCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBubble(icon: icon, color: color),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _HeroStatPill extends StatelessWidget {
  const _HeroStatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconBubble(
            icon: icon,
            color: color,
            size: AppIconSize.sm,
            backgroundColor: color.withValues(alpha: 0.12),
          ),
          const SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.labelSmall),
              Text(
                value,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.icon,
    required this.color,
    this.size = AppIconSize.md,
    this.backgroundColor,
  });

  final IconData icon;
  final Color color;
  final double size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Icon(icon, size: size, color: color),
    );
  }
}

class _SparklineChart extends StatelessWidget {
  const _SparklineChart({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
  });

  final List<double> points;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(
        points: points,
        lineColor: lineColor,
        fillColor: fillColor,
        gridColor: gridColor,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
  });

  final List<double> points;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    final minPoint = points.reduce(math.min);
    final maxPoint = points.reduce(math.max);
    final range = math.max(maxPoint - minPoint, 1);
    final stepX = size.width / (points.length - 1);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 1; i <= 2; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePath = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final normalizedY = (points[i] - minPoint) / range;
      final x = stepX * i;
      final y = size.height - (normalizedY * (size.height - 8)) - 4;
      final point = Offset(x, y);

      if (i == 0) {
        linePath.moveTo(point.dx, point.dy);
        fillPath
          ..moveTo(point.dx, size.height)
          ..lineTo(point.dx, point.dy);
      } else {
        linePath.lineTo(point.dx, point.dy);
        fillPath.lineTo(point.dx, point.dy);
      }
    }

    fillPath
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart({
    required this.values,
    required this.barColor,
    required this.mutedBarColor,
    required this.alertBarColor,
  });

  final List<double> values;
  final Color barColor;
  final Color mutedBarColor;
  final Color alertBarColor;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.reduce(math.max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (index) {
        final value = values[index];
        final isAlert = index == values.length - 2;
        final color = isAlert
            ? alertBarColor
            : index.isEven
            ? barColor
            : mutedBarColor;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == values.length - 1 ? 0 : AppSpacing.xs,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 84 * (value / maxValue),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.vertical(top: AppRadii.md),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'H${index + 1}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _FarmBackdropPainter extends CustomPainter {
  _FarmBackdropPainter({required this.strokeColor, required this.accentColor});

  final Color strokeColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.24),
      26,
      strokePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.82, size.height * 0.24),
        width: 68,
        height: 68,
      ),
      math.pi * 0.15,
      math.pi * 1.2,
      false,
      accentPaint,
    );

    final barn = Path()
      ..moveTo(size.width * 0.56, size.height * 0.70)
      ..lineTo(size.width * 0.68, size.height * 0.52)
      ..lineTo(size.width * 0.80, size.height * 0.70)
      ..lineTo(size.width * 0.80, size.height * 0.88)
      ..lineTo(size.width * 0.56, size.height * 0.88)
      ..close();
    canvas.drawPath(barn, strokePaint);

    canvas.drawLine(
      Offset(size.width * 0.56, size.height * 0.70),
      Offset(size.width * 0.80, size.height * 0.70),
      accentPaint,
    );

    final coop = Path()
      ..moveTo(size.width * 0.20, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.60,
        size.width * 0.36,
        size.height * 0.78,
      );
    canvas.drawPath(coop, strokePaint);
    canvas.drawCircle(
      Offset(size.width * 0.30, size.height * 0.68),
      8,
      accentPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.92),
      Offset(size.width * 0.92, size.height * 0.92),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FarmBackdropPainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.accentColor != accentColor;
  }
}
