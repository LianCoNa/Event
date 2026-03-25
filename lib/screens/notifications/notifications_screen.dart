import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../data/app_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final notifications = AppState.instance.notifications;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notificaciones'),
            actions: [
              TextButton(
                onPressed: () {
                  AppState.instance.markAllNotificationsAsRead();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notificaciones marcadas como leídas')),
                  );
                },
                child: const Text('Leer todo'),
              ),
            ],
          ),
          body: notifications.isEmpty
              ? Center(
                  child: Text(
                    'No tienes notificaciones.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = notifications[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        AppState.instance.markNotificationAsRead(item.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: item.isRead ? Colors.white : AppColors.softGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                item.isRead
                                    ? Icons.notifications_none_rounded
                                    : Icons.notifications_active_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(item.message),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.time,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}