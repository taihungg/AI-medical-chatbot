import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassTheme {
  // Brand Color Palette
  static const Color primary = Color(0xFF005D90);
  static const Color oceanBlue = Color(0xFF0077B6);
  static const Color cyan = Color(0xFF50D9FE);
  static const Color teal = Color(0xFF00645F);
  static const Color surface = Color(0xFFF7F9FB);
  static const Color darkSurface = Color(0xFF191C1E);
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF404850);
  static const Color outline = Color(0xFF707881);
  static const Color error = Color(0xFFBA1A1A);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [oceanBlue, Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00B2A9), cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFCDE5FF), Color(0xFFF7F9FB), Color(0xFFB3EBFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Typography Styles
  static TextStyle h1({Color color = onSurface}) => GoogleFonts.inter(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.6,
        color: color,
      );

  static TextStyle h2({Color color = onSurface}) => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle h3({Color color = onSurface}) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  static TextStyle bodyLg({Color color = onSurface}) => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMd({Color color = onSurface}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color,
      );

  static TextStyle labelCaps({Color color = onSurface}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: color,
      );
}

// Background layer with organic meshes and glowing blobs
class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDCEBFF), Color(0xFFF7F9FB), Color(0xFFD4F6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Simulated glowing blobs
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: GlassTheme.oceanBlue.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: RepaintBoundary(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                color: GlassTheme.cyan.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: RepaintBoundary(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),
          Positioned(
            top: 350,
            right: 50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF72F7ED).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: RepaintBoundary(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

// Frosted Glass Card
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final dynamic borderRadius;
  final double borderWidth;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 24.0,
    this.opacity = 0.65,
    this.borderRadius = 24.0,
    this.borderWidth = 1.2,
    this.borderColor = Colors.white,
    this.padding = const EdgeInsets.all(20.0),
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedRadius = borderRadius is num
        ? BorderRadius.circular((borderRadius as num).toDouble())
        : borderRadius as BorderRadius;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: resolvedRadius,
        boxShadow: [
          BoxShadow(
            color: GlassTheme.oceanBlue.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: resolvedRadius,
        child: RepaintBoundary(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: opacity),
                borderRadius: resolvedRadius,
                border: Border.all(
                  color: borderColor.withValues(alpha: 0.4),
                  width: borderWidth,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// Glassmorphism Button (Primary / Secondary)
class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final IconData? icon;
  final double height;
  final double? width;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.height = 54.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: GlassTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: GlassTheme.oceanBlue.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  text,
                  style: GlassTheme.bodyLg(color: Colors.white).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: GlassCard(
          padding: EdgeInsets.zero,
          opacity: 0.4,
          borderRadius: 16,
          borderColor: GlassTheme.oceanBlue,
          borderWidth: 1.5,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: GlassTheme.oceanBlue, size: 18),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: GlassTheme.bodyLg(color: GlassTheme.oceanBlue)
                          .copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
}

// Recessed Glass Text Field
class GlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixPressed;
  final bool isPassword;
  final int maxLines;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixPressed,
    this.isPassword = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
            child: Text(
              widget.label,
              style: GlassTheme.labelCaps(color: GlassTheme.onSurfaceVariant),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: GlassTheme.oceanBlue.withValues(alpha: 0.12),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: GlassCard(
            padding: EdgeInsets.zero,
            opacity: _isFocused ? 0.8 : 0.45,
            borderRadius: 16,
            borderColor: _isFocused ? GlassTheme.oceanBlue : Colors.white,
            borderWidth: _isFocused ? 1.8 : 1.0,
            child: Focus(
              onFocusChange: (focused) {
                setState(() {
                  _isFocused = focused;
                });
              },
              child: TextField(
                controller: widget.controller,
                obscureText: widget.isPassword,
                maxLines: widget.maxLines,
                keyboardType: widget.keyboardType,
                onChanged: widget.onChanged,
                style: GlassTheme.bodyMd(),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: GlassTheme.bodyMd(color: GlassTheme.outline),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  border: InputBorder.none,
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(widget.prefixIcon,
                          color: GlassTheme.oceanBlue, size: 20)
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? IconButton(
                          icon: Icon(widget.suffixIcon,
                              color: GlassTheme.oceanBlue, size: 20),
                          onPressed: widget.onSuffixPressed,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Top frosted Header Bar
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const GlassAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: GlassTheme.oceanBlue.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRect(
        child: RepaintBoundary(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: Colors.white.withValues(alpha: 0.7),
              elevation: 0,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.health_and_safety, color: GlassTheme.oceanBlue, size: 28),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: GlassTheme.h2(color: GlassTheme.oceanBlue),
                  ),
                ],
              ),
              centerTitle: false,
              automaticallyImplyLeading: automaticallyImplyLeading,
              iconTheme: const IconThemeData(color: GlassTheme.oceanBlue),
              leading: leading,
              actions: actions,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.4),
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Beautiful Floating Bottom Navigation Bar Dock
class GlassNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  const GlassNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        borderRadius: 32,
        opacity: 0.75,
        borderWidth: 1.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (idx) {
            final active = selectedIndex == idx;
            final item = items[idx];
            return Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onTap(idx),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: active
                        ? BoxDecoration(
                            color: GlassTheme.oceanBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          )
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.isProminent)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: active ? GlassTheme.primaryGradient : GlassTheme.accentGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: GlassTheme.oceanBlue.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            ),
                            child: Icon(
                              item.icon,
                              color: Colors.white,
                              size: 22,
                            ),
                          )
                        else
                          Icon(
                            item.icon,
                            color: active
                                ? GlassTheme.oceanBlue
                                : GlassTheme.onSurfaceVariant,
                            size: 24,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: GlassTheme.labelCaps(
                            color: active
                                ? GlassTheme.oceanBlue
                                : (item.isProminent ? GlassTheme.teal : GlassTheme.onSurfaceVariant),
                          ).copyWith(
                            fontSize: 9,
                            fontWeight: item.isProminent ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class GlassNavItem {
  final IconData icon;
  final String label;
  final bool isProminent;

  GlassNavItem({required this.icon, required this.label, this.isProminent = false});
}
