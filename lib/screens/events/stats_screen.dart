import 'package:flutter/material.dart';
import '../../app/constants.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  Widget statCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          children: [
            statCard(context, 'Eventos creados', '12', Icons.event),
            statCard(context, 'Asistentes', '385', Icons.people_alt_rounded),
            statCard(context, 'Ingresos QR', '341', Icons.qr_code_scanner_rounded),
            statCard(context, 'Satisfacción', '4.8', Icons.star_rounded),
          ],
        ),
      ),
    );
  }
}