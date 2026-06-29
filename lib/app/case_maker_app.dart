import 'package:flutter/material.dart';

import '../geometry/geometry_backend.dart';
import '../geometry/geometry_service.dart';
import '../project/project_model.dart';
import '../ui/shell/workspace_shell.dart';
import 'app_strings.dart';

class CaseMakerApp extends StatelessWidget {
  const CaseMakerApp({super.key, this.geometryService});

  final GeometryService? geometryService;

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF159A9C),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF27C5BE),
          secondary: const Color(0xFFFFB84D),
          surface: const Color(0xFF22272B),
          error: const Color(0xFFFF6B6B),
        );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFF181B1E),
        visualDensity: VisualDensity.compact,
      ),
      home: WorkspaceShell(
        geometryService:
            geometryService ?? createGeometryServiceFromEnvironment(),
        project: ProjectModel.initial(),
      ),
    );
  }
}
