import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/voice_input_service.dart';
import '../../state/app_state.dart';
import '../../state/chat_directive.dart';
import '../../widgets/glass_widgets.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/chat_directives.dart';
import '../../widgets/voice_recording_indicator.dart';
import '../../widgets/patient_shell_menu.dart';
import '../splash_screen.dart';
import 'patient_navigation.dart';

enum SymptomFlowMode { guestConsultation, inShell }

/// The AI chatbot screen. A thin, pure chat shell: it renders messages and the
/// interactive components the bot attaches to them, and forwards every user
/// action (free text or component response) back into [AppState]. All decision
/// logic lives in AppState's seam, so this screen never changes when Gemini
/// replaces the scripted brain.
class SymptomFlowScreen extends StatefulWidget {
  final SymptomFlowMode mode;

  const SymptomFlowScreen({
    super.key,
    this.mode = SymptomFlowMode.inShell,
  });

  bool get isGuest => mode == SymptomFlowMode.guestConsultation;

  @override
  State<SymptomFlowScreen> createState() => _SymptomFlowScreenState();
}

class _SymptomFlowScreenState extends State<SymptomFlowScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final VoiceInputService _voice = VoiceInputService();

  // Image selected but not yet sent (shown as a preview above the input).
  ChatAttachment? _pendingImage;
  bool _voiceAvailable = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initVoice();
  }

  @override
  void dispose() {
    _voice.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initVoice() async {
    _voice.onPartialResult = (text) {
      if (!mounted) return;
      _inputController.text = text;
      _inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: text.length),
      );
    };
    _voice.onListeningStateChanged = (listening) {
      if (!mounted) return;
      setState(() => _isListening = listening);
    };
    final ok = await _voice.initialize();
    if (mounted) setState(() => _voiceAvailable = ok);
  }

  Future<void> _toggleVoiceInput() async {
    if (!_voiceAvailable) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nhận diện giọng nói không khả dụng trên thiết bị này.',
          ),
        ),
      );
      return;
    }
    if (_isListening || _voice.isListening) {
      final text = await _voice.stopListening();
      if (!mounted) return;
      if (text == null || text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không nhận diện được giọng nói.'),
          ),
        );
        return;
      }
      _handleSend(text);
      return;
    }

    try {
      final started = await _voice.startListening();
      if (!mounted) return;
      if (!started) {
        final detail = _voice.lastErrorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              detail != null && detail.isNotEmpty
                  ? detail
                  : 'Không thể bắt đầu ghi âm. Vui lòng kiểm tra quyền micro.',
            ),
          ),
        );
        return;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi ghi âm: $e')),
      );
    }
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
    final image = _pendingImage;
    if (text.trim().isEmpty && image == null) return;
    AppState.instance.sendChatMessage(text, image: image);
    _inputController.clear();
    setState(() => _pendingImage = null);
    _scrollToBottom();
  }

  // ── image attachment ───────────────────────────────────────────────────────

  /// Lets the user attach a photo from the camera or gallery. The bytes are
  /// kept in memory (works on every platform incl. web) and previewed before
  /// sending. Compressed on pick to keep the base64 payload small.
  Future<void> _pickFrom(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 70,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pendingImage = ChatAttachment(
          bytes: bytes,
          mimeType: _mimeTypeFor(file),
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể truy cập ảnh. Vui lòng kiểm tra quyền truy cập.")),
      );
    }
  }

  String _mimeTypeFor(XFile file) {
    final mime = file.mimeType;
    if (mime != null && mime.startsWith('image/')) return mime;
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.heic') || name.endsWith('.heif')) return 'image/heic';
    if (name.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: GlassTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined,
                    color: GlassTheme.oceanBlue),
                title: Text("Chụp ảnh", style: GlassTheme.bodyMd()),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickFrom(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: GlassTheme.oceanBlue),
                title: Text("Chọn từ thư viện", style: GlassTheme.bodyMd()),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickFrom(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showFullImage(ChatAttachment image) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(child: Image.memory(image.bytes)),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ),
          ],
        ),
      ),
    );
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
      if (lastUserMsg.text.isNotEmpty || lastUserMsg.image != null) {
        AppState.instance
            .sendChatMessage(lastUserMsg.text, image: lastUserMsg.image);
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
    if (widget.isGuest) {
      openPatientLoginThenBooking(context);
    } else {
      appState.setPatientNavIndex(1);
    }
  }

  void _onBookingCta() {
    openPatientLoginThenBooking(context);
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
              child: Text("Đã hiểu",
                  style: GlassTheme.bodyMd(color: GlassTheme.oceanBlue)),
            ),
          ],
        );
      },
    );
  }

  void _onMenuSelected(String value) {
    if (widget.isGuest) {
      if (value == 'switch_role') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
        );
      }
      return;
    }
    PatientShellMenu.handleSelection(context, value);
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    if (widget.isGuest) {
      return const [
        PopupMenuItem(
          value: 'switch_role',
          child: Row(
            children: [
              Icon(Icons.arrow_back,
                  size: 20, color: GlassTheme.oceanBlue),
              SizedBox(width: 12),
              Text("Quay lại"),
            ],
          ),
        ),
      ];
    }
    return PatientShellMenu.items();
  }

  Widget _buildWelcomeBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: GlassCard(
        borderColor: GlassTheme.oceanBlue,
        borderWidth: 1.5,
        opacity: 0.92,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandMark(size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Chào mừng đến với DrAI",
                        style: GlassTheme.h2(color: GlassTheme.oceanBlue)
                            .copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: GlassTheme.cyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: GlassTheme.cyan.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          "Chế độ tư vấn — Không cần đăng nhập",
                          style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)
                              .copyWith(fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandMark(size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Bạn đang trò chuyện với Trợ lý DrAI để được hướng dẫn về triệu chứng. "
                    "Hãy mô tả tình trạng của bạn bên dưới — kết quả chỉ mang tính tham khảo, "
                    "không thay thế khám bác sĩ.",
                    style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)
                        .copyWith(fontSize: 12.5, height: 1.45),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final title = widget.isGuest ? "Tư vấn triệu chứng" : "Tư vấn với DrAI";

    return Scaffold(
      appBar: GlassAppBar(
        title: title,
        actions: [
          if (widget.isGuest)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: TextButton.icon(
                onPressed: _onBookingCta,
                icon: const Icon(Icons.edit_calendar_outlined,
                    size: 18, color: GlassTheme.oceanBlue),
                label: Text(
                  "Đặt lịch khám",
                  style: GlassTheme.bodyMd(color: GlassTheme.oceanBlue)
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: GlassTheme.oceanBlue, size: 24),
            tooltip: "Làm mới",
            onPressed: () {
              appState.resetChat();
            },
          ),
          IconButton(
            icon: const Icon(Icons.emergency_share,
                color: GlassTheme.error, size: 26),
            tooltip: "Cấp cứu 115",
            onPressed: _showEmergencyDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: GlassTheme.oceanBlue),
            tooltip: "Menu",
            offset: const Offset(0, 56),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: _onMenuSelected,
            itemBuilder: (context) => _buildMenuItems(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GlassBackground(
        child: Column(
          children: [
            if (widget.isGuest) _buildWelcomeBanner(),
            Expanded(
              child: ListenableBuilder(
                listenable: appState,
                builder: (context, child) {
                  final messages = appState.chatMessages;
                  final itemCount =
                      messages.length + (appState.isAiTyping ? 1 : 0);

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
                          if (msg.directive != null &&
                              msg.directive!.isInteractive)
                            ChatDirectiveView(
                              directive: msg.directive!,
                              enabled: !msg.directiveResolved,
                              onPicked: (opt) => _onPicked(msg.directive!, opt),
                              onConfirmed: (opts) =>
                                  _onConfirmed(msg.directive!, opts),
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
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            const BrandMark(size: 32),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.image != null) ...[
                    GestureDetector(
                      onTap: () => _showFullImage(message.image!),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 200,
                            maxWidth: 240,
                          ),
                          child: Image.memory(
                            message.image!.bytes,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    if (message.text.isNotEmpty) const SizedBox(height: 8),
                  ],
                  if (message.text.isNotEmpty)
                    Text(
                      message.text,
                      style: GlassTheme.bodyMd(
                        color:
                            isMe ? GlassTheme.oceanBlue : GlassTheme.onSurface,
                      ).copyWith(
                          fontWeight:
                              isMe ? FontWeight.w600 : FontWeight.normal),
                    ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  gradient: GlassTheme.accentGradient, shape: BoxShape.circle),
              child: const Center(
                  child: Icon(Icons.person, color: Colors.white, size: 18)),
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
          const BrandMark(size: 32),
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

  Widget _buildPendingImagePreview() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                _pendingImage!.bytes,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: -8,
              right: -8,
              child: GestureDetector(
                onTap: () => setState(() => _pendingImage = null),
                child: Container(
                  decoration: const BoxDecoration(
                    color: GlassTheme.error,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBar() {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        // Must read isAiTyping inside this builder — otherwise micDisabled goes
        // stale when only AppState notifies (mic stays grey after AI finishes).
        final micDisabled = appState.isAiTyping || !_voiceAvailable;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: GlassCard(
            padding: const EdgeInsets.all(8),
            borderRadius: 32,
            opacity: 0.8,
            borderColor: _isListening ? GlassTheme.error : GlassTheme.oceanBlue,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isListening) const VoiceRecordingIndicator(),
                if (_pendingImage != null) _buildPendingImagePreview(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_photo_alternate_outlined,
                          color: GlassTheme.oceanBlue, size: 26),
                      tooltip: "Đính kèm ảnh",
                      onPressed:
                          _isListening ? null : _showImageSourceSheet,
                    ),
                    if (_voiceAvailable)
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.stop : Icons.mic_none,
                          color: _isListening
                              ? GlassTheme.error
                              : (micDisabled
                                  ? GlassTheme.outline
                                  : GlassTheme.oceanBlue),
                          size: 26,
                        ),
                        tooltip: _isListening
                            ? "Dừng và gửi"
                            : "Nói triệu chứng",
                        onPressed: micDisabled && !_isListening
                            ? null
                            : _toggleVoiceInput,
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: TextField(
                          controller: _inputController,
                          style: GlassTheme.bodyMd(),
                          maxLines: 5,
                          minLines: 1,
                          readOnly: _isListening,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: _isListening
                                ? "Đang nghe... nói triệu chứng của bạn"
                                : "Mô tả triệu chứng của bạn...",
                            hintStyle:
                                GlassTheme.bodyMd(color: GlassTheme.outline),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onSubmitted: _isListening ? null : _handleSend,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: _isListening || appState.isAiTyping
                            ? GlassTheme.outline
                            : GlassTheme.oceanBlue,
                      ),
                      onPressed: _isListening || appState.isAiTyping
                          ? null
                          : () => _handleSend(_inputController.text),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
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
        decoration: const BoxDecoration(
            color: GlassTheme.oceanBlue, shape: BoxShape.circle),
      ),
    );
  }
}
