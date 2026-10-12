part of 'appointments_bloc.dart';

sealed class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();

  @override
  List<Object?> get props => [];
}

class AppointmentsRequested extends AppointmentsEvent {
  const AppointmentsRequested();
}

class AppointmentStatusChangeRequested extends AppointmentsEvent {
  final String id;
  final AppointmentStatus status;

  const AppointmentStatusChangeRequested(this.id, this.status);

  @override
  List<Object?> get props => [id, status];
}

class AppointmentRemoveRequested extends AppointmentsEvent {
  final String id;

  const AppointmentRemoveRequested(this.id);

  @override
  List<Object?> get props => [id];
}
