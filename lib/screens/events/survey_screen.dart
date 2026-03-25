import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../widgets/primary_button.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  bool? wouldHireAgain;
  double rating = 4;
  final TextEditingController improvementController = TextEditingController();

  void submitSurvey() {
    if (wouldHireAgain == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona si volverías a contratar nuestros servicios')),
      );
      return;
    }

    AppState.instance.submitSurvey(
      wouldHireAgain: wouldHireAgain!,
      rating: rating.toInt(),
      improvement: improvementController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Encuesta enviada correctamente')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final appState = AppState.instance;

        if (appState.isAdmin) {
          final surveys = appState.surveys;

          return Scaffold(
            appBar: AppBar(title: const Text('Respuestas de encuestas')),
            body: surveys.isEmpty
                ? Center(
                    child: Text(
                      'Aún no hay encuestas respondidas.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: surveys.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = surveys[index];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Respuesta ${index + 1}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 10),
                              Text('¿Volvería a contratar?: ${item['wouldHireAgain']}'),
                              const SizedBox(height: 6),
                              Text('Calificación: ${item['rating']}/5'),
                              const SizedBox(height: 6),
                              Text(
                                'Propuesta de mejora: ${item['improvement'].toString().isEmpty ? 'Sin comentarios' : item['improvement']}',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Encuesta de satisfacción')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                '¡Tu opinión es importante para nosotros!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 10),
              Text(
                'Ayúdanos respondiendo estas preguntas.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Volverías a contratar nuestros servicios?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 14),
                      RadioListTile<bool>(
                        value: true,
                        groupValue: wouldHireAgain,
                        activeColor: const Color(0xFF2E7D32),
                        title: const Text('Sí'),
                        onChanged: (value) {
                          setState(() {
                            wouldHireAgain = value;
                          });
                        },
                      ),
                      RadioListTile<bool>(
                        value: false,
                        groupValue: wouldHireAgain,
                        activeColor: const Color(0xFF2E7D32),
                        title: const Text('No'),
                        onChanged: (value) {
                          setState(() {
                            wouldHireAgain = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Cómo evalúas la calidad de nuestros servicios?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          rating.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      Slider(
                        value: rating,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: rating.toStringAsFixed(0),
                        onChanged: (value) {
                          setState(() {
                            rating = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Tienes alguna propuesta de mejora sugerida?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: improvementController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Escribe aquí tu propuesta de mejora',
                          prefixIcon: Icon(Icons.edit_note_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Enviar encuesta',
                onPressed: submitSurvey,
              ),
            ],
          ),
        );
      },
    );
  }
}