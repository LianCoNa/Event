import 'package:flutter/material.dart';
import '../app/constants.dart';
import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback? onRegister;
  final String? actionText;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onRegister,
    this.actionText,
  });

  Color categoryColor(String category) {
    switch (category) {
      case 'Música':
        return const Color(0xFF43A047);
      case 'Tecnología':
        return const Color(0xFF00897B);
      case 'Negocios':
        return const Color(0xFF2E7D32);
      case 'Diseño':
        return const Color(0xFF6A1B9A);
      case 'Arte':
        return const Color(0xFFD81B60);
      case 'Gastronomía':
        return const Color(0xFFE65100);
      case 'Deportes':
        return const Color(0xFF1565C0);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagColor = categoryColor(event.category);

    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 210,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.grey.shade200,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      event.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: AppColors.softGreen,
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.05),
                            Colors.black.withOpacity(0.55),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.95),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              event.isFree ? 'GRATIS' : 'PAGO',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: event.isFree
                                    ? AppColors.primary
                                    : Colors.deepOrange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: tagColor.withOpacity(.92),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              event.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${event.date} • ${event.time}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${event.location} • ${event.distance}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.darkText,
                          ),
                    ),
                  ),
                  if (onRegister != null)
                    FilledButton(
                      onPressed: onRegister,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(actionText ?? 'Registrarte'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}