import 'dart:io';

import 'package:file_selector/file_selector.dart';

abstract interface class ProjectFileDialogService {
  Future<File?> pickOpenProjectFile();

  Future<File?> pickSaveProjectFile({required String suggestedName});
}

class FileSelectorProjectFileDialogService implements ProjectFileDialogService {
  const FileSelectorProjectFileDialogService();

  static const projectTypeGroup = XTypeGroup(
    label: 'Shell Case project',
    extensions: ['json'],
  );

  @override
  Future<File?> pickOpenProjectFile() async {
    final file = await openFile(
      acceptedTypeGroups: const [projectTypeGroup],
      confirmButtonText: 'Open project',
    );

    return file == null ? null : File(file.path);
  }

  @override
  Future<File?> pickSaveProjectFile({required String suggestedName}) async {
    final location = await getSaveLocation(
      acceptedTypeGroups: const [projectTypeGroup],
      suggestedName: suggestedName,
      confirmButtonText: 'Save project',
    );

    return location == null
        ? null
        : ensureProjectFileExtension(File(location.path));
  }
}

File ensureProjectFileExtension(File file) {
  final path = file.path;
  final lowerPath = path.toLowerCase();
  if (lowerPath.endsWith('.enclosure.json') || lowerPath.endsWith('.json')) {
    return file;
  }

  return File('$path.enclosure.json');
}
