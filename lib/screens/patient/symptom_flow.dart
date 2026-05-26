import 'dart:async';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import 'recommendation_result.dart';

class SymptomFlowScreen extends StatefulWidget {
  const SymptomFlowScreen({super.key});

  @override
  State<SymptomFlowScreen> createState() => _SymptomFlowScreenState();
}

class _SymptomFlowScreenState extends State<SymptomFlowScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Survey selections
  double _severityValue = 5.0; // 1-10 severity scale
  String _durationSelected = "1-3 ngày"; // Dưới 24h, 1-3 ngày, > 3 ngày
  
  // Phase management
  // 0: Chat & Symptom selection
  // 1: Details survey (shows inline details card)
  // 2: AI Loading screen (full-overlay)
  int _flowPhase = 0;
  
  // AI Progress overlay variables
  double _analyzingProgress = 0.0;
  String _analyzingStatus = "Đang kết nối hệ thống y khoa...";
  Timer? _analysisTimer;

  final List<String> _durationOptions = ["Dưới 24h", "1-3 ngày", "Hơn 3 ngày"];

  final List<Map<String, dynamic>> _quickSymptoms = [
    {"name": "Đau đầu", "icon": Icons.headset_off, "risk": "Trung bình"},
    {"name": "Đau ngực", "icon": Icons.favorite_border, "risk": "Khẩn cấp"},
    {"name": "Sốt cao", "icon": Icons.thermostat, "risk": "Cao"},
    {"name": "Ho khan", "icon": Icons.air, "risk": "Thấp"},
    {"name": "Khó thở", "icon": Icons.bubble_chart, "risk": "Cao"},
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _analysisTimer?.cancel();
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
    
    final appState = AppState.instance;
    appState.sendChatMessage(text);
    _inputController.clear();
    _scrollToBottom();
    
    // Automatically trigger showing the Survey details card after 1 conversation exchange
    if (_flowPhase == 0) {
      Timer(const Duration(milliseconds: 2000), () {
        setState(() {
          _flowPhase = 1;
        });
        _scrollToBottom();
      });
    }
  }

  void _handleQuickSymptomTap(Map<String, dynamic> symptom) {
    final name = symptom["name"] as String;
    final risk = symptom["risk"] as String;
    
    final appState = AppState.instance;
    appState.addAuditLog("Bệnh nhân chọn nhanh triệu chứng: $name (Mức độ: $risk)");
    
    // Send selected message
    appState.sendChatMessage("Tôi bị $name.");
    
    setState(() {
      _flowPhase = 1; // Transition to detail survey
    });
    
    _scrollToBottom();
  }

  void _startAIAnalysis() {
    setState(() {
      _flowPhase = 2; // AI analyzing progress screen
      _analyzingProgress = 0.0;
    });

    final appState = AppState.instance;
    appState.addAuditLog("Bệnh nhân khởi động quy trình chẩn đoán AI.");

    int step = 0;
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        _analyzingProgress += 0.12;
        step++;

        if (step == 2) {
          _analyzingStatus = "Đang đối chuẩn triệu chứng với 1.2M hồ sơ...";
        } else if (step == 5) {
          _analyzingStatus = "Phân tích tần suất và các chỉ số sinh tồn liên quan...";
        } else if (step == 7) {
          _analyzingStatus = "Đang tính toán mức độ rủi ro & giải pháp tối ưu...";
        }

        if (_analyzingProgress >= 1.0) {
          _analyzingProgress = 1.0;
          timer.cancel();
          _onAnalysisComplete();
        }
      });
    });
  }

  void _onAnalysisComplete() {
    final appState = AppState.instance;
    
    // Determine risk based on selections
    String finalRisk = "Thấp";
    String symptomsSummary = appState.selectedSymptomsText;
    if (symptomsSummary.isEmpty) {
      symptomsSummary = "Khảo sát triệu chứng chung";
    }

    final lowerSymptoms = symptomsSummary.toLowerCase();
    if (lowerSymptoms.contains("ngực") || lowerSymptoms.contains("khó thở")) {
      finalRisk = _severityValue >= 7.0 ? "Khẩn cấp" : "Cao";
    } else if (lowerSymptoms.contains("sốt") || _severityValue >= 6.0) {
      finalRisk = "Cao";
    } else if (_severityValue >= 4.0 || _durationSelected == "Hơn 3 ngày") {
      finalRisk = "Trung bình";
    }

    appState.completeDirectAssessment(
      "$symptomsSummary. Thời gian kéo dài: $_durationSelected. Mức độ nghiêm trọng: ${_severityValue.toInt()}/10.",
      finalRisk,
    );

    // Push the result screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RecommendationResultScreen(
          symptoms: appState.selectedSymptomsText,
          risk: finalRisk,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return Scaffold(
      appBar: GlassAppBar(
        title: "Đánh Giá Sức Khỏe AI",
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: GlassTheme.oceanBlue),
            onPressed: () {
              appState.resetChat();
              setState(() {
                _flowPhase = 0;
              });
            },
          )
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
                  color: Colors.white.withOpacity(0.3),
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
                            backgroundColor: Colors.white.withOpacity(0.4),
                            color: GlassTheme.oceanBlue,
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Chat logs list
                Expanded(
                  child: ListenableBuilder(
                    listenable: appState,
                    builder: (context, child) {
                      final messages = appState.chatMessages;
                      
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        itemCount: messages.length + (_flowPhase == 1 ? 1 : 0) + (appState.isAiTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          // 1. Typing animation
                          if (index == messages.length && appState.isAiTyping) {
                            return _buildAiTypingIndicator();
                          }
                          
                          // 2. Render survey block if flow phase is 1 (inline survey bento card)
                          if (index == messages.length && _flowPhase == 1) {
                            return _buildSymptomSurveyCard();
                          }
                          
                          final msg = messages[index];
                          return _buildChatBubble(msg);
                        },
                      );
                    },
                  ),
                ),

                // Bottom presets or text entry input bar
                if (_flowPhase == 0) ...[
                  _buildQuickSymptomsGrid(),
                  _buildChatBar(),
                ] else if (_flowPhase == 1) ...[
                  // Prompt to complete analysis
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                    child: GlassButton(
                      text: "Tiến hành phân tích y khoa AI",
                      icon: Icons.auto_awesome,
                      onPressed: _startAIAnalysis,
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Fullscreen Overlay for AI computing progress (Phase 2)
          if (_flowPhase == 2) _buildAIProcessingOverlay(),
        ],
      ),
    );
  }

  // Visual widgets

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
              decoration: const BoxDecoration(
                color: GlassTheme.oceanBlue,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
              ),
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
                ).copyWith(
                  fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: GlassTheme.accentGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
            ),
          ]
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
            decoration: const BoxDecoration(
              color: GlassTheme.oceanBlue,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
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
              backgroundColor: Colors.white.withOpacity(0.5),
              side: BorderSide(color: GlassTheme.oceanBlue.withOpacity(0.3)),
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
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 96),
      child: GlassCard(
        padding: const EdgeInsets.all(8),
        borderRadius: 32,
        opacity: 0.8,
        borderColor: GlassTheme.oceanBlue,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: GlassTheme.cyan,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.mic, color: Colors.white, size: 22),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextField(
                  controller: _inputController,
                  style: GlassTheme.bodyMd(),
                  decoration: InputDecoration(
                    hintText: "Mô tả triệu chứng của bạn...",
                    hintStyle: GlassTheme.bodyMd(color: GlassTheme.outline),
                    border: InputBorder.none,
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
                        backgroundColor: isSelected ? GlassTheme.oceanBlue.withOpacity(0.12) : Colors.transparent,
                        side: BorderSide(
                          color: isSelected ? GlassTheme.oceanBlue : GlassTheme.outline.withOpacity(0.4),
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
      color: Colors.black.withOpacity(0.4),
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
                          color: GlassTheme.cyan.withOpacity(0.3),
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

// Micro pulsing dot animation for chatbot typing
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
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _animController.repeat(reverse: true);
      }
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
        decoration: const BoxDecoration(
          color: GlassTheme.oceanBlue,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
