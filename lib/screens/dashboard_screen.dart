import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/obd_provider.dart';
import '../providers/vehicle_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/telemetry_card.dart';
import '../widgets/glowing_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final obdProvider = Provider.of<ObdProvider>(context);
    final vehicleProvider = Provider.of<VehicleProvider>(context);
    final vehicle = vehicleProvider.selectedVehicle;
    final telemetry = obdProvider.telemetry;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MECHANIQ MONITOR'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: AppColors.primaryNeonBlue),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Identity Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.make} ${vehicle.model}'.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Orbitron',
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'VIN: ${vehicle.vin}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.0),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: obdProvider.connectionState == ObdConnectionState.connected
                        ? AppColors.successNeonGreen.withOpacity(0.15)
                        : AppColors.errorNeonRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: obdProvider.connectionState == ObdConnectionState.connected
                          ? AppColors.successNeonGreen
                          : AppColors.errorNeonRed,
                    ),
                  ),
                  child: Text(
                    obdProvider.connectionState == ObdConnectionState.connected ? 'LINKED' : 'OFFLINE',
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                      color: obdProvider.connectionState == ObdConnectionState.connected
                          ? AppColors.successNeonGreen
                          : AppColors.errorNeonRed,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // OBD Connection control
            if (obdProvider.connectionState == ObdConnectionState.disconnected)
              GlowingButton(
                onTap: () => obdProvider.connectOBD(),
                text: 'Connect OBD2 Scanner',
                icon: Icons.bluetooth_searching,
              )
            else if (obdProvider.connectionState == ObdConnectionState.searching)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primaryNeonBlue)),
                    SizedBox(height: 12.0),
                    Text('Searching for OBD2 Bluetooth Dongle...', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              )
            else if (obdProvider.connectionState == ObdConnectionState.connecting)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.secondaryNeonOrange)),
                    SizedBox(height: 12.0),
                    Text('Reading Engine protocols (CAN-BUS)...', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              )
            else
              GlowingButton(
                onTap: () => obdProvider.disconnectOBD(),
                text: 'Disconnect OBD2 Scanner',
                glowColor: AppColors.secondaryNeonOrange,
                icon: Icons.bluetooth_disabled,
              ),

            const SizedBox(height: 30.0),

            // Live metrics title
            const Text(
              'LIVE ENGINE TELEMETRY',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16.0),

            // Telemetry Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.35,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: [
                TelemetryCard(
                  label: 'Engine RPM',
                  value: obdProvider.connectionState == ObdConnectionState.connected
                      ? telemetry.rpm.toStringAsFixed(0)
                      : '---',
                  unit: 'rpm',
                  progressValue: telemetry.rpm / 8000.0,
                  accentColor: AppColors.primaryNeonBlue,
                  icon: Icons.speed,
                ),
                TelemetryCard(
                  label: 'Vehicle Speed',
                  value: obdProvider.connectionState == ObdConnectionState.connected
                      ? telemetry.speed.toStringAsFixed(0)
                      : '---',
                  unit: 'mph',
                  progressValue: telemetry.speed / 160.0,
                  accentColor: AppColors.successNeonGreen,
                  icon: Icons.alt_route,
                ),
                TelemetryCard(
                  label: 'Coolant Temp',
                  value: obdProvider.connectionState == ObdConnectionState.connected
                      ? telemetry.coolantTemp.toStringAsFixed(1)
                      : '---',
                  unit: '°C',
                  progressValue: telemetry.coolantTemp / 120.0,
                  accentColor: AppColors.secondaryNeonOrange,
                  icon: Icons.thermostat,
                ),
                TelemetryCard(
                  label: 'Engine Load',
                  value: obdProvider.connectionState == ObdConnectionState.connected
                      ? telemetry.engineLoad.toStringAsFixed(1)
                      : '---',
                  unit: '%',
                  progressValue: telemetry.engineLoad / 100.0,
                  accentColor: AppColors.errorNeonRed,
                  icon: Icons.leaderboard,
                ),
              ],
            ),

            const SizedBox(height: 30.0),

            // Dynamic Chart representation
            const Text(
              'CAN-BUS REALTIME STRESS',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              height: 180,
              padding: const EdgeInsets.only(right: 18.0, top: 12.0, bottom: 12.0),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: AppColors.borderCyan, width: 1.0),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 1),
                        FlSpot(1, obdProvider.connectionState == ObdConnectionState.connected ? (telemetry.rpm / 2000) : 0),
                        FlSpot(2, obdProvider.connectionState == ObdConnectionState.connected ? (telemetry.engineLoad / 20) : 0),
                        FlSpot(3, obdProvider.connectionState == ObdConnectionState.connected ? (telemetry.speed / 40) : 0),
                        const FlSpot(4, 2),
                      ],
                      isCurved: true,
                      color: AppColors.primaryNeonBlue,
                      barWidth: 4,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primaryNeonBlue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}