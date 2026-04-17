import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/survey_service.dart';
import '../../widgets/primary_button.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  final improvementController = TextEditingController();

  String wouldHireAgain = 'Sí';
  int rating = 3;
  bool isLoading = false;
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    improvementController.dispose();
    super.dispose();
  }

  Future<void> submitSurvey() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        autoValidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await SurveyService.instance.submitSurvey(
        userId: firebaseUser.uid,
        wouldHireAgain: wouldHireAgain == 'Sí',
        rating: rating,
        improvement: improvementController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Encuesta enviada correctamente')),
      );

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar la encuesta')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encuesta de satisfacción'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '¡Tu opinión es importante para nosotros!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 10),
          Text(
            'Ayúdanos a mejorar nuestros servicios respondiendo esta breve encuesta.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          sectionTitle('¿Volverías a contratar nuestros servicios?'),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment<String>(
                value: 'Sí',
                label: Text('Sí'),
                icon: Icon(Icons.thumb_up_alt_outlined),
              ),
              ButtonSegment<String>(
                value: 'No',
                label: Text('No'),
                icon: Icon(Icons.thumb_down_alt_outlined),
              ),
            ],
            selected: {wouldHireAgain},
            onSelectionChanged: (value) {
              setState(() {
                wouldHireAgain = value.first;
              });
            },
          ),
          const SizedBox(height: 24),
          sectionTitle('¿Cómo evalúas la calidad de nuestros servicios?'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Slider(
                    value: rating.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '$rating',
                    onChanged: (value) {
                      setState(() {
                        rating = value.round();
                      });
                    },
                  ),
                  Text(
                    'Calificación: $rating / 5',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          sectionTitle('¿Tienes alguna propuesta de mejora sugerida?'),
          Form(
            key: _formKey,
            autovalidateMode: autoValidateMode,
            child: TextFormField(
              controller: improvementController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Escribe tu sugerencia aquí',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Escribe una propuesta de mejora';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Enviar encuesta',
            isLoading: isLoading,
            onPressed: submitSurvey,
          ),
        ],
      ),
    );
  }
}