class Vehicle {
  final String id;
  final String make;
  final String model;
  final String year;
  final String vin;
  final String engineType;
  final String status;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.vin,
    required this.engineType,
    required this.status,
  });

  Vehicle copyWith({
    String? id,
    String? make,
    String? model,
    String? year,
    String? vin,
    String? engineType,
    String? status,
  }) {
    return Vehicle(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      engineType: engineType ?? this.engineType,
      status: status ?? this.status,
    );
  }
}