import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/auth/auth_controller.dart';
import '../../application/theme/theme_controller.dart';
import '../../core/theme/app_theme.dart';
import '../common/widgets/if_primitives.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).session;
    final selectedPreset = ref.watch(themeControllerProvider);
    final user = session?.user;
    final firstInitial = (user?.name.isNotEmpty == true)
        ? user!.name[0].toUpperCase()
        : '?';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        IFHeroHeader(
          title: 'Profil Pengguna',
          subtitle: user?.email ?? '-',
          leadingIcon: Icons.person_outline,
          badgeText: (user?.role ?? '-').toUpperCase(),
        ),
        const SizedBox(height: 12),
        IFSectionCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: AppCorners.lg,
                  ),
                  child: Center(
                    child: Text(
                      firstInitial,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? '-',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '-',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _ProfileRow(
                  icon: Icons.badge_outlined,
                  label: 'Role',
                  value: (user?.role ?? '-').toUpperCase(),
                ),
                const _ProfileRow(
                  icon: Icons.verified_user_outlined,
                  label: 'Status',
                  value: 'ACTIVE',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        IFSectionCard(
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondaryContainer.withValues(alpha: 0.7),
                borderRadius: AppCorners.sm,
              ),
              child: const Icon(Icons.sync),
            ),
            title: const Text('Sinkronisasi Draft'),
            subtitle: const Text(
              'Data draft akan dikirim ulang saat jaringan kembali.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 10),
        IFSectionCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tema Aplikasi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih preset tampilan yang paling nyaman dipakai.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final preset in AppTheme.presets)
                      SizedBox(
                        width: 168,
                        child: _ThemePresetCard(
                          preset: preset,
                          isSelected: selectedPreset == preset,
                          onTap: () => ref
                              .read(themeControllerProvider.notifier)
                              .selectPreset(preset),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        FilledButton.icon(
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          IFStatusPill(label: value),
        ],
      ),
    );
  }
}

class _ThemePresetCard extends StatelessWidget {
  const _ThemePresetCard({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  final AppThemePreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final presetMeta = AppTheme.metaFor(preset);

    return AnimatedContainer(
      duration: AppMotion.normal,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.34)
            : colorScheme.surfaceContainerHigh.withValues(alpha: 0.84),
        borderRadius: AppCorners.lg,
        border: Border.all(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: 0.9),
          width: isSelected ? 1.4 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppCorners.lg,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: presetMeta.previewColors.first.withValues(
                          alpha: 0.14,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        presetMeta.icon,
                        size: AppIconSize.sm,
                        color: presetMeta.previewColors.first,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IFStatusPill(
                    label: isSelected ? 'Aktif' : 'Pilih',
                    icon: isSelected ? Icons.check_circle_outline : null,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  presetMeta.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(presetMeta.subtitle, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    for (final color in presetMeta.previewColors) ...[
                      _ThemeDot(color: color),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeDot extends StatelessWidget {
  const _ThemeDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
