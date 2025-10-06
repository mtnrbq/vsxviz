import 'dart:io';
import 'package:flutter/material.dart';
import '../models/models.dart';

class ExtensionIcon extends StatelessWidget {
  final VsCodeExtension extension;
  final double size;
  final double borderRadius;

  const ExtensionIcon({
    super.key,
    required this.extension,
    this.size = 16,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    if (extension.iconPath != null && extension.iconPath!.isNotEmpty) {
      final iconFile = File(extension.iconPath!);
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: size,
          height: size,
          child: Image.file(
            iconFile,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackIcon();
            },
          ),
        ),
      );
    }
    
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: const Color(0xFF007ACC),
      ),
      child: Icon(
        Icons.extension,
        color: Colors.white,
        size: size * 0.6, // Scale icon relative to container
      ),
    );
  }
}