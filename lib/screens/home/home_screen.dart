import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../data/app_state.dart';
import '../../models/event_model.dart';
import '../../widgets/event_card.dart';
import '../../widgets/search_bar_widget.dart';
import '../auth/login_screen.dart';
import '../events/event_detail_screen.dart';
import '../notifications/notifications_screen.dart';
import 'all_events_screen.dart';
import 'main_navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = 'Todos';
  final TextEditingController searchController = TextEditingController();

  final List<String> categories = const [
    'Todos',
    'Música',
    'Tecnología',
    'Negocios',
    'Diseño',
    'Gratis',
    'Pago',
  ];

  List<EventModel> getFilteredEvents() {
    final appState = AppState.instance;
    List<EventModel> baseList = appState.allEvents;

    if (selectedFilter != 'Todos') {
      if (selectedFilter == 'Gratis') {
        baseList = baseList.where((e) => e.isFree).toList();
      } else if (selectedFilter == 'Pago') {
        baseList = baseList.where((e) => !e.isFree).toList();
      } else {
        baseList = baseList.where((e) => e.category == selectedFilter).toList();
      }
    }

    return baseList;
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
    }
  }

  Widget buildFilterChip(String label) {
    final selected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.darkText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget categoryOverviewCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.softGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.softGreen,
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.mutedText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void goToSearchTab() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(initialIndex: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final appState = AppState.instance;
        final featured = getFilteredEvents();

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Eventia'),
            actions: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                  if (appState.unreadNotificationsCount > 0)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            appState.unreadNotificationsCount > 9
                                ? '9+'
                                : '${appState.unreadNotificationsCount}',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
              children: [
                Text(
                  'Bienvenido a Eventia',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 30,
                      ),
                ),
                const SizedBox(height: 16),
                SearchBarWidget(
                  hintText: 'Buscar eventos...',
                  controller: searchController,
                  readOnly: true,
                  onTap: goToSearchTab,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.softGreen,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'CATEGORÍAS DISPONIBLES EVENTIA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      categoryOverviewCard(
                        icon: Icons.music_note_rounded,
                        title: 'Música',
                        subtitle: 'Conciertos y shows',
                      ),
                      categoryOverviewCard(
                        icon: Icons.devices_rounded,
                        title: 'Tecnología',
                        subtitle: 'Innovación digital',
                      ),
                      categoryOverviewCard(
                        icon: Icons.business_center_rounded,
                        title: 'Negocios',
                        subtitle: 'Foros y networking',
                      ),
                      categoryOverviewCard(
                        icon: Icons.palette_rounded,
                        title: 'Diseño',
                        subtitle: 'Creatividad y UX',
                      ),
                      categoryOverviewCard(
                        icon: Icons.sell_rounded,
                        title: 'Gratis / Pago',
                        subtitle: 'Tipos de entrada',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Filtrar eventos',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 24,
                            ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllEventsScreen(),
                          ),
                        );
                      },
                      child: const Text('Ver más'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map(buildFilterChip).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Próximos eventos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 14),
                if (featured.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Center(
                      child: Text(
                        'No hay eventos para este filtro.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ...featured.map(
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
                      onRegister: () => _handleRegister(context, event),
                      actionText: appState.isRegisteredToEvent(event.id)
                          ? 'Registrado'
                          : 'Registrarte',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}