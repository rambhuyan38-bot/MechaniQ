import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/vehicle_model.dart';
import '../utils/app_colors.dart';
import '../widgets/glowing_button.dart';
import '../widgets/neon_card.dart';

class GarageScreen extends StatelessWidget {
  const GarageScreen({Key? key}) : super(key: key);

  void _showAddVehicleDialog(BuildContext context) {
    final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
    final makeController = TextEditingController();
    final modelController = TextEditingController();
    final yearController = TextEditingController();
    final vinController = TextEditingController();
    final engineController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24.0,
            left: 20.0,
            right: 20.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ENLIST NEW VEHICLE',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNeonBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: makeController,
                  decoration: const InputDecoration(labelText: 'Manufacturer / Brand (e.g. BMW)'),
                ),
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(labelText: 'Model Spec (e.g. M3 Competiton)'),
                ),
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Year of Build'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: vinController,
                  decoration: const InputDecoration(labelText: 'Chassis VIN ID (17 Chars)'),
                ),
                TextField(
                  controller: engineController,
                  decoration: const InputDecoration(labelText: 'Engine Spec (e.g. 3.0L Inline-6 Turbo)'),
                ),
                const SizedBox(height: 30.0),
                GlowingButton(
                  onTap: () {
                    if (makeController.text.isNotEmpty && modelController.text.isNotEmpty) {
                      vehicleProvider.addVehicle(
                        Vehicle(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          make: makeController.text,
                          model: modelController.text,
                          year: yearController.text,
                          vin: vinController.text,
                          engineType: engineController.text,
                          status: 'Ready to Scan',
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  text: 'Register to Garage',
                ),
                const SizedBox(height: 30.0),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = Provider.of<VehicleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MECHANIQ GARAGE'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlowingButton(
              onTap: () => _showAddVehicleDialog(context),
              text: 'Add Custom Vehicle',
              icon: Icons.add_circle_outline,
            ),
            const SizedBox(height: 24.0),
            const Text(
              'ACTIVE FLEET CHIPS',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12.0),
            Expanded(
              child: ListView.builder(
                itemCount: vehicleProvider.vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicleProvider.vehicles[index];
                  final isSelected = vehicle == vehicleProvider.selectedVehicle;

                  return GestureDetector(
                    onTap: () => vehicleProvider.selectVehicle(index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: NeonCard(
                        borderColor: isSelected ? AppColors.primaryNeonBlue : AppColors.borderCyan.withOpacity(0.3),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? AppColors.primaryNeonBlue.withOpacity(0.15) : Colors.white10,
                              ),
                              child: Icon(
                                Icons.directions_car_filled,
                                color: isSelected ? AppColors.primaryNeonBlue : AppColors.textSecondary,
                                size: 30.0,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${vehicle.make} ${vehicle.model}'.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      fontFamily: 'Orbitron',
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'Year: ${vehicle.year} | Eng: ${vehicle.engineType}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.0),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'VIN: ${vehicle.vin}',
                                    style: const TextStyle(color: Colors.white38, fontSize: 11.0),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primaryNeonBlue,
                                size: 28.0,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}