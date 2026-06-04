import 'package:flutter/material.dart';
import '../splash_screen.dart';
import '../../state/app_state.dart';
import '../../state/chat_directive.dart';
import '../../widgets/glass_widgets.dart';
import '../../widgets/chat_directives.dart';
import 'emergency_screens.dart';
import '../../config/env.dart';


/// The AI chatbot screen. A thin, pure chat shell: it renders messages and the
/// interactive components the bot attaches to them, and forwards every user
/// action (free text or component response) back into [AppState]. All decision
/// logic lives in AppState's seam, so this screen never changes when Gemini
/// replaces the scripted brain.
class SymptomFlowScreen extends StatefulWidget {
  const SymptomFlowScreen({super.key});

  @override
  State<SymptomFlowScreen> createState() => _SymptomFlowScreenState();
}

class _SymptomFlowScreenState extends State<SymptomFlowScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;
    AppState.instance.sendChatMessage(text);
    _inputController.clear();
    _scrollToBottom();
  }

  // ── component response handlers → AppState.respondToDirective ──────────────

  void _onPicked(ChatUiDirective d, ChatOption opt) {
    if (opt.value == '__retry__') {
      // Retry: find the last user message and resend it
      final messages = AppState.instance.chatMessages;
      final lastUserMsg = messages.lastWhere(
        (m) => m.isUser,
        orElse: () => ChatMessage(text: '', isUser: true, time: DateTime.now()),
      );
      if (lastUserMsg.text.isNotEmpty) {
        AppState.instance.sendChatMessage(lastUserMsg.text);
      }
      _scrollToBottom();
      return;
    }
    AppState.instance.respondToDirective(
      directiveId: d.directiveId,
      selectedValue: opt.value,
      userEcho: opt.label,
    );
    _scrollToBottom();
  }


  void _onConfirmed(ChatUiDirective d, List<ChatOption> opts) {
    final echo = opts.isEmpty
        ? "Không có triệu chứng kèm theo"
        : opts.map((e) => e.label).join(", ");
    AppState.instance.respondToDirective(
      directiveId: d.directiveId,
      selectedValues: opts.map((e) => e.value).toList(),
      userEcho: echo,
    );
    _scrollToBottom();
  }

  void _onSlider(ChatUiDirective d, double value) {
    final suffix = d.slider?.unitSuffix ?? '/10';
    AppState.instance.respondToDirective(
      directiveId: d.directiveId,
      sliderValue: value,
      userEcho: "${value.toInt()}$suffix",
    );
    _scrollToBottom();
  }

  void _onBook() {
    final appState = AppState.instance;
    appState.triggerBookingFromAI();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainFramework(initialPatientTab: 1)),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: GlassTheme.surface.withValues(alpha: 0.9),
          title: Row(
            children: [
              const Icon(Icons.emergency_share, color: GlassTheme.error),
              const SizedBox(width: 10),
              Text("CẢNH BÁO", style: GlassTheme.h3(color: GlassTheme.error)),
            ],
          ),
          content: Text(
            "Nếu bạn hoặc người thân đang gặp tình trạng nguy hiểm, vui lòng gọi ngay 115 hoặc đến cơ sở y tế gần nhất.",
            style: GlassTheme.bodyMd(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Đã hiểu", style: GlassTheme.bodyMd(color: GlassTheme.oceanBlue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return Scaffold(
      appBar: GlassAppBar(
        title: Env.hasGeminiApiKey ? "Trợ Lý AI ✦ Gemini" : "Trợ Lý AI ✦ Demo",

        actions: [
          // Quick SOS access for emergencies.
          IconButton(
            icon: const Icon(Icons.emergency_share, color: GlassTheme.error, size: 26),
            tooltip: "Cấp cứu 115",
            onPressed: _showEmergencyDialog,
          ),
          IconButton(
            icon: const Icon(Icons.swap_horizontal_circle_outlined,
                color: GlassTheme.oceanBlue, size: 28),
            tooltip: "Đổi vai trò",
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SplashScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: GlassTheme.oceanBlue),
            tooltip: "Trò chuyện mới",
            onPressed: () => appState.resetChat(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GlassBackground(
        child: Column(
          children: [
            Expanded(
              child: ListenableBuilder(
                listenable: appState,
                builder: (context, child) {
                  final messages = appState.chatMessages;
                  final itemCount = messages.length + (appState.isAiTyping ? 1 : 0);

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      if (index == messages.length && appState.isAiTyping) {
                        return _buildAiTypingIndicator();
                      }
                      final msg = messages[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChatBubble(msg),
                          if (msg.directive != null && msg.directive!.isInteractive)
                            ChatDirectiveView(
                              directive: msg.directive!,
                              enabled: !msg.directiveResolved,
                              onPicked: (opt) => _onPicked(msg.directive!, opt),
                              onConfirmed: (opts) => _onConfirmed(msg.directive!, opts),
                              onSlider: (v) => _onSlider(msg.directive!, v),
                              onBook: _onBook,
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            _buildChatBar(),
          ],
        ),
      ),
    );
  }

  // ── chat bubble ─────────────────────────────────────────────────────────
  Widget _buildChatBubble(ChatMessage message) {
    final isMe = message.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(color: GlassTheme.oceanBlue, shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.smart_toy, color: Colors.white, size: 18)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
              opacity: isMe ? 0.8 : 0.6,
              borderColor: isMe ? GlassTheme.oceanBlue : Colors.white,
              borderWidth: 1.0,
              child: Text(
                message.text,
                style: GlassTheme.bodyMd(
                  color: isMe ? GlassTheme.oceanBlue : GlassTheme.onSurface,
                ).copyWith(fontWeight: isMe ? FontWeight.w600 : FontWeight.normal),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(gradient: GlassTheme.accentGradient, shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.person, color: Colors.white, size: 18)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAiTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: GlassTheme.oceanBlue, shape: BoxShape.circle),
            child: const Center(child: Icon(Icons.smart_toy, color: Colors.white, size: 18)),
          ),
          const SizedBox(width: 8),
          const GlassCard(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: SizedBox(
              width: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _TypingDot(delay: 0),
                  _TypingDot(delay: 200),
                  _TypingDot(delay: 400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBar() {
    // GlassBackground already wraps the body in a SafeArea, so the Column's
    // bottom edge sits right at the top of the floating nav bar. Only a small
    // gap is needed to separate the chat bar from the nav bar.
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: GlassCard(
        padding: const EdgeInsets.all(8),
        borderRadius: 32,
        opacity: 0.8,
        borderColor: GlassTheme.oceanBlue,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: GlassTheme.cyan, shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.mic, color: Colors.white, size: 22)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextField(
                  controller: _inputController,
                  style: GlassTheme.bodyMd(),
                  maxLines: 5,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  // No textInputAction.send — keeps Vietnamese Telex typing intact.
                  decoration: InputDecoration(
                    hintText: "Mô tả triệu chứng của bạn...",
                    hintStyle: GlassTheme.bodyMd(color: GlassTheme.outline),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: _handleSend,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: GlassTheme.oceanBlue),
              onPressed: () => _handleSend(_inputController.text),
            ),
          ],
        ),
      ),
    );
  }
}

// Micro pulsing dot animation for chatbot typing.
class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _animController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(color: GlassTheme.oceanBlue, shape: BoxShape.circle),
      ),
    );
  }
}
