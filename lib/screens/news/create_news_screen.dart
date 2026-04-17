import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/news_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/global_loading_overlay.dart';
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

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    tagController.dispose();
    super.dispose();
  }

  Future<void> saveNews() async {
    if (!_formKey.currentState!.validate()) return;

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión')),
      );
      return;
    }

    setState(() => isLoading = true);
    GlobalLoadingOverlay.show(
      context,
      message: 'Estamos publicando la noticia...',
    );

    try {
      await NewsService.instance.createNews(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        tag: tagController.text.trim().isEmpty
            ? 'General'
            : tagController.text.trim(),
        createdBy: firebaseUser.uid,
      );

      await NotificationService.instance.notifyAllUsers(
        title: 'Nueva noticia publicada',
        message: titleController.text.trim(),
        excludeUserId: firebaseUser.uid,
      );

      if (!mounted) return;
      GlobalLoadingOverlay.hide(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Noticia publicada correctamente')),
      );

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      GlobalLoadingOverlay.hide(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo publicar la noticia')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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