import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../auth/login_screen.dart';
import '../events/event_detail_screen.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, child) {
        final appState = AppState.instance;
        final tickets = appState.myTickets;

        if (!appState.isLoggedIn) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mis entradas')),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 70,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Inicia sesión para ver tus entradas',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text('Iniciar sesión'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Mis entradas')),
          body: tickets.isEmpty
              ? const Center(
                  child: Text('Aún no tienes eventos registrados'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: tickets.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final event = tickets[index];

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text('${event.date} • ${event.time}'),
                            const SizedBox(height: 4),
                            Text(event.location),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              EventDetailScreen(event: event),
                                        ),
                                      );
                                    },
                                    child: const Text('Ver entrada'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () {
                                      AppState.instance.removeTicket(event.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Entrada eliminada'),
                                        ),
                                      );
                                    },
                                    child: const Text('Eliminar'),
                                  ),
                                ),
                              ],
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