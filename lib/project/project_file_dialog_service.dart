import 'dart:io';

import 'package:file_selector/file_selector.dart';

abstract interface class ProjectFileDialogService {
  Future<File?> pickOpenProjectFile();

  Future<File?> pickSaveProjectFile({required String suggestedName});

  Future<File?> pickExportStepFile({required String suggestedName});
}

class FileSelectorProjectFileDialogService implements ProjectFileDialogService {
  const FileSelectorProjectFileDialogService();

  static const projectTypeGroup = XTypeGroup(
    label: 'Shell Case project',
    extensions: ['json'],
  );
  static const stepTypeGroup = XTypeGroup(
    label: 'STEP geometry',
    extensions: ['step', 'stp'],
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

  @override
  Future<File?> pickExportStepFile({required String suggestedName}) async {
    final location = await getSaveLocation(
      acceptedTypeGroups: const [stepTypeGroup],
      suggestedName: suggestedName,
      confirmButtonText: 'Export STEP',
    );

    return location == null
        ? null
        : ensureStepFileExtension(File(location.path));
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

File ensureStepFileExtension(File file) {
  final path = file.path;
  final lowerPath = path.toLowerCase();
  if (lowerPath.endsWith('.step') || lowerPath.endsWith('.stp')) {
    return file;
  }

  return File('$path.step');
}
