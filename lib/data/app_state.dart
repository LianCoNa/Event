import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/notification_model.dart';

class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  final List<EventModel> _allEvents = [];
  final List<EventModel> _myTickets = [];
  final List<EventModel> _myCreatedEvents = [];
  final List<NotificationModel> _notifications = [];
  final List<Map<String, dynamic>> _surveys = [];
  final List<Map<String, dynamic>> _news = [];

  bool _isLoggedIn = false;
  bool _isAdmin = false;
  String _userName = 'Invitado';
  String _userEmail = '';

  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;
  String get userName => _userName;
  String get userEmail => _userEmail;

  List<EventModel> get allEvents => List.unmodifiable(_allEvents);
  List<EventModel> get myTickets => List.unmodifiable(_myTickets);
  List<EventModel> get myCreatedEvents => List.unmodifiable(_myCreatedEvents);
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  List<Map<String, dynamic>> get surveys => List.unmodifiable(_surveys);
  List<Map<String, dynamic>> get news => List.unmodifiable(_news);

  int get unreadNotificationsCount =>
      _notifications.where((item) => !item.isRead).length;

  void loginUser({
    String name = 'Usuario',
    String email = '',
    bool isAdmin = false,
  }) {
    _isLoggedIn = true;
    _isAdmin = isAdmin;
    _userName = name;
    _userEmail = email;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _isAdmin = false;
    _userName = 'Invitado';
    _userEmail = '';
    _myTickets.clear();
    _notifications.clear();
    notifyListeners();
  }

  bool registerUser({
    required String name,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) {
    _isLoggedIn = true;
    _isAdmin = false;
    _userName = '$name $lastName'.trim();
    _userEmail = email;
    notifyListeners();
    return true;
  }

  bool login({
    required String email,
    required String password,
  }) {
    _isLoggedIn = true;
    _isAdmin = false;
    _userEmail = email;
    _userName = 'Usuario';
    notifyListeners();
    return true;
  }

  bool loginAdmin({
    required String email,
    required String password,
  }) {
    _isLoggedIn = true;
    _isAdmin = true;
    _userEmail = email;
    _userName = 'Administrador';
    notifyListeners();
    return true;
  }

  bool isRegisteredToEvent(String eventId) {
    return _myTickets.any((event) => event.id == eventId);
  }

  void registerToEvent(EventModel event) {
    final exists = _myTickets.any((item) => item.id == event.id);
    if (!exists) {
      _myTickets.add(event);
      notifyListeners();
    }
  }

  void removeTicket(String eventId) {
    _myTickets.removeWhere((event) => event.id == eventId);
    notifyListeners();
  }

  void createEvent(EventModel event) {
    _allEvents.insert(0, event);
    _myCreatedEvents.insert(0, event);
    notifyListeners();
  }

  void deleteCreatedEvent(String eventId) {
    _myCreatedEvents.removeWhere((event) => event.id == eventId);
    _allEvents.removeWhere((event) => event.id == eventId);
    _myTickets.removeWhere((event) => event.id == eventId);
    notifyListeners();
  }

  void updateEvent(EventModel updatedEvent) {
    final allIndex = _allEvents.indexWhere((event) => event.id == updatedEvent.id);
    if (allIndex != -1) _allEvents[allIndex] = updatedEvent;

    final myIndex =
        _myCreatedEvents.indexWhere((event) => event.id == updatedEvent.id);
    if (myIndex != -1) _myCreatedEvents[myIndex] = updatedEvent;

    final ticketIndex =
        _myTickets.indexWhere((event) => event.id == updatedEvent.id);
    if (ticketIndex != -1) _myTickets[ticketIndex] = updatedEvent;

    notifyListeners();
  }

  void submitSurvey({
    required bool wouldHireAgain,
    required int rating,
    required String improvement,
  }) {
    _surveys.insert(0, {
      'wouldHireAgain': wouldHireAgain ? 'Sí' : 'No',
      'rating': rating,
      'improvement': improvement,
    });
    notifyListeners();
  }

  void addNews(Map<String, dynamic> newsItem) {
    _news.insert(0, newsItem);
    notifyListeners();
  }

  List<EventModel> searchEvents(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return allEvents;

    return _allEvents.where((event) {
      return event.title.toLowerCase().contains(normalized) ||
          event.category.toLowerCase().contains(normalized) ||
          event.location.toLowerCase().contains(normalized) ||
          event.organizer.toLowerCase().contains(normalized);
    }).toList();
  }

  void markAllNotificationsAsRead() {
    for (final item in _notifications) {
      item.isRead = true;
    }
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    for (final item in _notifications) {
      if (item.id == id) {
        item.isRead = true;
        break;
      }
    }
    notifyListeners();
  }
}