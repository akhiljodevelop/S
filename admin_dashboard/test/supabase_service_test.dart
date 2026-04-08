import 'package:flutter_test/flutter_test.dart';
import 'package:admin_dashboard/models/project.dart';

void main() {
  group('Project Model', () {
    test('Project.fromJson creates a valid Project object', () {
      final json = {
        'id': '1',
        'category': 'art',
        'title': 'Test Project',
        'metadata_info': '2023',
        'description': 'Description',
        'images': ['url1', 'url2'],
        'sort_order': 1
      };

      final project = Project.fromJson(json);

      expect(project.id, '1');
      expect(project.title, 'Test Project');
      expect(project.images.length, 2);
      expect(project.sortOrder, 1);
    });

    test('Project.toJson returns correct Map', () {
      final project = Project(
        id: '1',
        category: 'art',
        title: 'Test Project',
        images: ['url1'],
        sortOrder: 1,
      );

      final json = project.toJson();

      expect(json['id'], '1');
      expect(json['title'], 'Test Project');
      expect(json['category'], 'art');
      expect(json['images'], ['url1']);
    });
  });
}
