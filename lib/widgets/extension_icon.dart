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
      return RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            width: size,
            height: size,
            child: Image.file(
              iconFile,
              fit: BoxFit.cover,
              // Aggressive caching and performance optimizations
              cacheWidth: size.round(),
              cacheHeight: size.round(),
              filterQuality: FilterQuality.low, // Faster rendering
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                // Prevent flickering during loads
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 100),
                  child: child,
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackIcon();
              },
              // Prevent rebuild on every frame
              gaplessPlayback: true,
              // Additional memory optimization
              isAntiAlias: false,
            ),
          ),
        ),
      );
    }
    
    return RepaintBoundary(child: _buildFallbackIcon());
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