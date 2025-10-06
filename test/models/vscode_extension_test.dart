import 'package:flutter_test/flutter_test.dart';
import 'package:vsxviz/models/models.dart';

void main() {
  group('VsCodeExtension', () {
    test('creates extension with required fields', () {
      final extension = VsCodeExtension(
        id: 'ms-python.python',
        displayName: 'Python',
        version: '2023.20.0',
        publisher: 'Microsoft',
      );

      expect(extension.id, equals('ms-python.python'));
      expect(extension.displayName, equals('Python'));
      expect(extension.version, equals('2023.20.0'));
      expect(extension.publisher, equals('Microsoft'));
      expect(extension.isBuiltIn, isFalse);
      expect(extension.isEnabled, isTrue);
    });

    test('creates extension with all fields', () {
      final installDate = DateTime(2023, 10, 1);
      final extension = VsCodeExtension(
        id: 'ms-python.python',
        displayName: 'Python',
        version: '2023.20.0',
        publisher: 'Microsoft',
        description: 'Python language support',
        isBuiltIn: false,
        isEnabled: true,
        profileName: 'Python Development',
        installDate: installDate,
        category: 'Programming Languages',
        repository: 'https://github.com/microsoft/vscode-python',
        installCount: 50000000,
        rating: 4.5,
        iconPath: '/path/to/icon.png',
        iconUrl: 'https://example.com/icon.png',
      );

      expect(extension.description, equals('Python language support'));
      expect(extension.profileName, equals('Python Development'));
      expect(extension.installDate, equals(installDate));
      expect(extension.category, equals('Programming Languages'));
      expect(extension.repository, equals('https://github.com/microsoft/vscode-python'));
      expect(extension.installCount, equals(50000000));
      expect(extension.rating, equals(4.5));
      expect(extension.iconPath, equals('/path/to/icon.png'));
      expect(extension.iconUrl, equals('https://example.com/icon.png'));
    });

    test('creates extension from map with various field names', () {
      final map = {
        'extensionId': 'ms-python.python',
        'name': 'Python',
        'version': '2023.20.0',
        'publisher': 'Microsoft',
        'description': 'Python support',
        'builtIn': 'false',
        'enabled': '1',
        'profileName': 'Dev',
        'installDate': '2023-10-01T00:00:00.000Z',
        'category': 'Languages',
        'repository': 'https://github.com/microsoft/vscode-python',
        'installCount': '50000000',
        'rating': '4.5',
        'iconPath': '/home/user/.vscode/extensions/ms-python.python-2023.20.0/icon.png',
        'iconUrl': 'https://ms-python.gallerycdn.vsassets.io/extensions/ms-python/python/2023.20.0/icon.png',
      };

      final extension = VsCodeExtension.fromMap(map);

      expect(extension.id, equals('ms-python.python'));
      expect(extension.displayName, equals('Python'));
      expect(extension.version, equals('2023.20.0'));
      expect(extension.publisher, equals('Microsoft'));
      expect(extension.description, equals('Python support'));
      expect(extension.isBuiltIn, isFalse);
      expect(extension.isEnabled, isTrue);
      expect(extension.profileName, equals('Dev'));
      expect(extension.installDate, equals(DateTime.parse('2023-10-01T00:00:00.000Z')));
      expect(extension.category, equals('Languages'));
      expect(extension.repository, equals('https://github.com/microsoft/vscode-python'));
      expect(extension.installCount, equals(50000000));
      expect(extension.rating, equals(4.5));
      expect(extension.iconPath, equals('/home/user/.vscode/extensions/ms-python.python-2023.20.0/icon.png'));
      expect(extension.iconUrl, equals('https://ms-python.gallerycdn.vsassets.io/extensions/ms-python/python/2023.20.0/icon.png'));
    });

    test('handles missing or null values in fromMap', () {
      final map = <String, dynamic>{
        'id': 'test.extension',
      };

      final extension = VsCodeExtension.fromMap(map);

      expect(extension.id, equals('test.extension'));
      expect(extension.displayName, equals(''));
      expect(extension.version, equals('unknown'));
      expect(extension.publisher, equals('unknown'));
      expect(extension.description, isNull);
      expect(extension.isBuiltIn, isFalse);
      expect(extension.isEnabled, isTrue);
      expect(extension.profileName, isNull);
      expect(extension.installDate, isNull);
      expect(extension.category, isNull);
      expect(extension.repository, isNull);
      expect(extension.installCount, isNull);
      expect(extension.rating, isNull);
      expect(extension.iconPath, isNull);
      expect(extension.iconUrl, isNull);
    });

    test('converts to map correctly', () {
      final installDate = DateTime(2023, 10, 1);
      final extension = VsCodeExtension(
        id: 'ms-python.python',
        displayName: 'Python',
        version: '2023.20.0',
        publisher: 'Microsoft',
        description: 'Python support',
        isBuiltIn: false,
        isEnabled: true,
        profileName: 'Dev',
        installDate: installDate,
        category: 'Languages',
        repository: 'https://github.com/microsoft/vscode-python',
        installCount: 50000000,
        rating: 4.5,
        iconPath: '/path/to/icon.png',
        iconUrl: 'https://example.com/icon.png',
      );

      final map = extension.toMap();

      expect(map['id'], equals('ms-python.python'));
      expect(map['displayName'], equals('Python'));
      expect(map['version'], equals('2023.20.0'));
      expect(map['publisher'], equals('Microsoft'));
      expect(map['description'], equals('Python support'));
      expect(map['isBuiltIn'], isFalse);
      expect(map['isEnabled'], isTrue);
      expect(map['profileName'], equals('Dev'));
      expect(map['installDate'], equals(installDate.toIso8601String()));
      expect(map['category'], equals('Languages'));
      expect(map['repository'], equals('https://github.com/microsoft/vscode-python'));
      expect(map['installCount'], equals(50000000));
      expect(map['rating'], equals(4.5));
      expect(map['iconPath'], equals('/path/to/icon.png'));
      expect(map['iconUrl'], equals('https://example.com/icon.png'));
    });

    test('copyWith creates new instance with modified values', () {
      final original = VsCodeExtension(
        id: 'ms-python.python',
        displayName: 'Python',
        version: '2023.20.0',
        publisher: 'Microsoft',
      );

      final modified = original.copyWith(
        displayName: 'Python Language Support',
        version: '2023.21.0',
        description: 'Enhanced Python support',
      );

      expect(modified.id, equals('ms-python.python'));
      expect(modified.displayName, equals('Python Language Support'));
      expect(modified.version, equals('2023.21.0'));
      expect(modified.publisher, equals('Microsoft'));
      expect(modified.description, equals('Enhanced Python support'));
    });

    test('equality and hashCode work correctly', () {
      final ext1 = VsCodeExtension(
        id: 'ms-python.python',
        displayName: 'Python',
        version: '2023.20.0',
        publisher: 'Microsoft',
      );

      final ext2 = VsCodeExtension(
        id: 'ms-python.python',
        displayName: 'Python Support', // Different display name
        version: '2023.20.0',
        publisher: 'Microsoft',
      );

      final ext3 = VsCodeExtension(
        id: 'ms-python.python',
        displayName: 'Python',
        version: '2023.21.0', // Different version
        publisher: 'Microsoft',
      );

      expect(ext1, equals(ext2)); // Same id, version, publisher
      expect(ext1.hashCode, equals(ext2.hashCode));
      expect(ext1, isNot(equals(ext3))); // Different version
    });

    test('toString returns meaningful representation', () {
      final extension = VsCodeExtension(
        id: 'ms-python.python',
        displayName: 'Python',
        version: '2023.20.0',
        publisher: 'Microsoft',
      );

      final str = extension.toString();
      expect(str, contains('ms-python.python'));
      expect(str, contains('Python'));
      expect(str, contains('2023.20.0'));
      expect(str, contains('Microsoft'));
    });
  });
}