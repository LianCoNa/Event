import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/constants.dart';
import '../../data/app_state.dart';
import '../../models/event_model.dart';
import '../../widgets/primary_button.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  final List<String> categories = const [
    'Música',
    'Negocios',
    'Tecnología',
    'Diseño',
    'Arte',
    'Gastronomía',
    'Deportes',
    'General',
  ];

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String selectedCategory = 'General';
  bool isFree = true;

  String categoryImage(String category) {
    switch (category) {
      case 'Música':
        return 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?q=80&w=1400&auto=format&fit=crop';
      case 'Negocios':
        return 'https://images.unsplash.com/photo-1511578314322-379afb476865?q=80&w=1400&auto=format&fit=crop';
      case 'Tecnología':
        return 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=1400&auto=format&fit=crop';
      case 'Diseño':
        return 'https://images.unsplash.com/photo-1522542550221-31fd19575a2d?q=80&w=1400&auto=format&fit=crop';
      case 'Arte':
        return 'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?q=80&w=1400&auto=format&fit=crop';
      case 'Gastronomía':
        return 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=1400&auto=format&fit=crop';
      case 'Deportes':
        return 'https://images.unsplash.com/photo-1517649763962-0c623066013b?q=80&w=1400&auto=format&fit=crop';
      default:
        return 'https://images.unsplash.com/photo-1511578314322-379afb476865?q=80&w=1400&auto=format&fit=crop';
    }
  }

  IconData categoryIcon(String category) {
    switch (category) {
      case 'Música':
        return Icons.music_note_rounded;
      case 'Negocios':
        return Icons.business_center_rounded;
      case 'Tecnología':
        return Icons.devices_rounded;
      case 'Diseño':
        return Icons.palette_rounded;
      case 'Arte':
        return Icons.brush_rounded;
      case 'Gastronomía':
        return Icons.restaurant_rounded;
      case 'Deportes':
        return Icons.sports_soccer_rounded;
      default:
        return Icons.celebration_rounded;
    }
  }

  Future<void> pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.darkText,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text =
            DateFormat('d MMMM yyyy', 'es_ES').format(picked);
      });
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.darkText,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
        final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
        final minute = picked.minute.toString().padLeft(2, '0');
        final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
        timeController.text = '$hour:$minute $period';
      });
    }
  }

  String getFilterTagFromDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);

    if (eventDay == today) return 'Hoy';

    final difference = eventDay.difference(today).inDays;
    if (difference >= 0 && difference <= 7) return 'Esta semana';

    return 'Este mes';
  }

  void saveEvent() {
    if (titleController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty ||
        timeController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa título, fecha, hora y ubicación'),
        ),
      );
      return;
    }

     final event = EventModel(
       id: DateTime.now().millisecondsSinceEpoch.toString(),
       title: titleController.text.trim(),
      date: dateController.text.trim(),
      time: timeController.text.trim(),
      location: locationController.text.trim(),
      description: descriptionController.text.trim().isEmpty
          ? 'Evento creado desde Eventia.'
          : descriptionController.text.trim(),
      category: selectedCategory,
      isFree: isFree,
      distance: '0 km',
      organizer: AppState.instance.userName,
      filterTag: getFilterTagFromDate(selectedDate!),
      imageUrl: categoryImage(selectedCategory),
      );

      
    AppState.instance.createEvent(event);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evento creado correctamente')),
    );

    Navigator.pop(context);
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
    );
  }

  Widget pickerField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(title),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: IgnorePointer(
            child: TextField(
              controller: controller,
              readOnly: true,
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: Icon(icon),
                suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewTitle = titleController.text.trim().isEmpty
        ? 'Tu evento aquí'
        : titleController.text.trim();

    final previewDate = dateController.text.trim().isEmpty
        ? 'Selecciona fecha'
        : dateController.text.trim();

    final previewTime = timeController.text.trim().isEmpty
        ? 'Selecciona hora'
        : timeController.text.trim();

    final previewLocation = locationController.text.trim().isEmpty
        ? 'Agrega una ubicación'
        : locationController.text.trim();

    final imageUrl = categoryImage(selectedCategory);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear evento')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Diseña tu próximo evento',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Completa la información y mira una vista previa antes de publicarlo.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
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
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: AppColors.softGreen,
                            child: Center(
                              child: Icon(
                                categoryIcon(selectedCategory),
                                size: 60,
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
                                isFree ? 'GRATIS' : 'PAGO',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isFree
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
                                color: AppColors.primary.withOpacity(.92),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                selectedCategory,
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
                              previewTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$previewDate • $previewTime',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              previewLocation,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          sectionTitle('Nombre del evento'),
          TextField(
            controller: titleController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Ej: Festival Verde 2026',
              prefixIcon: Icon(Icons.event_outlined),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: pickerField(
                  title: 'Fecha',
                  hint: 'Selecciona la fecha',
                  controller: dateController,
                  icon: Icons.calendar_month_outlined,
                  onTap: pickDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: pickerField(
                  title: 'Hora',
                  hint: 'Selecciona la hora',
                  controller: timeController,
                  icon: Icons.access_time_outlined,
                  onTap: pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          sectionTitle('Ubicación'),
          TextField(
            controller: locationController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Ej: Centro de Convenciones',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 16),
          sectionTitle('Categoría'),
          DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.grid_view_rounded),
            ),
            borderRadius: BorderRadius.circular(18),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Icon(
                      categoryIcon(category),
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(category),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedCategory = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.sell_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tipo de evento',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  isFree ? 'Gratis' : 'Pago',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Switch(
                  value: isFree,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      isFree = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          sectionTitle('Descripción'),
          TextField(
            controller: descriptionController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Describe tu evento',
              prefixIcon: Icon(Icons.description_outlined),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.softGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'La fecha seleccionada clasificará el evento automáticamente y la imagen cambiará según la categoría.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkText,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Guardar evento',
            onPressed: saveEvent,
          ),
        ],
      ),
    );
  }
}