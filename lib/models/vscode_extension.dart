/// Represents a VS Code extension with metadata for visualization and analysis
class VsCodeExtension {
  /// Unique identifier for the extension (e.g., "ms-python.python")
  final String id;
  
  /// Human-readable name of the extension
  final String displayName;
  
  /// Version string of the extension
  final String version;
  
  /// Publisher/author of the extension
  final String publisher;
  
  /// Optional description of the extension's functionality
  final String? description;
  
  /// Whether this is a built-in VS Code extension
  final bool isBuiltIn;
  
  /// Whether the extension is currently enabled
  final bool isEnabled;
  
  /// Name of the profile this extension belongs to
  final String? profileName;
  
  /// When the extension was installed (if available)
  final DateTime? installDate;
  
  /// Category/genre of the extension
  final String? category;
  
  /// Repository URL for the extension
  final String? repository;
  
  /// Number of installations from marketplace (if available)
  final int? installCount;
  
  /// User rating from marketplace (if available)
  final double? rating;

  const VsCodeExtension({
    required this.id,
    required this.displayName,
    required this.version,
    required this.publisher,
    this.description,
    this.isBuiltIn = false,
    this.isEnabled = true,
    this.profileName,
    this.installDate,
    this.category,
    this.repository,
    this.installCount,
    this.rating,
  });

  /// Creates an extension from a map (useful for JSON/CSV parsing)
  factory VsCodeExtension.fromMap(Map<String, dynamic> map) {
    return VsCodeExtension(
      id: map['id'] as String? ?? map['extensionId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? map['name'] as String? ?? '',
      version: map['version'] as String? ?? 'unknown',
      publisher: map['publisher'] as String? ?? 'unknown',
      description: map['description'] as String?,
      isBuiltIn: _parseBool(map['isBuiltIn']) ?? _parseBool(map['builtIn']) ?? false,
      isEnabled: _parseBool(map['isEnabled']) ?? _parseBool(map['enabled']) ?? true,
      profileName: map['profileName'] as String?,
      installDate: _parseDateTime(map['installDate']),
      category: map['category'] as String?,
      repository: map['repository'] as String?,
      installCount: _parseInt(map['installCount']),
      rating: _parseDouble(map['rating']),
    );
  }

  /// Converts the extension to a map (useful for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'version': version,
      'publisher': publisher,
      'description': description,
      'isBuiltIn': isBuiltIn,
      'isEnabled': isEnabled,
      'profileName': profileName,
      'installDate': installDate?.toIso8601String(),
      'category': category,
      'repository': repository,
      'installCount': installCount,
      'rating': rating,
    };
  }

  /// Creates a copy of this extension with modified values
  VsCodeExtension copyWith({
    String? id,
    String? displayName,
    String? version,
    String? publisher,
    String? description,
    bool? isBuiltIn,
    bool? isEnabled,
    String? profileName,
    DateTime? installDate,
    String? category,
    String? repository,
    int? installCount,
    double? rating,
  }) {
    return VsCodeExtension(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      version: version ?? this.version,
      publisher: publisher ?? this.publisher,
      description: description ?? this.description,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isEnabled: isEnabled ?? this.isEnabled,
      profileName: profileName ?? this.profileName,
      installDate: installDate ?? this.installDate,
      category: category ?? this.category,
      repository: repository ?? this.repository,
      installCount: installCount ?? this.installCount,
      rating: rating ?? this.rating,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VsCodeExtension && 
           other.id == id &&
           other.version == version &&
           other.publisher == publisher;
  }

  @override
  int get hashCode {
    return id.hashCode ^ version.hashCode ^ publisher.hashCode;
  }

  @override
  String toString() {
    return 'VsCodeExtension(id: $id, displayName: $displayName, version: $version, publisher: $publisher)';
  }

  // Helper methods for parsing various data types from maps
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

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) return value.toInt();
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}