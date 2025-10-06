import 'dart:io';
import '../models/models.dart';

/// Service for parsing CSV files containing VS Code extension data
class CsvParserService {
  /// Parses a CSV file and returns a list of VS Code extensions
  static Future<List<VsCodeExtension>> parseExtensionsFromCsv(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('CSV file not found: $filePath');
      }

      final contents = await file.readAsString();
      final lines = contents.split('\n');
      
      if (lines.isEmpty) {
        return [];
      }

      // Parse header to get column indices
      final header = _parseCsvLine(lines[0]);
      final columnIndices = <String, int>{};
      for (int i = 0; i < header.length; i++) {
        columnIndices[header[i].toLowerCase()] = i;
      }

      final extensions = <VsCodeExtension>[];
      
      // Parse data rows (skip header)
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        try {
          final fields = _parseCsvLine(line);
          if (fields.length < header.length) continue; // Skip incomplete rows
          
          final extension = _createExtensionFromFields(fields, columnIndices);
          if (extension != null) {
            extensions.add(extension);
          }
        } catch (e) {
          // Skip malformed rows
          continue;
        }
      }

      return extensions;
    } catch (e) {
      throw Exception('Failed to parse CSV file: $e');
    }
  }

  /// Parses extensions from the Default profile only
  static Future<List<VsCodeExtension>> parseDefaultProfileExtensions(String filePath) async {
    final allExtensions = await parseExtensionsFromCsv(filePath);
    return allExtensions.where((ext) => ext.profileName == 'Default').toList();
  }

  /// Parses a CSV line handling quoted fields
  static List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote
          buffer.write('"');
          i++; // Skip next quote
        } else {
          // Toggle quote state
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        // Field separator
        fields.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    
    // Add final field
    fields.add(buffer.toString());
    
    return fields;
  }

  /// Creates a VsCodeExtension from CSV fields
  static VsCodeExtension? _createExtensionFromFields(
    List<String> fields, 
    Map<String, int> columnIndices,
  ) {
    try {
      final map = <String, dynamic>{};
      
      // Map CSV columns to model fields
      final mappings = {
        'profilename': 'profileName',
        'extensionid': 'id',
        'displayname': 'displayName',
        'publisher': 'publisher',
        'version': 'version',
        'description': 'description',
        'category': 'category',
        'enabled': 'isEnabled',
        'builtin': 'isBuiltIn',
        'installdate': 'installDate',
        'repository': 'repository',
        'installcount': 'installCount',
        'rating': 'rating',
        'iconpath': 'iconPath',
        'iconurl': 'iconUrl',
      };

      for (final entry in mappings.entries) {
        final csvColumn = entry.key;
        final modelField = entry.value;
        final columnIndex = columnIndices[csvColumn];
        
        if (columnIndex != null && columnIndex < fields.length) {
          final value = fields[columnIndex].trim();
          if (value.isNotEmpty) {
            map[modelField] = value;
          }
        }
      }

      return VsCodeExtension.fromMap(map);
    } catch (e) {
      return null;
    }
  }
}