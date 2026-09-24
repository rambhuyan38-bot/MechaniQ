import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/obd_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/glowing_button.dart';
import '../widgets/neon_card.dart';
import '../models/dtc_model.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final obdProvider = Provider.of<ObdProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DIAGNOSTIC FAULTS'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (obdProvider.connectionState != ObdConnectionState.connected) ...[
              const SizedBox(height: 60.0),
              NeonCard(
                borderColor: AppColors.errorNeonRed,
                child: Column(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 60.0, color: AppColors.errorNeonRed),
                    const SizedBox(height: 16.0),
                    const Text(
                      'OBD2 SCANNER DISCONNECTED',
                      style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      'Please connect to your vehicle OBD2 hardware adapter first under the Dashboard page.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14.0),
                    ),
                    const SizedBox(height: 20.0),
                    GlowingButton(
                      onTap: () => obdProvider.connectOBD(),
                      text: 'Quick Connect',
                      glowColor: AppColors.primaryNeonBlue,
                    )
                  ],
                ),
              ),
            ] else ...[
              NeonCard(
                borderColor: AppColors.primaryNeonBlue,
                child: Column(
                  children: [
                    const Text(
                      'SYSTEM ECU FAULT ANALYSIS',
                      style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      'Executes deep scan against Powertrain, Emissions, Exhaust, and Electrical modules.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13.0),
                    ),
                    const SizedBox(height: 20.0),
                    if (obdProvider.isScanning)
                      const Column(
                        children: [
                          SpinKitRing(color: AppColors.primaryNeonBlue, size: 50),
                          SizedBox(height: 12.0),
                          Text('Injecting CAN Diagnostic signals...', style: TextStyle(color: AppColors.primaryNeonBlue)),
                        ],
                      )
                    else
                      GlowingButton(
                        onTap: () => obdProvider.runDiagnostics(),
                        text: 'Execute Scan Engine',
                        icon: Icons.troubleshoot,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30.0),
              if (obdProvider.activeCodes.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DETECTED FAULT CODES (${obdProvider.activeCodes.length})',
                      style: const TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold, fontSize: 14.0),
                    ),
                    TextButton(
                      onPressed: () => obdProvider.clearCodes(),
                      child: const Text('CLEAR ALL', style: TextStyle(color: AppColors.errorNeonRed, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 10.0),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: obdProvider.activeCodes.length,
                  itemBuilder: (context, index) {
                    final dtc = obdProvider.activeCodes[index];
                    return _buildDtcCard(context, dtc);
                  },
                ),
              ] else if (!obdProvider.isScanning) ...[
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: const [
                      Icon(Icons.check_circle_outline, size: 60.0, color: AppColors.successNeonGreen),
                      SizedBox(height: 12.0),
                      Text('ALL ECU CHIPS OPTIMAL', style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold)),
                      SizedBox(height: 6.0),
                      Text('No pending fault codes detected in standard registry.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13.0)),
                    ],
                  ),
                )
              ]
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDtcCard(BuildContext context, DiagnosticTroubleCode dtc) {
    Color severityColor;
    switch (dtc.severity) {
      case DtcSeverity.critical:
        severityColor = AppColors.errorNeonRed;
        break;
      case DtcSeverity.warning:
        severityColor = AppColors.secondaryNeonOrange;
        break;
      case DtcSeverity.advisory:
        severityColor = AppColors.primaryNeonBlue;
        break;
    }

    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: severityColor.withOpacity(0.4), width: 1.0),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: severityColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: severityColor),
              ),
              child: Text(
                dtc.code,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.bold,
                  color: severityColor,
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dtc.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                  ),
                  Text(
                    dtc.system,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.0),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(color: Colors.white12),
                const SizedBox(height: 8.0),
                const Text('SYMPTOM & CAUSE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0, color: AppColors.textSecondary)),
                const SizedBox(height: 4.0),
                Text(dtc.description, style: const TextStyle(fontSize: 13.0, height: 1.4)),
                const SizedBox(height: 16.0),
                const Text('MECHANIQ AI DETAILED DECODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0, color: AppColors.primaryNeonBlue)),
                const SizedBox(height: 4.0),
                Text(dtc.aiAnalysis, style: const TextStyle(fontSize: 13.0, height: 1.4, fontStyle: FontStyle.italic)),
                const SizedBox(height: 16.0),
                const Text('RECOMMENDED REMEDIATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0, color: AppColors.successNeonGreen)),
                const SizedBox(height: 6.0),
                ...dtc.resolutionSteps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.arrow_right_alt, color: AppColors.successNeonGreen, size: 16.0),
                      const SizedBox(width: 6.0),
                      Expanded(child: Text(step, style: const TextStyle(fontSize: 12.0))),
                    ],
                  ),
                )),
              ],
            ),
          )
        ],
      ),
    );
  }
}