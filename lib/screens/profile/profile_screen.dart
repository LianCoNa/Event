import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../events/create_event_screen.dart';
import '../events/my_events_screen.dart';
import '../news/create_news_screen.dart';
import '../news/news_screen.dart';
import '../events/stats_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget optionTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget page,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, child) {
        final appState = AppState.instance;

        if (!appState.isLoggedIn) {
          return Scaffold(
            appBar: AppBar(title: const Text('Perfil')),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  const SizedBox(height: 30),
                  const CircleAvatar(
                    radius: 42,
                    child: Icon(Icons.person_outline, size: 42),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Bienvenido',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Inicia sesión o crea una cuenta para acceder a más funciones.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text('Iniciar sesión'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Crear cuenta'),
                  ),
                  const SizedBox(height: 24),
                  optionTile(
                    context: context,
                    title: 'Noticias',
                    icon: Icons.newspaper_outlined,
                    page: const NewsScreen(),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Perfil')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.green.shade50,
                child: const Icon(Icons.person, size: 42, color: Colors.green),
              ),
              const SizedBox(height: 16),
              Text(
                appState.userName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                appState.userEmail,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              optionTile(
                context: context,
                title: 'Mis eventos',
                icon: Icons.event_note_rounded,
                page: const MyEventsScreen(),
              ),
              optionTile(
                context: context,
                title: 'Crear evento',
                icon: Icons.add_circle_outline_rounded,
                page: const CreateEventScreen(),
              ),
              optionTile(
                context: context,
                title: 'Noticias',
                icon: Icons.newspaper_outlined,
                page: const NewsScreen(),
              ),
              if (appState.isAdmin)
                optionTile(
                  context: context,
                  title: 'Crear noticia',
                  icon: Icons.campaign_outlined,
                  page: const CreateNewsScreen(),
                ),
              if (appState.isAdmin)
                optionTile(
                  context: context, 
                  title: 'Estadístcas', 
                  icon: Icons.bar_chart_rounded, 
                  page: const StatsScreen()
                  ),
              const SizedBox(height: 20),
              FilledButton.tonal(
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