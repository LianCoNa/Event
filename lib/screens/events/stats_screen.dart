import 'package:flutter/material.dart';
import '../../services/stats_service.dart';
import '../../services/survey_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  Widget statCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.green.shade50,
            child: Icon(icon, color: Colors.green),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget surveyCard(BuildContext context, Map<String, dynamic> survey) {
    final bool wouldHireAgain = survey['wouldHireAgain'] ?? false;
    final int rating = survey['rating'] ?? 0;
    final String improvement = survey['improvement'] ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              wouldHireAgain
                  ? 'Volvería a contratarnos: Sí'
                  : 'Volvería a contratarnos: No',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Calificación: $rating / 5'),
            const SizedBox(height: 8),
            Text('Sugerencia: $improvement'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Resumen general',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 18),
          StreamBuilder<Map<String, int>>(
            stream: StatsService.instance.getStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final stats = snapshot.data ??
                  {
                    'users': 0,
                    'events': 0,
                    'tickets': 0,
                    'news': 0,
                    'surveys': 0,
                  };

              return Column(
                children: [
                  statCard(
                    context: context,
                    title: 'Usuarios registrados',
                    value: '${stats['users']}',
                    icon: Icons.people_alt_outlined,
                  ),
                  const SizedBox(height: 14),
                  statCard(
                    context: context,
                    title: 'Eventos creados',
                    value: '${stats['events']}',
                    icon: Icons.event_available_outlined,
                  ),
                  const SizedBox(height: 14),
                  statCard(
                    context: context,
                    title: 'Entradas generadas',
                    value: '${stats['tickets']}',
                    icon: Icons.confirmation_num_outlined,
                  ),
                  const SizedBox(height: 14),
                  statCard(
                    context: context,
                    title: 'Noticias publicadas',
                    value: '${stats['news']}',
                    icon: Icons.newspaper_outlined,
                  ),
                  const SizedBox(height: 14),
                  statCard(
                    context: context,
                    title: 'Encuestas recibidas',
                    value: '${stats['surveys']}',
                    icon: Icons.rate_review_outlined,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          Text(
            'Encuestas recibidas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: SurveyService.instance.getSurveys(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final surveys = snapshot.data ?? [];

              if (surveys.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text('Aún no hay encuestas registradas.'),
                );
              }

              return Column(
                children: surveys
                    .map((survey) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: surveyCard(context, survey),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}