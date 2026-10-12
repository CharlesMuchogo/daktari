import 'package:daktari/domain/entities/appointment.dart';
import 'package:daktari/presentation/bloc/appointments/appointments_bloc.dart';
import 'package:daktari/presentation/bloc/status.dart';
import 'package:daktari/presentation/theme/app_theme.dart';
import 'package:daktari/presentation/widgets/appointment_card.dart';
import 'package:daktari/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppointmentList extends StatelessWidget {
  const AppointmentList({
    super.key,
    required this.select,
    required this.emptyIcon,
    required this.emptyMessage,
    this.sliver = false,
  });

  final List<Appointment> Function(AppointmentsState state) select;
  final IconData emptyIcon;
  final String emptyMessage;
  final bool sliver;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentsBloc, AppointmentsState>(
      builder: (context, state) {
        final appointments = select(state);
        final Widget? placeholder = appointments.isNotEmpty
            ? null
            : switch (state.status) {
                Status.failure when state.appointments.isEmpty => ErrorState(
                  message: state.message,
                  onRetry: () => context.read<AppointmentsBloc>().add(
                    const AppointmentsRequested(),
                  ),
                ),
                Status.initial || Status.loading => const Loading(),
                _ => EmptyState(icon: emptyIcon, message: emptyMessage),
              };

        if (sliver) {
          return placeholder != null
              ? SliverFillRemaining(hasScrollBody: false, child: placeholder)
              : SliverPadding(
                  padding: AppSpacing.page.copyWith(top: 0),
                  sliver: SliverList.separated(
                    itemCount: appointments.length,
                    separatorBuilder: (_, _) => gap,
                    itemBuilder: (_, i) => AppointmentCard(appointments[i]),
                  ),
                );
        }

        return RefreshIndicator(
          onRefresh: () async => context.read<AppointmentsBloc>().add(
            const AppointmentsRequested(),
          ),
          child: placeholder != null
              ? LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: placeholder,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: AppSpacing.page.copyWith(top: 0),
                  itemCount: appointments.length,
                  separatorBuilder: (_, _) => gap,
                  itemBuilder: (_, i) => AppointmentCard(appointments[i]),
                ),
        );
      },
    );
  }
}
