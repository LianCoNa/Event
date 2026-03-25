import 'dart:async';
import 'package:flutter/material.dart';
import '../app/constants.dart';

class HomeCarousel extends StatefulWidget {
  HomeCarousel({super.key});

  @override
  State<HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<HomeCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int currentIndex = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> banners = const [
    {
      'title': 'Descubre eventos\npremium en tu ciudad',
      'subtitle': 'Encuentra experiencias únicas y regístrate en segundos.',
      'icon': Icons.celebration_rounded,
      'colors': [Color(0xFF8FD19A), Color(0xFFDDF3E1)],
    },
    {
      'title': 'Organiza tus eventos\ncon estilo',
      'subtitle': 'Crea, administra y comparte eventos desde Eventia.',
      'icon': Icons.event_available_rounded,
      'colors': [Color(0xFF66BB6A), Color(0xFFC8E6C9)],
    },
    {
      'title': 'Accede con QR\ny vive la experiencia',
      'subtitle': 'Tus entradas siempre listas, rápidas y seguras.',
      'icon': Icons.qr_code_2_rounded,
      'colors': [Color(0xFF43A047), Color(0xFFA5D6A7)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) return;
      int next = currentIndex + 1;
      if (next >= banners.length) next = 0;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = banners[index];
              final colors = banner['colors'] as List<Color>;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(
                  right: 12,
                  top: currentIndex == index ? 0 : 8,
                  bottom: currentIndex == index ? 0 : 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              banner['title'],
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontSize: 24,
                                    height: 1.2,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              banner['subtitle'],
                              style: const TextStyle(
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.white.withOpacity(.18),
                        child: Icon(
                          banner['icon'],
                          size: 38,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: currentIndex == index ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: currentIndex == index
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}