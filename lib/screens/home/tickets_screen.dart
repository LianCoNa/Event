import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../events/event_detail_screen.dart';
import '../../models/event_model.dart';
import '../../services/ticket_service.dart';
import '../../widgets/empty_state_widget.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mis entradas')),
        body: EmptyStateWidget(
          icon: Icons.qr_code_2_rounded,
          title: 'Tus entradas te esperan',
          subtitle:
              'Inicia sesión para ver tus eventos registrados y tu código QR de acceso.',
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
      stream: TicketService.instance.getUserTickets(firebaseUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final tickets = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(title: const Text('Mis entradas')),
          body: tickets.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.confirmation_num_outlined,
                  title: 'No tienes entradas aún',
                  subtitle:
                      'Cuando te registres a un evento, tu QR aparecerá aquí automáticamente.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: tickets.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];

                    final event = EventModel(
                      id: ticket['eventId'] ?? '',
                      title: ticket['title'] ?? '',
                      date: ticket['date'] ?? '',
                      time: ticket['time'] ?? '',
                      location: ticket['location'] ?? '',
                      description: 'Tu entrada registrada en Eventia.',
                      category: ticket['category'] ?? 'General',
                      isFree: true,
                      distance: '0 km',
                      organizer: 'Eventia',
                      filterTag: 'Este mes',
                      imageUrl: ticket['imageUrl'] ?? '',
                    );

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket['title'] ?? '',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text('${ticket['date']} • ${ticket['time']}'),
                            const SizedBox(height: 4),
                            Text(ticket['location'] ?? ''),
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
                                    onPressed: () async {
                                      try {
                                        await TicketService.instance.removeTicket(
                                          eventId: ticket['eventId'] ?? '',
                                          userId: firebaseUser.uid,
                                        );

                                        if (!context.mounted) return;

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Entrada eliminada'),
                                          ),
                                        );
                                      } catch (_) {
                                        if (!context.mounted) return;

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'No se pudo eliminar la entrada',
                                            ),
                                          ),
                                        );
                                      }
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