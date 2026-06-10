import 'package:flutter/material.dart';
import '../widgets/glass_widgets.dart';
import '../state/app_state.dart';

class LoginScreen extends StatefulWidget {
  final UserRole expectedRole;

  const LoginScreen({super.key, required this.expectedRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pre-fill for easier testing
    if (widget.expectedRole == UserRole.patient) {
      _emailController.text = 'benhnhan@test.com';
    } else if (widget.expectedRole == UserRole.doctor) {
      _emailController.text = 'bacsi@test.com';
    } else if (widget.expectedRole == UserRole.manager) {
      _emailController.text = 'quanly@test.com';
    }
    _passwordController.text = '123456';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Vui lòng nhập đầy đủ email và mật khẩu.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await AppState.instance.login(email, password, widget.expectedRole);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Return success to the caller
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage = "Sai email hoặc mật khẩu cho vai trò này.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String roleTitle = "";
    Color roleColor = GlassTheme.oceanBlue;
    
    switch (widget.expectedRole) {
      case UserRole.patient:
        roleTitle = "Bệnh nhân";
        break;
      case UserRole.doctor:
        roleTitle = "Bác sĩ";
        roleColor = Colors.teal;
        break;
      case UserRole.manager:
        roleTitle = "Quản lý";
        roleColor = Colors.deepPurple;
        break;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(
        title: "Đăng Nhập",
      ),
      body: GlassBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_hospital, size: 80, color: roleColor),
                const SizedBox(height: 24),
                Text(
                  "Đăng Nhập Vai Trò",
                  style: GlassTheme.h2(color: roleColor),
                ),
                const SizedBox(height: 8),
                Text(
                  "Đăng nhập tài khoản $roleTitle để tiếp tục.",
                  style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Email field
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: GlassTheme.outline.withValues(alpha: 0.3)),
                        ),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.email_outlined, color: GlassTheme.oceanBlue),
                            border: InputBorder.none,
                            hintText: "Email",
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Password field
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: GlassTheme.outline.withValues(alpha: 0.3)),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.lock_outline, color: GlassTheme.oceanBlue),
                            border: InputBorder.none,
                            hintText: "Mật khẩu",
                          ),
                        ),
                      ),
                      
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: GlassTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: GlassTheme.error.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: GlassTheme.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: GlassTheme.bodyMd(color: GlassTheme.error).copyWith(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: _isLoading 
                            ? const Center(child: CircularProgressIndicator())
                            : GlassButton(
                                text: "Đăng Nhập",
                                onPressed: _handleLogin,
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Dữ liệu đang dùng: email có đuôi @test.com và mk là 123456",
                        style: GlassTheme.labelCaps(color: GlassTheme.outline).copyWith(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
