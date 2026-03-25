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

  void _search(String value) {
    setState(() {
      results = AppState.instance.searchEvents(value);
    });
  }

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
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SearchBarWidget(
            hintText: 'Busca música, negocios, diseño...',
            controller: controller,
            onChanged: _search,
          ),
          const SizedBox(height: 20),
          Text(
            'Resultados',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 14),
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'No encontramos eventos con esa búsqueda.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ...results.map(
            (event) => Padding(
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
            ),
          ),
        ],
      ),
    );
  }
}