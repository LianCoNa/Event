import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/notification_model.dart';
import 'mock_data.dart';

class AppUser {
  final String id;
  final String name;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final bool isAdmin;

  AppUser({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    this.isAdmin = false,
  });

  String get fullName => '$name $lastName';
}

class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  static const String adminEmail = 'admin@eventia.com';
  static const String adminPassword = 'EventiaAdmin123';
  static const String demoUserEmail = 'demo@eventia.com';
  static const String demoUserPassword = '123456';

  bool _isLoggedIn = false;
  AppUser? _currentUser;

  final List<AppUser> _users = [
    AppUser(
      id: 'admin-1',
      name: 'Admin',
      lastName: 'Eventia',
      email: adminEmail,
      phone: '0000000000',
      password: adminPassword,
      isAdmin: true,
    ),
    AppUser(
      id: 'demo-1',
      name: 'Usuario',
      lastName: 'Demo',
      email: demoUserEmail,
      phone: '3000000000',
      password: demoUserPassword,
      isAdmin: false,
    ),
  ];

  final List<EventModel> _allEvents = [...initialMockEvents];
  final List<EventModel> _myTickets = [];
  final List<EventModel> _myCreatedEvents = [];
  final List<NotificationModel> _notifications = [...initialNotifications];
  final List<Map<String, dynamic>> _surveys = [];

  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  String get userName => _currentUser?.fullName ?? 'Invitado';
  String get userEmail => _currentUser?.email ?? '';

  List<AppUser> get users => List.unmodifiable(_users);
  List<EventModel> get allEvents => List.unmodifiable(_allEvents);
  List<EventModel> get myTickets => List.unmodifiable(_myTickets);
  List<EventModel> get myCreatedEvents => List.unmodifiable(_myCreatedEvents);
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  List<Map<String, dynamic>> get surveys => List.unmodifiable(_surveys);

  int get unreadNotificationsCount =>
      _notifications.where((item) => !item.isRead).length;

  bool registerUser({
    required String name,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();

    final exists = _users.any((u) => u.email.toLowerCase() == normalizedEmail);
    if (exists) return false;

    final user = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      lastName: lastName.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      password: password.trim(),
      isAdmin: false,
    );

    _users.add(user);
    _isLoggedIn = true;
    _currentUser = user;
    notifyListeners();
    return true;
  }

  bool login({
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();

    try {
      final user = _users.firstWhere(
        (u) =>
            u.email.toLowerCase() == normalizedEmail &&
            u.password == normalizedPassword,
      );

      _isLoggedIn = true;
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    _myTickets.clear();
    notifyListeners();
  }

  bool isRegisteredToEvent(String eventId) {
    return _myTickets.any((event) => event.id == eventId);
  }

  void registerToEvent(EventModel event) {
    if (!_isLoggedIn) return;

    final exists = _myTickets.any((item) => item.id == event.id);
    if (!exists) {
      _myTickets.add(event);
      _notifications.insert(
        0,
        NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Registro confirmado',
          message: 'Te registraste en ${event.title}.',
          time: 'Ahora',
        ),
      );
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
    final index = _allEvents.indexWhere((event) => event.id == updatedEvent.id);
    if (index != -1) {
      _allEvents[index] = updatedEvent;
    }

    final myIndex =
        _myCreatedEvents.indexWhere((event) => event.id == updatedEvent.id);
    if (myIndex != -1) {
      _myCreatedEvents[myIndex] = updatedEvent;
    }

    final ticketIndex =
        _myTickets.indexWhere((event) => event.id == updatedEvent.id);
    if (ticketIndex != -1) {
      _myTickets[ticketIndex] = updatedEvent;
    }

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
      'date': DateTime.now().toString(),
      'user': userName,
    });
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