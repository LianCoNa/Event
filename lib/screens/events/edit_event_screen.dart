import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
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
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController dateController;
  late final TextEditingController timeController;
  late final TextEditingController locationController;
  late final TextEditingController descriptionController;

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
  bool isLoading = false;
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

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

  @override
  void dispose() {
    titleController.dispose();
    dateController.dispose();
    timeController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
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

  String getFilterTagFromDateText(String text) {
    return 'Este mes';
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        autoValidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    setState(() => isLoading = true);

    try {
      await EventService.instance.updateEvent(
        eventId: widget.event.id,
        title: titleController.text.trim(),
        date: dateController.text.trim(),
        time: timeController.text.trim(),
        location: locationController.text.trim(),
        description: descriptionController.text.trim(),
        category: selectedCategory,
        isFree: isFree,
        filterTag: getFilterTagFromDateText(dateController.text.trim()),
        imageUrl: categoryImage(selectedCategory),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento actualizado')),
      );

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar el evento')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget pickerField({
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: IgnorePointer(
        child: TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Campo obligatorio';
            }
            return null;
          },
        ),
      ),
    );
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
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.green.shade50,
                  child: const Center(
                    child: Icon(Icons.image_outlined, color: Colors.green, size: 50),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            autovalidateMode: autoValidateMode,
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'Nombre del evento',
                    prefixIcon: Icon(Icons.event_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el nombre del evento';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                pickerField(
                  hint: 'Selecciona la fecha',
                  controller: dateController,
                  icon: Icons.calendar_month_outlined,
                  onTap: pickDate,
                ),
                const SizedBox(height: 14),
                pickerField(
                  hint: 'Selecciona la hora',
                  controller: timeController,
                  icon: Icons.access_time_outlined,
                  onTap: pickTime,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    hintText: 'Ubicación',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa la ubicación';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
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
                  title: Text(isFree ? 'Evento gratis' : 'Evento pago'),
                  activeThumbColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  tileColor: Colors.white,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Descripción',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa una descripción';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: 'Guardar cambios',
            isLoading: isLoading,
            onPressed: saveChanges,
          ),
        ],
      ),
    );
  }
}