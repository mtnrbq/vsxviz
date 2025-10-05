import 'vscode_extension.dart';

/// Represents a VS Code user profile with its location and extensions
class VsCodeProfile {
  /// Display name of the profile
  final String name;
  
  /// File system path to the profile directory
  final String path;
  
  /// List of extensions installed in this profile
  final List<VsCodeExtension> extensions;
  
  /// Whether this is the default VS Code profile
  final bool isDefault;
  
  /// When the profile was last modified
  final DateTime? lastModified;

  const VsCodeProfile({
    required this.name,
    required this.path,
    required this.extensions,
    this.isDefault = false,
    this.lastModified,
  });

  /// Creates a profile from a map (useful for JSON parsing)
  factory VsCodeProfile.fromMap(Map<String, dynamic> map) {
    return VsCodeProfile(
      name: map['name'] as String? ?? map['profileName'] as String? ?? '',
      path: map['path'] as String? ?? map['profilePath'] as String? ?? '',
      extensions: _parseExtensions(map['extensions']),
      isDefault: _parseBool(map['isDefault']) ?? false,
      lastModified: _parseDateTime(map['lastModified']),
    );
  }

  /// Converts the profile to a map (useful for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'path': path,
      'extensions': extensions.map((e) => e.toMap()).toList(),
      'isDefault': isDefault,
      'lastModified': lastModified?.toIso8601String(),
    };
  }

  /// Creates a copy of this profile with modified values
  VsCodeProfile copyWith({
    String? name,
    String? path,
    List<VsCodeExtension>? extensions,
    bool? isDefault,
    DateTime? lastModified,
  }) {
    return VsCodeProfile(
      name: name ?? this.name,
      path: path ?? this.path,
      extensions: extensions ?? this.extensions,
      isDefault: isDefault ?? this.isDefault,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  /// Gets the total number of extensions in this profile
  int get extensionCount => extensions.length;

  /// Gets the number of enabled extensions
  int get enabledExtensionCount => extensions.where((e) => e.isEnabled).length;

  /// Gets the number of built-in extensions
  int get builtInExtensionCount => extensions.where((e) => e.isBuiltIn).length;

  /// Gets the number of third-party extensions
  int get thirdPartyExtensionCount => extensions.where((e) => !e.isBuiltIn).length;

  /// Gets extensions grouped by publisher
  Map<String, List<VsCodeExtension>> get extensionsByPublisher {
    final Map<String, List<VsCodeExtension>> grouped = {};
    for (final extension in extensions) {
      grouped.putIfAbsent(extension.publisher, () => []).add(extension);
    }
    return grouped;
  }

  /// Gets extensions grouped by category (excluding null categories)
  Map<String, List<VsCodeExtension>> get extensionsByCategory {
    final Map<String, List<VsCodeExtension>> grouped = {};
    for (final extension in extensions) {
      final category = extension.category;
      if (category != null && category.isNotEmpty) {
        grouped.putIfAbsent(category, () => []).add(extension);
      }
    }
    return grouped;
  }

  /// Finds extensions by ID (case-insensitive partial match)
  List<VsCodeExtension> findExtensionsByName(String query) {
    final lowercaseQuery = query.toLowerCase();
    return extensions.where((e) =>
      e.id.toLowerCase().contains(lowercaseQuery) ||
      e.displayName.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  /// Gets a summary string for this profile
  String get summary {
    return '$name: $extensionCount extensions ($builtInExtensionCount built-in, $thirdPartyExtensionCount third-party)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VsCodeProfile && 
           other.name == name &&
           other.path == path;
  }

  @override
  int get hashCode {
    return name.hashCode ^ path.hashCode;
  }

  @override
  String toString() {
    return 'VsCodeProfile(name: $name, path: $path, extensions: ${extensions.length})';
  }

  // Helper methods for parsing
  static List<VsCodeExtension> _parseExtensions(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => item is Map<String, dynamic> 
              ? VsCodeExtension.fromMap(item) 
              : null)
          .where((ext) => ext != null)
          .cast<VsCodeExtension>()
          .toList();
    }
    return [];
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}