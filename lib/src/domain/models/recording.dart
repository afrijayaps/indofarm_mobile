class EggRow {
  const EggRow({
    required this.jenis,
    required this.kg,
    required this.butir,
  });

  final String jenis;
  final double kg;
  final int butir;

  factory EggRow.fromJson(Map<String, dynamic> json) {
    return EggRow(
      jenis: json['jenis']?.toString() ?? 'utuh',
      kg: (json['kg'] as num?)?.toDouble() ?? 0,
      butir: (json['butir'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jenis': jenis,
      'kg': kg,
      'butir': butir,
    };
  }
}

class RecordingPayload {
  const RecordingPayload({
    required this.farmId,
    required this.cageId,
    required this.tanggal,
    required this.pakanPagiKg,
    required this.pakanSoreKg,
    required this.telurRows,
    this.pakanTotalKg,
    this.mortalitas,
    this.suhu,
    this.kelembaban,
  });

  final int farmId;
  final int cageId;
  final String tanggal;
  final double pakanPagiKg;
  final double pakanSoreKg;
  final List<EggRow> telurRows;
  final double? pakanTotalKg;
  final int? mortalitas;
  final double? suhu;
  final double? kelembaban;

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'cage_id': cageId,
      'tanggal': tanggal,
      'pakan_pagi_kg': pakanPagiKg,
      'pakan_sore_kg': pakanSoreKg,
      'telur_rows': telurRows.map((e) => e.toJson()).toList(),
    };

    if (pakanTotalKg != null) {
      payload['pakan_total_kg'] = pakanTotalKg;
    }
    if (mortalitas != null) {
      payload['mortalitas'] = mortalitas;
    }
    if (suhu != null) {
      payload['suhu'] = suhu;
    }
    if (kelembaban != null) {
      payload['kelembaban'] = kelembaban;
    }

    return payload;
  }
}

enum DraftStatus { pending, synced, failed }

class RecordingDraft {
  const RecordingDraft({
    required this.id,
    required this.payload,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final RecordingPayload payload;
  final DraftStatus status;
  final DateTime createdAt;
}
