import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../models/event_model.dart';
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
  List<EventModel> results = AppState.instance.allEvents;

  @override
  void initState() {
    super.initState();
    results = AppState.instance.allEvents;
  }

  void search(String value) {
    setState(() {
      results = AppState.instance.searchEvents(value);
    });
  }

  void handleRegister(BuildContext context, EventModel event) {
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
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Buscar eventos')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SearchBarWidget(
                hintText: 'Busca por nombre, categoría, ubicación...',
                controller: controller,
                onChanged: search,
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
                    actionText: AppState.instance.isRegisteredToEvent(event.id)
                        ? 'Registrado'
                        : 'Registrarte',
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