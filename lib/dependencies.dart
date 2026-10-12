import 'package:daktari/data/network/api_client.dart';
import 'package:daktari/data/network/token_store.dart';
import 'package:daktari/data/push/firebase_notification_repository.dart';
import 'package:daktari/data/realtime/chat_socket.dart';
import 'package:daktari/data/repositories/appointment_repository_impl.dart';
import 'package:daktari/data/repositories/auth_repository_impl.dart';
import 'package:daktari/data/repositories/chat_repository_impl.dart';
import 'package:daktari/data/repositories/category_repository_impl.dart';
import 'package:daktari/data/repositories/user_repository_impl.dart';
import 'package:daktari/data/social/social_auth.dart';
import 'package:daktari/domain/repositories/appointment_repository.dart';
import 'package:daktari/domain/repositories/auth_repository.dart';
import 'package:daktari/domain/repositories/chat_repository.dart';
import 'package:daktari/domain/repositories/category_repository.dart';
import 'package:daktari/domain/repositories/notification_repository.dart';
import 'package:daktari/domain/repositories/user_repository.dart';

class Dependencies {
  final AuthRepository auth;
  final UserRepository users;
  final CategoryRepository categories;
  final AppointmentRepository appointments;
  final ChatRepository chats;
  final NotificationRepository notifications;

  const Dependencies({
    required this.auth,
    required this.users,
    required this.categories,
    required this.appointments,
    required this.chats,
    required this.notifications,
  });

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://matibabu.muchogoc.com',
  );

  factory Dependencies.create() {
    final baseUrl = Uri.parse(apiBaseUrl);
    final api = ApiClient(
      baseUrl: baseUrl.resolve('/api/v1').toString(),
      tokens: SecureTokenStore(),
    );
    final socket = ChatSocket(
      url: baseUrl.replace(
        scheme: baseUrl.scheme == 'https' ? 'wss' : 'ws',
        path: '/api/v1/ws',
      ),
      token: api.freshAccessToken,
    );

    return Dependencies(
      auth: AuthRepositoryImpl(api: api, social: FirebaseSocialAuth()),
      users: UserRepositoryImpl(api),
      categories: CategoryRepositoryImpl(api),
      appointments: AppointmentRepositoryImpl(api),
      chats: ChatRepositoryImpl(api: api, socket: socket),
      notifications: FirebaseNotificationRepository(api: api),
    );
  }
}
