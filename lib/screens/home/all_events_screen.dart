import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../models/event_model.dart';
import '../auth/login_screen.dart';
import '../events/event_detail_screen.dart';
import '../../widgets/event_card.dart';

class AllEventsScreen extends StatelessWidget {
  const AllEventsScreen({super.key});

  void _handleRegister(BuildContext context, EventModel event) {
    final appState = AppState.instance;

    if (!appState.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    if (!appState.isRegisteredToEvent(event.id)) {
      appState.registerToEvent(event);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Te registraste en ${event.title}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final events = AppState.instance.allEvents;

        return Scaffold(
          appBar: AppBar(title: const Text('Todos los eventos')),
          body: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
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
                  onRegister: () => _handleRegister(context, event),
                  actionText: AppState.instance.isRegisteredToEvent(event.id)
                      ? 'Registrado'
                      : 'Registrarte',
                ),
              );
            },
          ),
        );
      },
    );
  }
}