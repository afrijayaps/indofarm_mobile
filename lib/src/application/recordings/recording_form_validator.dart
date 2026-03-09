class RecordingFormValidator {
  const RecordingFormValidator();

  String? validateRequired(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field wajib diisi';
    }
    return null;
  }

  String? validateNumber(String? value, String field) {
    if (validateRequired(value, field) != null) {
      return validateRequired(value, field);
    }
    final parsed = num.tryParse(value!.trim());
    if (parsed == null || parsed < 0) {
      return '$field harus angka >= 0';
    }
    return null;
  }

  String? validateDateIso(String? value) {
    if (validateRequired(value, 'Tanggal') != null) {
      return validateRequired(value, 'Tanggal');
    }
    final date = DateTime.tryParse(value!);
    if (date == null) {
      return 'Tanggal harus format YYYY-MM-DD';
    }
    return null;
  }
}
