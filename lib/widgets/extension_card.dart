import 'package:flutter/material.dart';
import '../models/models.dart';
import 'extension_icon.dart';

/// A card widget that displays extension information with icon, name, and publisher
class ExtensionCard extends StatelessWidget {
  final VsCodeExtension extension;
  final VoidCallback? onTap;
  final bool isCompact;

  const ExtensionCard({
    super.key,
    required this.extension,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 8.0 : 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildExtensionIcon(),
                _buildSpacing(),
                _buildExtensionName(),
                ..._buildPublisherSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExtensionIcon() {
    return ExtensionIcon(
      extension: extension,
      size: isCompact ? 32 : 48,
      borderRadius: isCompact ? 6 : 8,
    );
  }

  Widget _buildSpacing() {
    return SizedBox(height: isCompact ? 4 : 8);
  }

  Widget _buildExtensionName() {
    return Text(
      extension.displayName,
      style: TextStyle(
        fontSize: isCompact ? 12 : 14,
        fontWeight: FontWeight.bold,
      ),
      maxLines: isCompact ? 1 : 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }

  List<Widget> _buildPublisherSection() {
    if (isCompact) return [];
    
    return [
      const SizedBox(height: 4),
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
    ];
  }


}