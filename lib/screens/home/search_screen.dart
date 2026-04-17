import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../services/ticket_service.dart';
import '../../widgets/event_card.dart';
import '../../widgets/search_bar_widget.dart';
import '../auth/login_screen.dart';
import '../events/event_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController controller = TextEditingController();
  String query = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<EventModel> filterEvents(List<EventModel> events) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return events;

    return events.where((event) {
      return event.title.toLowerCase().contains(normalized) ||
          event.category.toLowerCase().contains(normalized) ||
          event.location.toLowerCase().contains(normalized) ||
          event.organizer.toLowerCase().contains(normalized);
    }).toList();
  }

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
        final results = filterEvents(events);

        return Scaffold(
          appBar: AppBar(title: const Text('Buscar eventos')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SearchBarWidget(
                hintText: 'Busca por nombre, categoría, ubicación...',
                controller: controller,
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              if (results.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                    child: Text('No se encontraron eventos'),
                  ),
                ),
              ...results.map(
                (event) => Padding(
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}