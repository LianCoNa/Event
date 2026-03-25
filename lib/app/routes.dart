import 'package:flutter/material.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/events/create_event_screen.dart';
import '../screens/events/my_events_screen.dart';
import '../screens/events/stats_screen.dart';
import '../screens/events/survey_screen.dart';
import '../screens/home/all_events_screen.dart';
import '../screens/home/main_navigation_screen.dart';
import '../screens/news/news_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRoutes {
  static const String forgotPassword = '/forgot-password';
  static const String login = '/login';
  static const String register = '/register';
  static const String mainNav = '/main-nav';
  static const String createEvent = '/create-event';
  static const String myEvents = '/my-events';
  static const String stats = '/stats';
  static const String survey = '/survey';
  static const String news = '/news';
  static const String profile = '/profile';
  static const String allEvents = '/all-events';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> get routes => {
        forgotPassword: (_) => const ForgotPasswordScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        mainNav: (_) => const MainNavigationScreen(),
        createEvent: (_) => const CreateEventScreen(),
        myEvents: (_) => const MyEventsScreen(),
        stats: (_) => const StatsScreen(),
        survey: (_) => const SurveyScreen(),
        news: (_) => const NewsScreen(),
        profile: (_) => const ProfileScreen(),
        allEvents: (_) => const AllEventsScreen(),
        notifications: (_) => const NotificationsScreen(),
      };
}