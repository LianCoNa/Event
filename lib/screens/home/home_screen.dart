import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../services/notification_service.dart';
import '../../services/ticket_service.dart';
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
    'Arte',
    'Gastronomía',
    'Deportes',
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

  List<EventModel> getFilteredEvents(List<EventModel> events) {
    List<EventModel> baseList = events;

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

      await NotificationService.instance.createNotification(
        userId: firebaseUser.uid,
        title: 'Registro confirmado',
        message: 'Tu entrada para ${event.title} ya está lista.',
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
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<List<EventModel>>(
      stream: EventService.instance.getEvents(),
      builder: (context, eventSnapshot) {
        if (eventSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final events = eventSnapshot.data ?? [];
        final featured = getFilteredEvents(events);

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: firebaseUser == null
              ? null
              : NotificationService.instance.getNotifications(firebaseUser.uid),
          builder: (context, notificationSnapshot) {
            final unreadCount = firebaseUser == null
                ? 0
                : (notificationSnapshot.data ?? [])
                    .where((item) => item['isRead'] == false)
                    .length;

            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: const Text('Eventia'),
                actions: [
                  if (firebaseUser != null)
                    Stack(
                      alignment: Alignment.center,
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
                        if (unreadCount > 0)
                          Positioned(
                            right: 8,
                            top: 10,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.redAccent.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
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
                              icon: Icons.brush_rounded,
                              title: 'Arte',
                              subtitle: 'Exposiciones y cultura',
                            ),
                            categoryOverviewCard(
                              icon: Icons.restaurant_menu_rounded,
                              title: 'Gastronomía',
                              subtitle: 'Sabores y experiencias',
                            ),
                            categoryOverviewCard(
                              icon: Icons.sports_soccer_rounded,
                              title: 'Deportes',
                              subtitle: 'Actividad y competencia',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Mover a la izquierda',
                          onPressed: () {
                            final double target = (categoriesController.offset - 220)
                                .clamp(
                                  0.0,
                                  categoriesController.position.maxScrollExtent,
                                )
                                .toDouble();

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
                                .clamp(
                                  0.0,
                                  categoriesController.position.maxScrollExtent,
                                )
                                .toDouble();

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
                      (event) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(bottom: 16),
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
              ),
            );
          },
        );
      },
    );
  }
}