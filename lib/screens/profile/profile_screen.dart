import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../events/create_event_screen.dart';
import '../events/my_events_screen.dart';
import '../events/stats_screen.dart';
import '../news/create_news_screen.dart';
import '../news/news_screen.dart';

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
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, authSnapshot) {
        final firebaseUser = authSnapshot.data;

        if (firebaseUser == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Perfil')),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  const SizedBox(height: 30),
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.green.shade50,
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 42,
                      color: Colors.green,
                    ),
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

        return StreamBuilder<Map<String, dynamic>?>(
          stream: AuthService.instance
              .currentUserDocStream()
              .map((doc) => doc.data()),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final userData = userSnapshot.data ?? {};
            final String name = userData['name'] ?? 'Usuario';
            final String lastName = userData['lastName'] ?? '';
            final String email = userData['email'] ?? firebaseUser.email ?? '';
            final bool isAdmin = userData['isAdmin'] ?? false;

            final String fullName = '$name $lastName'.trim();

            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: NotificationService.instance.getNotifications(firebaseUser.uid),
              builder: (context, notificationSnapshot) {
                final unreadCount = (notificationSnapshot.data ?? [])
                    .where((item) => item['isRead'] == false)
                    .length;

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Perfil'),
                    actions: [
                      if (unreadCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  body: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const SizedBox(height: 10),
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.green.shade50,
                        child: Icon(
                          isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                          size: 42,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        fullName.isEmpty ? 'Usuario' : fullName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? Colors.green.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isAdmin ? 'Administrador' : 'Usuario',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isAdmin ? Colors.green.shade800 : Colors.black87,
                            ),
                          ),
                        ),
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
                      if (isAdmin)
                        optionTile(
                          context: context,
                          title: 'Crear noticia',
                          icon: Icons.campaign_outlined,
                          page: const CreateNewsScreen(),
                        ),
                      if (isAdmin)
                        optionTile(
                          context: context,
                          title: 'Estadísticas',
                          icon: Icons.bar_chart_rounded,
                          page: const StatsScreen(),
                        ),
                      const SizedBox(height: 20),
                      FilledButton.tonal(
                        onPressed: () async {
                          await AuthService.instance.logout();

                          if (!context.mounted) return;

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
          },
        );
      },
    );
  }
}