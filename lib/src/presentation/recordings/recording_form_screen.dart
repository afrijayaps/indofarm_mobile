import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/farms/farm_controller.dart';
import '../../application/recordings/recording_controller.dart';
import '../../application/recordings/recording_form_validator.dart';
import '../../domain/models/recording.dart';

class RecordingFormScreen extends ConsumerStatefulWidget {
  const RecordingFormScreen({super.key});

  @override
  ConsumerState<RecordingFormScreen> createState() => _RecordingFormScreenState();
}

class _RecordingFormScreenState extends ConsumerState<RecordingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _validator = const RecordingFormValidator();

  int? _selectedFarmId;
  final _cageId = TextEditingController(text: '1');
  final _tanggal = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  final _mortalitas = TextEditingController(text: '0');
  final _telurKg = TextEditingController();
  final _telurButir = TextEditingController();
  final _pakanTotal = TextEditingController();
  final _suhu = TextEditingController();
  final _kelembaban = TextEditingController();

  @override
  void dispose() {
    _cageId.dispose();
    _tanggal.dispose();
    _mortalitas.dispose();
    _telurKg.dispose();
    _telurButir.dispose();
    _pakanTotal.dispose();
    _suhu.dispose();
    _kelembaban.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final farmsAsync = ref.watch(farmsProvider);
    final submitState = ref.watch(recordingControllerProvider);

    return farmsAsync.when(
      data: (farms) {
        _selectedFarmId ??= farms.isNotEmpty ? farms.first.id : null;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Daily Recording',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                _DatePill(date: _tanggal.text),
              ],
            ),
            const SizedBox(height: 14),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _SectionCard(
                    icon: Icons.location_on_outlined,
                    title: 'Farm Selection',
                    child: Column(
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue: _selectedFarmId,
                          decoration: const InputDecoration(
                            labelText: 'Select Farm / House',
                          ),
                          items: farms
                              .map(
                                (farm) => DropdownMenuItem<int>(
                                  value: farm.id,
                                  child: Text(farm.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => _selectedFarmId = value),
                          validator: (value) =>
                              value == null ? 'Farm wajib dipilih' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _cageId,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'House / Cage ID',
                            prefixIcon: Icon(Icons.home_work_outlined),
                          ),
                          validator: (value) =>
                              _validator.validateNumber(value, 'House/Cage ID'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _tanggal,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal (YYYY-MM-DD)',
                            prefixIcon: Icon(Icons.calendar_month_outlined),
                          ),
                          validator: _validator.validateDateIso,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    icon: Icons.analytics_outlined,
                    title: 'Production Data',
                    child: Column(
                      children: [
                        _InputTile(
                          controller: _mortalitas,
                          label: 'Mortality',
                          hint: 'Number of birds',
                          icon: Icons.heart_broken_outlined,
                          validator: (v) => _validator.validateNumber(v, 'Mortality'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        _InputTile(
                          controller: _telurKg,
                          label: 'Egg Production (KG)',
                          hint: '0.00',
                          icon: Icons.egg_alt_outlined,
                          validator: (v) => _validator.validateNumber(v, 'Egg KG'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _InputTile(
                          controller: _telurButir,
                          label: 'Egg Production (PCS)',
                          hint: '0',
                          icon: Icons.tag_outlined,
                          validator: (v) => _validator.validateNumber(v, 'Egg PCS'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        _InputTile(
                          controller: _pakanTotal,
                          label: 'Feed Consumed (KG)',
                          hint: '0.0',
                          icon: Icons.restaurant_outlined,
                          validator: (v) =>
                              _validator.validateNumber(v, 'Feed Consumed'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _InputTile(
                          controller: _suhu,
                          label: 'Temperature (C)',
                          hint: '0',
                          icon: Icons.thermostat_outlined,
                          validator: (v) => _validator.validateNumber(v, 'Temperature'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _InputTile(
                          controller: _kelembaban,
                          label: 'Humidity (%)',
                          hint: '0',
                          icon: Icons.water_drop_outlined,
                          validator: (v) => _validator.validateNumber(v, 'Humidity'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (submitState.error != null)
                    Text(
                      submitState.error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  if (submitState.message != null)
                    Text(
                      submitState.message!,
                      style: const TextStyle(color: Colors.green),
                    ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: submitState.isSubmitting ? null : _submit,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      submitState.isSubmitting ? 'Menyimpan...' : 'Save Record',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Records are automatically synced to the cloud',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        );
      },
      error: (error, _) => Center(child: Text('Error farm: $error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedFarmId == null) return;

    final pakanTotal = double.parse(_pakanTotal.text.trim());
    final payload = RecordingPayload(
      farmId: _selectedFarmId!,
      cageId: int.parse(_cageId.text.trim()),
      tanggal: _tanggal.text.trim(),
      pakanPagiKg: pakanTotal,
      pakanSoreKg: 0,
      pakanTotalKg: pakanTotal,
      mortalitas: int.parse(_mortalitas.text.trim()),
      suhu: double.parse(_suhu.text.trim()),
      kelembaban: double.parse(_kelembaban.text.trim()),
      telurRows: [
        EggRow(
          jenis: 'utuh',
          kg: double.parse(_telurKg.text.trim()),
          butir: int.parse(_telurButir.text.trim()),
        ),
      ],
    );

    await ref.read(recordingControllerProvider.notifier).submit(payload);
    ref.invalidate(recordingDraftsProvider);
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            date,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InputTile extends StatelessWidget {
  const _InputTile({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    required this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
