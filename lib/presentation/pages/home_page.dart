import 'package:daktari/presentation/bloc/appointments/appointments_bloc.dart';
import 'package:daktari/presentation/bloc/auth/auth_bloc.dart';
import 'package:daktari/presentation/theme/app_theme.dart';
import 'package:daktari/presentation/widgets/appointment_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    final firstName = context.select(
      (AuthBloc bloc) => bloc.state.user?.firstName,
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async =>
            context.read<AppointmentsBloc>().add(const AppointmentsRequested()),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: theme.colorScheme.primary,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: AppSpacing.page.copyWith(bottom: AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: onPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          firstName == null ? "Doctor" : "Dr. $firstName",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: AppSpacing.page,
              sliver: SliverToBoxAdapter(
                child: Text(
                  "Upcoming appointments",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            AppointmentList(
              sliver: true,
              select: (state) => state.upcomingAt(DateTime.now()),
              emptyIcon: Icons.event_available_outlined,
              emptyMessage: "You do not have any upcoming appointments",
            ),
          ],
        ),
      ),
    );
  }
}
