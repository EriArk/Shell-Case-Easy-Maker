import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/app/case_maker_app.dart';
import 'package:shell_case_easy_maker/commands/command_ids.dart';
import 'package:shell_case_easy_maker/geometry/geometry_service.dart';
import 'package:shell_case_easy_maker/project/project_model.dart';
import 'package:shell_case_easy_maker/ui/shell/workspace_shell.dart';

void main() {
  testWidgets('workspace shell shows semantic enclosure UI', (tester) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    expect(find.text('Shell Case Easy Maker'), findsOneWidget);
    expect(find.text('main_enclosure'), findsWidgets);
    expect(find.text('Custom Button Board'), findsWidgets);

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();

    expect(find.text('120 x 70 x 28 mm'), findsOneWidget);
  });

  testWidgets('selecting a feature updates contextual inspector', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    expect(find.text('width'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('USB-C'),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('USB-C').first);
    await tester.pumpAndSettle();

    expect(find.text('width'), findsOneWidget);
    expect(find.text('front_usb_c'), findsWidgets);
  });

  testWidgets('editing enclosure width updates semantic inspector', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('enclosure-param-width')),
      '150',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('150 x 70 x 28 mm'), findsOneWidget);
  });

  testWidgets('enclosure parameter edits can be undone and redone', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('main_enclosure').first);
    await tester.pumpAndSettle();

    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );
    final redoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.redo}'),
    );

    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
    expect(tester.widget<IconButton>(redoButton).onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('enclosure-param-width')),
      '150',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('150 x 70 x 28 mm'), findsOneWidget);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);
    expect(tester.widget<IconButton>(redoButton).onPressed, isNull);

    await tester.tap(undoButton);
    await tester.pumpAndSettle();

    expect(find.text('120 x 70 x 28 mm'), findsOneWidget);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
    expect(tester.widget<IconButton>(redoButton).onPressed, isNotNull);

    await tester.tap(redoButton);
    await tester.pumpAndSettle();

    expect(find.text('150 x 70 x 28 mm'), findsOneWidget);
  });

  testWidgets('create enclosure rail command commits through undo history', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final createButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.createEnclosure}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    expect(tester.widget<IconButton>(createButton).onPressed, isNotNull);

    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('create-enclosure-confirm')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('create-enclosure-param-width')),
      '180',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('create-enclosure-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('180 x 70 x 28 mm'), findsOneWidget);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(find.text('120 x 70 x 28 mm'), findsOneWidget);
  });

  testWidgets('create enclosure rail command can be cancelled', (tester) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final createButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.createEnclosure}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    await tester.tap(createButton);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('create-enclosure-param-width')),
      '180',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('create-enclosure-cancel')));
    await _pumpAsyncUi(tester);

    await tester.tap(find.text('main_enclosure').first);
    await _pumpAsyncUi(tester);

    expect(find.text('120 x 70 x 28 mm'), findsOneWidget);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
  });

  testWidgets('place component rail command commits through undo history', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final placeButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.placeComponent}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    expect(tester.widget<IconButton>(placeButton).onPressed, isNotNull);

    await tester.tap(placeButton);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('place-component-confirm')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('place-component-x')),
      '24',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('place-component-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('custom_button_board_v1_placement_2'), findsWidgets);
    expect(find.text('24 x 0 x 4 mm'), findsOneWidget);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(find.text('custom_button_board_v1_placement_2'), findsNothing);
  });

  testWidgets('place component rail command can be cancelled', (tester) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final placeButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.placeComponent}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    await tester.tap(placeButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('place-component-cancel')));
    await _pumpAsyncUi(tester);

    expect(find.text('custom_button_board_v1_placement_2'), findsNothing);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
  });

  testWidgets('place component command is disabled without templates', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial().copyWith(
            componentTemplates: const [],
            componentPlacements: const [],
          ),
          geometryService: const MockGeometryService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final placeButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.placeComponent}'),
    );

    expect(tester.widget<IconButton>(placeButton).onPressed, isNull);
  });

  testWidgets('add USB-C rail command commits through undo history', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final addUsbCButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.addUsbC}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    expect(tester.widget<IconButton>(addUsbCButton).onPressed, isNull);

    await tester.tap(find.text('Front wall').first);
    await tester.pumpAndSettle();

    expect(tester.widget<IconButton>(addUsbCButton).onPressed, isNotNull);

    await tester.tap(addUsbCButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('usb-c-confirm')), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('usb-c-width')), '12');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('usb-c-confirm')));
    await _pumpAsyncUi(tester);

    expect(find.text('usb_c_cutout_2'), findsWidgets);
    expect(find.text('12.0'), findsOneWidget);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

    await tester.tap(undoButton);
    await _pumpAsyncUi(tester);

    expect(find.text('usb_c_cutout_2'), findsNothing);
  });

  testWidgets('add USB-C rail command can be cancelled', (tester) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final addUsbCButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.addUsbC}'),
    );
    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    await tester.tap(find.text('Front wall').first);
    await tester.pumpAndSettle();
    await tester.tap(addUsbCButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('usb-c-cancel')));
    await _pumpAsyncUi(tester);

    expect(find.text('usb_c_cutout_2'), findsNothing);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
  });

  testWidgets('unimplemented rail commands are visible but disabled', (
    tester,
  ) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    final generateSlotButton = find.byKey(
      const ValueKey('rail-command-${CommandIds.generateSlot}'),
    );

    expect(generateSlotButton, findsOneWidget);
    expect(tester.widget<IconButton>(generateSlotButton).onPressed, isNull);
  });

  testWidgets('save command writes current semantic project file', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final dialog = _FakeProjectFileDialogService(saveFile: File('edited_case'));

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: const MockGeometryService(),
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('main_enclosure').first);
    await _pumpAsyncUi(tester);
    await tester.enterText(
      find.byKey(const ValueKey('enclosure-param-width')),
      '150',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _pumpAsyncUi(tester);

    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.saveProject}')),
    );
    await _pumpAsyncUi(tester);

    final savedFile = File('edited_case.enclosure.json');
    final savedProject = await fileService.readProject(savedFile);

    expect(fileService.hasFile(savedFile), isTrue);
    expect(savedProject.bodies.single.size, [150, 70, 28]);
    expect(dialog.saveCount, 1);
    expect(find.textContaining('Сохранено:'), findsOneWidget);
  });

  testWidgets('save picker opens without pre-picker status rebuild', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final dialog = _BlockingProjectFileDialogService();

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: const MockGeometryService(),
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final saveButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.saveProject}'),
    );

    await tester.tap(saveButton);
    await tester.pump();

    expect(dialog.saveCount, 1);
    expect(find.textContaining('Сохранение проекта'), findsNothing);

    await tester.tap(saveButton);
    await tester.pump();

    expect(dialog.saveCount, 1);

    dialog.completeSave(File('stable_case'));
    await _pumpAsyncUi(tester);

    expect(fileService.hasFile(File('stable_case.enclosure.json')), isTrue);
    expect(find.textContaining('Сохранено:'), findsOneWidget);
  });

  testWidgets('open command loads semantic project file and resets undo', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final openFile = File('opened.enclosure.json');
    final openedProject = ProjectModel.initial().replaceEnclosure(
      ProjectModel.initial().bodies.single.copyWith(size: const [160, 80, 32]),
    );
    fileService.seed(openFile, openedProject);
    final dialog = _FakeProjectFileDialogService(openFile: openFile);

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: const MockGeometryService(),
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.openProject}')),
    );
    await _pumpAsyncUi(tester);

    await tester.tap(find.text('main_enclosure').first);
    await _pumpAsyncUi(tester);

    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    expect(find.text('160 x 80 x 32 mm'), findsOneWidget);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
    expect(dialog.openCount, 1);
    expect(find.textContaining('Открыто:'), findsOneWidget);
  });

  testWidgets(
    'open command can be cancelled when project has unsaved changes',
    (tester) async {
      final fileService = _MemoryProjectFileService();
      final openFile = File('opened.enclosure.json');
      fileService.seed(
        openFile,
        ProjectModel.initial().replaceEnclosure(
          ProjectModel.initial().bodies.single.copyWith(
            size: const [160, 80, 32],
          ),
        ),
      );
      final dialog = _FakeProjectFileDialogService(openFile: openFile);

      await tester.pumpWidget(
        MaterialApp(
          home: WorkspaceShell(
            project: ProjectModel.initial(),
            geometryService: const MockGeometryService(),
            projectFileService: fileService,
            projectFileDialogService: dialog,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('main_enclosure').first);
      await _pumpAsyncUi(tester);
      await tester.enterText(
        find.byKey(const ValueKey('enclosure-param-width')),
        '150',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _pumpAsyncUi(tester);

      await tester.tap(
        find.byKey(const ValueKey('toolbar-command-${CommandIds.openProject}')),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('discard-unsaved-cancel')),
        findsOneWidget,
      );
      expect(dialog.openCount, 0);

      await tester.tap(find.byKey(const ValueKey('discard-unsaved-cancel')));
      await _pumpAsyncUi(tester);

      expect(dialog.openCount, 0);
      expect(find.text('150 x 70 x 28 mm'), findsOneWidget);
      expect(
        find.textContaining('Есть несохранённые изменения'),
        findsOneWidget,
      );
    },
  );

  testWidgets('open command can discard unsaved changes after confirmation', (
    tester,
  ) async {
    final fileService = _MemoryProjectFileService();
    final openFile = File('opened.enclosure.json');
    fileService.seed(
      openFile,
      ProjectModel.initial().replaceEnclosure(
        ProjectModel.initial().bodies.single.copyWith(
          size: const [160, 80, 32],
        ),
      ),
    );
    final dialog = _FakeProjectFileDialogService(openFile: openFile);

    await tester.pumpWidget(
      MaterialApp(
        home: WorkspaceShell(
          project: ProjectModel.initial(),
          geometryService: const MockGeometryService(),
          projectFileService: fileService,
          projectFileDialogService: dialog,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('main_enclosure').first);
    await _pumpAsyncUi(tester);
    await tester.enterText(
      find.byKey(const ValueKey('enclosure-param-width')),
      '150',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _pumpAsyncUi(tester);

    await tester.tap(
      find.byKey(const ValueKey('toolbar-command-${CommandIds.openProject}')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('discard-unsaved-confirm')));
    await _pumpAsyncUi(tester);
    await tester.tap(find.text('main_enclosure').first);
    await _pumpAsyncUi(tester);

    final undoButton = find.byKey(
      const ValueKey('toolbar-command-${CommandIds.undo}'),
    );

    expect(dialog.openCount, 1);
    expect(find.text('160 x 80 x 32 mm'), findsOneWidget);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
    expect(find.textContaining('Открыто:'), findsOneWidget);
  });
}

Future<void> _pumpAsyncUi(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump();
}

class _FakeProjectFileDialogService implements ProjectFileDialogService {
  _FakeProjectFileDialogService({this.openFile, this.saveFile});

  final File? openFile;
  final File? saveFile;
  int openCount = 0;
  int saveCount = 0;
  String? lastSuggestedName;

  @override
  Future<File?> pickOpenProjectFile() async {
    openCount += 1;
    return openFile;
  }

  @override
  Future<File?> pickSaveProjectFile({required String suggestedName}) async {
    saveCount += 1;
    lastSuggestedName = suggestedName;
    return saveFile;
  }
}

class _BlockingProjectFileDialogService implements ProjectFileDialogService {
  final Completer<File?> _saveCompleter = Completer<File?>();
  int saveCount = 0;

  void completeSave(File? file) {
    _saveCompleter.complete(file);
  }

  @override
  Future<File?> pickOpenProjectFile() async {
    return null;
  }

  @override
  Future<File?> pickSaveProjectFile({required String suggestedName}) async {
    saveCount += 1;
    return _saveCompleter.future;
  }
}

class _MemoryProjectFileService extends ProjectFileService {
  final Map<String, String> _files = {};

  void seed(File file, ProjectModel project) {
    _files[file.path] = encode(project);
  }

  bool hasFile(File file) {
    return _files.containsKey(file.path);
  }

  @override
  Future<void> writeProject(File file, ProjectModel project) async {
    _files[file.path] = encode(project);
  }

  @override
  Future<ProjectModel> readProject(File file) async {
    final source = _files[file.path];
    if (source == null) {
      throw FileSystemException('File not found.', file.path);
    }

    return decode(source);
  }
}
