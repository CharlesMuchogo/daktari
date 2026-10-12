import 'package:daktari/domain/entities/chat.dart';
import 'package:daktari/presentation/bloc/auth/auth_bloc.dart';
import 'package:daktari/presentation/bloc/chats/chats_bloc.dart';
import 'package:daktari/presentation/bloc/status.dart';
import 'package:daktari/presentation/formatters.dart';
import 'package:daktari/presentation/navigation/chat_router.dart';
import 'package:daktari/presentation/theme/app_theme.dart';
import 'package:daktari/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessagePatientButton extends StatelessWidget {
  const MessagePatientButton(this.patientId, {super.key});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    final opening = context.select(
      (ChatsBloc bloc) => bloc.state.openStatus.isLoading,
    );
    return FilledButton.tonalIcon(
      onPressed: opening
          ? null
          : () => context.read<ChatsBloc>().add(ChatOpenRequested(patientId)),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      icon: opening
          ? const ButtonSpinner()
          : const Icon(Icons.chat_bubble_outline),
      label: const Text("Message patient"),
    );
  }
}

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),
      body: BlocBuilder<ChatsBloc, ChatsState>(
        builder: (context, state) {
          final chats = state.conversations;
          if (chats.isEmpty) {
            return switch (state.status) {
              Status.failure => ErrorState(
                message: state.message,
                onRetry: () =>
                    context.read<ChatsBloc>().add(const ChatsRefreshed()),
              ),
              Status.loaded => const EmptyState(
                icon: Icons.chat_bubble_outline,
                message:
                    "No messages yet.\nOpen an appointment and tap "
                    "Message patient to start a conversation.",
              ),
              _ => const Loading(),
            };
          }
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<ChatsBloc>().add(const ChatsRefreshed()),
            child: ListView.separated(
              padding: AppSpacing.page,
              itemCount: chats.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) => _ChatTile(chats[i]),
            ),
          );
        },
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile(this.chat);

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final userId = context.select((AuthBloc bloc) => bloc.state.user?.id);
    if (userId == null) return const SizedBox.shrink();
    final other = chat.otherParty(userId);
    final unread = chat.unreadFor(userId);
    final at = chat.lastMessageAt;
    final preview = chat.lastSenderId == userId
        ? "You: ${chat.lastMessage}"
        : chat.lastMessage;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ChatRouter.openChat(chat.id),
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: [
              PersonAvatar(other?.profilePhoto, radius: 26),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      other?.fullName ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: unread > 0
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                        fontWeight: unread > 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    at == null ? "" : chatListTimeLabel(context, at.toLocal()),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: unread > 0
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  if (unread > 0)
                    Badge(
                      label: Text("$unread"),
                      backgroundColor: scheme.primary,
                    )
                  else
                    const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
