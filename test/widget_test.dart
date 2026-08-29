import 'package:flutter_test/flutter_test.dart';
import 'package:gaza_build/core/constants/app_constants.dart';
import 'package:gaza_build/core/theme/app_theme.dart';
import 'package:gaza_build/features/auth/models/user_model.dart';
import 'package:gaza_build/features/projects/models/project_model.dart';

void main() {
  test('App theme enforces global radius 3.0', () {
    expect(AppTheme.borderRadiusValue, 3.0);
    expect(AppTheme.borderRadius.topLeft.x, 3.0);
  });

  test('User roles and constants are defined properly', () {
    expect(UserRole.values.length, 4);
    expect(AppConstants.gazaCities.isNotEmpty, true);
    expect(AppConstants.clientProjectTypes.isNotEmpty, true);
    expect(AppConstants.engineerSpecialties.isNotEmpty, true);
    expect(AppConstants.studentSkills.isNotEmpty, true);
  });

  test('Project model serialization works cleanly', () {
    final project = Project(
      id: 'test_1',
      clientId: 'client_1',
      clientName: 'أحمد',
      title: 'مشروع تجريبي',
      description: 'شرح للمشروع',
      projectType: AppConstants.clientProjectTypes.first,
      areaM2: 120,
      approximateBudgetUsd: 3000,
      preferredStyle: 'مودرن',
      city: 'غزة',
      createdAt: DateTime.now(),
    );

    final json = project.toJson();
    final restored = Project.fromJson(json);

    expect(restored.id, 'test_1');
    expect(restored.areaM2, 120.0);
    expect(restored.approximateBudgetUsd, 3000.0);
  });
}
