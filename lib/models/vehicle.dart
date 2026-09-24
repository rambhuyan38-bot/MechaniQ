class Vehicle {
  final String type; // Two-Wheeler, Car, EV
  final String brand;
  final String model;
  final int year;
  final String fuelType;

  Vehicle({
    required this.type,
    required this.brand,
    required this.model,
    required this.year,
    required this.fuelType,
  });
}

class DtcRecord {
  final String code;
  final String definition;
  final String severity; // Low, Medium, Critical
  final String riderExplanation;
  final String possibleCauses;
  final String recommendedTest;
  final double repairCostOem;
  final double repairCostAftermarket;
  final double laborCost;

  DtcRecord({
    required this.code,
    required this.definition,
    required this.severity,
    required this.riderExplanation,
    required this.possibleCauses,
    required this.recommendedTest,
    required this.repairCostOem,
    required this.repairCostAftermarket,
    required this.laborCost,
  });
}

class PidMetadata {
  final String mode;
  final String pid;
  final String name;
  final double min;
  final double max;
  final String unit;
  final String formula;

  PidMetadata({
    required this.mode,
    required this.pid,
    required this.name,
    required this.min,
    required this.max,
    required this.unit,
    required this.formula,
  });
}