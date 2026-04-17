import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../services/ticket_service.dart';
import '../../widgets/event_card.dart';
import '../auth/login_screen.dart';
import '../events/event_detail_screen.dart';

class AllEventsScreen extends StatelessWidget {
  const AllEventsScreen({super.key});

  Future<void> handleRegister(BuildContext context, EventModel event) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    try {
      final alreadyRegistered = await TicketService.instance.isRegistered(
        eventId: event.id,
        userId: firebaseUser.uid,
      );

      if (alreadyRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya estás registrado en este evento')),
        );
        return;
      }

      await TicketService.instance.registerToEvent(
        event: event,
        userId: firebaseUser.uid,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Te registraste en ${event.title}')),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo registrar la entrada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EventModel>>(
      stream: EventService.instance.getEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final events = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Todos los eventos'),
          ),
          body: events.isEmpty
              ? const Center(
                  child: Text('No hay eventos disponibles'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: EventCard(
                        event: event,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailScreen(event: event),
                            ),
                          );
                        },
                        onRegister: () => handleRegister(context, event),
                        actionText: 'Registrarte',
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}