import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.mark_email_read_outlined, size: 80, color: Color(0xFF2E7D32)),
            const SizedBox(height: 18),
            Text(
              '¿Olvidaste tu contraseña?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              'Te enviaremos un enlace de recuperación a tu correo.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Ingresa tu correo',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              text: 'Enviar enlace',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Correo enviado a ${emailController.text}')),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}