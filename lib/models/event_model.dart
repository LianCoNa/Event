class EventModel {
  final String id;
  final String title;
  final String date;
  final String time;
  final String location;
  final String description;
  final String category;
  final bool isFree;
  final String distance;
  final String organizer;
  final String filterTag;
  final String imageUrl;

  EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.category,
    required this.isFree,
    required this.distance,
    required this.organizer,
    required this.filterTag,
    required this.imageUrl,
  });

  EventModel copyWith({
    String? id,
    String? title,
    String? date,
    String? time,
    String? location,
    String? description,
    String? category,
    bool? isFree,
    String? distance,
    String? organizer,
    String? filterTag,
    String? imageUrl,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      description: description ?? this.description,
      category: category ?? this.category,
      isFree: isFree ?? this.isFree,
      distance: distance ?? this.distance,
      organizer: organizer ?? this.organizer,
      filterTag: filterTag ?? this.filterTag,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}