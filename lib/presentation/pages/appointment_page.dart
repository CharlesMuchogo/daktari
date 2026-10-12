import 'package:daktari/domain/entities/appointment.dart';
import 'package:daktari/presentation/bloc/appointments/appointments_bloc.dart';
import 'package:daktari/presentation/bloc/status.dart';
import 'package:daktari/presentation/formatters.dart';
import 'package:daktari/presentation/pages/chats_page.dart';
import 'package:daktari/presentation/theme/app_theme.dart';
import 'package:daktari/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

enum DoctorAction {
  confirm(
    "Confirm appointment",
    "Do you want to confirm the appointment?",
    AppointmentStatus.confirmed,
  ),
  complete(
    "Mark as completed",
    "Mark this appointment as completed?",
    AppointmentStatus.completed,
  ),
  cancel(
    "Cancel appointment",
    "Do you want to cancel the appointment?",
    AppointmentStatus.cancelled,
  ),
  remove("Remove from list", "Remove this appointment from your list?", null);

  final String label;
  final String question;
  final AppointmentStatus? status;

  const DoctorAction(this.label, this.question, this.status);

  bool get destructive => this == cancel || this == remove;

  static List<DoctorAction> availableFor(Appointment a, DateTime now) {
    final started = !a.startsAt.isAfter(now);
    return [
      if (a.status == AppointmentStatus.pending && !started) confirm,
      if (a.status.isActive && started) complete,
      if (a.status.isActive) cancel,
      if (a.canRemoveAt(now) && !a.status.isActive) remove,
    ];
  }
}

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key, required this.appointmentId});

  final String appointmentId;

  Future<void> _run(BuildContext context, DoctorAction action) async {
    final ok = await confirm(
      context,
      title: action.question,
      confirmLabel: action.label,
      destructive: action.destructive,
    );
    if (!ok || !context.mounted) return;
    final status = action.status;
    context.read<AppointmentsBloc>().add(
      status == null
          ? AppointmentRemoveRequested(appointmentId)
          : AppointmentStatusChangeRequested(appointmentId, status),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentsBloc, AppointmentsState>(
      listenWhen: (previous, current) => previous.action != current.action,
      listener: (context, state) {
        if (state.action.isFailure) {
          showMessage(context, title: "Error", message: state.message);
        } else if (state.action == Status.loaded) {
          if (state.byId(appointmentId) == null) {
            Navigator.pop(context);
          } else {
            showSnack(context, "Appointment updated");
          }
        }
      },
      builder: (context, state) {
        final appointment = state.byId(appointmentId);
        if (appointment == null) {
          return Scaffold(appBar: AppBar(), body: const Loading());
        }
        final theme = Theme.of(context);
        final now = DateTime.now();
        final patient = appointment.patient;
        final busy = state.action.isLoading;
        final actions = DoctorAction.availableFor(appointment, now);

        return Scaffold(
          appBar: AppBar(title: const Text("Appointment")),
          body: SafeArea(
            child: ListView(
              padding: AppSpacing.page,
              children: [
                Row(
                  children: [
                    PersonAvatar(patient?.profilePhoto, radius: 28),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        patient?.fullName ?? "Patient",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    StatusChip(appointment.displayStatusAt(now)),
                  ],
                ),
                gapLarge,
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_month_outlined),
                        title: const Text("Date"),
                        subtitle: Text(formatDate(appointment.startsAt)),
                      ),
                      ListTile(
                        leading: const Icon(Icons.schedule_outlined),
                        title: const Text("Time"),
                        subtitle: Text(formatTime(appointment.startsAt)),
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: const Text("Location"),
                        subtitle: Text(
                          appointment.address.isEmpty
                              ? "—"
                              : appointment.address,
                        ),
                      ),
                      if (appointment.notes.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.notes_outlined),
                          title: const Text("Notes"),
                          subtitle: Text(appointment.notes),
                        ),
                      if (patient != null && patient.phoneNumber.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.phone_outlined),
                          title: const Text("Patient phone"),
                          subtitle: Text(patient.phoneNumber),
                          trailing: const Icon(Icons.call_outlined),
                          onTap: () => launchUrl(
                            Uri.parse("tel:${patient.phoneNumber}"),
                          ),
                        ),
                    ],
                  ),
                ),
                gap,
                if (patient != null) MessagePatientButton(patient.id),
                if (actions.isNotEmpty) const SizedBox(height: AppSpacing.xl),
                for (final action in actions) ...[
                  if (action.destructive)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                      ),
                      onPressed: busy ? null : () => _run(context, action),
                      child: Text(action.label),
                    )
                  else
                    FilledButton(
                      onPressed: busy ? null : () => _run(context, action),
                      child: Text(action.label),
                    ),
                  gap,
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
