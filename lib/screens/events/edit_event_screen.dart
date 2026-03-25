import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/constants.dart';
import '../../data/app_state.dart';
import '../../models/event_model.dart';
import '../../widgets/primary_button.dart';

class EditEventScreen extends StatefulWidget {
  final EventModel event;

  const EditEventScreen({
    super.key,
    required this.event,
  });

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController titleController;
  late TextEditingController dateController;
  late TextEditingController timeController;
  late TextEditingController locationController;
  late TextEditingController descriptionController;

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
  late String selectedCategory;
  late bool isFree;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event.title);
    dateController = TextEditingController(text: widget.event.date);
    timeController = TextEditingController(text: widget.event.time);
    locationController = TextEditingController(text: widget.event.location);
    descriptionController = TextEditingController(text: widget.event.description);
    selectedCategory = widget.event.category;
    isFree = widget.event.isFree;
  }

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

  Future<void> pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('d MMMM yyyy', 'es_ES').format(picked);
      });
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
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

  void saveChanges() {
    final updated = widget.event.copyWith(
      title: titleController.text.trim(),
      date: dateController.text.trim(),
      time: timeController.text.trim(),
      location: locationController.text.trim(),
      description: descriptionController.text.trim(),
      category: selectedCategory,
      isFree: isFree,
      filterTag: selectedDate != null
          ? getFilterTagFromDate(selectedDate!)
          : widget.event.filterTag,
      imageUrl: categoryImage(selectedCategory),
    );

    AppState.instance.updateEvent(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evento actualizado')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = categoryImage(selectedCategory);

    return Scaffold(
      appBar: AppBar(title: const Text('Editar evento')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.grey.shade200,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              hintText: 'Nombre del evento',
              prefixIcon: Icon(Icons.event_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: dateController,
            readOnly: true,
            onTap: pickDate,
            decoration: const InputDecoration(
              hintText: 'Fecha',
              prefixIcon: Icon(Icons.calendar_month_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: timeController,
            readOnly: true,
            onTap: pickTime,
            decoration: const InputDecoration(
              hintText: 'Hora',
              prefixIcon: Icon(Icons.access_time_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: locationController,
            decoration: const InputDecoration(
              hintText: 'Ubicación',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.grid_view_rounded),
            ),
            items: categories
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedCategory = value;
                });
              }
            },
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            value: isFree,
            onChanged: (value) {
              setState(() {
                isFree = value;
              });
            },
            title: const Text('Evento gratis'),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            tileColor: Colors.white,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: descriptionController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Descripción',
              prefixIcon: Icon(Icons.description_outlined),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: 'Guardar cambios',
            onPressed: saveChanges,
          ),
        ],
      ),
    );
  }
}