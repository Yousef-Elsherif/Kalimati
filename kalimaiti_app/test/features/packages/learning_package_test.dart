import 'package:flutter_test/flutter_test.dart';
import 'package:kalimaiti_app/features/packages/domain/models/learning_package.dart';

void main() {
  group('LearningPackage JSON Serialization', () {
    test('should serialize and deserialize correctly', () {
      // Arrange
      final originalPackage = LearningPackage(
        id: 1,
        author: 'test@example.com',
        category: 'vocabulary',
        description: 'Test package',
        iconUrl: 'https://example.com/icon.png',
        language: 'Spanish',
        lastUpdatedDate: '2025-11-07T10:30:00.000Z',
        level: 'beginner',
        title: 'Test Package',
        version: 1,
        words: [
          Word(
            id: 1,
            text: 'hola',
            definitions: [
              Definition(id: 1, text: 'hello', source: 'dictionary'),
            ],
            sentences: [
              Sentence(
                id: 1,
                text: 'Hola, ¿cómo estás?',
                resources: [
                  Resource(
                    id: 1,
                    title: 'Video',
                    url: 'https://example.com/video',
                    type: 'video',
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      // Act - Convert to JSON string and back
      final jsonString = originalPackage.toJsonString();
      final deserializedPackage = LearningPackage.fromJsonString(jsonString);

      // Assert
      expect(deserializedPackage.id, originalPackage.id);
      expect(deserializedPackage.title, originalPackage.title);
      expect(deserializedPackage.author, originalPackage.author);
      expect(deserializedPackage.words.length, 1);
      expect(deserializedPackage.words[0].text, 'hola');
      expect(deserializedPackage.words[0].definitions.length, 1);
      expect(deserializedPackage.words[0].definitions[0].text, 'hello');
      expect(deserializedPackage.words[0].sentences.length, 1);
      expect(
        deserializedPackage.words[0].sentences[0].text,
        'Hola, ¿cómo estás?',
      );
      expect(deserializedPackage.words[0].sentences[0].resources.length, 1);
      expect(
        deserializedPackage.words[0].sentences[0].resources[0].title,
        'Video',
      );
    });

    test('should handle empty words list', () {
      // Arrange
      final package = LearningPackage(
        author: 'test@example.com',
        category: 'vocabulary',
        description: 'Empty package',
        iconUrl: 'https://example.com/icon.png',
        language: 'Spanish',
        lastUpdatedDate: '2025-11-07T10:30:00.000Z',
        level: 'beginner',
        title: 'Empty Package',
        version: 1,
        words: [],
      );

      // Act
      final jsonString = package.toJsonString();
      final deserializedPackage = LearningPackage.fromJsonString(jsonString);

      // Assert
      expect(deserializedPackage.words.isEmpty, true);
      expect(deserializedPackage.title, 'Empty Package');
    });

    test('should serialize without IDs (for new packages)', () {
      // Arrange
      final package = LearningPackage(
        author: 'test@example.com',
        category: 'vocabulary',
        description: 'New package',
        iconUrl: 'https://example.com/icon.png',
        language: 'Spanish',
        lastUpdatedDate: '2025-11-07T10:30:00.000Z',
        level: 'beginner',
        title: 'New Package',
        version: 1,
        words: [
          Word(
            text: 'hola',
            definitions: [Definition(text: 'hello', source: 'dictionary')],
            sentences: [],
          ),
        ],
      );

      // Act
      final json = package.toJson();

      // Assert
      expect(json.containsKey('id'), false);
      expect((json['words'] as List)[0].containsKey('id'), false);
    });

    test('should handle complex nested structure', () {
      // Arrange
      final package = LearningPackage(
        author: 'test@example.com',
        category: 'vocabulary',
        description: 'Complex package',
        iconUrl: 'https://example.com/icon.png',
        language: 'Spanish',
        lastUpdatedDate: '2025-11-07T10:30:00.000Z',
        level: 'intermediate',
        title: 'Complex Package',
        version: 1,
        words: [
          Word(
            text: 'casa',
            definitions: [
              Definition(text: 'house', source: 'dictionary'),
              Definition(text: 'home', source: 'thesaurus'),
            ],
            sentences: [
              Sentence(
                text: 'Mi casa es grande.',
                resources: [
                  Resource(
                    title: 'Video 1',
                    url: 'https://example.com/video1',
                    type: 'video',
                  ),
                  Resource(
                    title: 'Article 1',
                    url: 'https://example.com/article1',
                    type: 'article',
                  ),
                ],
              ),
              Sentence(text: 'La casa está limpia.', resources: []),
            ],
          ),
        ],
      );

      // Act
      final jsonString = package.toJsonString();
      final deserializedPackage = LearningPackage.fromJsonString(jsonString);

      // Assert
      expect(deserializedPackage.words[0].definitions.length, 2);
      expect(deserializedPackage.words[0].sentences.length, 2);
      expect(deserializedPackage.words[0].sentences[0].resources.length, 2);
      expect(deserializedPackage.words[0].sentences[1].resources.isEmpty, true);
    });
  });
}
