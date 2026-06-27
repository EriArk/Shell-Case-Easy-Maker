import 'dart:convert';
import 'dart:io';

import 'project_model.dart';

class ProjectFileService {
  const ProjectFileService();

  String encode(ProjectModel project) {
    return '${project.toPrettyJson()}\n';
  }

  ProjectModel decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<Object?, Object?>) {
      throw const FormatException('Project file root must be a JSON object.');
    }

    return ProjectModel.fromJson(Map<String, Object?>.from(decoded));
  }

  Future<void> writeProject(File file, ProjectModel project) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(encode(project));
  }

  Future<ProjectModel> readProject(File file) async {
    return decode(await file.readAsString());
  }
}
