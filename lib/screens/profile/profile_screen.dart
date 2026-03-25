import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../app/routes.dart';
import '../../data/app_state.dart';
import '../../widgets/primary_button.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget option(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.softGreen,
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        onTap: () {
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final appState = AppState.instance;

        if (!appState.isLoggedIn) {
          return Scaffold(
            appBar: AppBar(title: const Text('Perfil')),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColors.softGreen,
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 42,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tu perfil en Eventia',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia sesión o crea una cuenta para ver tus entradas y gestionar tus eventos.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  text: 'Iniciar sesión',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Crear cuenta'),
                  ),
                ),
              ],
            ),
          );
        }

        if (appState.isAdmin) {
          return Scaffold(
            appBar: AppBar(title: const Text('Panel administrador')),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColors.softGreen,
                        child: Icon(Icons.admin_panel_settings_rounded,
                            size: 42, color: AppColors.primary),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Administrador',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Control total de la aplicación',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                option(context, 'Crear evento', Icons.add_circle_outline, AppRoutes.createEvent),
                const SizedBox(height: 12),
                option(context, 'Administrar eventos', Icons.event_note_outlined, AppRoutes.myEvents),
                const SizedBox(height: 12),
                option(context, 'Ver estadísticas', Icons.bar_chart_rounded, AppRoutes.stats),
                const SizedBox(height: 12),
                option(context, 'Ver encuestas', Icons.assignment_outlined, AppRoutes.survey),
                const SizedBox(height: 12),
                option(context, 'Noticias', Icons.article_outlined, AppRoutes.news),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {
                    AppState.instance.logout();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sesión cerrada')),
                    );
                  },
                  child: const Text('Cerrar sesión'),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Perfil')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 42,
                      backgroundColor: AppColors.softGreen,
                      child: Icon(Icons.person, size: 42, color: AppColors.primary),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      appState.userName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Usuario activo',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              option(context, 'Crear evento', Icons.add_circle_outline, AppRoutes.createEvent),
              const SizedBox(height: 12),
              option(context, 'Mis eventos', Icons.event_note_outlined, AppRoutes.myEvents),
              const SizedBox(height: 12),
              option(context, 'Estadísticas', Icons.bar_chart_rounded, AppRoutes.stats),
              const SizedBox(height: 12),
              option(context, 'Encuesta de satisfacción', Icons.star_outline_rounded, AppRoutes.survey),
              const SizedBox(height: 12),
              option(context, 'Noticias', Icons.article_outlined, AppRoutes.news),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () {
                  AppState.instance.logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sesión cerrada')),
                  );
                },
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        );
      },
    );
  }
}