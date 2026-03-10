import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/auth/auth_controller.dart';
import '../../application/farms/farm_controller.dart';
import '../../core/theme/app_theme.dart';
import '../common/widgets/if_primitives.dart';
import '../farms/recording_list_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int? _selectedFarmId;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final farmsAsync = ref.watch(farmsProvider);
    final user = authState.session?.user;
    final role = user?.role ?? '-';
    final name = _displayName(user?.name, user?.email);

    return farmsAsync.when(
      data: (farms) {
        if (farms.isNotEmpty && _selectedFarmId == null) {
          _selectedFarmId = farms.first.id;
        }

        final selectedFarms = farms.where((f) => f.id == _selectedFarmId);
        final selectedFarm = selectedFarms.isEmpty ? null : selectedFarms.first;
        final summaryAsync = _selectedFarmId != null
            ? ref.watch(farmSummaryProvider(_selectedFarmId!))
            : const AsyncValue<Map<String, dynamic>>.data({});
        final trendAsync = _selectedFarmId != null
            ? ref.watch(farmWeeklyTrendProvider(_selectedFarmId!))
            : const AsyncValue<List<FarmWeeklyTrendPoint>>.data([]);

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(farmsProvider);
            await ref.read(farmsProvider.future);
            if (_selectedFarmId != null) {
              ref.invalidate(farmSummaryProvider(_selectedFarmId!));
              await ref.read(farmSummaryProvider(_selectedFarmId!).future);
              ref.invalidate(farmWeeklyTrendProvider(_selectedFarmId!));
              await ref.read(farmWeeklyTrendProvider(_selectedFarmId!).future);
            }
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            children: [
              _DashboardHeader(name: name, role: role),
              const SizedBox(height: 16),
              _WelcomeCard(name: name),
              const SizedBox(height: 16),
              if (farms.isNotEmpty)
                DropdownButtonFormField<int>(
                  initialValue: _selectedFarmId,
                  isExpanded: true,
                  borderRadius: AppCorners.sm,
                  dropdownColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHigh,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Farm',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  items: farms
                      .map(
                        (farm) => DropdownMenuItem<int>(
                          value: farm.id,
                          child: Text(
                            farm.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedFarmId = value);
                  },
                ),
              const SizedBox(height: 12),
              summaryAsync.when(
                data: (summary) {
                  if (summary.isEmpty) {
                    return const IFEmptyState(
                      icon: Icons.analytics_outlined,
                      title:
                          'Belum ada data summary. Silakan input recording dulu.',
                      message: '',
                    );
                  }

                  final cards = _snapshotCards(summary);
                  final meta = _summaryMeta(summary);

                  return AnimatedSwitcher(
                    duration: AppMotion.normal,
                    child: Column(
                      key: ValueKey<int>(_selectedFarmId ?? 0),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Farm Snapshot',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            TextButton.icon(
                              onPressed: selectedFarm == null
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => RecordingListScreen(
                                            farmId: selectedFarm.id,
                                            farmName: selectedFarm.name,
                                          ),
                                        ),
                                      );
                                    },
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text('Detail'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GridView.builder(
                          itemCount: cards.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.28,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemBuilder: (context, index) =>
                              _MetricCard(data: cards[index]),
                        ),
                        const SizedBox(height: 12),
                        _SummaryMetaCard(meta: meta),
                        const SizedBox(height: 12),
                        trendAsync.when(
                          data: (trendPoints) =>
                              _WeeklyTrendCard(points: trendPoints),
                          loading: () => const IFSectionCard(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ),
                          error: (error, _) => IFSectionCard(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Text(
                                'Gagal memuat grafik mingguan: $error',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => IFSectionCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Gagal memuat summary: $error'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Gagal load dashboard: $error')),
    );
  }

  List<_MetricCardData> _snapshotCards(Map<String, dynamic> summary) {
    final metrics = summary['metrics'] is Map<String, dynamic>
        ? summary['metrics'] as Map<String, dynamic>
        : <String, dynamic>{};

    return [
      _MetricCardData(
        title: 'Total Egg (Butir)',
        value: _numberText(metrics['total_egg_count']),
        icon: Icons.egg_alt_outlined,
      ),
      _MetricCardData(
        title: 'Total Egg (Kg)',
        value: '${_numberText(metrics['total_egg_kg'])} kg',
        icon: Icons.scale_outlined,
      ),
      _MetricCardData(
        title: 'Total Feed (Kg)',
        value: '${_numberText(metrics['total_feed_kg'])} kg',
        icon: Icons.restaurant_outlined,
      ),
      _MetricCardData(
        title: 'Recording Count',
        value: _numberText(metrics['recording_count']),
        icon: Icons.fact_check_outlined,
      ),
    ];
  }

  _SummaryMeta _summaryMeta(Map<String, dynamic> summary) {
    final metrics = summary['metrics'] is Map<String, dynamic>
        ? summary['metrics'] as Map<String, dynamic>
        : <String, dynamic>{};

    final period = summary['period'] is Map<String, dynamic>
        ? summary['period'] as Map<String, dynamic>
        : <String, dynamic>{};

    return _SummaryMeta(
      latestRecordingDate: summary['latest_recording_date']?.toString() ?? '-',
      avgFeedPerDayKg: '${_numberText(metrics['avg_feed_per_day_kg'])} kg',
      periodFrom: period['from']?.toString() ?? '-',
      periodTo: period['to']?.toString() ?? '-',
    );
  }

  String _numberText(Object? value) {
    if (value == null) return '0';
    if (value is num) {
      if (value % 1 == 0) return value.toInt().toString();
      return value.toString();
    }
    final text = value.toString().trim();
    return text.isEmpty ? '0' : text;
  }

  String _displayName(String? name, String? email) {
    final n = (name ?? '').trim();
    if (n.isNotEmpty) return n;
    final e = (email ?? '').trim();
    if (e.contains('@')) {
      return e.split('@').first;
    }
    return 'User';
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.name, required this.role});

  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: AppCorners.md,
          ),
          child: Center(
            child: Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              IFStatusPill(label: 'Role: ${role.toUpperCase()}'),
            ],
          ),
        ),
        IconButton.filled(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
        ),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return IFHeroHeader(
      title: 'Selamat datang, $name',
      subtitle: 'Monitoring operasional farm harian.',
      leadingIcon: Icons.agriculture,
      trailing: IconButton.filledTonal(
        onPressed: () {},
        icon: const Icon(Icons.insights_outlined),
      ),
    );
  }
}

class _MetricCardData {
  const _MetricCardData({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricCardData data;

  @override
  Widget build(BuildContext context) {
    return IFMetricTile(title: data.title, value: data.value, icon: data.icon);
  }
}

class _SummaryMeta {
  const _SummaryMeta({
    required this.latestRecordingDate,
    required this.avgFeedPerDayKg,
    required this.periodFrom,
    required this.periodTo,
  });

  final String latestRecordingDate;
  final String avgFeedPerDayKg;
  final String periodFrom;
  final String periodTo;
}

class _SummaryMetaCard extends StatelessWidget {
  const _SummaryMetaCard({required this.meta});

  final _SummaryMeta meta;

  @override
  Widget build(BuildContext context) {
    return IFSectionCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Periode',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _MetaRow(
            label: 'Recording Terakhir',
            value: meta.latestRecordingDate,
          ),
          _MetaRow(label: 'Rata-rata Pakan/Hari', value: meta.avgFeedPerDayKg),
          _MetaRow(
            label: 'Periode',
            value: '${meta.periodFrom} s/d ${meta.periodTo}',
          ),
        ],
      ),
    );
  }
}

class _WeeklyTrendCard extends StatefulWidget {
  const _WeeklyTrendCard({required this.points});

  final List<FarmWeeklyTrendPoint> points;

  @override
  State<_WeeklyTrendCard> createState() => _WeeklyTrendCardState();
}

class _WeeklyTrendCardState extends State<_WeeklyTrendCard> {
  int? _activeIndex;
  bool _showHd = true;
  bool _showEgg = true;

  int _nearestIndex(double dx, double width, int count) {
    if (count <= 1) return 0;
    final step = width / (count - 1);
    final raw = (dx / step).round();
    if (raw < 0) return 0;
    if (raw > count - 1) return count - 1;
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    final selected = (points.isNotEmpty && _activeIndex != null)
        ? points[_activeIndex!]
        : null;

    return IFSectionCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grafik Mingguan',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            'HD (%) dan produksi telur (kg)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _LegendDot(
                color: const Color(0xFF1E88E5),
                label: 'HD %',
                selected: _showHd,
                onTap: () => setState(() => _showHd = !_showHd),
              ),
              const SizedBox(width: 14),
              _LegendDot(
                color: const Color(0xFFFFA000),
                label: 'Telur kg/minggu',
                selected: _showEgg,
                onTap: () => setState(() => _showEgg = !_showEgg),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: AppMotion.normal,
            child: selected == null
                ? const SizedBox.shrink()
                : Padding(
                    key: ValueKey<String>(selected.label),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: AppCorners.sm,
                      ),
                      child: Text(
                        '${selected.label}  |  HD ${selected.hdPercent.toStringAsFixed(2)}%  |  Egg ${selected.eggKg.toStringAsFixed(2)} kg',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return SizedBox(
                height: 160,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    if (points.isEmpty) return;
                    setState(() {
                      _activeIndex = _nearestIndex(
                        details.localPosition.dx,
                        width,
                        points.length,
                      );
                    });
                  },
                  onHorizontalDragUpdate: (details) {
                    if (points.isEmpty) return;
                    setState(() {
                      _activeIndex = _nearestIndex(
                        details.localPosition.dx,
                        width,
                        points.length,
                      );
                    });
                  },
                  child: CustomPaint(
                    painter: _DualLineChartPainter(
                      points: points,
                      activeIndex: _activeIndex,
                      showHd: _showHd,
                      showEgg: _showEgg,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: points
                .asMap()
                .entries
                .map((entry) {
                  final index = entry.key;
                  final p = entry.value;
                  final isActive = index == _activeIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _activeIndex = index),
                    child: Text(
                      p.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                  );
                })
                .toList(growable: false),
          ),
          if (points.isNotEmpty && _activeIndex == null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Tap grafik untuk lihat detail per minggu.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                decoration: selected ? null : TextDecoration.lineThrough,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DualLineChartPainter extends CustomPainter {
  _DualLineChartPainter({
    required this.points,
    this.activeIndex,
    required this.showHd,
    required this.showEgg,
  });

  final List<FarmWeeklyTrendPoint> points;
  final int? activeIndex;
  final bool showHd;
  final bool showEgg;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      return;
    }

    final hdValues = points.map((p) => p.hdPercent).toList(growable: false);
    final eggValues = points.map((p) => p.eggKg).toList(growable: false);

    final hdMax = hdValues.reduce((a, b) => a > b ? a : b);
    final eggMax = eggValues.reduce((a, b) => a > b ? a : b);

    final chartTop = 10.0;
    final chartHeight = size.height - 20;

    final hdPath = Path();
    final eggPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? size.width / 2
          : (size.width / (points.length - 1)) * i;

      final hdNorm = hdMax <= 0 ? 0.0 : points[i].hdPercent / hdMax;
      final eggNorm = eggMax <= 0 ? 0.0 : points[i].eggKg / eggMax;

      final yHd = chartTop + chartHeight - (hdNorm * chartHeight);
      final yEgg = chartTop + chartHeight - (eggNorm * chartHeight);

      if (i == 0) {
        hdPath.moveTo(x, yHd);
        eggPath.moveTo(x, yEgg);
      } else {
        hdPath.lineTo(x, yHd);
        eggPath.lineTo(x, yEgg);
      }

      if (showHd) {
        canvas.drawCircle(
          Offset(x, yHd),
          3,
          Paint()..color = const Color(0xFF1E88E5),
        );
      }
      if (showEgg) {
        canvas.drawCircle(
          Offset(x, yEgg),
          3,
          Paint()..color = const Color(0xFFFFA000),
        );
      }

      if (activeIndex == i) {
        final markerPaint = Paint()
          ..color = const Color(0xAA000000)
          ..strokeWidth = 1.2;
        canvas.drawLine(
          Offset(x, chartTop),
          Offset(x, chartTop + chartHeight),
          markerPaint,
        );
        if (showHd) {
          canvas.drawCircle(
            Offset(x, yHd),
            5,
            Paint()
              ..color = const Color(0xFF1E88E5)
              ..style = PaintingStyle.fill,
          );
        }
        if (showEgg) {
          canvas.drawCircle(
            Offset(x, yEgg),
            5,
            Paint()
              ..color = const Color(0xFFFFA000)
              ..style = PaintingStyle.fill,
          );
        }
      }
    }

    final hdPaint = Paint()
      ..color = const Color(0xFF1E88E5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final eggPaint = Paint()
      ..color = const Color(0xFFFFA000)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gridPaint = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = chartTop + (chartHeight / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (showHd) {
      canvas.drawPath(hdPath, hdPaint);
    }
    if (showEgg) {
      canvas.drawPath(eggPath, eggPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DualLineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.showHd != showHd ||
        oldDelegate.showEgg != showEgg;
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
