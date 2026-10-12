import 'package:daktari/domain/entities/appointment.dart';
import 'package:daktari/presentation/formatters.dart';
import 'package:daktari/presentation/pages/appointment_page.dart';
import 'package:daktari/presentation/theme/app_theme.dart';
import 'package:daktari/presentation/widgets/common.dart';
import 'package:flutter/material.dart';

String appointmentSearchText(Appointment appointment) => [
  appointment.patient?.fullName,
  formatDate(appointment.startsAt),
  formatTime(appointment.startsAt),
  statusLabel(appointment.displayStatusAt(DateTime.now())),
  appointment.address,
  appointment.notes,
].whereType<String>().join(' ');

class AppointmentCard extends StatelessWidget {
  const AppointmentCard(this.appointment, {super.key});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patient = appointment.patient;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => AppointmentPage(appointmentId: appointment.id),
          ),
        ),
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PersonAvatar(patient?.profilePhoto),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient?.fullName ?? "Patient",
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (appointment.address.isNotEmpty)
                          Text(
                            appointment.address,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  StatusChip(appointment.displayStatusAt(DateTime.now())),
                ],
              ),
              gap,
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.xs,
                children: [
                  IconLabel(
                    Icons.calendar_month_outlined,
                    formatDate(appointment.startsAt),
                  ),
                  IconLabel(
                    Icons.schedule_outlined,
                    formatTime(appointment.startsAt),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
