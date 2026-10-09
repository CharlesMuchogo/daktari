import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daktari/pages/appointment.dart';
import 'package:daktari/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Vertical gap between stacked form fields / sections.
const gap = SizedBox(height: AppSpacing.md);
const gapLarge = SizedBox(height: AppSpacing.lg);

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType,
    this.obscure = false,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final int maxLines;
  final TextInputAction textInputAction;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _hidden,
      maxLines: widget.obscure ? 1 : widget.maxLines,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: widget.icon == null ? null : Icon(widget.icon),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(_hidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
      ),
    );
  }
}

/// App name + tagline shown on the auth screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.local_hospital_rounded,
              size: 36, color: theme.colorScheme.onPrimaryContainer),
        ),
        gap,
        Text(
          "Daktari",
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.outline),
            gap,
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text("or", style: Theme.of(context).textTheme.bodyMedium),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Text(
        "G",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4285F4),
        ),
      ),
      label: const Text("Continue with Google"),
    );
  }
}

void showLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
}

Future<void> showMessage(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Okay"),
        ),
      ],
    ),
  );
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  String confirmLabel = "Yes",
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                    minimumSize: const Size(64, 40),
                  )
                : FilledButton.styleFrom(minimumSize: const Size(64, 40)),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      "Confirmed" => Colors.green,
      "Pending" => Colors.amber.shade700,
      _ => Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + AppSpacing.xs, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Card for a document from a doctor's "My appointments" collection.
/// Looks up the patient and opens [AppointmentPage] on tap.
class AppointmentCard extends StatelessWidget {
  const AppointmentCard(this.appointment, {super.key});

  final QueryDocumentSnapshot appointment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String date = appointment["Date"];
    final String time = appointment["Time"];
    final String status = appointment["Status"];
    final String patientId = appointment["Patient Id"];

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("Patient")
          .doc(patientId)
          .snapshots(),
      builder: (context, snapshot) {
        final patient = snapshot.data?.data();
        final name = patient == null
            ? "Loading…"
            : "${patient["First Name"]} ${patient["Last Name"]}";
        final String? photo = patient?["Profile Photo"];

        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: patient == null
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AppointmentPage(
                          appointment.id,
                          patientId,
                          date,
                          appointment["Consultation"],
                          time,
                          appointment["Address"],
                          name,
                          status,
                        ),
                      ),
                    ),
            child: Padding(
              padding: AppSpacing.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage:
                            photo == null ? null : NetworkImage(photo),
                        child: photo == null
                            ? const Icon(Icons.person_outline)
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: theme.textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis),
                            Text(appointment["Consultation"],
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      StatusChip(status),
                    ],
                  ),
                  gap,
                  Row(
                    children: [
                      _IconLabel(Icons.calendar_month_outlined, date),
                      const SizedBox(width: AppSpacing.lg),
                      _IconLabel(Icons.schedule_outlined, time),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IconLabel extends StatelessWidget {
  const _IconLabel(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.xs + 2),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}
