import 'dart:io';
import 'package:flutter/material.dart';
import '../models/models.dart';

/// A card widget that displays extension information with icon, name, and publisher
class ExtensionCard extends StatelessWidget {
  final VsCodeExtension extension;
  final VoidCallback? onTap;

  const ExtensionCard({
    super.key,
    required this.extension,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Extension Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: _buildExtensionIcon(),
              ),
              const SizedBox(height: 8),
              // Extension Name
              Text(
                extension.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // Publisher
              Text(
                extension.publisher,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtensionIcon() {
    if (extension.iconPath != null && extension.iconPath!.isNotEmpty) {
      final iconFile = File(extension.iconPath!);
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          iconFile,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackIcon();
          },
        ),
      );
    }
    
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF007ACC),
      ),
      child: const Icon(
        Icons.extension,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}