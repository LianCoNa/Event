import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../models/event_model.dart';
import '../../widgets/event_card.dart';
import '../../widgets/home_carousel.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/survey_banner.dart';
import '../auth/login_screen.dart';
import '../events/event_detail_screen.dart';
import '../events/survey_screen.dart';
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

  final ScrollController categoriesController = ScrollController();
  final ScrollController filtersController = ScrollController();

  final List<String> categories = const [
    'Todos',
    'Música',
    'Tecnología',
    'Negocios',
    'Diseño',
    'Gratis',
    'Pago',
  ];

  @override
  void dispose() {
    searchController.dispose();
    categoriesController.dispose();
    filtersController.dispose();
    super.dispose();
  }

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
          color: selected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.shade50,
            child: Icon(icon, color: Colors.green),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.black54,
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

  void goToSurvey() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SurveyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, child) {
        final appState = AppState.instance;
        final featured = getFilteredEvents();

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Eventia'),
            actions: [
              if (appState.isLoggedIn)
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
                const SizedBox(height: 20),
                const HomeCarousel(),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'CATEGORÍAS DISPONIBLES EVENTIA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                /// CATEGORIAS DESLIZABLES CON MOUSE/TOUCH
                SizedBox(
                  height: 155,
                  child: ScrollConfiguration(
                    behavior: const MaterialScrollBehavior().copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                        PointerDeviceKind.stylus,
                        PointerDeviceKind.unknown,
                      },
                    ),
                    child: ListView(
                      controller: categoriesController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
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
                ),

                const SizedBox(height: 10),

                /// BOTONES PARA MOVER LAS CATEGORIAS
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: 'Mover a la izquierda',
                      onPressed: () {
                        final double target = (categoriesController.offset - 220)
                            .clamp(0, categoriesController.position.maxScrollExtent);
                        categoriesController.animateTo(
                          target,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    IconButton(
                      tooltip: 'Mover a la derecha',
                      onPressed: () {
                        final double target = (categoriesController.offset + 220)
                            .clamp(0, categoriesController.position.maxScrollExtent);
                        categoriesController.animateTo(
                          target,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                SurveyBanner(onTap: goToSurvey),
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

                /// FILTROS DESLIZABLES TAMBIEN
                SizedBox(
                  height: 52,
                  child: ScrollConfiguration(
                    behavior: const MaterialScrollBehavior().copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                        PointerDeviceKind.stylus,
                        PointerDeviceKind.unknown,
                      },
                    ),
                    child: ListView(
                      controller: filtersController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: categories.map(buildFilterChip).toList(),
                    ),
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
                      onRegister: () => handleRegister(context, event),
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