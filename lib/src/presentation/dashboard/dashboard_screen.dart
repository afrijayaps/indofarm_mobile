import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/auth/auth_controller.dart';
import '../../application/farms/farm_controller.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(farmsProvider);
            await ref.read(farmsProvider.future);
            if (_selectedFarmId != null) {
              ref.invalidate(farmSummaryProvider(_selectedFarmId!));
              await ref.read(farmSummaryProvider(_selectedFarmId!).future);
            }
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            children: [
              _DashboardHeader(name: name, role: role, isDark: isDark),
              const SizedBox(height: 16),
              _WelcomeCard(name: name),
              const SizedBox(height: 16),
              if (farms.isNotEmpty)
                DropdownButtonFormField<int>(
                  initialValue: _selectedFarmId,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Farm',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  items: farms
                      .map(
                        (farm) => DropdownMenuItem<int>(
                          value: farm.id,
                          child: Text(farm.name),
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
                  final cards = _snapshotCards(summary);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Farm Snapshot',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
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
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.28,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) => _MetricCard(data: cards[index]),
                      ),
                      const SizedBox(height: 16),
                      const _TrendCard(),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Card(
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

    String pick(List<String> keys, String fallback) {
      for (final key in keys) {
        final value = metrics[key] ?? summary[key];
        if (value != null) return value.toString();
      }
      return fallback;
    }

    return [
      _MetricCardData(
        title: 'Total Eggs',
        value: pick(['total_eggs', 'egg_total', 'eggs'], '-'),
        icon: Icons.egg_alt_outlined,
        trend: '+2.1%',
        positive: true,
      ),
      _MetricCardData(
        title: 'Feed Intake',
        value: pick(['feed_total_kg', 'feed_intake', 'pakan_total_kg'], '-'),
        icon: Icons.restaurant_outlined,
        trend: '-0.5%',
        positive: false,
      ),
      _MetricCardData(
        title: 'HD Production',
        value: pick(['hd_production', 'hd_percent'], '-'),
        icon: Icons.analytics_outlined,
        trend: '-1.2%',
        positive: false,
      ),
      _MetricCardData(
        title: 'Depletion',
        value: pick(['depletion', 'depletion_rate'], '-'),
        icon: Icons.heart_broken_outlined,
        trend: '-0.01%',
        positive: true,
      ),
    ];
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
  const _DashboardHeader({
    required this.name,
    required this.role,
    required this.isDark,
  });

  final String name;
  final String role;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
          child: Text(
            name.isEmpty ? '?' : name[0].toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Indofarm.app',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                role.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.1,
                  color: isDark
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)
                      : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB700), Color(0xFFE5A400)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $name',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF231D0F),
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Production is up 2.4% today',
                  style: TextStyle(
                    color: Color(0xCC231D0F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.agriculture, size: 42, color: Color(0xAA231D0F)),
        ],
      ),
    );
  }
}

class _MetricCardData {
  const _MetricCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.trend,
    required this.positive,
  });

  final String title;
  final String value;
  final IconData icon;
  final String trend;
  final bool positive;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricCardData data;

  @override
  Widget build(BuildContext context) {
    final trendColor = data.positive ? Colors.green : Colors.redAccent;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(data.icon, color: Theme.of(context).colorScheme.primary, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    data.title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              data.value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  data.positive ? Icons.trending_up : Icons.trending_down,
                  size: 14,
                  color: trendColor,
                ),
                const SizedBox(width: 4),
                Text(
                  data.trend,
                  style: TextStyle(
                    color: trendColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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

class _TrendCard extends StatelessWidget {
  const _TrendCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Production Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              'Last 7 days',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: CustomPaint(
                painter: _TrendPainter(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const points = [0.78, 0.64, 0.72, 0.45, 0.55, 0.28, 0.34, 0.18, 0.22];
    final path = Path();

    for (var i = 0; i < points.length; i++) {
      final x = (size.width / (points.length - 1)) * i;
      final y = size.height * points[i];
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paintLine = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paintLine);

    final areaPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final areaPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(areaPath, areaPaint);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
