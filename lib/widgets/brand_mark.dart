import 'package:flutter/material.dart';

/// Shared DrAI logo in a circular frame — same asset everywhere, different [size].
class BrandMark extends StatelessWidget {
  static const assetPath = 'assets/logo/app-logo.png';
  static const _oceanBlue = Color(0xFF0077B6);
  static const _cyan = Color(0xFF50D9FE);

  final double size;
  final bool showLabel;
  final Color? labelColor;

  const BrandMark({
    super.key,
    this.size = 32,
    this.showLabel = false,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderWidth = size >= 48 ? 2.0 : 1.5;
    final innerPadding = size * 0.1;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: _cyan.withValues(alpha: 0.55),
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: _oceanBlue.withValues(alpha: 0.16),
            blurRadius: size * 0.14,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(innerPadding),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            semanticLabel: 'DrAI',
          ),
        ),
      ),
    );
  }
}
