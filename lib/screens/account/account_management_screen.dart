import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import '../../models/models.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final profile = AppState.instance.currentUserProfile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _addressController = TextEditingController(text: profile?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = UserProfile(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
      );

      AppState.instance.updateUserProfile(updatedProfile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cập nhật thông tin thành công!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlassAppBar(
        title: "Quản lý Tài khoản",

      ),
      body: GlassBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: GlassCard(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_circle,
                        size: 80,
                        color: GlassTheme.oceanBlue,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Thông tin cá nhân",
                        style: GlassTheme.h2(),
                      ),
                      const SizedBox(height: 32),
                      
                      // Name
                      TextFormField(
                        controller: _nameController,
                        style: GlassTheme.bodyMd(),
                        decoration: InputDecoration(
                          labelText: "Họ và Tên",
                          labelStyle: TextStyle(color: GlassTheme.onSurfaceVariant),
                          prefixIcon: const Icon(Icons.person_outline, color: GlassTheme.oceanBlue),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Vui lòng nhập họ và tên" : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        style: GlassTheme.bodyMd(),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Số điện thoại",
                          labelStyle: TextStyle(color: GlassTheme.onSurfaceVariant),
                          prefixIcon: const Icon(Icons.phone_outlined, color: GlassTheme.oceanBlue),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Vui lòng nhập số điện thoại" : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Email
                      TextFormField(
                        controller: _emailController,
                        style: GlassTheme.bodyMd(),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(color: GlassTheme.onSurfaceVariant),
                          prefixIcon: const Icon(Icons.email_outlined, color: GlassTheme.oceanBlue),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Vui lòng nhập email";
                          if (!value.contains('@')) return "Email không hợp lệ";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Address
                      TextFormField(
                        controller: _addressController,
                        style: GlassTheme.bodyMd(),
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: "Địa chỉ",
                          labelStyle: TextStyle(color: GlassTheme.onSurfaceVariant),
                          prefixIcon: const Icon(Icons.location_on_outlined, color: GlassTheme.oceanBlue),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Vui lòng nhập địa chỉ" : null,
                      ),
                      const SizedBox(height: 32),
                      
                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: GlassButton(
                          onPressed: _saveProfile,
                          text: "LƯU THAY ĐỔI",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
