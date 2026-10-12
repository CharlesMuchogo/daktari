import 'package:daktari/domain/entities/appointment.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> appointments();

  Future<Appointment> updateStatus(String id, AppointmentStatus status);

  Future<void> remove(String id);
}
