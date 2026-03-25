import '../models/event_model.dart';
import '../models/news_model.dart';
import '../models/notification_model.dart';

List<EventModel> initialMockEvents = [
  EventModel(
    id: '1',
    title: 'Festival de Música Urbana',
    date: '1 junio 2026',
    time: '7:00 PM',
    location: 'Parque Central',
    description:
        'Vive una noche llena de música, artistas invitados y experiencias inolvidables.',
    category: 'Música',
    isFree: true,
    distance: '1.5 km',
    organizer: 'Eventia Music',
    filterTag: 'Hoy',
    imageUrl:
        'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?q=80&w=1400&auto=format&fit=crop',
  ),
  EventModel(
    id: '2',
    title: 'Foro de Emprendimiento Verde',
    date: '8 junio 2026',
    time: '4:00 PM',
    location: 'Centro de Convenciones',
    description:
        'Encuentra charlas, networking y espacios para impulsar ideas sostenibles e innovadoras.',
    category: 'Negocios',
    isFree: false,
    distance: '3 km',
    organizer: 'Eventia Business',
    filterTag: 'Esta semana',
    imageUrl:
        'https://images.unsplash.com/photo-1511578314322-379afb476865?q=80&w=1400&auto=format&fit=crop',
  ),
  EventModel(
    id: '3',
    title: 'Expo Tecnología Creativa',
    date: '15 junio 2026',
    time: '10:00 AM',
    location: 'Hub de Innovación',
    description:
        'Descubre tendencias digitales, desarrollo móvil, IA y nuevas herramientas.',
    category: 'Tecnología',
    isFree: true,
    distance: '2 km',
    organizer: 'Eventia Tech',
    filterTag: 'Este mes',
    imageUrl:
        'https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=1400&auto=format&fit=crop',
  ),
  EventModel(
    id: '4',
    title: 'Meetup Diseñadores UI/UX',
    date: '21 junio 2026',
    time: '6:30 PM',
    location: 'Cowork Verde',
    description:
        'Aprende sobre interfaces modernas, experiencia de usuario y branding.',
    category: 'Diseño',
    isFree: false,
    distance: '2.8 km',
    organizer: 'Eventia Design',
    filterTag: 'Este mes',
    imageUrl:
        'https://images.unsplash.com/photo-1522542550221-31fd19575a2d?q=80&w=1400&auto=format&fit=crop',
  ),
];

List<NotificationModel> initialNotifications = [
  NotificationModel(
    id: 'n1',
    title: 'Nuevo evento disponible',
    message: 'Ya puedes registrarte al Festival de Música Urbana.',
    time: 'Hace 5 min',
  ),
  NotificationModel(
    id: 'n2',
    title: 'Tu registro fue exitoso',
    message: 'Tu entrada estará disponible en Mis entradas.',
    time: 'Hace 20 min',
  ),
  NotificationModel(
    id: 'n3',
    title: 'Consejo Eventia',
    message: 'Explora la sección de noticias para descubrir tendencias.',
    time: 'Hace 1 hora',
    isRead: true,
  ),
];

const List<NewsModel> mockNews = [
  NewsModel(
    title: 'Eventia lanza una nueva experiencia para organizadores',
    description:
        'Una interfaz más limpia y moderna para crear, administrar y compartir eventos.',
    tag: 'Actualización',
  ),
  NewsModel(
    title: 'Los eventos híbridos siguen creciendo',
    description:
        'Cada vez más personas buscan experiencias que mezclen lo presencial con lo virtual.',
    tag: 'Tendencias',
  ),
  NewsModel(
    title: '5 claves para mejorar la experiencia del asistente',
    description:
        'Desde check-in con QR hasta encuestas de satisfacción, estos detalles elevan mucho la calidad.',
    tag: 'Consejos',
  ),
];