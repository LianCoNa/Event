import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/event_model.dart';
import '../../services/notification_service.dart';
import '../../services/ticket_service.dart';
import '../../widgets/global_loading_overlay.dart';
import '../auth/login_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del evento')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.grey.shade200,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  event.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.green.shade50,
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 56,
                          color: Colors.green,
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.58),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          event.isFree ? 'GRATIS' : 'PAGO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: event.isFree ? Colors.green : Colors.deepOrange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: .92),
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
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: 28, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
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
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(event.location)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('Organiza: ${event.organizer}')),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sobre este evento',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (firebaseUser == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 48,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Inicia sesión para registrarte y obtener tu QR.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text('Iniciar sesión'),
                    ),
                  ],
                ),
              ),
            )
          else
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: TicketService.instance.userTicketStream(
                eventId: event.id,
                userId: firebaseUser.uid,
              ),
              builder: (context, snapshot) {
                final hasTicket = snapshot.data?.exists ?? false;
                final ticketData = snapshot.data?.data();

                return Column(
                  children: [
                    if (hasTicket && ticketData != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              QrImageView(
                                data: ticketData['qrData'] ?? '',
                                version: QrVersions.auto,
                                size: 210,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Código QR de acceso',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.qr_code_2_rounded,
                                size: 52,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Regístrate en este evento para generar tu código QR de acceso.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: () async {
                        GlobalLoadingOverlay.show(
                          context,
                          message: hasTicket
                              ? 'Estamos cancelando tu asistencia...'
                              : 'Estamos generando tu entrada...',
                        );

                        try {
                          if (hasTicket) {
                            await TicketService.instance.removeTicket(
                              eventId: event.id,
                              userId: firebaseUser.uid,
                            );

                            await NotificationService.instance.createNotification(
                              userId: firebaseUser.uid,
                              title: 'Asistencia cancelada',
                              message:
                                  'Ya no asistirás a ${event.title}. Tu entrada fue eliminada.',
                            );

                            if (!context.mounted) return;
                            GlobalLoadingOverlay.hide(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Registro eliminado'),
                              ),
                            );
                          } else {
                            await TicketService.instance.registerToEvent(
                              event: event,
                              userId: firebaseUser.uid,
                            );

                            await NotificationService.instance.createNotification(
                              userId: firebaseUser.uid,
                              title: 'Registro confirmado',
                              message:
                                  'Tu entrada para ${event.title} ya está lista.',
                            );

                            if (!context.mounted) return;
                            GlobalLoadingOverlay.hide(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Registro exitoso'),
                              ),
                            );
                          }
                        } catch (_) {
                          if (!context.mounted) return;
                          GlobalLoadingOverlay.hide(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No se pudo completar la acción'),
                            ),
                          );
                        }
                      },
                      child: Text(
                        hasTicket ? 'Cancelar asistencia' : 'Registrarte',
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}