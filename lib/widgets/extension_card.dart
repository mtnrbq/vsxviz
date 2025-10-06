import 'package:flutter/material.dart';
import '../models/models.dart';
import 'extension_icon.dart';

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
              ExtensionIcon(
                extension: extension,
                size: 48,
                borderRadius: 8,
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


}