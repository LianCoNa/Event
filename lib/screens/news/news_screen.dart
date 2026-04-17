import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/news_model.dart';
import '../../services/auth_service.dart';
import '../../services/news_service.dart';
import '../../widgets/empty_state_widget.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<List<NewsModel>>(
      stream: NewsService.instance.getNews(),
      builder: (context, newsSnapshot) {
        if (newsSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final news = newsSnapshot.data ?? [];

        if (firebaseUser == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Noticias'),
            ),
            body: news.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.newspaper_outlined,
                    title: 'No hay noticias disponibles',
                    subtitle: 'Cuando el administrador publique noticias, aparecerán aquí.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: news.length,
                    itemBuilder: (context, index) {
                      final item = news[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item.tag,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.description,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        }

        return StreamBuilder<Map<String, dynamic>?>(
          stream:
              AuthService.instance.currentUserDocStream().map((doc) => doc.data()),
          builder: (context, userSnapshot) {
            final userData = userSnapshot.data ?? {};
            final bool isAdmin = userData['isAdmin'] ?? false;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Noticias'),
              ),
              body: news.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.newspaper_outlined,
                      title: 'No hay noticias disponibles',
                      subtitle:
                          'Cuando se publiquen noticias, aparecerán aquí.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: news.length,
                      itemBuilder: (context, index) {
                        final item = news[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        item.tag,
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isAdmin)
                                      IconButton(
                                        tooltip: 'Eliminar noticia',
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text('Eliminar noticia'),
                                                content: const Text(
                                                  '¿Seguro que deseas eliminar esta noticia?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context, false);
                                                    },
                                                    child: const Text('Cancelar'),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () {
                                                      Navigator.pop(context, true);
                                                    },
                                                    child: const Text('Eliminar'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (confirm != true) return;

                                          try {
                                            await NewsService.instance
                                                .deleteNews(item.id);

                                            if (!context.mounted) return;

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content:
                                                    Text('Noticia eliminada correctamente'),
                                              ),
                                            );
                                          } catch (_) {
                                            if (!context.mounted) return;

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content:
                                                    Text('No se pudo eliminar la noticia'),
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.description,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    height: 1.45,
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
      },
    );
  }
}