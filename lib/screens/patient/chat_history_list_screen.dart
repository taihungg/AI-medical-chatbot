import 'package:flutter/material.dart';
import 'symptom_flow.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';

class ChatHistoryListScreen extends StatefulWidget {
  const ChatHistoryListScreen({super.key});

  @override
  State<ChatHistoryListScreen> createState() => _ChatHistoryListScreenState();
}

class _ChatHistoryListScreenState extends State<ChatHistoryListScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final sessions = state.chatSessions;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const GlassAppBar(
            title: "Tư vấn DrAI",
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GlassButton(
                  text: "Bắt đầu tư vấn mới",
                  icon: Icons.add_comment_rounded,
                  onPressed: () {
                    state.createNewSession();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SymptomFlowScreen()),
                    );
                  },
                ),
              ),
              Expanded(
                child: sessions.isEmpty
                    ? Center(
                        child: Text(
                          "Chưa có lịch sử tư vấn",
                          style: GlassTheme.bodyLg(color: GlassTheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          // Find the first user message for a snippet
                          final userMsgs = session.messages.where((m) => m.isUser).toList();
                          final snippet = userMsgs.isNotEmpty ? userMsgs.first.text : "Cuộc trò chuyện mới";
                          
                          // Format time
                          final timeStr = "${session.startTime.day}/${session.startTime.month} lúc ${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')}";

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: InkWell(
                                onTap: () {
                                  state.setActiveSession(session.id);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const SymptomFlowScreen()),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: GlassTheme.oceanBlue.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.chat_bubble_outline, color: GlassTheme.oceanBlue),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(timeStr, style: GlassTheme.labelCaps(color: GlassTheme.onSurfaceVariant)),
                                          const SizedBox(height: 4),
                                          Text(
                                            snippet,
                                            style: GlassTheme.h3(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: GlassTheme.outline),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 90), // Spacing for bottom nav bar
            ],
          ),
        );
      },
    );
  }
}
