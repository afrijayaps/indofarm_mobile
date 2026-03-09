class Farm {
  const Farm({
    required this.id,
    required this.name,
    this.location = '',
  });

  final int id;
  final String name;
  final String location;

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
    );
  }
}
