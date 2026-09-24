class TelemetryData {
  final double rpm;
  final double speed;
  final double coolantTemp;
  final double engineLoad;
  final double fuelPressure;
  final double voltage;

  TelemetryData({
    required this.rpm,
    required this.speed,
    required this.coolantTemp,
    required this.engineLoad,
    required this.fuelPressure,
    required this.voltage,
  });

  factory TelemetryData.initial() {
    return TelemetryData(
      rpm: 0.0,
      speed: 0.0,
      coolantTemp: 0.0,
      engineLoad: 0.0,
      fuelPressure: 0.0,
      voltage: 0.0,
    );
  }
}