import 'package:flutter_test/flutter_test.dart';
import 'package:vsxviz/models/models.dart';

void main() {
  group('VsCodeProfile', () {
    late List<VsCodeExtension> sampleExtensions;

    setUp(() {
      sampleExtensions = [
        VsCodeExtension(
          id: 'ms-python.python',
          displayName: 'Python',
          version: '2023.20.0',
          publisher: 'Microsoft',
          isBuiltIn: false,
          isEnabled: true,
          category: 'Programming Languages',
        ),
        VsCodeExtension(
          id: 'vscode.theme-defaults',
          displayName: 'Default Themes',
          version: '1.0.0',
          publisher: 'vscode',
          isBuiltIn: true,
          isEnabled: true,
          category: 'Themes',
        ),
        VsCodeExtension(
          id: 'esbenp.prettier-vscode',
          displayName: 'Prettier',
          version: '10.1.0',
          publisher: 'Prettier',
          isBuiltIn: false,
          isEnabled: false,
          category: 'Formatters',
        ),
      ];
    });

    test('creates profile with required fields', () {
      final profile = VsCodeProfile(
        name: 'Default',
        path: '/home/user/.config/Code/User',
        extensions: sampleExtensions,
      );

      expect(profile.name, equals('Default'));
      expect(profile.path, equals('/home/user/.config/Code/User'));
      expect(profile.extensions, equals(sampleExtensions));
      expect(profile.isDefault, isFalse);
      expect(profile.lastModified, isNull);
    });

    test('creates profile with all fields', () {
      final lastModified = DateTime(2023, 10, 1);
      final profile = VsCodeProfile(
        name: 'Development',
        path: '/home/user/.config/Code/User/profiles/dev',
        extensions: sampleExtensions,
        isDefault: true,
        lastModified: lastModified,
      );

      expect(profile.name, equals('Development'));
      expect(profile.path, equals('/home/user/.config/Code/User/profiles/dev'));
      expect(profile.extensions, equals(sampleExtensions));
      expect(profile.isDefault, isTrue);
      expect(profile.lastModified, equals(lastModified));
    });

    test('creates profile from map', () {
      final map = {
        'name': 'Test Profile',
        'path': '/test/path',
        'extensions': [
          {
            'id': 'test.extension',
            'displayName': 'Test Extension',
            'version': '1.0.0',
            'publisher': 'Test Publisher',
          }
        ],
        'isDefault': 'true',
        'lastModified': '2023-10-01T00:00:00.000Z',
      };

      final profile = VsCodeProfile.fromMap(map);

      expect(profile.name, equals('Test Profile'));
      expect(profile.path, equals('/test/path'));
      expect(profile.extensions.length, equals(1));
      expect(profile.extensions.first.id, equals('test.extension'));
      expect(profile.isDefault, isTrue);
      expect(profile.lastModified, equals(DateTime.parse('2023-10-01T00:00:00.000Z')));
    });

    test('handles missing values in fromMap', () {
      final map = <String, dynamic>{};

      final profile = VsCodeProfile.fromMap(map);

      expect(profile.name, equals(''));
      expect(profile.path, equals(''));
      expect(profile.extensions, isEmpty);
      expect(profile.isDefault, isFalse);
      expect(profile.lastModified, isNull);
    });

    test('converts to map correctly', () {
      final lastModified = DateTime(2023, 10, 1);
      final profile = VsCodeProfile(
        name: 'Test Profile',
        path: '/test/path',
        extensions: [sampleExtensions.first],
        isDefault: true,
        lastModified: lastModified,
      );

      final map = profile.toMap();

      expect(map['name'], equals('Test Profile'));
      expect(map['path'], equals('/test/path'));
      expect(map['extensions'], isA<List>());
      expect((map['extensions'] as List).length, equals(1));
      expect(map['isDefault'], isTrue);
      expect(map['lastModified'], equals(lastModified.toIso8601String()));
    });

    test('copyWith creates new instance with modified values', () {
      final original = VsCodeProfile(
        name: 'Original',
        path: '/original/path',
        extensions: sampleExtensions,
      );

      final modified = original.copyWith(
        name: 'Modified',
        isDefault: true,
      );

      expect(modified.name, equals('Modified'));
      expect(modified.path, equals('/original/path'));
      expect(modified.extensions, equals(sampleExtensions));
      expect(modified.isDefault, isTrue);
    });

    test('calculates extension counts correctly', () {
      final profile = VsCodeProfile(
        name: 'Test',
        path: '/test',
        extensions: sampleExtensions,
      );

      expect(profile.extensionCount, equals(3));
      expect(profile.enabledExtensionCount, equals(2)); // Python and Default Themes
      expect(profile.builtInExtensionCount, equals(1)); // Default Themes
      expect(profile.thirdPartyExtensionCount, equals(2)); // Python and Prettier
    });

    test('groups extensions by publisher', () {
      final profile = VsCodeProfile(
        name: 'Test',
        path: '/test',
        extensions: sampleExtensions,
      );

      final byPublisher = profile.extensionsByPublisher;

      expect(byPublisher.keys.length, equals(3));
      expect(byPublisher['Microsoft']?.length, equals(1));
      expect(byPublisher['vscode']?.length, equals(1));
      expect(byPublisher['Prettier']?.length, equals(1));
    });

    test('groups extensions by category', () {
      final profile = VsCodeProfile(
        name: 'Test',
        path: '/test',
        extensions: sampleExtensions,
      );

      final byCategory = profile.extensionsByCategory;

      expect(byCategory.keys.length, equals(3));
      expect(byCategory['Programming Languages']?.length, equals(1));
      expect(byCategory['Themes']?.length, equals(1));
      expect(byCategory['Formatters']?.length, equals(1));
    });

    test('finds extensions by name', () {
      final profile = VsCodeProfile(
        name: 'Test',
        path: '/test',
        extensions: sampleExtensions,
      );

      final pythonResults = profile.findExtensionsByName('python');
      expect(pythonResults.length, equals(1));
      expect(pythonResults.first.id, equals('ms-python.python'));

      final themeResults = profile.findExtensionsByName('theme');
      expect(themeResults.length, equals(1));
      expect(themeResults.first.id, equals('vscode.theme-defaults'));

      final noResults = profile.findExtensionsByName('nonexistent');
      expect(noResults, isEmpty);
    });

    test('generates correct summary', () {
      final profile = VsCodeProfile(
        name: 'Test Profile',
        path: '/test',
        extensions: sampleExtensions,
      );

      final summary = profile.summary;
      expect(summary, contains('Test Profile'));
      expect(summary, contains('3 extensions'));
      expect(summary, contains('1 built-in'));
      expect(summary, contains('2 third-party'));
    });

    test('equality and hashCode work correctly', () {
      final profile1 = VsCodeProfile(
        name: 'Test',
        path: '/test/path',
        extensions: [],
      );

      final profile2 = VsCodeProfile(
        name: 'Test',
        path: '/test/path',
        extensions: sampleExtensions, // Different extensions
      );

      final profile3 = VsCodeProfile(
        name: 'Different',
        path: '/test/path',
        extensions: [],
      );

      expect(profile1, equals(profile2)); // Same name and path
      expect(profile1.hashCode, equals(profile2.hashCode));
      expect(profile1, isNot(equals(profile3))); // Different name
    });

    test('toString returns meaningful representation', () {
      final profile = VsCodeProfile(
        name: 'Test Profile',
        path: '/test/path',
        extensions: sampleExtensions,
      );

      final str = profile.toString();
      expect(str, contains('Test Profile'));
      expect(str, contains('/test/path'));
      expect(str, contains('3')); // Extension count
    });
  });
}