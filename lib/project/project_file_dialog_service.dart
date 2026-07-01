import 'dart:io';

import 'package:file_selector/file_selector.dart';

abstract interface class ProjectFileDialogService {
  Future<File?> pickOpenProjectFile();

  Future<File?> pickSaveProjectFile({required String suggestedName});

  Future<File?> pickExportFile({
    required ProjectExportFormat format,
    required String suggestedName,
  });
}

enum ProjectExportFormat {
  step(
    label: 'STEP',
    typeGroupLabel: 'STEP geometry',
    extensions: ['step', 'stp'],
    defaultExtension: 'step',
    confirmButtonText: 'Export STEP',
  ),
  stl(
    label: 'STL',
    typeGroupLabel: 'STL print file',
    extensions: ['stl'],
    defaultExtension: 'stl',
    confirmButtonText: 'Export STL',
  );

  const ProjectExportFormat({
    required this.label,
    required this.typeGroupLabel,
    required this.extensions,
    required this.defaultExtension,
    required this.confirmButtonText,
  });

  final String label;
  final String typeGroupLabel;
  final List<String> extensions;
  final String defaultExtension;
  final String confirmButtonText;

  String get artifactType => name;
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

  @override
  Future<File?> pickExportFile({
    required ProjectExportFormat format,
    required String suggestedName,
  }) async {
    final location = await getSaveLocation(
      acceptedTypeGroups: [
        XTypeGroup(label: format.typeGroupLabel, extensions: format.extensions),
      ],
      suggestedName: suggestedName,
      confirmButtonText: format.confirmButtonText,
    );

    return location == null
        ? null
        : ensureExportFileExtension(File(location.path), format);
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
  return ensureExportFileExtension(file, ProjectExportFormat.step);
}

File ensureStlFileExtension(File file) {
  return ensureExportFileExtension(file, ProjectExportFormat.stl);
}

File ensureExportFileExtension(File file, ProjectExportFormat format) {
  final path = file.path;
  final lowerPath = path.toLowerCase();
  if (format.extensions.any((extension) => lowerPath.endsWith('.$extension'))) {
    return file;
  }

  return File('$path.${format.defaultExtension}');
}
