import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import 'edit_event_screen.dart';
import 'event_detail_screen.dart';

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, child) {
        final myEvents = AppState.instance.myCreatedEvents;
        final isAdmin = AppState.instance.isAdmin;
        final visibleEvents = isAdmin ? AppState.instance.allEvents : myEvents;

        return Scaffold(
          appBar: AppBar(
            title: Text(isAdmin ? 'Administrar eventos' : 'Mis eventos'),
          ),
          body: visibleEvents.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      isAdmin
                          ? 'No hay eventos disponibles.'
                          : 'Aún no has creado eventos.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: visibleEvents.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final event = visibleEvents[index];

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: Colors.grey.shade200,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.network(
                                    event.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(
                                      Icons.image_outlined,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.title,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 6),
                                      Text('${event.date} • ${event.time}'),
                                      const SizedBox(height: 4),
                                      Text(event.location),
                                      const SizedBox(height: 6),
                                      Text(
                                        event.isFree ? 'Gratis' : 'Pago',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: event.isFree
                                              ? Colors.green
                                              : Colors.deepOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                                    child: const Text('Ver'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              EditEventScreen(event: event),
                                        ),
                                      );
                                    },
                                    child: const Text('Editar'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () {
                                      AppState.instance.deleteCreatedEvent(event.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Evento eliminado'),
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