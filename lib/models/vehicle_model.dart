class VehicleModel {
  final String id;
  final String make;
  final String model;
  final int year;
  final String? vin;
  final String? licensePlate;
  final double mileage;
  final DateTime? lastServiceDate;

  VehicleModel({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.vin,
    this.licensePlate,
    required this.mileage,
    this.lastServiceDate,
  });

  // Convert to Map for Firestore/Local Storage without standard JSON serializers
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'vin': vin,
      'licensePlate': licensePlate,
      'mileage': mileage,
      'lastServiceDate': lastServiceDate?.toIso8601String(),
    };
  }

  // Create VehicleModel from Map
  factory VehicleModel.fromMap(Map<String, dynamic> map, String documentId) {
    return VehicleModel(
      id: documentId,
      make: map['make'] as String? ?? '',
      model: map['model'] as String? ?? '',
      year: map['year'] as int? ?? DateTime.now().year,
      vin: map['vin'] as String?,
      licensePlate: map['licensePlate'] as String?,
      mileage: (map['mileage'] as num?)?.toDouble() ?? 0.0,
      lastServiceDate: map['lastServiceDate'] != null
          ? DateTime.tryParse(map['lastServiceDate'] as String)
          : null,
    );
  }

  // CopyWith helper for state updates
  VehicleModel copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    String? vin,
    String? licensePlate,
    double? mileage,
    DateTime? lastServiceDate,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      licensePlate: licensePlate ?? this.licensePlate,
      mileage: mileage ?? this.mileage,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
    );
  }
}