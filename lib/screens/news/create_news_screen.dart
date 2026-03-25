import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../models/news_model.dart';
import '../../widgets/primary_button.dart';

class CreateNewsScreen extends StatefulWidget {
  const CreateNewsScreen({super.key});

  @override
  State<CreateNewsScreen> createState() => _CreateNewsScreenState();
}

class _CreateNewsScreenState extends State<CreateNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final tagController = TextEditingController();

  bool isLoading = false;

  Future<void> saveNews() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));

    AppState.instance.addNews(
      NewsModel(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        tag: tagController.text.trim().isEmpty ? 'General' : tagController.text.trim(),
      ),
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Noticia publicada correctamente')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear noticia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Título de la noticia',
                  prefixIcon: Icon(Icons.article_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Descripción',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: tagController,
                decoration: const InputDecoration(
                  hintText: 'Etiqueta',
                  prefixIcon: Icon(Icons.sell_outlined),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Publicar noticia',
                isLoading: isLoading,
                onPressed: saveNews,
              ),
            ],
          ),
        ),
      ),
    );
  }
}