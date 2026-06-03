import 'package:flutter/material.dart';
import '../splash_screen.dart';
import '../../state/app_state.dart';
import '../../state/chat_directive.dart';
import '../../widgets/glass_widgets.dart';
import '../../widgets/chat_directives.dart';
import 'emergency_screens.dart';

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
    // Listen for emergency SOS flag changes outside of build()
    AppState.instance.addListener(_maybeHandleEmergency);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_maybeHandleEmergency);
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
    AppState.instance.respondToDirective(
      directiveId: d.directiveId,
      selectedValue: opt.value,
      userEcho: opt.label,
    );
    _scrollToBottom();
  }

  void _onConfirmed(ChatUiDirective d, List<ChatOption> opts) {
    final echo =
        opts.isEmpty ? "Không có triệu chứng kèm theo" : opts.map((e) => e.label).join(", ");
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

  /// Bot routed to emergency — open the SOS screen once.
  void _maybeHandleEmergency() {
    final appState = AppState.instance;
    if (appState.pendingEmergencySos) {
      appState.consumeEmergencySos();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SOSEmergencyAlertScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return Scaffold(
      appBar: GlassAppBar(
        title: "Trợ Lý Y Tế AI",
        actions: [
          // Quick SOS access for emergencies.
          IconButton(
            icon: const Icon(Icons.emergency_share, color: GlassTheme.error, size: 26),
            tooltip: "Cấp cứu 115",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SOSEmergencyAlertScreen()),
              );
            },
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
      body: Stack(
        children: [
          // Base Chatboard
          GlassBackground(
            child: Column(
              children: [
                // Top Progress indicator bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  color: Colors.white.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      const Icon(Icons.psychology, color: GlassTheme.oceanBlue, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Tiến trình khảo sát: ",
                        style: GlassTheme.labelCaps(color: GlassTheme.onSurfaceVariant),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _flowPhase == 0 ? 0.35 : (_flowPhase == 1 ? 0.75 : 1.0),
                            backgroundColor: Colors.white.withValues(alpha: 0.4),
                            color: GlassTheme.oceanBlue,
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

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

  Widget _buildQuickSymptomsGrid() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _quickSymptoms.length,
        itemBuilder: (context, index) {
          final sym = _quickSymptoms[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ActionChip(
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              side: BorderSide(color: GlassTheme.oceanBlue.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              avatar: Icon(sym["icon"] as IconData, size: 16, color: GlassTheme.oceanBlue),
              label: Text(sym["name"] as String, style: GlassTheme.bodyMd().copyWith(fontSize: 12)),
              onPressed: () => _handleQuickSymptomTap(sym),
            ),
          );
        },
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
                  // Removed textInputAction: TextInputAction.send to fix Vietnamese Telex typing issues
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

  Widget _buildSymptomSurveyCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: GlassCard(
        borderColor: GlassTheme.cyan,
        borderWidth: 1.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment, color: GlassTheme.oceanBlue),
                const SizedBox(width: 8),
                Text(
                  "Khảo Sát Chi Tiết Triệu Chứng",
                  style: GlassTheme.h3(color: GlassTheme.oceanBlue).copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Duration selector
            Text(
              "Triệu chứng xuất hiện bao lâu rồi?",
              style: GlassTheme.bodyMd().copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: _durationOptions.map((opt) {
                final isSelected = _durationSelected == opt;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected ? GlassTheme.oceanBlue.withValues(alpha: 0.12) : Colors.transparent,
                        side: BorderSide(
                          color: isSelected ? GlassTheme.oceanBlue : GlassTheme.outline.withValues(alpha: 0.4),
                          width: isSelected ? 2 : 1,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        setState(() {
                          _durationSelected = opt;
                        });
                      },
                      child: Text(
                        opt,
                        style: GlassTheme.bodyMd(
                          color: isSelected ? GlassTheme.oceanBlue : GlassTheme.onSurface,
                        ).copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Severity Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Mức độ khó chịu/đau đớn:",
                  style: GlassTheme.bodyMd().copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  "${_severityValue.toInt()}/10",
                  style: GlassTheme.h3(
                    color: _severityValue >= 7.0
                        ? GlassTheme.error
                        : (_severityValue >= 4.0 ? Colors.orange : Colors.green),
                  ).copyWith(fontSize: 16),
                ),
              ],
            ),
            Slider(
              value: _severityValue,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              activeColor: GlassTheme.oceanBlue,
              inactiveColor: Colors.white30,
              onChanged: (val) {
                setState(() {
                  _severityValue = val;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Nhẹ nhàng", style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 11)),
                Text("Rất dữ dội", style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // High-fidelity AI calculation progress screen
  Widget _buildAIProcessingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Large rotating pulsing circular analyzer
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: GlassTheme.cyan.withValues(alpha: 0.3),
                          blurRadius: 50,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: _analyzingProgress,
                      strokeWidth: 8,
                      color: GlassTheme.cyan,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                  // Glowing glass center card with pulsing heart icon
                  GlassCard(
                    padding: EdgeInsets.zero,
                    width: 120,
                    height: 120,
                    borderRadius: 60,
                    opacity: 0.8,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.monitor_heart,
                            color: GlassTheme.oceanBlue,
                            size: 44,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${(_analyzingProgress * 100).toInt()}%",
                            style: GlassTheme.h2(color: GlassTheme.oceanBlue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Glowing Glass Text Panel
              GlassCard(
                opacity: 0.85,
                borderColor: GlassTheme.oceanBlue,
                borderWidth: 1.5,
                child: Column(
                  children: [
                    Text(
                      "AI Đang Phân Tích...",
                      style: GlassTheme.h2(color: GlassTheme.oceanBlue),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _analyzingStatus,
                      style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white30),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock, size: 14, color: GlassTheme.outline),
                        const SizedBox(width: 6),
                        Text(
                          "Đã mã hóa đầu cuối tuân thủ HIPAA",
                          style: GlassTheme.labelCaps(color: GlassTheme.outline).copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
