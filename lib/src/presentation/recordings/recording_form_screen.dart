import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/farms/farm_controller.dart';
import '../../application/recordings/recording_controller.dart';
import '../../application/recordings/recording_form_validator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_exception.dart';
import '../../domain/models/farm.dart';
import '../../domain/models/recording.dart';
import '../common/widgets/if_primitives.dart';

class RecordingFormScreen extends ConsumerStatefulWidget {
  const RecordingFormScreen({super.key});

  @override
  ConsumerState<RecordingFormScreen> createState() =>
      _RecordingFormScreenState();
}

class _RecordingFormScreenState extends ConsumerState<RecordingFormScreen> {
  final _validator = const RecordingFormValidator();

  int _step = 0;
  int? _selectedFarmId;
  int? _selectedCageId;
  String _tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _modeButir = 'manual';
  double _estimasiBeratButirGr = 60;
  int? _feedInventoryItemId;

  String _pakanPagiKg = '';
  String _pakanSoreKg = '0';
  int _jamLampu = 12;
  String _tempMin = '';
  String _tempMax = '';
  String _humMin = '';
  String _humMax = '';

  List<AyamKeluarRow> _ayamKeluarRows = <AyamKeluarRow>[];
  List<EggRow> _telurRows = <EggRow>[];
  List<PerlakuanRow> _perlakuanRows = <PerlakuanRow>[];

  int? _optionDefaultsAppliedFarmId;

  @override
  Widget build(BuildContext context) {
    final farmsAsync = ref.watch(farmsProvider);
    final submitState = ref.watch(recordingControllerProvider);

    return farmsAsync.when(
      data: (farms) {
        if (farms.isEmpty) {
          return const Center(child: Text('Farm tidak tersedia'));
        }

        _selectedFarmId ??= farms.first.id;
        final farmId = _selectedFarmId!;
        final formOptionsAsync = ref.watch(
          recordingFormOptionsProvider(farmId),
        );

        return formOptionsAsync.when(
          data: (options) {
            _syncDefaultsFromOptions(farmId, options);

            final isLastStep = _step == 3;
            return Form(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: [
                        const IFHeroHeader(
                          title: 'Input Recording',
                          subtitle:
                              'Lengkapi data harian farm dengan wizard 4 langkah.',
                          leadingIcon: Icons.edit_note,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        IFSectionCard(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _StepChip(
                                  title: 'Info',
                                  active: _step == 0,
                                  done: _step > 0,
                                ),
                                _StepChip(
                                  title: 'Telur',
                                  active: _step == 1,
                                  done: _step > 1,
                                ),
                                _StepChip(
                                  title: 'Pakan',
                                  active: _step == 2,
                                  done: _step > 2,
                                ),
                                _StepChip(
                                  title: 'Medis',
                                  active: _step == 3,
                                  done: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        IFSectionCard(
                          child: Stepper(
                            physics: const NeverScrollableScrollPhysics(),
                            currentStep: _step,
                            controlsBuilder: (_, __) => const SizedBox.shrink(),
                            onStepTapped: (index) {
                              if (index <= _step) {
                                setState(() => _step = index);
                                return;
                              }
                              if (_validateStep(options, _step)) {
                                setState(() => _step = index);
                              }
                            },
                            steps: [
                              Step(
                                title: _buildStepTitle(
                                  'Info Dasar & Populasi',
                                  Icons.dataset_outlined,
                                ),
                                isActive: _step >= 0,
                                content: _buildBasicStep(farms, options),
                              ),
                              Step(
                                title: _buildStepTitle(
                                  'Produksi Telur',
                                  Icons.egg_alt_outlined,
                                ),
                                isActive: _step >= 1,
                                content: _buildEggStep(options),
                              ),
                              Step(
                                title: _buildStepTitle(
                                  'Pakan & Lingkungan',
                                  Icons.grass_outlined,
                                ),
                                isActive: _step >= 2,
                                content: _buildFeedStep(options),
                              ),
                              Step(
                                title: _buildStepTitle(
                                  'Perlakuan / Medis',
                                  Icons.medication_outlined,
                                ),
                                isActive: _step >= 3,
                                content: _buildTreatmentStep(options),
                              ),
                            ],
                          ),
                        ),
                        if (submitState.error != null)
                          _InlineStatusBanner(
                            text: submitState.error!,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        if (submitState.message != null)
                          _InlineStatusBanner(
                            text: submitState.message!,
                            color: Colors.green,
                          ),
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                      child: IFSectionCard(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
                              child: Row(
                                children: [
                                  Text(
                                    'Step ${_step + 1} dari 4',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const Spacer(),
                                  Text(
                                    isLastStep ? 'Finalisasi' : 'Lengkapi data',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                minHeight: 5,
                                value: (_step + 1) / 4,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (_step > 0)
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: submitState.isSubmitting
                                          ? null
                                          : () => setState(() => _step -= 1),
                                      icon: const Icon(
                                        Icons.arrow_back_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Kembali'),
                                    ),
                                  ),
                                if (_step > 0) const SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: submitState.isSubmitting
                                        ? null
                                        : () async {
                                            if (!_validateStep(options, _step))
                                              return;
                                            if (isLastStep) {
                                              await _submit();
                                              return;
                                            }
                                            setState(() => _step += 1);
                                          },
                                    icon: Icon(
                                      isLastStep
                                          ? Icons.check_circle_outline
                                          : Icons.arrow_forward_rounded,
                                      size: 18,
                                    ),
                                    label: Text(
                                      isLastStep
                                          ? (submitState.isSubmitting
                                                ? 'Menyimpan...'
                                                : 'Simpan Recording')
                                          : 'Lanjut',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          error: (error, _) => _OptionsErrorView(
            error: error,
            onRetry: () => ref.invalidate(recordingFormOptionsProvider(farmId)),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, _) => Center(child: Text('Error farm: $error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildStepTitle(String title, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: AppIconSize.sm, color: scheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Flexible(child: Text(title)),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: AppIconSize.sm, color: scheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Text(title, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }

  Widget _buildBasicStep(List<Farm> farms, RecordingFormOptions options) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<int>(
          initialValue: _selectedFarmId,
          isExpanded: true,
          borderRadius: AppCorners.sm,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          decoration: const InputDecoration(labelText: 'Farm'),
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
            if (value == null || value == _selectedFarmId) {
              return;
            }
            setState(() {
              _selectedFarmId = value;
              _step = 0;
              _optionDefaultsAppliedFarmId = null;
              _selectedCageId = null;
              _feedInventoryItemId = null;
              _ayamKeluarRows = <AyamKeluarRow>[];
              _telurRows = <EggRow>[];
              _perlakuanRows = <PerlakuanRow>[];
            });
          },
          validator: (value) => value == null ? 'Farm wajib dipilih' : null,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(
          initialValue: _selectedCageId,
          isExpanded: true,
          borderRadius: AppCorners.sm,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          decoration: const InputDecoration(labelText: 'Kandang'),
          items: options.cages
              .map(
                (cage) => DropdownMenuItem<int>(
                  value: cage.id,
                  child: Text(
                    cage.code.trim().isEmpty
                        ? cage.name
                        : '${cage.code} - ${cage.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCageId = value;
              _feedInventoryItemId = value == null
                  ? null
                  : options.defaultFeedItemByCage[value];
            });
          },
          validator: (value) => value == null ? 'Kandang wajib dipilih' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          initialValue: _tanggal,
          decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
          onChanged: (value) => _tanggal = value,
          validator: _validator.validateDateIso,
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: _buildSectionTitle('Ayam Keluar', Icons.groups_2_outlined),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < _ayamKeluarRows.length; i++)
          _AyamKeluarRowEditor(
            row: _ayamKeluarRows[i],
            types: options.ayamKeluarTypes,
            onChanged: (row) => setState(() => _ayamKeluarRows[i] = row),
            onRemove: () => setState(() => _ayamKeluarRows.removeAt(i)),
          ),
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              final defaultType = options.ayamKeluarTypes.keys.isEmpty
                  ? 'mati'
                  : options.ayamKeluarTypes.keys.first;
              setState(() {
                _ayamKeluarRows = [
                  ..._ayamKeluarRows,
                  AyamKeluarRow(type: defaultType, qty: 0),
                ];
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah baris ayam keluar'),
          ),
        ),
      ],
    );
  }

  Widget _buildEggStep(RecordingFormOptions options) {
    final estimasiButir = _modeButir == 'estimasi'
        ? _estimateEggTotalButir(_telurRows, _estimasiBeratButirGr)
        : null;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          initialValue: _modeButir,
          isExpanded: true,
          borderRadius: AppCorners.sm,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          decoration: const InputDecoration(labelText: 'Mode Butir'),
          items: const [
            DropdownMenuItem(value: 'manual', child: Text('Manual')),
            DropdownMenuItem(value: 'estimasi', child: Text('Estimasi')),
          ],
          onChanged: (value) => setState(() => _modeButir = value ?? 'manual'),
        ),
        const SizedBox(height: 14),
        if (_modeButir == 'estimasi')
          TextFormField(
            initialValue: _estimasiBeratButirGr.toStringAsFixed(1),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Estimasi Berat Butir (gr)',
            ),
            onChanged: (value) =>
                _estimasiBeratButirGr = double.tryParse(value.trim()) ?? 60,
            validator: (value) => _validator.validatePositiveNumber(
              value,
              'Estimasi berat butir',
            ),
          ),
        if (_modeButir == 'estimasi') const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: _buildSectionTitle('Telur Rows', Icons.view_list_outlined),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < _telurRows.length; i++)
          _TelurRowEditor(
            row: _telurRows[i],
            telurTypes: options.telurTypes,
            manualMode: _modeButir == 'manual',
            onChanged: (row) => setState(() => _telurRows[i] = row),
            onRemove: () => setState(() => _telurRows.removeAt(i)),
          ),
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              final jenisDefault = options.telurTypes.keys.isEmpty
                  ? 'utuh'
                  : options.telurTypes.keys.first;
              setState(() {
                _telurRows = [
                  ..._telurRows,
                  EggRow(jenis: jenisDefault, kg: 0, butir: 0),
                ];
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah baris telur'),
          ),
        ),
        if (estimasiButir != null) const SizedBox(height: AppSpacing.sm),
        if (estimasiButir != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Preview estimasi butir: ${estimasiButir.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }

  Widget _buildFeedStep(RecordingFormOptions options) {
    final jamLampuItems = options.jamLampuOptions.isEmpty
        ? List<int>.generate(25, (index) => index)
        : options.jamLampuOptions;
    final jamLampuValue = jamLampuItems.contains(_jamLampu)
        ? _jamLampu
        : jamLampuItems.first;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<int?>(
          initialValue: _feedInventoryItemId,
          isExpanded: true,
          borderRadius: AppCorners.sm,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          decoration: const InputDecoration(
            labelText: 'Sumber Pakan (opsional)',
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Tidak dipilih'),
            ),
            ...options.feedItems.map(
              (item) => DropdownMenuItem<int?>(
                value: item.id,
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: (value) => setState(() => _feedInventoryItemId = value),
        ),
        const SizedBox(height: 14),
        TextFormField(
          initialValue: _pakanPagiKg,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Pakan Pagi (kg)'),
          onChanged: (value) => _pakanPagiKg = value,
          validator: (value) =>
              _validator.validateRequired(value, 'Pakan pagi'),
        ),
        const SizedBox(height: 14),
        TextFormField(
          initialValue: _pakanSoreKg,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Pakan Sore (kg)'),
          onChanged: (value) => _pakanSoreKg = value,
          validator: (value) => _validator.validateNumber(value, 'Pakan sore'),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(
          initialValue: jamLampuValue,
          isExpanded: true,
          borderRadius: AppCorners.sm,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          decoration: const InputDecoration(labelText: 'Jam Lampu'),
          items: jamLampuItems
              .map(
                (hour) => DropdownMenuItem(value: hour, child: Text('$hour')),
              )
              .toList(),
          onChanged: (value) => setState(() => _jamLampu = value ?? 0),
          validator: (value) => value == null ? 'Jam lampu wajib diisi' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          initialValue: _tempMin,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Temp Min (opsional)'),
          onChanged: (value) => _tempMin = value,
        ),
        const SizedBox(height: 14),
        TextFormField(
          initialValue: _tempMax,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Temp Max (opsional)'),
          onChanged: (value) => _tempMax = value,
        ),
        const SizedBox(height: 14),
        TextFormField(
          initialValue: _humMin,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Humidity Min (opsional)',
          ),
          onChanged: (value) => _humMin = value,
        ),
        const SizedBox(height: 14),
        TextFormField(
          initialValue: _humMax,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Humidity Max (opsional)',
          ),
          onChanged: (value) => _humMax = value,
        ),
      ],
    );
  }

  Widget _buildTreatmentStep(RecordingFormOptions options) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < _perlakuanRows.length; i++)
          _PerlakuanRowEditor(
            row: _perlakuanRows[i],
            treatmentTypes: options.treatmentTypes,
            qtyUnits: options.qtyUnits,
            onChanged: (row) => setState(() => _perlakuanRows[i] = row),
            onRemove: () => setState(() => _perlakuanRows.removeAt(i)),
          ),
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              final defaultType = options.treatmentTypes.keys.isEmpty
                  ? ''
                  : options.treatmentTypes.keys.first;
              final defaultUnit = options.qtyUnits.keys.isEmpty
                  ? 'gr'
                  : options.qtyUnits.keys.first;
              setState(() {
                _perlakuanRows = [
                  ..._perlakuanRows,
                  PerlakuanRow(
                    treatmentType: defaultType,
                    medicineName: '',
                    qtyGram: 0,
                    qtyUnit: defaultUnit,
                  ),
                ];
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah baris perlakuan'),
          ),
        ),
      ],
    );
  }

  void _syncDefaultsFromOptions(int farmId, RecordingFormOptions options) {
    if (_optionDefaultsAppliedFarmId == farmId) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedFarmId != farmId) {
        return;
      }

      setState(() {
        _optionDefaultsAppliedFarmId = farmId;
        _modeButir = options.modeButirDefault;
        _estimasiBeratButirGr = options.estimasiBeratButirGrDefault;
        _tanggal = options.tanggalToday.isEmpty
            ? DateFormat('yyyy-MM-dd').format(DateTime.now())
            : options.tanggalToday;

        final cageId = options.cages.isEmpty ? null : options.cages.first.id;
        _selectedCageId ??= cageId;
        _jamLampu = options.jamLampuOptions.isEmpty
            ? 0
            : options.jamLampuOptions.first;

        if (_selectedCageId != null) {
          _feedInventoryItemId =
              options.defaultFeedItemByCage[_selectedCageId!];
        }

        if (_telurRows.isEmpty) {
          final defaultTelur = options.telurTypes.keys.isEmpty
              ? 'utuh'
              : options.telurTypes.keys.first;
          _telurRows = <EggRow>[EggRow(jenis: defaultTelur, kg: 0, butir: 0)];
        }
      });
    });
  }

  bool _validateStep(RecordingFormOptions options, int step) {
    if (step == 0) {
      if (_selectedFarmId == null) {
        _showValidationError('Farm wajib dipilih');
        return false;
      }
      if (_selectedCageId == null) {
        _showValidationError('Kandang wajib dipilih');
        return false;
      }
      final dateError = _validator.validateDateIso(_tanggal);
      if (dateError != null) {
        _showValidationError(dateError);
        return false;
      }
      return true;
    }

    if (step == 1) {
      final eggRowsError = _validator.validateNonEmptyRows(_telurRows);
      if (eggRowsError != null) {
        _showValidationError(eggRowsError);
        return false;
      }
      if (_modeButir == 'estimasi' && _estimasiBeratButirGr <= 0) {
        _showValidationError('Estimasi berat butir harus > 0');
        return false;
      }
      return true;
    }

    if (step == 2) {
      final pagiRequired = _validator.validateRequired(
        _pakanPagiKg,
        'Pakan pagi',
      );
      if (pagiRequired != null) {
        _showValidationError(pagiRequired);
        return false;
      }
      final pagiNumber = _validator.validateNumber(_pakanPagiKg, 'Pakan pagi');
      if (pagiNumber != null) {
        _showValidationError(pagiNumber);
        return false;
      }
      if (options.jamLampuOptions.isNotEmpty &&
          !options.jamLampuOptions.contains(_jamLampu)) {
        _showValidationError('Jam lampu wajib diisi');
        return false;
      }
      return true;
    }

    if (step == 3) {
      final perlakuanError = _validator.validatePerlakuanRows(_perlakuanRows);
      if (perlakuanError != null) {
        _showValidationError(perlakuanError);
        return false;
      }
      return true;
    }

    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  double _estimateEggTotalButir(List<EggRow> rows, double eggWeightGr) {
    if (eggWeightGr <= 0) {
      return 0;
    }
    final totalKg = rows.fold<double>(0, (sum, row) => sum + row.kg);
    return (totalKg * 1000) / eggWeightGr;
  }

  Future<void> _submit() async {
    if (_selectedFarmId == null || _selectedCageId == null) {
      return;
    }

    final payload = RecordingPayload(
      farmId: _selectedFarmId!,
      cageId: _selectedCageId!,
      tanggal: _tanggal,
      modeButir: _modeButir,
      estimasiBeratButirGr: _estimasiBeratButirGr,
      pakanPagiKg: double.tryParse(_pakanPagiKg.trim()) ?? 0,
      pakanSoreKg: double.tryParse(_pakanSoreKg.trim()) ?? 0,
      jamLampu: _jamLampu,
      telurRows: _modeButir == 'estimasi'
          ? _telurRows
                .map((row) => EggRow(jenis: row.jenis, kg: row.kg, butir: 0))
                .toList()
          : _telurRows,
      ayamKeluarRows: _ayamKeluarRows,
      perlakuanRows: _perlakuanRows,
      feedInventoryItemId: _feedInventoryItemId,
      tempMin: double.tryParse(_tempMin.trim()),
      tempMax: double.tryParse(_tempMax.trim()),
      humMin: double.tryParse(_humMin.trim()),
      humMax: double.tryParse(_humMax.trim()),
    );

    await ref.read(recordingControllerProvider.notifier).submit(payload);
    ref.invalidate(recordingDraftsProvider);
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.title,
    required this.active,
    required this.done,
  });

  final String title;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = active
        ? theme.colorScheme.primary.withValues(alpha: 0.26)
        : done
        ? theme.colorScheme.primary.withValues(alpha: 0.16)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_circle : Icons.circle,
            size: 14,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: active ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineStatusBanner extends StatelessWidget {
  const _InlineStatusBanner({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: IFSectionCard(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: AppCorners.sm,
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}

class _AyamKeluarRowEditor extends StatelessWidget {
  const _AyamKeluarRowEditor({
    required this.row,
    required this.types,
    required this.onChanged,
    required this.onRemove,
  });

  final AyamKeluarRow row;
  final Map<String, String> types;
  final ValueChanged<AyamKeluarRow> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final typeItems = types.entries
        .map(
          (entry) => DropdownMenuItem(
            value: entry.key,
            child: Text(
              entry.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList();
    if (typeItems.isEmpty) {
      typeItems.add(
        DropdownMenuItem(
          value: row.type,
          child: Text(row.type, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      );
    }

    return IFSectionCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: row.type,
            isExpanded: true,
            borderRadius: AppCorners.sm,
            dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            decoration: const InputDecoration(labelText: 'Jenis'),
            items: typeItems,
            onChanged: (value) => onChanged(
              AyamKeluarRow(
                type: value ?? row.type,
                qty: row.qty,
                note: row.note,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            initialValue: row.qty.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Qty'),
            onChanged: (value) => onChanged(
              AyamKeluarRow(
                type: row.type,
                qty: int.tryParse(value.trim()) ?? 0,
                note: row.note,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            initialValue: row.note ?? '',
            decoration: const InputDecoration(
              labelText: 'Keterangan (opsional)',
            ),
            onChanged: (value) => onChanged(
              AyamKeluarRow(
                type: row.type,
                qty: row.qty,
                note: value.trim().isEmpty ? null : value,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: AppTheme.destructiveTextButtonStyle(context),
              onPressed: onRemove,
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: AppIconSize.md,
              ),
              label: const Text('Hapus'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TelurRowEditor extends StatelessWidget {
  const _TelurRowEditor({
    required this.row,
    required this.telurTypes,
    required this.manualMode,
    required this.onChanged,
    required this.onRemove,
  });

  final EggRow row;
  final Map<String, String> telurTypes;
  final bool manualMode;
  final ValueChanged<EggRow> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final telurItems = telurTypes.entries
        .map(
          (entry) => DropdownMenuItem(
            value: entry.key,
            child: Text(
              entry.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList();
    if (telurItems.isEmpty) {
      telurItems.add(
        DropdownMenuItem(
          value: row.jenis,
          child: Text(row.jenis, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      );
    }

    return IFSectionCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: row.jenis,
            isExpanded: true,
            borderRadius: AppCorners.sm,
            dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            decoration: const InputDecoration(labelText: 'Jenis Telur'),
            items: telurItems,
            onChanged: (value) => onChanged(
              EggRow(jenis: value ?? row.jenis, kg: row.kg, butir: row.butir),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            initialValue: row.kg.toString(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Kg'),
            onChanged: (value) => onChanged(
              EggRow(
                jenis: row.jenis,
                kg: double.tryParse(value.trim()) ?? 0,
                butir: row.butir,
              ),
            ),
          ),
          if (manualMode) ...[
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              initialValue: row.butir.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Butir'),
              onChanged: (value) => onChanged(
                EggRow(
                  jenis: row.jenis,
                  kg: row.kg,
                  butir: int.tryParse(value.trim()) ?? 0,
                ),
              ),
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: AppTheme.destructiveTextButtonStyle(context),
              onPressed: onRemove,
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: AppIconSize.md,
              ),
              label: const Text('Hapus'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerlakuanRowEditor extends StatelessWidget {
  const _PerlakuanRowEditor({
    required this.row,
    required this.treatmentTypes,
    required this.qtyUnits,
    required this.onChanged,
    required this.onRemove,
  });

  final PerlakuanRow row;
  final Map<String, String> treatmentTypes;
  final Map<String, String> qtyUnits;
  final ValueChanged<PerlakuanRow> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final treatmentItems = treatmentTypes.entries
        .map(
          (entry) => DropdownMenuItem(
            value: entry.key,
            child: Text(
              entry.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList();
    if (treatmentItems.isEmpty && row.treatmentType.isNotEmpty) {
      treatmentItems.add(
        DropdownMenuItem(
          value: row.treatmentType,
          child: Text(
            row.treatmentType,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    final unitItems = qtyUnits.entries
        .map(
          (entry) => DropdownMenuItem(
            value: entry.key,
            child: Text(
              entry.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList();
    if (unitItems.isEmpty) {
      unitItems.add(
        DropdownMenuItem(
          value: row.qtyUnit,
          child: Text(
            row.qtyUnit,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return IFSectionCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: row.treatmentType.isEmpty ? null : row.treatmentType,
            isExpanded: true,
            borderRadius: AppCorners.sm,
            dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            decoration: const InputDecoration(labelText: 'Treatment Type'),
            items: treatmentItems,
            onChanged: (value) => onChanged(
              PerlakuanRow(
                treatmentType: value ?? '',
                medicineName: row.medicineName,
                qtyGram: row.qtyGram,
                qtyUnit: row.qtyUnit,
                keterangan: row.keterangan,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            initialValue: row.medicineName,
            decoration: const InputDecoration(labelText: 'Nama Obat'),
            onChanged: (value) => onChanged(
              PerlakuanRow(
                treatmentType: row.treatmentType,
                medicineName: value,
                qtyGram: row.qtyGram,
                qtyUnit: row.qtyUnit,
                keterangan: row.keterangan,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            initialValue: row.qtyGram.toString(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Qty'),
            onChanged: (value) => onChanged(
              PerlakuanRow(
                treatmentType: row.treatmentType,
                medicineName: row.medicineName,
                qtyGram: double.tryParse(value.trim()) ?? 0,
                qtyUnit: row.qtyUnit,
                keterangan: row.keterangan,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: row.qtyUnit,
            isExpanded: true,
            borderRadius: AppCorners.sm,
            dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            decoration: const InputDecoration(labelText: 'Satuan'),
            items: unitItems,
            onChanged: (value) => onChanged(
              PerlakuanRow(
                treatmentType: row.treatmentType,
                medicineName: row.medicineName,
                qtyGram: row.qtyGram,
                qtyUnit: value ?? row.qtyUnit,
                keterangan: row.keterangan,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            initialValue: row.keterangan ?? '',
            decoration: const InputDecoration(
              labelText: 'Keterangan (opsional)',
            ),
            onChanged: (value) => onChanged(
              PerlakuanRow(
                treatmentType: row.treatmentType,
                medicineName: row.medicineName,
                qtyGram: row.qtyGram,
                qtyUnit: row.qtyUnit,
                keterangan: value.trim().isEmpty ? null : value,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: AppTheme.destructiveTextButtonStyle(context),
              onPressed: onRemove,
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: AppIconSize.md,
              ),
              label: const Text('Hapus'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionsErrorView extends StatelessWidget {
  const _OptionsErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    String message = 'Gagal memuat opsi form recording.';
    var unsupportedServer = false;

    if (error is ApiException) {
      final apiError = error as ApiException;
      message = apiError.message;
      unsupportedServer = apiError.statusCode == 404;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: IFEmptyState(
          icon: Icons.cloud_off_outlined,
          title: unsupportedServer
              ? 'Server belum support endpoint ini.'
              : 'Gagal memuat opsi recording.',
          message:
              '$message\n\nSubmit dinonaktifkan sampai opsi form tersedia.',
          action: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
      ),
    );
  }
}
