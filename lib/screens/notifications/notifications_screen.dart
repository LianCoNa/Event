import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../widgets/empty_state_widget.dart';
import '../auth/login_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String formatTimestamp(dynamic value) {
    return 'Reciente';
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notificaciones')),
        body: EmptyStateWidget(
          icon: Icons.notifications_off_outlined,
          title: 'No puedes ver notificaciones',
          subtitle: 'Inicia sesión para revisar tus avisos y actualizaciones.',
          buttonText: 'Iniciar sesión',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
            );
          },
        ),
      );
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: NotificationService.instance.getNotifications(firebaseUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final notifications = snapshot.data ?? [];
        final unreadCount =
            notifications.where((item) => item['isRead'] == false).length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notificaciones'),
            actions: [
              if (notifications.isNotEmpty)
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'read') {
                      await NotificationService.instance
                          .markAllAsRead(firebaseUser.uid);

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notificaciones marcadas como leídas'),
                        ),
                      );
                    }

                    if (value == 'clear') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Limpiar notificaciones'),
                            content: const Text(
                              '¿Seguro que deseas eliminar todas tus notificaciones?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm != true) return;

                      await NotificationService.instance
                          .clearUserNotifications(firebaseUser.uid);

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notificaciones eliminadas'),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'read',
                      child: Text('Marcar todas como leídas'),
                    ),
                    PopupMenuItem(
                      value: 'clear',
                      child: Text('Limpiar todas'),
                    ),
                  ],
                ),
            ],
          ),
          body: notifications.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.notifications_none_rounded,
                  title: 'No tienes notificaciones',
                  subtitle:
                      'Cuando ocurran acciones importantes en Eventia, aparecerán aquí.',
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (unreadCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          '$unreadCount sin leer',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.green,
                                  ),
                        ),
                      ),
                    ...notifications.map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: item['isRead'] == true
                              ? Colors.white
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: Icon(
                              item['isRead'] == true
                                  ? Icons.notifications_none_rounded
                                  : Icons.notifications_active_rounded,
                              color: Colors.green,
                            ),
                          ),
                          title: Text(
                            item['title'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${item['message'] ?? ''}\n${formatTimestamp(item['createdAt'])}',
                            ),
                          ),
                          isThreeLine: true,
                          onTap: () async {
                            if (item['isRead'] != true) {
                              await NotificationService.instance
                                  .markAsRead(item['id']);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}