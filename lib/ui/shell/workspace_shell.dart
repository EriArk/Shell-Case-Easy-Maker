import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../app/app_strings.dart';
import '../../commands/app_command.dart';
import '../../commands/command_ids.dart';
import '../../commands/command_registry.dart';
import '../../commands/undo_history.dart' as app_undo;
import '../../component_features/component_feature_projection.dart';
import '../../geometry/geometry_service.dart';
import '../../parameters/enclosure_parameter_adapter.dart';
import '../../parameters/parameter_model.dart';
import '../../patterns/pattern_layout.dart';
import '../../project/project_file_dialog_service.dart';
import '../../project/project_model.dart';
import '../../selection/project_selection_resolver.dart';
import '../../selection/selection_model.dart';
import '../../validation/project_semantic_validator.dart';
import '../../validation/validation_result.dart';
import '../../viewport/preview_mesh_edges.dart';
import '../../viewport/viewport_controller.dart';

class WorkspaceShell extends StatefulWidget {
  const WorkspaceShell({
    super.key,
    required this.project,
    required this.geometryService,
    this.projectFileService = const ProjectFileService(),
    this.projectFileDialogService =
        const FileSelectorProjectFileDialogService(),
  });

  final ProjectModel project;
  final GeometryService geometryService;
  final ProjectFileService projectFileService;
  final ProjectFileDialogService projectFileDialogService;

  @override
  State<WorkspaceShell> createState() => _WorkspaceShellState();
}

class _WorkspaceShellState extends State<WorkspaceShell> {
  final _viewportController = ViewportController();
  late app_undo.UndoHistory<ProjectModel> _undoHistory;
  late Future<GeometryPreview> _previewFuture;
  late Future<ValidationReport> _validationFuture;
  SelectionModel _selection = const SelectionModel.workspace();
  _ActiveSnapTarget? _activeSnapTarget;
  ComponentPlacement? _placementDialogCandidate;
  File? _currentProjectFile;
  String? _fileStatusMessage;
  late String _lastPersistedProjectFingerprint;
  bool _fileBusy = false;

  ProjectModel get _project => _undoHistory.current;
  bool get _hasUnsavedChanges =>
      _lastPersistedProjectFingerprint != _fingerprintProject(_project);

  @override
  void initState() {
    super.initState();
    _undoHistory = app_undo.UndoHistory<ProjectModel>(widget.project);
    _lastPersistedProjectFingerprint = _fingerprintProject(widget.project);
    _loadGeometry();
  }

  @override
  void didUpdateWidget(covariant WorkspaceShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project != widget.project) {
      _undoHistory = app_undo.UndoHistory<ProjectModel>(widget.project);
      _lastPersistedProjectFingerprint = _fingerprintProject(widget.project);
      _loadGeometry();
    } else if (oldWidget.geometryService != widget.geometryService) {
      _loadGeometry();
    }
  }

  void _loadGeometry() {
    _previewFuture = widget.geometryService.generatePreview(_project);
    _validationFuture = widget.geometryService.validateGeometry(_project);
  }

  void _select(SelectionModel selection) {
    setState(() {
      _selection = selection;
      _activeSnapTarget = null;
      _placementDialogCandidate = null;
      _viewportController.setSelectedSemanticId(selection.id);
      _viewportController.setGhostPreview(_ghostPreviewFor(selection));
    });
  }

  void _orbitViewport(Offset delta) {
    setState(() {
      _viewportController.orbit(delta);
    });
  }

  void _panViewport(Offset delta) {
    setState(() {
      _viewportController.pan(delta);
    });
  }

  void _zoomViewport(double scrollDeltaY) {
    setState(() {
      _viewportController.zoomByScroll(scrollDeltaY);
    });
  }

  void _fitViewport() {
    setState(() {
      _viewportController.fit();
      _viewportController.setSelectedSemanticId(_selection.id);
      _viewportController.setGhostPreview(_ghostPreviewFor(_selection));
    });
  }

  void _applyViewportPreset(ViewportViewPreset preset) {
    setState(() {
      _viewportController.applyViewPreset(preset);
      _viewportController.setSelectedSemanticId(_selection.id);
      _viewportController.setGhostPreview(_ghostPreviewFor(_selection));
    });
  }

  void _clearActiveSnapTarget() {
    if (_activeSnapTarget == null) {
      return;
    }

    setState(() {
      _activeSnapTarget = null;
      _placementDialogCandidate = null;
      _fileStatusMessage = null;
    });
  }

  void _setPlacementDialogCandidate(ComponentPlacement placement) {
    if (!mounted) {
      return;
    }

    setState(() {
      _placementDialogCandidate = placement;
    });
  }

  void _selectViewportHit(ViewportHitResult? hit) {
    if (hit?.kind == ViewportHitKind.snapPoint) {
      final snapTarget = _snapTargetFromViewportHit(_project, hit!);
      final selection = _selectionFromViewportHit(hit);
      if (snapTarget != null && selection != null) {
        setState(() {
          _selection = selection;
          _activeSnapTarget = snapTarget;
          _fileStatusMessage = 'Точка привязки: ${snapTarget.label}';
          _viewportController.setSelectedSemanticId(selection.id);
          _viewportController.setGhostPreview(_ghostPreviewFor(selection));
        });
      }
      return;
    }

    final selection = _selectionFromViewportHit(hit);
    if (selection != null) {
      _select(selection);
    }
  }

  void _updateEnclosureParameter(
    String enclosureId,
    String parameterId,
    Object? value,
  ) {
    final enclosure = _project.bodies
        .where((body) => body.id == enclosureId)
        .firstOrNull;
    if (enclosure == null) {
      return;
    }

    final updatedEnclosure = EnclosureParameterAdapter.updateParameter(
      enclosure,
      parameterId,
      value,
    );
    _commitProjectEdit(
      id: 'enclosure.parameter.$parameterId',
      label: 'Изменить корпус',
      nextState: _project.replaceEnclosure(updatedEnclosure),
    );
  }

  void _updateFeatureParameter(
    String featureId,
    String parameterId,
    Object? value,
  ) {
    final feature = _project.features
        .where((feature) => feature.id == featureId)
        .firstOrNull;
    if (feature == null) {
      return;
    }

    final parameter = _featureParameterSchema(
      feature.type,
    )?.parameters.where((parameter) => parameter.id == parameterId).firstOrNull;
    if (parameter == null) {
      return;
    }

    final updatedFeature = SemanticFeature(
      id: feature.id,
      type: feature.type,
      targetSurface: feature.targetSurface,
      operation: feature.operation,
      parameters: {
        ...feature.parameters,
        parameterId: parameter.normalize(value),
      },
      source: feature.source,
      placement: feature.placement,
      metadata: feature.metadata,
    );
    _commitProjectEdit(
      id: 'feature.parameter.$parameterId',
      label: 'Изменить фичу',
      nextState: _project.replaceFeature(updatedFeature),
    );
  }

  void _updateComponentPlacementParameter(
    String placementId,
    String parameterId,
    Object? value,
  ) {
    final placement = _project.componentPlacements
        .where((placement) => placement.id == placementId)
        .firstOrNull;
    if (placement == null) {
      return;
    }

    final parameter = _componentPlacementParameterSchema.parameters
        .where((parameter) => parameter.id == parameterId)
        .firstOrNull;
    if (parameter == null) {
      return;
    }

    if (placement.locked &&
        parameterId != 'locked' &&
        parameterId != 'visible') {
      return;
    }

    final normalizedValue = parameter.normalize(value);
    final updatedPlacement = _updatedComponentPlacementParameter(
      placement,
      parameterId,
      normalizedValue,
    );

    _commitProjectEdit(
      id: 'componentPlacement.parameter.$parameterId',
      label: 'Изменить компонент',
      nextState: _project.replaceComponentPlacement(updatedPlacement),
    );
  }

  void _updateFeatureGroupParameter(
    String groupId,
    String parameterId,
    Object? value,
  ) {
    final group = _project.featureGroups
        .where((group) => group.id == groupId)
        .firstOrNull;
    if (group == null) {
      return;
    }

    final parameter = _featureGroupParameterSchema(
      group.type,
    )?.parameters.where((parameter) => parameter.id == parameterId).firstOrNull;
    final target = _featureGroupParameterTarget(group.type, parameterId);
    if (parameter == null || target == null) {
      return;
    }

    final nextPattern = {...group.pattern};
    final nextItemPrototype = {...group.itemPrototype};
    final normalizedValue = parameter.normalize(value);
    switch (target) {
      case _FeatureGroupParameterTarget.pattern:
        nextPattern[parameterId] = normalizedValue;
      case _FeatureGroupParameterTarget.itemPrototype:
        nextItemPrototype[parameterId] = normalizedValue;
    }

    final normalized = _normalizeFeatureGroupParameterMaps(
      group.type,
      pattern: nextPattern,
      itemPrototype: nextItemPrototype,
    );

    final updatedGroup = FeatureGroup(
      id: group.id,
      type: group.type,
      targetSurface: group.targetSurface,
      pattern: normalized.pattern,
      itemPrototype: normalized.itemPrototype,
      placement: group.placement,
      overrides: group.overrides,
      metadata: group.metadata,
    );
    _commitProjectEdit(
      id: 'featureGroup.parameter.$parameterId',
      label: 'Изменить группу',
      nextState: _project.replaceFeatureGroup(updatedGroup),
    );
  }

  void _commitProjectEdit({
    required String id,
    required String label,
    required ProjectModel nextState,
    SelectionModel? selection,
  }) {
    if (_sameJson(_project.toJson(), nextState.toJson())) {
      return;
    }

    setState(() {
      _undoHistory.commit(id: id, label: label, nextState: nextState);
      if (selection != null) {
        _selection = selection;
      }
      _activeSnapTarget = null;
      _placementDialogCandidate = null;
      _fileStatusMessage = null;
      _loadGeometry();
      _viewportController.setSelectedSemanticId(_selection.id);
      _viewportController.setGhostPreview(_ghostPreviewFor(_selection));
    });
  }

  VoidCallback? _commandActionFor(String commandId) {
    return switch (commandId) {
      CommandIds.createEnclosure => () {
        _runCreateEnclosureCommand();
      },
      CommandIds.placeComponent =>
        _project.componentTemplates.isEmpty
            ? null
            : () {
                _runPlaceComponentCommand();
              },
      CommandIds.addUsbC => _usbCCommandAction(),
      CommandIds.createButtonGroup => _buttonGroupCommandAction(),
      CommandIds.createGlassRecess =>
        _selection.kind == SelectionKind.surface
            ? () {
                _runCreateGlassRecessCommand(_selection);
              }
            : null,
      CommandIds.generateSlot =>
        _selection.kind == SelectionKind.surface
            ? () {
                _runCreateCircularCutoutCommand(_selection);
              }
            : null,
      CommandIds.generateMount => _mountCommandAction(),
      _ => null,
    };
  }

  VoidCallback? _mountCommandAction() {
    final target = _selectedMountablePlacement();
    if (target == null) {
      return null;
    }

    return () {
      _runGenerateMountCommand(target.placement, target.template);
    };
  }

  VoidCallback? _usbCCommandAction() {
    if (_selection.kind == SelectionKind.surface) {
      return () {
        _runAddUsbCCommand(_selection);
      };
    }

    final target = _selectedUsbCComponentPort();
    if (target == null) {
      return null;
    }

    return () {
      _runAddUsbCFromComponentCommand(
        target.placement,
        target.template,
        target.feature,
      );
    };
  }

  VoidCallback? _buttonGroupCommandAction() {
    if (_selection.kind == SelectionKind.surface) {
      return () {
        _runCreateButtonGroupCommand(_selection);
      };
    }

    final target = _selectedSwitchComponentGroup();
    if (target == null) {
      return null;
    }

    return () {
      _runCreateButtonGroupFromComponentCommand(
        target.placement,
        target.template,
        target.switches,
      );
    };
  }

  Future<void> _runCreateEnclosureCommand() async {
    final baseEnclosure = _project.bodies.firstOrNull ?? _defaultEnclosure();
    final values = await showDialog<Map<String, Object?>>(
      context: context,
      builder: (context) =>
          _CreateEnclosureDialog(initialEnclosure: baseEnclosure),
    );
    if (!mounted || values == null) {
      return;
    }

    final enclosure = EnclosureParameterAdapter.applyValues(
      baseEnclosure,
      values,
    );
    _commitProjectEdit(
      id: CommandIds.createEnclosure,
      label: 'Создать корпус',
      nextState: _project.replaceEnclosure(enclosure),
      selection: SelectionModel.enclosure(enclosure.id),
    );
  }

  Future<void> _runPlaceComponentCommand() async {
    if (_project.componentTemplates.isEmpty) {
      return;
    }

    final template = _project.componentTemplates.first;
    final snapTarget = _activeSnapTarget;
    final initialPlacement = _defaultComponentPlacement(
      id: _nextComponentPlacementId(_project, template.id),
      templateId: template.id,
      index: _project.componentPlacements.length,
      snapTarget: snapTarget,
    );

    setState(() {
      _placementDialogCandidate = initialPlacement;
    });

    final placement = await showDialog<ComponentPlacement>(
      context: context,
      builder: (context) => _PlaceComponentDialog(
        project: _project,
        templates: _project.componentTemplates,
        initialPlacement: initialPlacement,
        onCandidateChanged: _setPlacementDialogCandidate,
        snapTarget: snapTarget,
        snapHint: snapTarget?.label,
      ),
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _placementDialogCandidate = null;
    });

    if (placement == null) {
      return;
    }

    _commitProjectEdit(
      id: CommandIds.placeComponent,
      label: 'Разместить компонент',
      nextState: _project.replaceComponentPlacement(placement),
      selection: SelectionModel.componentPlacement(placement.id),
    );
  }

  Future<void> _runAddUsbCCommand(SelectionModel surfaceSelection) async {
    final targetSurfaceId = surfaceSelection.id;
    if (surfaceSelection.kind != SelectionKind.surface ||
        targetSurfaceId == null) {
      return;
    }

    final feature = await showDialog<SemanticFeature>(
      context: context,
      builder: (context) => _UsbCCutoutDialog(
        initialFeature: _defaultUsbCCutoutFeature(
          id: _nextFeatureId(_project, 'usb_c_cutout'),
          targetSurfaceId: targetSurfaceId,
        ),
      ),
    );
    if (!mounted || feature == null) {
      return;
    }

    _commitProjectEdit(
      id: CommandIds.addUsbC,
      label: 'Добавить USB-C',
      nextState: _project.replaceFeature(feature),
      selection: SelectionModel.feature(feature.id),
    );
  }

  Future<void> _runAddUsbCFromComponentCommand(
    ComponentPlacement placement,
    ComponentTemplate template,
    ComponentFeature componentFeature,
  ) async {
    final targetSurfaceId = _targetSurfaceForComponentFeature(
      _project,
      componentFeature,
    );
    if (targetSurfaceId == null) {
      return;
    }

    final feature = await showDialog<SemanticFeature>(
      context: context,
      builder: (context) => _UsbCCutoutDialog(
        initialFeature: _usbCCutoutFeatureFromComponent(
          id: _nextFeatureId(_project, 'usb_c_cutout'),
          targetSurfaceId: targetSurfaceId,
          project: _project,
          placement: placement,
          template: template,
          componentFeature: componentFeature,
        ),
      ),
    );
    if (!mounted || feature == null) {
      return;
    }

    _commitProjectEdit(
      id: CommandIds.addUsbC,
      label: 'Добавить USB-C от компонента',
      nextState: _project.replaceFeature(feature),
      selection: SelectionModel.feature(feature.id),
    );
  }

  Future<void> _runCreateButtonGroupCommand(
    SelectionModel surfaceSelection,
  ) async {
    final targetSurfaceId = surfaceSelection.id;
    if (surfaceSelection.kind != SelectionKind.surface ||
        targetSurfaceId == null) {
      return;
    }

    final group = await showDialog<FeatureGroup>(
      context: context,
      builder: (context) => _ButtonGroupDialog(
        initialGroup: _defaultButtonGroup(
          id: _nextFeatureGroupId(_project, 'button_group'),
          targetSurfaceId: targetSurfaceId,
        ),
      ),
    );
    if (!mounted || group == null) {
      return;
    }

    _commitProjectEdit(
      id: CommandIds.createButtonGroup,
      label: 'Создать группу кнопок',
      nextState: _project.replaceFeatureGroup(group),
      selection: SelectionModel.featureGroup(group.id),
    );
  }

  Future<void> _runCreateButtonGroupFromComponentCommand(
    ComponentPlacement placement,
    ComponentTemplate template,
    List<ComponentFeature> switches,
  ) async {
    if (switches.isEmpty) {
      return;
    }

    final firstProjection = ComponentFeatureSurfaceProjector.projectFeature(
      project: _project,
      placement: placement,
      feature: switches.first,
    );
    if (firstProjection == null) {
      return;
    }

    final group = await showDialog<FeatureGroup>(
      context: context,
      builder: (context) => _ButtonGroupDialog(
        initialGroup: _buttonGroupFromComponentSwitches(
          id: _nextFeatureGroupId(_project, 'button_group'),
          targetSurfaceId: firstProjection.targetSurfaceId,
          project: _project,
          placement: placement,
          template: template,
          switches: switches,
        ),
      ),
    );
    if (!mounted || group == null) {
      return;
    }

    _commitProjectEdit(
      id: CommandIds.createButtonGroup,
      label: 'Создать кнопки от компонента',
      nextState: _project.replaceFeatureGroup(group),
      selection: SelectionModel.featureGroup(group.id),
    );
  }

  Future<void> _runCreateGlassRecessCommand(
    SelectionModel surfaceSelection,
  ) async {
    final targetSurfaceId = surfaceSelection.id;
    if (surfaceSelection.kind != SelectionKind.surface ||
        targetSurfaceId == null) {
      return;
    }

    final feature = await showDialog<SemanticFeature>(
      context: context,
      builder: (context) => _GlassRecessDialog(
        initialFeature: _defaultGlassRecessFeature(
          id: _nextFeatureId(_project, 'glass_recess'),
          targetSurfaceId: targetSurfaceId,
        ),
      ),
    );
    if (!mounted || feature == null) {
      return;
    }

    _commitProjectEdit(
      id: CommandIds.createGlassRecess,
      label: 'Посадка под стекло',
      nextState: _project.replaceFeature(feature),
      selection: SelectionModel.feature(feature.id),
    );
  }

  Future<void> _runCreateCircularCutoutCommand(
    SelectionModel surfaceSelection,
  ) async {
    final targetSurfaceId = surfaceSelection.id;
    if (surfaceSelection.kind != SelectionKind.surface ||
        targetSurfaceId == null) {
      return;
    }

    final feature = await showDialog<SemanticFeature>(
      context: context,
      builder: (context) => _CircularCutoutDialog(
        initialFeature: _defaultCircularCutoutFeature(
          id: _nextFeatureId(_project, 'circular_cutout'),
          targetSurfaceId: targetSurfaceId,
        ),
      ),
    );
    if (!mounted || feature == null) {
      return;
    }

    _commitProjectEdit(
      id: CommandIds.generateSlot,
      label: 'Круглое отверстие',
      nextState: _project.replaceFeature(feature),
      selection: SelectionModel.feature(feature.id),
    );
  }

  Future<void> _runGenerateMountCommand(
    ComponentPlacement placement,
    ComponentTemplate template,
  ) async {
    if (template.mountingHoles.isEmpty) {
      return;
    }

    final group = await showDialog<FeatureGroup>(
      context: context,
      builder: (context) => _MountGenerationDialog(
        componentName: template.name,
        mountingHoleCount: template.mountingHoles.length,
        initialGroup: _defaultMountGroup(
          id: _nextFeatureGroupId(_project, 'standoff_mounts'),
          placement: placement,
          template: template,
        ),
      ),
    );
    if (!mounted || group == null) {
      return;
    }

    _commitProjectEdit(
      id: CommandIds.generateMount,
      label: 'Сгенерировать крепёж',
      nextState: _project.replaceFeatureGroup(group),
      selection: SelectionModel.featureGroup(group.id),
    );
  }

  ({ComponentPlacement placement, ComponentTemplate template})?
  _selectedMountablePlacement() {
    if (_selection.kind != SelectionKind.componentPlacement ||
        _selection.id == null) {
      return null;
    }

    final placement = _project.componentPlacements
        .where((placement) => placement.id == _selection.id)
        .firstOrNull;
    if (placement == null) {
      return null;
    }

    final template = _componentTemplateForPlacement(placement);
    if (template == null || template.mountingHoles.isEmpty) {
      return null;
    }

    return (placement: placement, template: template);
  }

  ({
    ComponentPlacement placement,
    ComponentTemplate template,
    ComponentFeature feature,
  })?
  _selectedUsbCComponentPort() {
    if (_selection.kind != SelectionKind.componentPlacement ||
        _selection.id == null) {
      return null;
    }

    final placement = _project.componentPlacements
        .where((placement) => placement.id == _selection.id)
        .firstOrNull;
    if (placement == null) {
      return null;
    }

    final template = _componentTemplateForPlacement(placement);
    if (template == null) {
      return null;
    }

    final feature = template.features
        .where(
          (feature) =>
              feature.type == 'usb_c' &&
              _componentFeatureCutout(feature).isNotEmpty &&
              ComponentFeatureSurfaceProjector.projectFeature(
                    project: _project,
                    placement: placement,
                    feature: feature,
                  ) !=
                  null,
        )
        .firstOrNull;
    if (feature == null) {
      return null;
    }

    return (placement: placement, template: template, feature: feature);
  }

  ({
    ComponentPlacement placement,
    ComponentTemplate template,
    List<ComponentFeature> switches,
  })?
  _selectedSwitchComponentGroup() {
    if (_selection.kind != SelectionKind.componentPlacement ||
        _selection.id == null) {
      return null;
    }

    final placement = _project.componentPlacements
        .where((placement) => placement.id == _selection.id)
        .firstOrNull;
    if (placement == null) {
      return null;
    }

    final template = _componentTemplateForPlacement(placement);
    if (template == null) {
      return null;
    }

    final switches = [
      for (final feature in template.features)
        if (feature.type == 'switch' &&
            feature.position.length >= 2 &&
            ComponentFeatureSurfaceProjector.projectFeature(
                  project: _project,
                  placement: placement,
                  feature: feature,
                ) !=
                null)
          feature,
    ];
    if (switches.isEmpty) {
      return null;
    }

    return (placement: placement, template: template, switches: switches);
  }

  ComponentTemplate? _componentTemplateForPlacement(
    ComponentPlacement placement,
  ) {
    return _project.componentTemplates
        .where((template) => template.id == placement.templateId)
        .firstOrNull;
  }

  void _undo() {
    if (!_undoHistory.canUndo) {
      return;
    }

    setState(() {
      _undoHistory.undo();
      _selection = _validSelectionFor(_project, _selection);
      _activeSnapTarget = null;
      _placementDialogCandidate = null;
      _fileStatusMessage = null;
      _loadGeometry();
      _viewportController.setSelectedSemanticId(_selection.id);
      _viewportController.setGhostPreview(_ghostPreviewFor(_selection));
    });
  }

  void _redo() {
    if (!_undoHistory.canRedo) {
      return;
    }

    setState(() {
      _undoHistory.redo();
      _selection = _validSelectionFor(_project, _selection);
      _activeSnapTarget = null;
      _placementDialogCandidate = null;
      _fileStatusMessage = null;
      _loadGeometry();
      _viewportController.setSelectedSemanticId(_selection.id);
      _viewportController.setGhostPreview(_ghostPreviewFor(_selection));
    });
  }

  Future<bool> _confirmDiscardUnsavedChanges() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Несохранённые изменения'),
          content: const Text(
            'Перед открытием другого проекта текущие правки будут потеряны.',
          ),
          actions: [
            TextButton(
              key: const ValueKey('discard-unsaved-cancel'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              key: const ValueKey('discard-unsaved-confirm'),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Открыть'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _openProject() async {
    if (_fileBusy) {
      return;
    }

    if (_hasUnsavedChanges && !await _confirmDiscardUnsavedChanges()) {
      if (!mounted) {
        return;
      }

      setState(() {
        _fileStatusMessage = 'Открытие отменено';
      });
      return;
    }

    _fileBusy = true;

    try {
      final file = await widget.projectFileDialogService.pickOpenProjectFile();
      if (!mounted) {
        _fileBusy = false;
        return;
      }

      if (file == null) {
        setState(() {
          _fileBusy = false;
          _fileStatusMessage = 'Открытие отменено';
        });
        return;
      }

      setState(() {
        _fileStatusMessage = 'Открытие проекта...';
      });
      final project = await widget.projectFileService.readProject(file);
      if (!mounted) {
        _fileBusy = false;
        return;
      }

      setState(() {
        _undoHistory = app_undo.UndoHistory<ProjectModel>(project);
        _lastPersistedProjectFingerprint = _fingerprintProject(project);
        _currentProjectFile = file;
        _selection = const SelectionModel.workspace();
        _fileBusy = false;
        _fileStatusMessage = 'Открыто: ${_fileName(file)}';
        _loadGeometry();
        _viewportController.setSelectedSemanticId(_selection.id);
        _viewportController.setGhostPreview(_ghostPreviewFor(_selection));
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _fileBusy = false;
        _fileStatusMessage = 'Не удалось открыть проект';
      });
    }
  }

  Future<void> _saveProject() async {
    if (_fileBusy) {
      return;
    }

    _fileBusy = true;

    try {
      final selectedFile =
          _currentProjectFile ??
          await widget.projectFileDialogService.pickSaveProjectFile(
            suggestedName: _suggestedProjectFileName(_project),
          );
      if (!mounted) {
        _fileBusy = false;
        return;
      }

      if (selectedFile == null) {
        setState(() {
          _fileBusy = false;
          _fileStatusMessage = 'Сохранение отменено';
        });
        return;
      }

      final file = ensureProjectFileExtension(selectedFile);
      setState(() {
        _fileStatusMessage = 'Сохранение проекта...';
      });
      await widget.projectFileService.writeProject(file, _project);
      if (!mounted) {
        _fileBusy = false;
        return;
      }

      setState(() {
        _currentProjectFile = file;
        _lastPersistedProjectFingerprint = _fingerprintProject(_project);
        _fileBusy = false;
        _fileStatusMessage = 'Сохранено: ${_fileName(file)}';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _fileBusy = false;
        _fileStatusMessage = 'Не удалось сохранить проект';
      });
    }
  }

  Future<void> _chooseExportFormat() async {
    if (_fileBusy) {
      return;
    }

    final format = await showModalBottomSheet<ProjectExportFormat>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 360),
      showDragHandle: true,
      builder: (_) => const _ExportFormatSheet(),
    );
    if (!mounted) {
      return;
    }

    if (format == null) {
      setState(() {
        _fileStatusMessage = 'Экспорт отменён';
      });
      return;
    }

    await _exportProject(format);
  }

  Future<void> _exportProject(ProjectExportFormat format) async {
    if (_fileBusy) {
      return;
    }

    _fileBusy = true;
    final label = format.label;

    try {
      final selectedFile = await widget.projectFileDialogService.pickExportFile(
        format: format,
        suggestedName: _suggestedExportFileName(_project, format),
      );
      if (!mounted) {
        _fileBusy = false;
        return;
      }

      if (selectedFile == null) {
        setState(() {
          _fileBusy = false;
          _fileStatusMessage = 'Экспорт отменён';
        });
        return;
      }

      final file = ensureExportFileExtension(selectedFile, format);
      setState(() {
        _fileStatusMessage = 'Экспорт $label...';
      });

      final response = await widget.geometryService.buildGeometry(
        switch (format) {
          ProjectExportFormat.step => GeometryRequest.exportStep(
            _project,
            requestId: 'toolbar_export_step',
            outputPath: file.path,
          ),
          ProjectExportFormat.stl => GeometryRequest.exportStl(
            _project,
            requestId: 'toolbar_export_stl',
            outputPath: file.path,
          ),
        },
      );
      if (!mounted) {
        _fileBusy = false;
        return;
      }

      final artifact = response.artifacts
          .where((artifact) => artifact.type == format.artifactType)
          .firstOrNull;
      final exportedPath = artifact?.path.isNotEmpty == true
          ? artifact!.path
          : file.path;

      setState(() {
        _fileBusy = false;
        _fileStatusMessage = response.hasErrors || artifact == null
            ? 'Не удалось экспортировать $label'
            : '$label экспортирован: ${_fileName(File(exportedPath))}';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _fileBusy = false;
        _fileStatusMessage = 'Не удалось экспортировать $label';
      });
    }
  }

  void _showValidationDetails(ValidationReport report) {
    if (!report.hasIssues) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => _ValidationDetailsSheet(
        report: report,
        selectionForTarget: (targetId) =>
            _selectionForValidationTarget(_project, targetId),
        onSelectionRequested: (selection) {
          Navigator.of(sheetContext).pop();
          _select(selection);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<GeometryPreview>(
          future: _previewFuture,
          builder: (context, previewSnapshot) {
            final preview = previewSnapshot.data;
            final surfaceLabels = {
              for (final surface in preview?.surfaces ?? <SelectableSurface>[])
                surface.id: surface.label,
              for (final surface
                  in preview?.previewMesh?.surfaces ??
                      <PreviewSurfaceMapping>[])
                surface.semanticId: surface.label,
            };
            final details = ProjectSelectionResolver(
              _project,
              surfaceLabels: surfaceLabels,
            ).describe(_selection);
            final commandContext = _selection.toCommandContext();
            final activeSnapPlacementIssue = _placementDialogCandidate == null
                ? _activeSnapPlacementIssue(_project, _activeSnapTarget)
                : null;
            final placementDialogCandidateIssue =
                _placementDialogCandidate == null
                ? null
                : _prospectivePlacementIssue(
                    _project,
                    _placementDialogCandidate!,
                  );

            return Column(
              children: [
                _TopToolbar(
                  projectName: _project.projectName,
                  canUndo: _undoHistory.canUndo,
                  canRedo: _undoHistory.canRedo,
                  fileBusy: _fileBusy,
                  onOpen: _openProject,
                  onSave: _saveProject,
                  onExport: _chooseExportFormat,
                  onUndo: _undo,
                  onRedo: _redo,
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ToolRail(
                        commandContext: commandContext,
                        commandActionFor: _commandActionFor,
                      ),
                      _ProjectBrowser(
                        project: _project,
                        surfaces: preview?.surfaces ?? const [],
                        selection: _selection,
                        onSelectionChanged: _select,
                      ),
                      Expanded(
                        child: _ViewportArea(
                          project: _project,
                          preview: preview,
                          selection: _selection,
                          selectionDetails: details,
                          activeSnapTarget: _activeSnapTarget,
                          activeSnapPlacementIssue: activeSnapPlacementIssue,
                          placementDialogCandidate: _placementDialogCandidate,
                          placementDialogCandidateIssue:
                              placementDialogCandidateIssue,
                          viewportState: _viewportController.state,
                          onOrbit: _orbitViewport,
                          onPan: _panViewport,
                          onZoom: _zoomViewport,
                          onFit: _fitViewport,
                          onViewPreset: _applyViewportPreset,
                          onHit: _selectViewportHit,
                        ),
                      ),
                      _Inspector(
                        details: details,
                        project: _project,
                        selection: _selection,
                        activeSnapTarget: _activeSnapTarget,
                        activeSnapPlacementIssue: activeSnapPlacementIssue,
                        onPlaceComponentFromSnap:
                            _activeSnapTarget != null &&
                                _project.componentTemplates.isNotEmpty
                            ? () {
                                _runPlaceComponentCommand();
                              }
                            : null,
                        onClearSnapTarget: _clearActiveSnapTarget,
                        onEnclosureParameterChanged: _updateEnclosureParameter,
                        onComponentPlacementParameterChanged:
                            _updateComponentPlacementParameter,
                        onFeatureParameterChanged: _updateFeatureParameter,
                        onFeatureGroupParameterChanged:
                            _updateFeatureGroupParameter,
                      ),
                    ],
                  ),
                ),
                FutureBuilder<ValidationReport>(
                  future: _validationFuture,
                  builder: (context, snapshot) {
                    final report = snapshot.data;
                    return _StatusBar(
                      report: report,
                      selectionDetails: details,
                      fileStatusMessage: _fileStatusMessage,
                      fileBusy: _fileBusy,
                      hasUnsavedChanges: _hasUnsavedChanges,
                      onShowValidationDetails:
                          report != null && report.hasIssues
                          ? () => _showValidationDetails(report)
                          : null,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

GhostPreview? _ghostPreviewFor(SelectionModel selection) {
  if (selection.kind != SelectionKind.surface || selection.id == null) {
    return null;
  }

  if (selection.id!.contains('front_wall')) {
    return GhostPreview(
      kind: GhostPreviewKind.usbC,
      semanticId: 'ghost_usb_c',
      targetSurfaceId: selection.id!,
      label: 'USB-C',
    );
  }

  if (selection.id!.contains('top_lid')) {
    return GhostPreview(
      kind: GhostPreviewKind.buttonGroup,
      semanticId: 'ghost_button_group',
      targetSurfaceId: selection.id!,
      label: 'Группа кнопок',
    );
  }

  return null;
}

SelectionModel? _selectionFromViewportHit(ViewportHitResult? hit) {
  if (hit == null) {
    return const SelectionModel.workspace();
  }

  return switch (hit.kind) {
    ViewportHitKind.enclosure => SelectionModel.enclosure(hit.semanticId),
    ViewportHitKind.surface => SelectionModel.surface(
      id: hit.semanticId,
      parentId: hit.parentId ?? 'main_enclosure',
    ),
    ViewportHitKind.componentPlacement => SelectionModel.componentPlacement(
      hit.semanticId,
    ),
    ViewportHitKind.feature => SelectionModel.feature(hit.semanticId),
    ViewportHitKind.featureGroup => SelectionModel.featureGroup(hit.semanticId),
    ViewportHitKind.snapPoint => _selectionForSnapHit(hit),
  };
}

SelectionModel? _selectionForSnapHit(ViewportHitResult hit) {
  return switch (hit.workplaneKind) {
    MockViewportWorkplaneKind.topLid ||
    MockViewportWorkplaneKind.frontWall => SelectionModel.surface(
      id: hit.semanticId,
      parentId: hit.parentId ?? 'main_enclosure',
    ),
    MockViewportWorkplaneKind.componentPlacement =>
      SelectionModel.componentPlacement(hit.semanticId),
    null => null,
  };
}

class _ActiveSnapTarget {
  const _ActiveSnapTarget({
    required this.workplaneId,
    required this.workplaneKind,
    required this.localPosition,
    required this.projectPosition,
    required this.z,
    required this.mountingSide,
    required this.label,
  });

  final String workplaneId;
  final MockViewportWorkplaneKind workplaneKind;
  final Offset localPosition;
  final Offset projectPosition;
  final double z;
  final String mountingSide;
  final String label;

  @override
  bool operator ==(Object other) {
    return other is _ActiveSnapTarget &&
        other.workplaneId == workplaneId &&
        other.workplaneKind == workplaneKind &&
        other.localPosition == localPosition &&
        other.projectPosition == projectPosition &&
        other.z == z &&
        other.mountingSide == mountingSide &&
        other.label == label;
  }

  @override
  int get hashCode {
    return Object.hash(
      workplaneId,
      workplaneKind,
      localPosition,
      projectPosition,
      z,
      mountingSide,
      label,
    );
  }
}

_ActiveSnapTarget? _snapTargetFromViewportHit(
  ProjectModel project,
  ViewportHitResult hit,
) {
  final kind = hit.workplaneKind;
  final localPosition = hit.localPosition;
  if (kind == null || localPosition == null) {
    return null;
  }

  return switch (kind) {
    MockViewportWorkplaneKind.topLid => _ActiveSnapTarget(
      workplaneId: hit.semanticId,
      workplaneKind: kind,
      localPosition: localPosition,
      projectPosition: localPosition,
      z: 4,
      mountingSide: 'top_lid_inside',
      label: 'крышка ${_formatSnapPoint(localPosition)}',
    ),
    MockViewportWorkplaneKind.frontWall => _ActiveSnapTarget(
      workplaneId: hit.semanticId,
      workplaneKind: kind,
      localPosition: localPosition,
      projectPosition: localPosition,
      z: 4,
      mountingSide: 'free',
      label: 'передняя стенка ${_formatSnapPoint(localPosition)}',
    ),
    MockViewportWorkplaneKind.componentPlacement =>
      _componentPlacementSnapTarget(project, hit, localPosition, kind),
  };
}

_ActiveSnapTarget? _componentPlacementSnapTarget(
  ProjectModel project,
  ViewportHitResult hit,
  Offset localPosition,
  MockViewportWorkplaneKind kind,
) {
  final placement = project.componentPlacements
      .where((placement) => placement.id == hit.semanticId)
      .firstOrNull;
  if (placement == null) {
    return null;
  }

  final rotated = _rotateLocalOffset(
    localPosition,
    _positionAt(placement.rotation, 2),
  );
  final base = Offset(
    _positionAt(placement.position, 0),
    _positionAt(placement.position, 1),
  );
  final projectPosition = base + rotated;

  return _ActiveSnapTarget(
    workplaneId: hit.semanticId,
    workplaneKind: kind,
    localPosition: localPosition,
    projectPosition: projectPosition,
    z: _positionAt(placement.position, 2),
    mountingSide: placement.mountingSide,
    label: 'плата ${_formatSnapPoint(localPosition)}',
  );
}

Offset _rotateLocalOffset(Offset point, double degrees) {
  final radians = degrees * math.pi / 180;
  final cos = math.cos(radians);
  final sin = math.sin(radians);
  return Offset(
    point.dx * cos - point.dy * sin,
    point.dx * sin + point.dy * cos,
  );
}

String _formatSnapPoint(Offset point) {
  return '${_formatNumber(point.dx)} x ${_formatNumber(point.dy)} mm';
}

String _mountingSideLabel(String mountingSide) {
  return switch (mountingSide) {
    'bottom_inside' => 'Внутри на дне',
    'top_lid_inside' => 'На крышке внутри',
    'free' => 'Свободно',
    _ => mountingSide,
  };
}

SelectionModel? _selectionForValidationTarget(
  ProjectModel project,
  String? targetId,
) {
  if (targetId == null || targetId.isEmpty) {
    return null;
  }

  for (final body in project.bodies) {
    if (body.id == targetId) {
      return SelectionModel.enclosure(body.id);
    }
  }

  for (final placement in project.componentPlacements) {
    if (placement.id == targetId) {
      return SelectionModel.componentPlacement(placement.id);
    }
  }

  for (final template in project.componentTemplates) {
    if (template.id == targetId) {
      return SelectionModel.componentTemplate(template.id);
    }
  }

  for (final feature in project.features) {
    if (feature.id == targetId) {
      return SelectionModel.feature(feature.id);
    }
  }

  for (final group in project.featureGroups) {
    if (group.id == targetId) {
      return SelectionModel.featureGroup(group.id);
    }
  }

  for (final body in project.bodies) {
    if (targetId.startsWith('${body.id}.')) {
      return SelectionModel.surface(id: targetId, parentId: body.id);
    }
  }

  for (final placement in project.componentPlacements) {
    if (targetId.startsWith('${placement.id}.')) {
      return SelectionModel.componentPlacement(placement.id);
    }
  }

  for (final template in project.componentTemplates) {
    if (targetId.startsWith('${template.id}.')) {
      return SelectionModel.componentTemplate(template.id);
    }
  }

  for (final feature in project.features) {
    if (targetId.startsWith('${feature.id}.')) {
      return SelectionModel.feature(feature.id);
    }
  }

  for (final group in project.featureGroups) {
    if (targetId.startsWith('${group.id}.')) {
      return SelectionModel.featureGroup(group.id);
    }
  }

  return null;
}

bool _sameJson(Map<String, Object?> left, Map<String, Object?> right) {
  return jsonEncode(left) == jsonEncode(right);
}

String _fingerprintProject(ProjectModel project) {
  return jsonEncode(project.toJson());
}

String _fileName(File file) {
  return file.path.split(Platform.pathSeparator).last;
}

String _suggestedProjectFileName(ProjectModel project) {
  return '${_safeFileName(project.projectName, fallback: 'project')}.enclosure.json';
}

String _suggestedExportFileName(
  ProjectModel project,
  ProjectExportFormat format,
) {
  return '${_safeFileName(project.projectName, fallback: 'project')}.${format.defaultExtension}';
}

String _safeFileName(String value, {required String fallback}) {
  final safeName = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return safeName.isEmpty ? fallback : safeName;
}

Enclosure _defaultEnclosure() {
  return const Enclosure(
    id: 'main_enclosure',
    shape: 'rounded_box',
    size: [120, 70, 28],
    wallThickness: 2,
    cornerRadius: 4,
    lid: LidSpec(type: 'top_screw_lid', clearanceProfile: 'fdm_normal'),
  );
}

ComponentPlacement _defaultComponentPlacement({
  required String id,
  required String templateId,
  required int index,
  _ActiveSnapTarget? snapTarget,
}) {
  return ComponentPlacement(
    id: id,
    templateId: templateId,
    position: [
      snapTarget?.projectPosition.dx ?? index * 8.0,
      snapTarget?.projectPosition.dy ?? 0,
      snapTarget?.z ?? 4,
    ],
    rotation: const [0, 0, 0],
    mountingSide: snapTarget?.mountingSide ?? 'bottom_inside',
    locked: false,
  );
}

const _activeSnapPreviewPlacementId = 'active_snap_component_preview';

ComponentPlacement? _activeSnapProspectivePlacement(
  ProjectModel project,
  _ActiveSnapTarget? snapTarget,
) {
  if (snapTarget == null) {
    return null;
  }

  final template = project.componentTemplates.firstOrNull;
  if (template == null) {
    return null;
  }

  return _defaultComponentPlacement(
    id: _activeSnapPreviewPlacementId,
    templateId: template.id,
    index: project.componentPlacements.length,
    snapTarget: snapTarget,
  );
}

ValidationMessage? _activeSnapPlacementIssue(
  ProjectModel project,
  _ActiveSnapTarget? snapTarget,
) {
  final placement = _activeSnapProspectivePlacement(project, snapTarget);
  if (placement == null) {
    return null;
  }

  return _prospectivePlacementIssue(project, placement);
}

ValidationMessage? _prospectivePlacementIssue(
  ProjectModel project,
  ComponentPlacement placement,
) {
  final report = ProjectSemanticValidator.validate(
    project.replaceComponentPlacement(placement),
  );

  return report.issues
      .where(
        (message) =>
            message.targetId == placement.id ||
            (message.targetId?.startsWith('${placement.id}.') ?? false),
      )
      .firstOrNull;
}

ComponentPlacement _updatedComponentPlacementParameter(
  ComponentPlacement placement,
  String parameterId,
  Object? value,
) {
  return switch (parameterId) {
    'x' => _copyComponentPlacementWithPosition(placement, x: _asDouble(value)),
    'y' => _copyComponentPlacementWithPosition(placement, y: _asDouble(value)),
    'z' => _copyComponentPlacementWithPosition(placement, z: _asDouble(value)),
    'rotationZ' => _copyComponentPlacementWithRotation(
      placement,
      z: _asDouble(value),
    ),
    'mountingSide' => ComponentPlacement(
      id: placement.id,
      templateId: placement.templateId,
      position: placement.position,
      rotation: placement.rotation,
      mountingSide: value is String ? value : placement.mountingSide,
      locked: placement.locked,
      visible: placement.visible,
      metadata: placement.metadata,
    ),
    'locked' => ComponentPlacement(
      id: placement.id,
      templateId: placement.templateId,
      position: placement.position,
      rotation: placement.rotation,
      mountingSide: placement.mountingSide,
      locked: value is bool ? value : placement.locked,
      visible: placement.visible,
      metadata: placement.metadata,
    ),
    'visible' => ComponentPlacement(
      id: placement.id,
      templateId: placement.templateId,
      position: placement.position,
      rotation: placement.rotation,
      mountingSide: placement.mountingSide,
      locked: placement.locked,
      visible: value is bool ? value : placement.visible,
      metadata: placement.metadata,
    ),
    _ => placement,
  };
}

ComponentPlacement _copyComponentPlacementWithPosition(
  ComponentPlacement placement, {
  double? x,
  double? y,
  double? z,
}) {
  return ComponentPlacement(
    id: placement.id,
    templateId: placement.templateId,
    position: [
      x ?? _positionAt(placement.position, 0),
      y ?? _positionAt(placement.position, 1),
      z ?? _positionAt(placement.position, 2),
    ],
    rotation: placement.rotation,
    mountingSide: placement.mountingSide,
    locked: placement.locked,
    visible: placement.visible,
    metadata: placement.metadata,
  );
}

ComponentPlacement _copyComponentPlacementWithRotation(
  ComponentPlacement placement, {
  double? x,
  double? y,
  double? z,
}) {
  return ComponentPlacement(
    id: placement.id,
    templateId: placement.templateId,
    position: placement.position,
    rotation: [
      x ?? _positionAt(placement.rotation, 0),
      y ?? _positionAt(placement.rotation, 1),
      z ?? _positionAt(placement.rotation, 2),
    ],
    mountingSide: placement.mountingSide,
    locked: placement.locked,
    visible: placement.visible,
    metadata: placement.metadata,
  );
}

double _asDouble(Object? value) {
  return value is num ? value.toDouble() : 0;
}

String _nextComponentPlacementId(ProjectModel project, String templateId) {
  final safeTemplateId = _safeIdPart(templateId);
  var index = project.componentPlacements.length + 1;
  while (true) {
    final candidate = '${safeTemplateId}_placement_$index';
    final exists = project.componentPlacements.any(
      (placement) => placement.id == candidate,
    );
    if (!exists) {
      return candidate;
    }
    index += 1;
  }
}

SemanticFeature _defaultUsbCCutoutFeature({
  required String id,
  required String targetSurfaceId,
}) {
  return SemanticFeature(
    id: id,
    type: 'usb_c_cutout',
    targetSurface: targetSurfaceId,
    operation: 'negative',
    parameters: const {
      'width': 10.5,
      'height': 4.2,
      'cornerRadius': 1.0,
      'clearanceProfile': 'fdm_normal',
    },
  );
}

SemanticFeature _usbCCutoutFeatureFromComponent({
  required String id,
  required String targetSurfaceId,
  required ProjectModel project,
  required ComponentPlacement placement,
  required ComponentTemplate template,
  required ComponentFeature componentFeature,
}) {
  final cutout = _componentFeatureCutout(componentFeature);
  final projection = ComponentFeatureSurfaceProjector.projectFeature(
    project: project,
    placement: placement,
    feature: componentFeature,
  );

  return SemanticFeature(
    id: id,
    type: 'usb_c_cutout',
    targetSurface: targetSurfaceId,
    operation: 'negative',
    source: {
      'componentPlacementId': placement.id,
      'componentTemplateId': template.id,
      'componentFeatureId': componentFeature.id,
    },
    placement: {
      'componentPosition': placement.position,
      'componentRotation': placement.rotation,
      if (projection != null)
        ...projection.toPlacementJson()
      else ...{
        'componentFeaturePosition': componentFeature.position,
        if (componentFeature.direction != null)
          'componentFeatureDirection': componentFeature.direction,
      },
    },
    parameters: {
      'width': _mapDouble(cutout, 'width', 10.5),
      'height': _mapDouble(cutout, 'height', 4.2),
      'cornerRadius': _mapDouble(cutout, 'cornerRadius', 1.0),
      'clearanceProfile': _mapString(cutout, 'clearanceProfile', 'fdm_normal'),
    },
  );
}

Map<String, Object?> _componentFeatureCutout(ComponentFeature feature) {
  final cutout = feature.metadata['cutout'];
  if (cutout is Map<Object?, Object?>) {
    return {
      for (final entry in cutout.entries)
        if (entry.key is String) entry.key as String: entry.value,
    };
  }

  return const {};
}

String? _targetSurfaceForComponentFeature(
  ProjectModel project,
  ComponentFeature feature,
) {
  return ComponentFeatureSurfaceProjector.targetSurfaceId(
    project: project,
    feature: feature,
  );
}

double _mapDouble(Map<String, Object?> values, String key, double fallback) {
  final value = values[key];
  return value is num ? value.toDouble() : fallback;
}

String _mapString(Map<String, Object?> values, String key, String fallback) {
  final value = values[key];
  return value is String ? value : fallback;
}

SemanticFeature _defaultGlassRecessFeature({
  required String id,
  required String targetSurfaceId,
}) {
  return SemanticFeature(
    id: id,
    type: 'glass_recess',
    targetSurface: targetSurfaceId,
    operation: 'recess',
    parameters: const {
      'width': 42.0,
      'height': 24.0,
      'recessDepth': 1.2,
      'ledgeWidth': 1.5,
      'cornerRadius': 2.0,
      'insertThickness': 1.0,
      'clearanceProfile': 'fdm_normal',
    },
  );
}

SemanticFeature _defaultCircularCutoutFeature({
  required String id,
  required String targetSurfaceId,
}) {
  return SemanticFeature(
    id: id,
    type: 'circular_cutout',
    targetSurface: targetSurfaceId,
    operation: 'negative',
    parameters: const {
      'diameter': 8.0,
      'depth': 3.0,
      'positionX': 0.0,
      'positionY': 0.0,
      'clearanceProfile': 'fdm_normal',
    },
  );
}

String _nextFeatureId(ProjectModel project, String type) {
  final safeType = _safeIdPart(type);
  var index =
      project.features.where((feature) => feature.type == type).length + 1;
  while (true) {
    final candidate = '${safeType}_$index';
    final exists = project.features.any((feature) => feature.id == candidate);
    if (!exists) {
      return candidate;
    }
    index += 1;
  }
}

FeatureGroup _defaultButtonGroup({
  required String id,
  required String targetSurfaceId,
}) {
  return FeatureGroup(
    id: id,
    type: 'button_group',
    targetSurface: targetSurfaceId,
    pattern: const {'layout': 'diamond', 'count': 4, 'spacing': 14.0},
    itemPrototype: const {
      'type': 'button',
      'shape': 'circle',
      'diameter': 8.0,
      'ringWidth': 1.2,
      'ringProtrusion': 0.45,
      'capDiameter': 7.4,
      'capHeight': 1.2,
      'stemDiameter': 3.0,
      'stemDepth': 2.8,
      'travel': 0.8,
      'switchClearance': 0.3,
      'guideClearance': 0.25,
      'mode': 'plunger',
    },
    placement: const {'anchor': 'center'},
  );
}

FeatureGroup _buttonGroupFromComponentSwitches({
  required String id,
  required String targetSurfaceId,
  required ProjectModel project,
  required ComponentPlacement placement,
  required ComponentTemplate template,
  required List<ComponentFeature> switches,
}) {
  final projections = <String, ComponentFeatureProjection>{};
  for (final switchFeature in switches) {
    final projection = ComponentFeatureSurfaceProjector.projectFeature(
      project: project,
      placement: placement,
      feature: switchFeature,
    );
    if (projection != null) {
      projections[switchFeature.id] = projection;
    }
  }

  return FeatureGroup(
    id: id,
    type: 'button_group',
    targetSurface: targetSurfaceId,
    pattern: {
      'layout': 'from_component_switches',
      'count': switches.length,
      'spacing': 14.0,
      'sourcePlacementId': placement.id,
      'sourceTemplateId': template.id,
      'switchPositions': [
        for (final switchFeature in switches)
          _switchPatternPoint(switchFeature, projections[switchFeature.id]),
      ],
    },
    itemPrototype: const {
      'type': 'button',
      'shape': 'circle',
      'diameter': 8.0,
      'ringWidth': 1.2,
      'ringProtrusion': 0.45,
      'capDiameter': 7.4,
      'capHeight': 1.2,
      'stemDiameter': 3.0,
      'stemDepth': 2.8,
      'travel': 0.8,
      'switchClearance': 0.3,
      'guideClearance': 0.25,
      'mode': 'plunger',
    },
    placement: {
      'anchor': 'component_switch_centers',
      'componentPosition': placement.position,
      'componentRotation': placement.rotation,
    },
  );
}

Map<String, Object?> _switchPatternPoint(
  ComponentFeature switchFeature,
  ComponentFeatureProjection? projection,
) {
  if (projection != null) {
    return projection.toPatternPointJson(id: switchFeature.id);
  }

  return {
    'id': switchFeature.id,
    'position': switchFeature.position,
    if (switchFeature.direction != null) 'direction': switchFeature.direction,
  };
}

FeatureGroup _defaultMountGroup({
  required String id,
  required ComponentPlacement placement,
  required ComponentTemplate template,
}) {
  final firstHole = template.mountingHoles.firstOrNull;
  final screw = firstHole?.screw ?? 'M2';

  return FeatureGroup(
    id: id,
    type: 'standoff_mounts',
    targetSurface: _mountTargetSurfaceFor(placement),
    pattern: {
      'layout': 'from_component_mounting_holes',
      'count': template.mountingHoles.length,
      'sourcePlacementId': placement.id,
      'sourceTemplateId': template.id,
      'holePositions': [
        for (final hole in template.mountingHoles)
          {
            'id': hole.id,
            'position': hole.position,
            'diameter': hole.diameter,
            if (hole.screw != null) 'screw': hole.screw,
          },
      ],
    },
    itemPrototype: {
      'type': 'standoff',
      'diameter': 5.0,
      'height': 4.0,
      'holeDiameter': firstHole?.diameter ?? 2.2,
      'screw': screw,
      'clearanceProfile': 'fdm_normal',
    },
    placement: {
      'anchor': 'component_mounting_holes',
      'componentPlacementId': placement.id,
      'componentPosition': placement.position,
      'componentRotation': placement.rotation,
      'mountingSide': placement.mountingSide,
    },
  );
}

String _mountTargetSurfaceFor(ComponentPlacement placement) {
  return switch (placement.mountingSide) {
    'top_lid_inside' => 'main_enclosure.top_lid.outer',
    'bottom_inside' => 'main_enclosure.bottom_inside',
    _ => 'main_enclosure.bottom_inside',
  };
}

String _nextFeatureGroupId(ProjectModel project, String type) {
  final safeType = _safeIdPart(type);
  var index =
      project.featureGroups.where((group) => group.type == type).length + 1;
  while (true) {
    final candidate = '${safeType}_$index';
    final exists = project.featureGroups.any((group) => group.id == candidate);
    if (!exists) {
      return candidate;
    }
    index += 1;
  }
}

String _safeIdPart(String value) {
  final safe = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return safe.isEmpty ? 'component' : safe;
}

SelectionModel _validSelectionFor(
  ProjectModel project,
  SelectionModel selection,
) {
  final id = selection.id;
  return switch (selection.kind) {
    SelectionKind.workspace => selection,
    SelectionKind.enclosure
        when id != null && project.bodies.any((body) => body.id == id) =>
      selection,
    SelectionKind.surface
        when selection.parentId != null &&
            project.bodies.any((body) => body.id == selection.parentId) =>
      selection,
    SelectionKind.componentPlacement
        when id != null &&
            project.componentPlacements.any(
              (placement) => placement.id == id,
            ) =>
      selection,
    SelectionKind.componentTemplate
        when id != null &&
            project.componentTemplates.any((template) => template.id == id) =>
      selection,
    SelectionKind.feature
        when id != null &&
            project.features.any((feature) => feature.id == id) =>
      selection,
    SelectionKind.featureGroup
        when id != null &&
            project.featureGroups.any((group) => group.id == id) =>
      selection,
    _ => const SelectionModel.workspace(),
  };
}

class _TopToolbar extends StatelessWidget {
  const _TopToolbar({
    required this.projectName,
    required this.canUndo,
    required this.canRedo,
    required this.fileBusy,
    required this.onOpen,
    required this.onSave,
    required this.onExport,
    required this.onUndo,
    required this.onRedo,
  });

  final String projectName;
  final bool canUndo;
  final bool canRedo;
  final bool fileBusy;
  final VoidCallback onOpen;
  final VoidCallback onSave;
  final VoidCallback onExport;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final registry = CommandRegistry.core;
    final commandContext = CommandContext(
      activeScope: CommandScope.workspace,
      canUndo: canUndo,
      canRedo: canRedo,
    );

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.18)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.view_in_ar_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text(
            AppStrings.appTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              projectName,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Spacer(),
          _ToolbarCommand(
            command: registry.byId(CommandIds.undo),
            context: commandContext,
            onPressed: onUndo,
          ),
          _ToolbarCommand(
            command: registry.byId(CommandIds.redo),
            context: commandContext,
            onPressed: onRedo,
          ),
          _ToolbarCommand(
            command: registry.byId(CommandIds.openProject),
            context: commandContext,
            onPressed: fileBusy ? null : onOpen,
          ),
          _ToolbarCommand(
            command: registry.byId(CommandIds.saveProject),
            context: commandContext,
            onPressed: fileBusy ? null : onSave,
          ),
          _ToolbarCommand(
            command: registry.byId(CommandIds.exportProject),
            context: commandContext,
            onPressed: fileBusy ? null : onExport,
          ),
        ],
      ),
    );
  }
}

class _ExportFormatSheet extends StatelessWidget {
  const _ExportFormatSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Экспорт',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _ExportFormatTile(
              key: const ValueKey('export-format-step'),
              format: ProjectExportFormat.step,
              icon: Icons.view_in_ar_outlined,
              extensionLabel: '.step / .stp',
            ),
            _ExportFormatTile(
              key: const ValueKey('export-format-stl'),
              format: ProjectExportFormat.stl,
              icon: Icons.print_outlined,
              extensionLabel: '.stl',
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportFormatTile extends StatelessWidget {
  const _ExportFormatTile({
    super.key,
    required this.format,
    required this.icon,
    required this.extensionLabel,
  });

  final ProjectExportFormat format;
  final IconData icon;
  final String extensionLabel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(format.label),
      trailing: Text(extensionLabel),
      onTap: () => Navigator.of(context).pop(format),
    );
  }
}

class _ToolbarCommand extends StatelessWidget {
  const _ToolbarCommand({
    required this.command,
    required this.context,
    required this.onPressed,
  });

  final AppCommand command;
  final CommandContext context;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = command.isAvailable(this.context) && onPressed != null;

    return Tooltip(
      message: command.label,
      child: IconButton(
        key: ValueKey('toolbar-command-${command.id}'),
        icon: Icon(_iconForCommand(command.icon)),
        iconSize: 20,
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}

typedef _CommandActionFor = VoidCallback? Function(String commandId);

class _ToolRail extends StatelessWidget {
  const _ToolRail({
    required this.commandContext,
    required this.commandActionFor,
  });

  final CommandContext commandContext;
  final _CommandActionFor commandActionFor;

  static const commandIds = [
    CommandIds.createEnclosure,
    CommandIds.placeComponent,
    CommandIds.addUsbC,
    CommandIds.createButtonGroup,
    CommandIds.generateMount,
    CommandIds.generateSlot,
    CommandIds.createGlassRecess,
    CommandIds.generateCase,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final registry = CommandRegistry.core;

    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2226),
        border: Border(
          right: BorderSide(color: theme.dividerColor.withValues(alpha: 0.18)),
        ),
      ),
      child: Column(
        children: [
          for (var index = 0; index < commandIds.length; index++)
            _RailButton(
              command: registry.byId(commandIds[index]),
              commandContext: commandContext,
              onPressed: commandActionFor(commandIds[index]),
            ),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.command,
    required this.commandContext,
    required this.onPressed,
  });

  final AppCommand command;
  final CommandContext commandContext;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = command.isAvailable(commandContext) && onPressed != null;
    final contextual =
        commandContext.activeScope != null &&
        command.scopes.contains(commandContext.activeScope);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: command.label,
        child: IconButton(
          key: ValueKey('rail-command-${command.id}'),
          icon: Icon(_iconForCommand(command.icon)),
          color: contextual && enabled
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          style: IconButton.styleFrom(
            backgroundColor: contextual && enabled
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: enabled ? onPressed : null,
        ),
      ),
    );
  }
}

IconData _iconForCommand(String icon) {
  return switch (icon) {
    'undo' => Icons.undo_rounded,
    'redo' => Icons.redo_rounded,
    'open' => Icons.folder_open_rounded,
    'save' => Icons.save_outlined,
    'export' => Icons.file_download_outlined,
    'enclosure' => Icons.crop_square_rounded,
    'component' => Icons.memory_rounded,
    'port' => Icons.settings_input_component_rounded,
    'button' => Icons.radio_button_checked_rounded,
    'mount' => Icons.construction_rounded,
    'slot' => Icons.inventory_2_outlined,
    'glass' => Icons.crop_16_9_rounded,
    'case' => Icons.cases_rounded,
    'advanced' => Icons.architecture_rounded,
    _ => Icons.circle_outlined,
  };
}

class _ProjectBrowser extends StatelessWidget {
  const _ProjectBrowser({
    required this.project,
    required this.surfaces,
    required this.selection,
    required this.onSelectionChanged,
  });

  final ProjectModel project;
  final List<SelectableSurface> surfaces;
  final SelectionModel selection;
  final ValueChanged<SelectionModel> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 226,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F22),
        border: Border(
          right: BorderSide(color: theme.dividerColor.withValues(alpha: 0.18)),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
        children: [
          _BrowserHeader(label: 'Проект'),
          _BrowserRow(
            icon: Icons.account_tree_rounded,
            title: project.projectName,
            subtitle: '${project.units} · ${project.printerProfile}',
            selected: selection.kind == SelectionKind.workspace,
            onTap: () => onSelectionChanged(const SelectionModel.workspace()),
          ),
          const SizedBox(height: 8),
          _BrowserHeader(label: 'Корпус'),
          for (final body in project.bodies)
            _BrowserRow(
              icon: Icons.crop_square_rounded,
              title: body.id,
              subtitle: body.shape,
              selected:
                  selection.kind == SelectionKind.enclosure &&
                  selection.id == body.id,
              onTap: () =>
                  onSelectionChanged(SelectionModel.enclosure(body.id)),
            ),
          if (surfaces.isNotEmpty) ...[
            const SizedBox(height: 8),
            _BrowserHeader(label: 'Грани'),
            for (final surface in surfaces)
              _BrowserRow(
                icon: Icons.flip_to_front_rounded,
                title: surface.label,
                subtitle: surface.id,
                depth: 1,
                selected:
                    selection.kind == SelectionKind.surface &&
                    selection.id == surface.id,
                onTap: () => onSelectionChanged(
                  SelectionModel.surface(
                    id: surface.id,
                    parentId: _surfaceParentId(project, surface.id),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 8),
          _BrowserHeader(label: 'Компоненты'),
          for (final placement in project.componentPlacements)
            _BrowserRow(
              icon: placement.visible
                  ? Icons.memory_rounded
                  : Icons.visibility_off_rounded,
              title: _templateName(project, placement.templateId),
              subtitle: placement.visible
                  ? placement.id
                  : '${placement.id} · скрыто',
              selected:
                  selection.kind == SelectionKind.componentPlacement &&
                  selection.id == placement.id,
              onTap: () => onSelectionChanged(
                SelectionModel.componentPlacement(placement.id),
              ),
            ),
          for (final template in project.componentTemplates)
            _BrowserRow(
              icon: Icons.developer_board_rounded,
              title: template.name,
              subtitle: 'template',
              depth: 1,
              selected:
                  selection.kind == SelectionKind.componentTemplate &&
                  selection.id == template.id,
              onTap: () => onSelectionChanged(
                SelectionModel.componentTemplate(template.id),
              ),
            ),
          const SizedBox(height: 8),
          _BrowserHeader(label: 'Фичи'),
          for (final feature in project.features)
            _BrowserRow(
              icon: _featureIcon(feature.type),
              title: _featureTitle(feature.type),
              subtitle: feature.id,
              selected:
                  selection.kind == SelectionKind.feature &&
                  selection.id == feature.id,
              onTap: () =>
                  onSelectionChanged(SelectionModel.feature(feature.id)),
            ),
          for (final group in project.featureGroups)
            _BrowserRow(
              icon: Icons.apps_rounded,
              title: _featureTitle(group.type),
              subtitle: group.id,
              selected:
                  selection.kind == SelectionKind.featureGroup &&
                  selection.id == group.id,
              onTap: () =>
                  onSelectionChanged(SelectionModel.featureGroup(group.id)),
            ),
        ],
      ),
    );
  }
}

class _BrowserHeader extends StatelessWidget {
  const _BrowserHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BrowserRow extends StatelessWidget {
  const _BrowserRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.depth = 0,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final int depth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(left: depth * 12, top: 2, bottom: 2),
      child: Material(
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight: selected ? FontWeight.w700 : null,
                        ),
                      ),
                      Text(
                        subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _surfaceParentId(ProjectModel project, String surfaceId) {
  for (final body in project.bodies) {
    if (surfaceId.startsWith('${body.id}.')) {
      return body.id;
    }
  }

  return project.bodies.firstOrNull?.id ?? 'project';
}

String _templateName(ProjectModel project, String templateId) {
  return project.componentTemplates
          .where((template) => template.id == templateId)
          .firstOrNull
          ?.name ??
      templateId;
}

IconData _featureIcon(String type) {
  return switch (type) {
    'usb_c_cutout' => Icons.settings_input_component_rounded,
    'button_group' => Icons.radio_button_checked_rounded,
    'glass_recess' => Icons.crop_square_rounded,
    'circular_cutout' => Icons.radio_button_unchecked_rounded,
    'standoff_mounts' => Icons.construction_rounded,
    _ => Icons.extension_rounded,
  };
}

String _featureTitle(String type) {
  return switch (type) {
    'usb_c_cutout' => 'USB-C',
    'button_group' => 'Группа кнопок',
    'glass_recess' => 'Посадка под стекло',
    'circular_cutout' => 'Круглое отверстие',
    'standoff_mounts' => 'Крепёж',
    _ => type.replaceAll('_', ' '),
  };
}

class _ViewportArea extends StatefulWidget {
  const _ViewportArea({
    required this.project,
    required this.preview,
    required this.selection,
    required this.selectionDetails,
    required this.activeSnapTarget,
    required this.activeSnapPlacementIssue,
    required this.placementDialogCandidate,
    required this.placementDialogCandidateIssue,
    required this.viewportState,
    required this.onOrbit,
    required this.onPan,
    required this.onZoom,
    required this.onFit,
    required this.onViewPreset,
    required this.onHit,
  });

  final ProjectModel project;
  final GeometryPreview? preview;
  final SelectionModel selection;
  final ProjectSelectionDetails selectionDetails;
  final _ActiveSnapTarget? activeSnapTarget;
  final ValidationMessage? activeSnapPlacementIssue;
  final ComponentPlacement? placementDialogCandidate;
  final ValidationMessage? placementDialogCandidateIssue;
  final ViewportState viewportState;
  final ValueChanged<Offset> onOrbit;
  final ValueChanged<Offset> onPan;
  final ValueChanged<double> onZoom;
  final VoidCallback onFit;
  final ValueChanged<ViewportViewPreset> onViewPreset;
  final ValueChanged<ViewportHitResult?> onHit;

  @override
  State<_ViewportArea> createState() => _ViewportAreaState();
}

class _ViewportAreaState extends State<_ViewportArea> {
  static const _hitTester = MockViewportHitTester();

  Offset? _lastPointerPosition;
  Offset? _pointerDownPosition;
  bool _movedSincePointerDown = false;

  void _handlePointerDown(PointerDownEvent event) {
    _lastPointerPosition = event.localPosition;
    _pointerDownPosition = event.localPosition;
    _movedSincePointerDown = false;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final last = _lastPointerPosition;
    _lastPointerPosition = event.localPosition;

    if (last == null || event.buttons == 0) {
      return;
    }

    final delta = event.localPosition - last;
    final downPosition = _pointerDownPosition;
    if (downPosition != null &&
        (event.localPosition - downPosition).distance > 4) {
      _movedSincePointerDown = true;
    }

    if ((event.buttons & kSecondaryMouseButton) != 0 ||
        (event.buttons & kMiddleMouseButton) != 0) {
      widget.onPan(delta);
      return;
    }

    widget.onOrbit(delta);
  }

  void _handlePointerUp(PointerUpEvent event, Size viewportSize) {
    _lastPointerPosition = null;

    if (!_movedSincePointerDown) {
      final bodyDimensions = _mockViewportBodyDimensions(widget.project);
      final workplaneOverlay = _mockWorkplaneOverlay(
        widget.project,
        widget.selection,
      );
      final mockHit = _hitTester.hitTest(
        position: event.localPosition,
        size: viewportSize,
        state: widget.viewportState,
        bodyDimensions: bodyDimensions,
        componentPlacements: _mockComponentPlacementPreviews(widget.project),
        workplaneOverlay: workplaneOverlay,
        features: _mockFeaturePreviews(widget.project),
        featureGroups: _mockFeatureGroupPreviews(widget.project),
      );
      final nativeHit = mockHit?.kind == ViewportHitKind.snapPoint
          ? null
          : _hitTestPreviewMesh(
              previewMesh: widget.preview?.previewMesh,
              position: event.localPosition,
              size: viewportSize,
              state: widget.viewportState,
              project: widget.project,
              bodyDimensions: bodyDimensions,
            );
      widget.onHit(
        mockHit?.kind == ViewportHitKind.snapPoint
            ? mockHit
            : nativeHit ?? mockHit,
      );
    }

    _pointerDownPosition = null;
    _movedSincePointerDown = false;
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _lastPointerPosition = null;
    _pointerDownPosition = null;
    _movedSincePointerDown = false;
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      widget.onZoom(event.scrollDelta.dy);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF151719)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportSize = constraints.biggest;
          final workplaneOverlay = _mockWorkplaneOverlay(
            widget.project,
            widget.selection,
          );
          final activeSnapPlacementPreview = _mockActiveSnapPlacementPreview(
            widget.project,
            widget.activeSnapTarget,
          );
          final placementDialogPreview = _mockPlacementCandidatePreview(
            widget.project,
            widget.placementDialogCandidate,
          );
          final placementCandidatePreview =
              placementDialogPreview ?? activeSnapPlacementPreview;
          final placementCandidateIssue =
              widget.placementDialogCandidateIssue ??
              widget.activeSnapPlacementIssue;
          final hasPreviewMesh = _hasPreviewMesh(widget.preview?.previewMesh);

          return Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _handlePointerDown,
            onPointerMove: _handlePointerMove,
            onPointerUp: (event) => _handlePointerUp(event, viewportSize),
            onPointerCancel: _handlePointerCancel,
            onPointerSignal: _handlePointerSignal,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      key: const ValueKey('mock-viewport-canvas'),
                      painter: _ViewportPainter(
                        colorScheme: theme.colorScheme,
                        previewMesh: widget.preview?.previewMesh,
                        bodyDimensions: _mockViewportBodyDimensions(
                          widget.project,
                        ),
                        componentPlacementPreviews:
                            _mockComponentPlacementPreviews(widget.project),
                        activeSnapPlacementPreview: placementCandidatePreview,
                        activeSnapPlacementIssue: placementCandidateIssue,
                        workplaneOverlay: workplaneOverlay,
                        activeSnapTarget: widget.activeSnapTarget,
                        featurePreviews: _mockFeaturePreviews(widget.project),
                        featureGroupPreviews: _mockFeatureGroupPreviews(
                          widget.project,
                        ),
                        selection: widget.selection,
                        viewportState: widget.viewportState,
                      ),
                    ),
                  ),
                  if (_hasPreviewMesh(widget.preview?.previewMesh))
                    const Positioned(
                      left: 0,
                      top: 0,
                      child: SizedBox(
                        key: ValueKey('geometry-preview-mesh-active'),
                      ),
                    ),
                  if (hasPreviewMesh)
                    const Positioned(
                      left: 0,
                      top: 0,
                      child: SizedBox(
                        key: ValueKey('native-semantic-overlay-mode-active'),
                      ),
                    ),
                  if (hasPreviewMesh &&
                      !_nativeSemanticAnnotationsFocused(widget.selection))
                    const Positioned(
                      left: 0,
                      top: 0,
                      child: SizedBox(
                        key: ValueKey('native-semantic-overlays-muted'),
                      ),
                    ),
                  if (hasPreviewMesh &&
                      _nativeSemanticAnnotationsFocused(widget.selection))
                    const Positioned(
                      left: 0,
                      top: 0,
                      child: SizedBox(
                        key: ValueKey('native-semantic-overlays-focused'),
                      ),
                    ),
                  if (_hasSelectedPreviewSurface(
                    widget.preview?.previewMesh,
                    widget.selection,
                  ))
                    const Positioned(
                      left: 0,
                      top: 0,
                      child: SizedBox(
                        key: ValueKey(
                          'geometry-preview-surface-highlight-active',
                        ),
                      ),
                    ),
                  if (workplaneOverlay != null)
                    const Positioned(
                      left: 0,
                      top: 0,
                      child: SizedBox(
                        key: ValueKey('mock-workplane-overlay-active'),
                      ),
                    ),
                  if (hasPreviewMesh &&
                      workplaneOverlay != null &&
                      !_nativeWorkplaneOverlayFocused(
                        selection: widget.selection,
                        workplane: workplaneOverlay,
                        activeSnapTarget: widget.activeSnapTarget,
                      ))
                    const Positioned(
                      left: 0,
                      top: 0,
                      child: SizedBox(
                        key: ValueKey('native-workplane-overlay-hidden'),
                      ),
                    ),
                  if (hasPreviewMesh &&
                      workplaneOverlay != null &&
                      _nativeWorkplaneOverlayFocused(
                        selection: widget.selection,
                        workplane: workplaneOverlay,
                        activeSnapTarget: widget.activeSnapTarget,
                      ))
                    const Positioned(
                      left: 0,
                      top: 0,
                      child: SizedBox(
                        key: ValueKey('native-workplane-overlay-focused'),
                      ),
                    ),
                  if (placementCandidatePreview != null)
                    const Positioned(
                      left: 0,
                      top: 0,
                      child: SizedBox(
                        key: ValueKey('mock-placement-candidate-preview'),
                      ),
                    ),
                  if (activeSnapPlacementPreview != null &&
                      placementDialogPreview == null)
                    const Positioned(
                      left: 0,
                      top: 0,
                      child: SizedBox(
                        key: ValueKey('mock-active-snap-placement-preview'),
                      ),
                    ),
                  Positioned(
                    left: 18,
                    top: 16,
                    child: _ViewportLabel(
                      icon: Icons.view_quilt_rounded,
                      text: AppStrings.workspaceTitle,
                      detail:
                          '${widget.preview?.backendLabel ?? AppStrings.mockBackend} · '
                          '${widget.viewportState.viewLabel}',
                    ),
                  ),
                  Positioned(
                    right: 18,
                    top: 16,
                    child: _ViewPresetControls(
                      viewportState: widget.viewportState,
                      onFit: widget.onFit,
                      onPreset: widget.onViewPreset,
                    ),
                  ),
                  Positioned(
                    left: 18,
                    bottom: 16,
                    child: _ViewportLabel(
                      icon: Icons.schema_rounded,
                      text: widget.selectionDetails.title,
                      detail: widget.selectionDetails.subtitle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ViewportLabel extends StatelessWidget {
  const _ViewportLabel({
    required this.icon,
    required this.text,
    required this.detail,
  });

  final IconData icon;
  final String text;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xCC1E2226),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium,
                    ),
                    Text(
                      detail,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewPresetControls extends StatelessWidget {
  const _ViewPresetControls({
    required this.viewportState,
    required this.onFit,
    required this.onPreset,
  });

  final ViewportState viewportState;
  final VoidCallback onFit;
  final ValueChanged<ViewportViewPreset> onPreset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presets = [
      ViewportViewPreset.top,
      ViewportViewPreset.front,
      ViewportViewPreset.right,
      ViewportViewPreset.left,
      ViewportViewPreset.iso,
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCC1E2226),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          width: 104,
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final preset in presets)
                _ViewPresetButton(
                  preset: preset,
                  selected: viewportState.isAtPreset(preset),
                  onPressed: () => onPreset(preset),
                ),
              Tooltip(
                message: 'Fit view',
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    key: const ValueKey('viewport-fit-view'),
                    borderRadius: BorderRadius.circular(6),
                    onTap: onFit,
                    child: SizedBox.square(
                      dimension: 32,
                      child: Center(
                        child: Icon(
                          Icons.fit_screen_rounded,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewPresetButton extends StatelessWidget {
  const _ViewPresetButton({
    required this.preset,
    required this.selected,
    required this.onPressed,
  });

  final ViewportViewPreset preset;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Tooltip(
      message: preset.tooltip,
      child: Material(
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          key: ValueKey('viewport-preset-${preset.name}'),
          borderRadius: BorderRadius.circular(6),
          onTap: onPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: selected
                    ? theme.colorScheme.primary.withValues(alpha: 0.82)
                    : theme.dividerColor.withValues(alpha: 0.26),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: SizedBox(
              width: 32,
              height: 26,
              child: Center(
                child: Text(
                  preset.shortLabel,
                  maxLines: 1,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Inspector extends StatelessWidget {
  const _Inspector({
    required this.details,
    required this.project,
    required this.selection,
    required this.activeSnapTarget,
    required this.activeSnapPlacementIssue,
    required this.onPlaceComponentFromSnap,
    required this.onClearSnapTarget,
    required this.onEnclosureParameterChanged,
    required this.onComponentPlacementParameterChanged,
    required this.onFeatureParameterChanged,
    required this.onFeatureGroupParameterChanged,
  });

  final ProjectSelectionDetails details;
  final ProjectModel project;
  final SelectionModel selection;
  final _ActiveSnapTarget? activeSnapTarget;
  final ValidationMessage? activeSnapPlacementIssue;
  final VoidCallback? onPlaceComponentFromSnap;
  final VoidCallback onClearSnapTarget;
  final void Function(String enclosureId, String parameterId, Object? value)
  onEnclosureParameterChanged;
  final void Function(String placementId, String parameterId, Object? value)
  onComponentPlacementParameterChanged;
  final void Function(String featureId, String parameterId, Object? value)
  onFeatureParameterChanged;
  final void Function(String groupId, String parameterId, Object? value)
  onFeatureGroupParameterChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedEnclosure = selection.kind == SelectionKind.enclosure
        ? project.bodies.where((body) => body.id == selection.id).firstOrNull
        : null;
    final selectedComponentPlacement =
        selection.kind == SelectionKind.componentPlacement
        ? project.componentPlacements
              .where((placement) => placement.id == selection.id)
              .firstOrNull
        : null;
    final selectedFeature = selection.kind == SelectionKind.feature
        ? project.features
              .where((feature) => feature.id == selection.id)
              .firstOrNull
        : null;
    final selectedFeatureGroup = selection.kind == SelectionKind.featureGroup
        ? project.featureGroups
              .where((group) => group.id == selection.id)
              .firstOrNull
        : null;

    return Container(
      width: 286,
      decoration: BoxDecoration(
        color: const Color(0xFF202428),
        border: Border(
          left: BorderSide(color: theme.dividerColor.withValues(alpha: 0.18)),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.title,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      details.subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final property in details.properties)
            _InspectorValue(label: property.label, value: property.value),
          if (activeSnapTarget != null) ...[
            const SizedBox(height: 14),
            _ActiveSnapTargetPanel(
              target: activeSnapTarget!,
              placementIssue: activeSnapPlacementIssue,
              onPlaceComponent: onPlaceComponentFromSnap,
              onClear: onClearSnapTarget,
            ),
          ],
          if (selectedEnclosure != null) ...[
            const SizedBox(height: 14),
            _EnclosureParameterEditor(
              enclosure: selectedEnclosure,
              onChanged: (parameterId, value) {
                onEnclosureParameterChanged(
                  selectedEnclosure.id,
                  parameterId,
                  value,
                );
              },
            ),
          ],
          if (selectedComponentPlacement != null) ...[
            const SizedBox(height: 14),
            _ComponentPlacementParameterEditor(
              placement: selectedComponentPlacement,
              onChanged: (parameterId, value) {
                onComponentPlacementParameterChanged(
                  selectedComponentPlacement.id,
                  parameterId,
                  value,
                );
              },
            ),
          ],
          if (selectedFeature != null &&
              _featureParameterSchema(selectedFeature.type) != null) ...[
            const SizedBox(height: 14),
            _FeatureParameterEditor(
              feature: selectedFeature,
              onChanged: (parameterId, value) {
                onFeatureParameterChanged(
                  selectedFeature.id,
                  parameterId,
                  value,
                );
              },
            ),
          ],
          if (selectedFeatureGroup != null &&
              _featureGroupParameterSchema(selectedFeatureGroup.type) !=
                  null) ...[
            const SizedBox(height: 14),
            _FeatureGroupParameterEditor(
              group: selectedFeatureGroup,
              onChanged: (parameterId, value) {
                onFeatureGroupParameterChanged(
                  selectedFeatureGroup.id,
                  parameterId,
                  value,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _ActiveSnapTargetPanel extends StatelessWidget {
  const _ActiveSnapTargetPanel({
    required this.target,
    required this.placementIssue,
    required this.onPlaceComponent,
    required this.onClear,
  });

  final _ActiveSnapTarget target;
  final ValidationMessage? placementIssue;
  final VoidCallback? onPlaceComponent;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      key: const ValueKey('active-snap-target-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: theme.dividerColor.withValues(alpha: 0.18)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.add_location_alt_rounded,
              size: 18,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Точка привязки',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Tooltip(
              message: 'Сбросить точку',
              child: IconButton(
                key: const ValueKey('active-snap-clear'),
                icon: const Icon(Icons.close_rounded),
                iconSize: 18,
                onPressed: onClear,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        _InspectorValue(label: 'Точка', value: target.label),
        _InspectorValue(
          label: 'Позиция',
          value:
              '${_formatNumber(target.projectPosition.dx)} x '
              '${_formatNumber(target.projectPosition.dy)} x '
              '${_formatNumber(target.z)} mm',
        ),
        _InspectorValue(
          label: 'Посадка',
          value: _mountingSideLabel(target.mountingSide),
        ),
        _ActiveSnapPlacementCheck(issue: placementIssue),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const ValueKey('active-snap-place-component'),
            onPressed: onPlaceComponent,
            icon: const Icon(Icons.memory_rounded, size: 18),
            label: const Text('Разместить компонент'),
          ),
        ),
      ],
    );
  }
}

class _ActiveSnapPlacementCheck extends StatelessWidget {
  const _ActiveSnapPlacementCheck({required this.issue});

  final ValidationMessage? issue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasIssue = issue != null;
    final color = hasIssue
        ? _validationSeverityColor(theme, issue!.severity)
        : theme.colorScheme.primary;
    final icon = hasIssue
        ? _validationSeverityIcon(issue!.severity)
        : Icons.check_circle_outline_rounded;

    return Padding(
      key: const ValueKey('active-snap-placement-check'),
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasIssue ? issue!.message : 'Плата помещается в текущий корпус.',
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnclosureParameterEditor extends StatelessWidget {
  const _EnclosureParameterEditor({
    required this.enclosure,
    required this.onChanged,
  });

  final Enclosure enclosure;
  final void Function(String parameterId, Object? value) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final schema = EnclosureParameterAdapter.schema;
    final values = EnclosureParameterAdapter.valuesFrom(enclosure);
    final issues = EnclosureParameterAdapter.validateValues(values);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: theme.dividerColor.withValues(alpha: 0.18)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.tune_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                schema.label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final parameter in schema.parameters) ...[
          if (parameter.kind == ParameterKind.choice)
            _ParameterChoiceField(
              parameter: parameter,
              value: values[parameter.id] as String?,
              onChanged: (value) => onChanged(parameter.id, value),
            )
          else
            _ParameterNumberField(
              parameter: parameter,
              value: values[parameter.id],
              onSubmitted: (value) => onChanged(parameter.id, value),
            ),
          const SizedBox(height: 10),
        ],
        for (final issue in issues)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              issue.message,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

class _ComponentPlacementParameterEditor extends StatelessWidget {
  const _ComponentPlacementParameterEditor({
    required this.placement,
    required this.onChanged,
  });

  final ComponentPlacement placement;
  final void Function(String parameterId, Object? value) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = _componentPlacementParameterValues(placement);
    final issues = _componentPlacementParameterSchema.validate(values);
    final fieldsEnabled = !placement.locked;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: theme.dividerColor.withValues(alpha: 0.18)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.memory_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _componentPlacementParameterSchema.label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final parameter
            in _componentPlacementParameterSchema.parameters) ...[
          if (parameter.kind == ParameterKind.choice)
            _ParameterChoiceField(
              keyPrefix: 'component-placement-param-${placement.id}',
              parameter: parameter,
              value: values[parameter.id] as String?,
              onChanged: (value) => onChanged(parameter.id, value),
              enabled: fieldsEnabled,
            )
          else if (parameter.kind == ParameterKind.boolean)
            _ParameterBoolField(
              keyPrefix: 'component-placement-param-${placement.id}',
              parameter: parameter,
              value: values[parameter.id] == true,
              onChanged: (value) => onChanged(parameter.id, value),
            )
          else
            _ParameterNumberField(
              keyPrefix: 'component-placement-param-${placement.id}',
              parameter: parameter,
              value: values[parameter.id],
              onSubmitted: (value) => onChanged(parameter.id, value),
              enabled: fieldsEnabled,
            ),
          const SizedBox(height: 10),
        ],
        if (placement.locked)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Размещение зафиксировано.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        for (final issue in issues)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              issue.message,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

class _FeatureParameterEditor extends StatelessWidget {
  const _FeatureParameterEditor({
    required this.feature,
    required this.onChanged,
  });

  final SemanticFeature feature;
  final void Function(String parameterId, Object? value) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final schema = _featureParameterSchema(feature.type);
    if (schema == null) {
      return const SizedBox.shrink();
    }

    final values = schema.applyDefaults(feature.parameters);
    final issues = schema.validate(values);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: theme.dividerColor.withValues(alpha: 0.18)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.tune_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                schema.label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final parameter in schema.parameters) ...[
          _ParameterNumberField(
            keyPrefix: 'feature-param-${feature.id}',
            parameter: parameter,
            value: values[parameter.id],
            onSubmitted: (value) => onChanged(parameter.id, value),
          ),
          const SizedBox(height: 10),
        ],
        for (final issue in issues)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              issue.message,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

class _FeatureGroupParameterEditor extends StatelessWidget {
  const _FeatureGroupParameterEditor({
    required this.group,
    required this.onChanged,
  });

  final FeatureGroup group;
  final void Function(String parameterId, Object? value) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final schema = _featureGroupParameterSchema(group.type);
    if (schema == null) {
      return const SizedBox.shrink();
    }

    final values = _featureGroupParameterValues(group, schema);
    final issues = schema.validate(values);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: theme.dividerColor.withValues(alpha: 0.18)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.dashboard_customize_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                schema.label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final parameter in schema.parameters) ...[
          if (parameter.kind == ParameterKind.choice)
            _ParameterChoiceField(
              keyPrefix: 'feature-group-param-${group.id}',
              parameter: parameter,
              value: values[parameter.id] as String?,
              onChanged: (value) => onChanged(parameter.id, value),
            )
          else
            _ParameterNumberField(
              keyPrefix: 'feature-group-param-${group.id}',
              parameter: parameter,
              value: values[parameter.id],
              onSubmitted: (value) => onChanged(parameter.id, value),
            ),
          const SizedBox(height: 10),
        ],
        for (final issue in issues)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              issue.message,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

Map<String, Object?> _componentPlacementParameterValues(
  ComponentPlacement placement,
) {
  return _componentPlacementParameterSchema.applyDefaults({
    'x': _positionAt(placement.position, 0),
    'y': _positionAt(placement.position, 1),
    'z': _positionAt(placement.position, 2),
    'rotationZ': _positionAt(placement.rotation, 2),
    'mountingSide': placement.mountingSide,
    'locked': placement.locked,
    'visible': placement.visible,
  });
}

const _componentPlacementParameterSchema = ParameterSchema(
  id: 'component.placement',
  label: 'Размещение',
  parameters: [
    ParameterDefinition(
      id: 'x',
      label: 'X',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 0.0,
      range: ParameterRange(min: -300, max: 300, step: 0.1),
    ),
    ParameterDefinition(
      id: 'y',
      label: 'Y',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 0.0,
      range: ParameterRange(min: -300, max: 300, step: 0.1),
    ),
    ParameterDefinition(
      id: 'z',
      label: 'Z',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 4.0,
      range: ParameterRange(min: -20, max: 200, step: 0.1),
    ),
    ParameterDefinition(
      id: 'rotationZ',
      label: 'Поворот Z',
      kind: ParameterKind.angle,
      unit: 'deg',
      defaultValue: 0.0,
      range: ParameterRange(min: -180, max: 180, step: 1),
    ),
    ParameterDefinition(
      id: 'mountingSide',
      label: 'Посадка',
      kind: ParameterKind.choice,
      defaultValue: 'bottom_inside',
      options: [
        ParameterOption(id: 'bottom_inside', label: 'Внутри на дне'),
        ParameterOption(id: 'top_lid_inside', label: 'На крышке внутри'),
        ParameterOption(id: 'free', label: 'Свободно'),
      ],
    ),
    ParameterDefinition(
      id: 'locked',
      label: 'Зафиксировать',
      kind: ParameterKind.boolean,
      defaultValue: false,
    ),
    ParameterDefinition(
      id: 'visible',
      label: 'Показывать',
      kind: ParameterKind.boolean,
      defaultValue: true,
    ),
  ],
);

ParameterSchema? _featureParameterSchema(String type) {
  return switch (type) {
    'usb_c_cutout' => _usbCParameterSchema,
    'glass_recess' => _glassRecessParameterSchema,
    'circular_cutout' => _circularCutoutParameterSchema,
    _ => null,
  };
}

const _usbCParameterSchema = ParameterSchema(
  id: 'feature.usb_c_cutout',
  label: 'USB-C',
  parameters: [
    ParameterDefinition(
      id: 'width',
      label: 'Ширина',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 10.5,
      range: ParameterRange(min: 4, max: 30, step: 0.1),
    ),
    ParameterDefinition(
      id: 'height',
      label: 'Высота',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 4.2,
      range: ParameterRange(min: 1, max: 14, step: 0.1),
    ),
    ParameterDefinition(
      id: 'cornerRadius',
      label: 'Радиус',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 1.0,
      range: ParameterRange(min: 0, max: 6, step: 0.1),
    ),
  ],
);

const _glassRecessParameterSchema = ParameterSchema(
  id: 'feature.glass_recess',
  label: 'Посадка под стекло',
  parameters: [
    ParameterDefinition(
      id: 'width',
      label: 'Ширина',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 42.0,
      range: ParameterRange(min: 8, max: 180, step: 0.1),
    ),
    ParameterDefinition(
      id: 'height',
      label: 'Высота',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 24.0,
      range: ParameterRange(min: 8, max: 140, step: 0.1),
    ),
    ParameterDefinition(
      id: 'recessDepth',
      label: 'Глубина',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 1.2,
      range: ParameterRange(min: 0.2, max: 8, step: 0.1),
    ),
    ParameterDefinition(
      id: 'ledgeWidth',
      label: 'Полка',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 1.5,
      range: ParameterRange(min: 0.2, max: 12, step: 0.1),
    ),
    ParameterDefinition(
      id: 'cornerRadius',
      label: 'Радиус',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 2.0,
      range: ParameterRange(min: 0, max: 24, step: 0.1),
    ),
    ParameterDefinition(
      id: 'insertThickness',
      label: 'Стекло',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 1.0,
      range: ParameterRange(min: 0.2, max: 8, step: 0.1),
    ),
  ],
);

const _circularCutoutParameterSchema = ParameterSchema(
  id: 'feature.circular_cutout',
  label: 'Круглое отверстие',
  parameters: [
    ParameterDefinition(
      id: 'diameter',
      label: 'Диаметр',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 8.0,
      range: ParameterRange(min: 1, max: 80, step: 0.1),
    ),
    ParameterDefinition(
      id: 'depth',
      label: 'Глубина',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 3.0,
      range: ParameterRange(min: 0.2, max: 80, step: 0.1),
    ),
    ParameterDefinition(
      id: 'positionX',
      label: 'X',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 0.0,
      range: ParameterRange(min: -150, max: 150, step: 0.1),
    ),
    ParameterDefinition(
      id: 'positionY',
      label: 'Y',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 0.0,
      range: ParameterRange(min: -150, max: 150, step: 0.1),
    ),
  ],
);

enum _FeatureGroupParameterTarget { pattern, itemPrototype }

ParameterSchema? _featureGroupParameterSchema(String type) {
  return switch (type) {
    'button_group' => _buttonGroupParameterSchema,
    'standoff_mounts' => _standoffMountsParameterSchema,
    _ => null,
  };
}

Map<String, Object?> _featureGroupParameterValues(
  FeatureGroup group,
  ParameterSchema schema,
) {
  return schema.applyDefaults({...group.pattern, ...group.itemPrototype});
}

_FeatureGroupParameterTarget? _featureGroupParameterTarget(
  String type,
  String parameterId,
) {
  return switch (type) {
    'button_group' => switch (parameterId) {
      'layout' || 'count' || 'spacing' => _FeatureGroupParameterTarget.pattern,
      'diameter' ||
      'ringWidth' ||
      'ringProtrusion' ||
      'capDiameter' ||
      'capHeight' ||
      'stemDiameter' ||
      'stemDepth' ||
      'travel' ||
      'switchClearance' ||
      'guideClearance' ||
      'mode' => _FeatureGroupParameterTarget.itemPrototype,
      _ => null,
    },
    'standoff_mounts' => switch (parameterId) {
      'diameter' ||
      'holeDiameter' ||
      'height' ||
      'clearanceProfile' => _FeatureGroupParameterTarget.itemPrototype,
      _ => null,
    },
    _ => null,
  };
}

({Map<String, Object?> pattern, Map<String, Object?> itemPrototype})
_normalizeFeatureGroupParameterMaps(
  String type, {
  required Map<String, Object?> pattern,
  required Map<String, Object?> itemPrototype,
}) {
  if (type == 'button_group') {
    final diameter = _featureDouble(itemPrototype, 'diameter', 8).clamp(2, 30);
    final ringWidth = _featureDouble(
      itemPrototype,
      'ringWidth',
      1.2,
    ).clamp(0.2, 8);
    final ringProtrusion = _featureDouble(
      itemPrototype,
      'ringProtrusion',
      0.45,
    ).clamp(0.1, 6);
    final maxCapDiameter = math.max(0.8, diameter.toDouble() - 0.2);
    final capDiameter = _featureDouble(
      itemPrototype,
      'capDiameter',
      math.max(0.8, diameter.toDouble() - 0.6),
    ).clamp(0.8, maxCapDiameter);
    final capHeight = _featureDouble(
      itemPrototype,
      'capHeight',
      1.2,
    ).clamp(0.2, 8);
    final maxStemDiameter = math.max(0.8, capDiameter.toDouble());
    final stemDiameter = _featureDouble(
      itemPrototype,
      'stemDiameter',
      math.min(3.0, maxStemDiameter),
    ).clamp(0.8, maxStemDiameter);
    final stemDepth = _featureDouble(
      itemPrototype,
      'stemDepth',
      2.8,
    ).clamp(0.5, 12);
    final maxTravel = math.max(0.1, stemDepth.toDouble() - 0.1);
    final travel = _featureDouble(
      itemPrototype,
      'travel',
      0.8,
    ).clamp(0.1, maxTravel);
    final maxSwitchClearance = math.max(0.0, stemDepth.toDouble() - travel);
    final switchClearance = _featureDouble(
      itemPrototype,
      'switchClearance',
      0.3,
    ).clamp(0.0, maxSwitchClearance);
    final guideClearance = _featureDouble(
      itemPrototype,
      'guideClearance',
      0.25,
    ).clamp(0.05, 1.5);

    return (
      pattern: pattern,
      itemPrototype: {
        ...itemPrototype,
        'diameter': diameter.toDouble(),
        'ringWidth': ringWidth.toDouble(),
        'ringProtrusion': ringProtrusion.toDouble(),
        'capDiameter': capDiameter.toDouble(),
        'capHeight': capHeight.toDouble(),
        'stemDiameter': stemDiameter.toDouble(),
        'stemDepth': stemDepth.toDouble(),
        'travel': travel.toDouble(),
        'switchClearance': switchClearance.toDouble(),
        'guideClearance': guideClearance.toDouble(),
      },
    );
  }

  if (type != 'standoff_mounts') {
    return (pattern: pattern, itemPrototype: itemPrototype);
  }

  final diameter = _featureDouble(itemPrototype, 'diameter', 5).clamp(3, 20);
  final maxHoleDiameter = math.max(0.8, diameter - 0.8);
  final holeDiameter = _featureDouble(
    itemPrototype,
    'holeDiameter',
    2.2,
  ).clamp(0.8, maxHoleDiameter);

  return (
    pattern: pattern,
    itemPrototype: {
      ...itemPrototype,
      'diameter': diameter.toDouble(),
      'holeDiameter': holeDiameter.toDouble(),
    },
  );
}

const _buttonGroupParameterSchema = ParameterSchema(
  id: 'feature_group.button_group',
  label: 'Группа кнопок',
  parameters: [
    ParameterDefinition(
      id: 'layout',
      label: 'Раскладка',
      kind: ParameterKind.choice,
      defaultValue: 'diamond',
      options: [
        ParameterOption(id: 'from_component_switches', label: 'От компонента'),
        ParameterOption(id: 'diamond', label: 'Ромб'),
        ParameterOption(id: 'row', label: 'Ряд'),
        ParameterOption(id: 'grid', label: 'Сетка'),
      ],
    ),
    ParameterDefinition(
      id: 'count',
      label: 'Кол-во',
      kind: ParameterKind.count,
      defaultValue: 4,
      range: ParameterRange(min: 1, max: 16, step: 1),
    ),
    ParameterDefinition(
      id: 'spacing',
      label: 'Шаг',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 14.0,
      range: ParameterRange(min: 4, max: 60, step: 0.1),
    ),
    ParameterDefinition(
      id: 'diameter',
      label: 'Диаметр',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 8.0,
      range: ParameterRange(min: 2, max: 30, step: 0.1),
    ),
    ParameterDefinition(
      id: 'ringWidth',
      label: 'Ободок',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 1.2,
      range: ParameterRange(min: 0.2, max: 8, step: 0.1),
    ),
    ParameterDefinition(
      id: 'ringProtrusion',
      label: 'Выступ',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 0.45,
      range: ParameterRange(min: 0.1, max: 6, step: 0.05),
    ),
    ParameterDefinition(
      id: 'capDiameter',
      label: 'Колпачок',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 7.4,
      range: ParameterRange(min: 0.8, max: 29.8, step: 0.1),
    ),
    ParameterDefinition(
      id: 'capHeight',
      label: 'Высота кнопки',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 1.2,
      range: ParameterRange(min: 0.2, max: 8, step: 0.1),
    ),
    ParameterDefinition(
      id: 'stemDiameter',
      label: 'Ножка',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 3.0,
      range: ParameterRange(min: 0.8, max: 20, step: 0.1),
    ),
    ParameterDefinition(
      id: 'stemDepth',
      label: 'Глубина ножки',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 2.8,
      range: ParameterRange(min: 0.5, max: 12, step: 0.1),
    ),
    ParameterDefinition(
      id: 'travel',
      label: 'Ход',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 0.8,
      range: ParameterRange(min: 0.1, max: 4, step: 0.05),
    ),
    ParameterDefinition(
      id: 'switchClearance',
      label: 'Зазор до свитча',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 0.3,
      range: ParameterRange(min: 0, max: 3, step: 0.05),
    ),
    ParameterDefinition(
      id: 'guideClearance',
      label: 'Зазор направл.',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 0.25,
      range: ParameterRange(min: 0.05, max: 1.5, step: 0.05),
    ),
    ParameterDefinition(
      id: 'mode',
      label: 'Тип',
      kind: ParameterKind.choice,
      defaultValue: 'plunger',
      options: [
        ParameterOption(id: 'plunger', label: 'Плунжеры'),
        ParameterOption(id: 'cutout', label: 'Только отверстия'),
      ],
    ),
  ],
);

const _standoffMountsParameterSchema = ParameterSchema(
  id: 'feature_group.standoff_mounts',
  label: 'Крепёж',
  parameters: [
    ParameterDefinition(
      id: 'diameter',
      label: 'Стойка',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 5.0,
      range: ParameterRange(min: 3, max: 20, step: 0.1),
    ),
    ParameterDefinition(
      id: 'holeDiameter',
      label: 'Отверстие',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 2.2,
      range: ParameterRange(min: 0.8, max: 19.2, step: 0.1),
    ),
    ParameterDefinition(
      id: 'height',
      label: 'Высота',
      kind: ParameterKind.length,
      unit: 'mm',
      defaultValue: 4.0,
      range: ParameterRange(min: 1, max: 30, step: 0.1),
    ),
    ParameterDefinition(
      id: 'clearanceProfile',
      label: 'Зазор',
      kind: ParameterKind.choice,
      defaultValue: 'fdm_normal',
      options: [
        ParameterOption(id: 'fdm_normal', label: 'FDM обычный'),
        ParameterOption(id: 'fdm_loose', label: 'FDM свободный'),
        ParameterOption(id: 'resin_normal', label: 'Resin обычный'),
      ],
    ),
  ],
);

class _CreateEnclosureDialog extends StatefulWidget {
  const _CreateEnclosureDialog({required this.initialEnclosure});

  final Enclosure initialEnclosure;

  @override
  State<_CreateEnclosureDialog> createState() => _CreateEnclosureDialogState();
}

class _CreateEnclosureDialogState extends State<_CreateEnclosureDialog> {
  late Map<String, Object?> _values;

  @override
  void initState() {
    super.initState();
    _values = EnclosureParameterAdapter.valuesFrom(widget.initialEnclosure);
  }

  void _updateValue(String id, Object? value) {
    setState(() {
      _values = EnclosureParameterAdapter.schema.applyDefaults({
        ..._values,
        id: value,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final schema = EnclosureParameterAdapter.schema;
    final issues = EnclosureParameterAdapter.validateValues(_values);

    return AlertDialog(
      title: const Text('Создать корпус'),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final parameter in schema.parameters) ...[
                if (parameter.kind == ParameterKind.choice)
                  _ParameterChoiceField(
                    keyPrefix: 'create-enclosure-param',
                    parameter: parameter,
                    value: _values[parameter.id] as String?,
                    onChanged: (value) => _updateValue(parameter.id, value),
                  )
                else
                  _ParameterNumberField(
                    keyPrefix: 'create-enclosure-param',
                    parameter: parameter,
                    value: _values[parameter.id],
                    onChanged: (value) => _updateValue(parameter.id, value),
                    onSubmitted: (value) => _updateValue(parameter.id, value),
                  ),
                const SizedBox(height: 10),
              ],
              for (final issue in issues)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      issue.message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('create-enclosure-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          key: const ValueKey('create-enclosure-confirm'),
          onPressed: issues.isEmpty
              ? () => Navigator.of(
                  context,
                ).pop(Map<String, Object?>.from(_values))
              : null,
          child: const Text('Создать'),
        ),
      ],
    );
  }
}

class _PlaceComponentDialog extends StatefulWidget {
  const _PlaceComponentDialog({
    required this.project,
    required this.templates,
    required this.initialPlacement,
    required this.onCandidateChanged,
    this.snapTarget,
    this.snapHint,
  });

  final ProjectModel project;
  final List<ComponentTemplate> templates;
  final ComponentPlacement initialPlacement;
  final ValueChanged<ComponentPlacement> onCandidateChanged;
  final _ActiveSnapTarget? snapTarget;
  final String? snapHint;

  @override
  State<_PlaceComponentDialog> createState() => _PlaceComponentDialogState();
}

class _PlaceComponentDialogState extends State<_PlaceComponentDialog> {
  late String _templateId;
  late double _x;
  late double _y;
  late double _z;
  late double _rotationZ;
  late String _anchorId;
  late bool _snapAnchorLocked;
  late String _mountingSide;
  late bool _locked;

  static const _centerAnchorId = 'center';

  static const _mountingSides = [
    _MountingSideOption('bottom_inside', 'Внутри на дне'),
    _MountingSideOption('top_lid_inside', 'На крышке внутри'),
    _MountingSideOption('free', 'Свободно'),
  ];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPlacement;
    _templateId = initial.templateId;
    _x = _positionAt(initial.position, 0);
    _y = _positionAt(initial.position, 1);
    _z = _positionAt(initial.position, 2);
    _rotationZ = _positionAt(initial.rotation, 2);
    _anchorId = _centerAnchorId;
    _snapAnchorLocked = widget.snapTarget != null;
    _mountingSide = initial.mountingSide;
    _locked = initial.locked;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCandidateChanged(_candidatePlacement);
    });
  }

  void _updateCandidate(VoidCallback update) {
    setState(update);
    widget.onCandidateChanged(_candidatePlacement);
  }

  void _applyQuickPreset(_PlacementQuickPreset preset) {
    FocusManager.instance.primaryFocus?.unfocus();
    _updateCandidate(() {
      _breakSnapAnchorLock();
      final x = preset.x;
      if (x != null) {
        _x = x;
      }

      final y = preset.y;
      if (y != null) {
        _y = y;
      }
    });
  }

  void _rotateCandidate(double delta) {
    FocusManager.instance.primaryFocus?.unfocus();
    _updateCandidate(() {
      _rotationZ = _normalizeRotationZ(_rotationZ + delta);
      _applySnapAnchorIfLocked();
    });
  }

  void _selectAnchor(String anchorId) {
    _updateCandidate(() {
      _anchorId = anchorId;
      _snapAnchorLocked = widget.snapTarget != null;
      _applySnapAnchorIfLocked();
    });
  }

  void _breakSnapAnchorLock() {
    _anchorId = _centerAnchorId;
    _snapAnchorLocked = false;
  }

  void _applySnapAnchorIfLocked() {
    final snapTarget = widget.snapTarget;
    if (!_snapAnchorLocked || snapTarget == null) {
      return;
    }

    final anchor = _selectedAnchor;
    final offset = _rotateLocalOffset(anchor.offset, _rotationZ);
    _x = snapTarget.projectPosition.dx - offset.dx;
    _y = snapTarget.projectPosition.dy - offset.dy;
  }

  @override
  Widget build(BuildContext context) {
    final candidatePlacement = _candidatePlacement;
    final selectedTemplate = _selectedTemplate;
    final placementIssue = _prospectivePlacementIssue(
      widget.project,
      candidatePlacement,
    );

    return AlertDialog(
      title: const Text('Разместить компонент'),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.snapHint != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Точка: ${widget.snapHint}',
                    key: const ValueKey('place-component-snap-hint'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              DropdownButtonFormField<String>(
                key: const ValueKey('place-component-template'),
                initialValue: _templateId,
                isExpanded: true,
                items: [
                  for (final template in widget.templates)
                    DropdownMenuItem(
                      value: template.id,
                      child: Text(template.name),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _updateCandidate(() {
                      _templateId = value;
                      _anchorId = _centerAnchorId;
                      _snapAnchorLocked = widget.snapTarget != null;
                      _applySnapAnchorIfLocked();
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Шаблон',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                ),
              ),
              _ComponentTemplateSummary(template: selectedTemplate),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('place-component-x'),
                      label: 'X',
                      value: _x,
                      onChanged: (value) => _updateCandidate(() {
                        _breakSnapAnchorLock();
                        _x = value;
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('place-component-y'),
                      label: 'Y',
                      value: _y,
                      onChanged: (value) => _updateCandidate(() {
                        _breakSnapAnchorLock();
                        _y = value;
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('place-component-z'),
                      label: 'Z',
                      value: _z,
                      onChanged: (value) => _updateCandidate(() => _z = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _PlacementQuickActions(
                presets: _quickPresets,
                onSelected: _applyQuickPreset,
              ),
              const SizedBox(height: 10),
              _PlacementRotationControl(
                value: _rotationZ,
                onChanged: (value) => _updateCandidate(() {
                  _rotationZ = value;
                  _applySnapAnchorIfLocked();
                }),
                onRotateLeft: () => _rotateCandidate(-90),
                onRotateRight: () => _rotateCandidate(90),
              ),
              if (widget.snapTarget != null) ...[
                const SizedBox(height: 10),
                _PlacementAnchorSelector(
                  anchors: _placementAnchors,
                  value: _selectedAnchor.id,
                  onChanged: _selectAnchor,
                ),
              ],
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                key: const ValueKey('place-component-side'),
                initialValue: _mountingSide,
                isExpanded: true,
                items: [
                  for (final side in _mountingSides)
                    DropdownMenuItem(value: side.id, child: Text(side.label)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _updateCandidate(() {
                      _mountingSide = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Посадка',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              CheckboxListTile(
                key: const ValueKey('place-component-locked'),
                value: _locked,
                onChanged: (value) =>
                    _updateCandidate(() => _locked = value ?? false),
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Зафиксировать'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              _PlacementDialogCheck(issue: placementIssue),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('place-component-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          key: const ValueKey('place-component-confirm'),
          onPressed: () => Navigator.of(context).pop(candidatePlacement),
          child: const Text('Разместить'),
        ),
      ],
    );
  }

  ComponentPlacement get _candidatePlacement {
    return ComponentPlacement(
      id: widget.initialPlacement.id,
      templateId: _templateId,
      position: [_x, _y, _z],
      rotation: [
        _positionAt(widget.initialPlacement.rotation, 0),
        _positionAt(widget.initialPlacement.rotation, 1),
        _rotationZ,
      ],
      mountingSide: _mountingSide,
      locked: _locked,
      visible: widget.initialPlacement.visible,
    );
  }

  ComponentTemplate? get _selectedTemplate {
    return widget.templates
        .where((template) => template.id == _templateId)
        .firstOrNull;
  }

  List<_ComponentPlacementAnchor> get _placementAnchors {
    final template = _selectedTemplate;
    if (template == null) {
      return const [_ComponentPlacementAnchor.center];
    }

    return _componentPlacementAnchors(template);
  }

  _ComponentPlacementAnchor get _selectedAnchor {
    return _placementAnchors
            .where((anchor) => anchor.id == _anchorId)
            .firstOrNull ??
        _ComponentPlacementAnchor.center;
  }

  List<_PlacementQuickPreset> get _quickPresets {
    final template = _selectedTemplate;
    final enclosure = widget.project.bodies.firstOrNull;
    if (template == null || enclosure == null) {
      return const [
        _PlacementQuickPreset(
          id: 'center',
          tooltip: 'Поставить в центр',
          icon: Icons.center_focus_strong_rounded,
          x: 0,
          y: 0,
        ),
      ];
    }

    final innerWidth = _innerEnclosureSize(enclosure, 0, 120);
    final innerDepth = _innerEnclosureSize(enclosure, 1, 70);
    final outline = template.board.outline;
    final xEdge = _quickPlacementEdgeOffset(innerWidth, outline.width);
    final yEdge = _quickPlacementEdgeOffset(innerDepth, outline.height);

    return [
      const _PlacementQuickPreset(
        id: 'center',
        tooltip: 'Поставить в центр',
        icon: Icons.center_focus_strong_rounded,
        x: 0,
        y: 0,
      ),
      _PlacementQuickPreset(
        id: 'left',
        tooltip: 'Сдвинуть левее',
        icon: Icons.keyboard_arrow_left_rounded,
        x: -xEdge,
      ),
      _PlacementQuickPreset(
        id: 'right',
        tooltip: 'Сдвинуть правее',
        icon: Icons.keyboard_arrow_right_rounded,
        x: xEdge,
      ),
      _PlacementQuickPreset(
        id: 'front',
        tooltip: 'Сдвинуть к передней стенке',
        icon: Icons.keyboard_arrow_down_rounded,
        y: -yEdge,
      ),
      _PlacementQuickPreset(
        id: 'back',
        tooltip: 'Сдвинуть к задней стенке',
        icon: Icons.keyboard_arrow_up_rounded,
        y: yEdge,
      ),
    ];
  }
}

class _ComponentTemplateSummary extends StatelessWidget {
  const _ComponentTemplateSummary({required this.template});

  final ComponentTemplate? template;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final template = this.template;
    if (template == null) {
      return Padding(
        key: const ValueKey('place-component-template-summary'),
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          'Шаблон компонента не найден.',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      );
    }

    final outline = template.board.outline;
    return Padding(
      key: const ValueKey('place-component-template-summary'),
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(
            Icons.developer_board_rounded,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Плата ${_formatNumber(outline.width)} x '
              '${_formatNumber(outline.height)} x '
              '${_formatNumber(template.board.thickness)} mm',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlacementQuickPreset {
  const _PlacementQuickPreset({
    required this.id,
    required this.tooltip,
    required this.icon,
    this.x,
    this.y,
  });

  final String id;
  final String tooltip;
  final IconData icon;
  final double? x;
  final double? y;
}

class _PlacementQuickActions extends StatelessWidget {
  const _PlacementQuickActions({
    required this.presets,
    required this.onSelected,
  });

  final List<_PlacementQuickPreset> presets;
  final ValueChanged<_PlacementQuickPreset> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Быстрая позиция',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final preset in presets)
                IconButton.outlined(
                  key: ValueKey('place-component-preset-${preset.id}'),
                  tooltip: preset.tooltip,
                  onPressed: () => onSelected(preset),
                  icon: Icon(preset.icon, size: 18),
                  constraints: const BoxConstraints.tightFor(
                    width: 36,
                    height: 36,
                  ),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlacementRotationControl extends StatelessWidget {
  const _PlacementRotationControl({
    required this.value,
    required this.onChanged,
    required this.onRotateLeft,
    required this.onRotateRight,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DialogNumberField(
            key: const ValueKey('place-component-rotation-z'),
            label: 'Поворот Z',
            value: value,
            suffixText: 'deg',
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          key: const ValueKey('place-component-rotate-left'),
          tooltip: 'Повернуть на 90 против часовой',
          onPressed: onRotateLeft,
          icon: const Icon(Icons.rotate_left_rounded, size: 18),
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(width: 6),
        IconButton.outlined(
          key: const ValueKey('place-component-rotate-right'),
          tooltip: 'Повернуть на 90 по часовой',
          onPressed: onRotateRight,
          icon: const Icon(Icons.rotate_right_rounded, size: 18),
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class _PlacementAnchorSelector extends StatelessWidget {
  const _PlacementAnchorSelector({
    required this.anchors,
    required this.value,
    required this.onChanged,
  });

  final List<_ComponentPlacementAnchor> anchors;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: const ValueKey('place-component-anchor'),
      initialValue: value,
      isExpanded: true,
      items: [
        for (final anchor in anchors)
          DropdownMenuItem(value: anchor.id, child: Text(anchor.label)),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
      decoration: InputDecoration(
        labelText: 'Якорь к точке',
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      ),
    );
  }
}

class _ComponentPlacementAnchor {
  const _ComponentPlacementAnchor({
    required this.id,
    required this.label,
    required this.offset,
  });

  static const center = _ComponentPlacementAnchor(
    id: 'center',
    label: 'Центр платы',
    offset: Offset.zero,
  );

  final String id;
  final String label;
  final Offset offset;
}

List<_ComponentPlacementAnchor> _componentPlacementAnchors(
  ComponentTemplate template,
) {
  return [
    _ComponentPlacementAnchor.center,
    for (final hole in template.mountingHoles)
      _ComponentPlacementAnchor(
        id: 'hole:${hole.id}',
        label: 'Отверстие ${hole.id}',
        offset: Offset(
          _positionAt(hole.position, 0),
          _positionAt(hole.position, 1),
        ),
      ),
    for (final feature in template.features)
      _ComponentPlacementAnchor(
        id: 'feature:${feature.id}',
        label: '${_componentFeatureAnchorLabel(feature.type)} ${feature.id}',
        offset: Offset(
          _positionAt(feature.position, 0),
          _positionAt(feature.position, 1),
        ),
      ),
  ];
}

String _componentFeatureAnchorLabel(String type) {
  return switch (type) {
    'usb_c' => 'USB-C',
    'switch' => 'Кнопка',
    'screen' => 'Экран',
    'led' => 'LED',
    _ => type,
  };
}

double _innerEnclosureSize(Enclosure enclosure, int index, double fallback) {
  final size = enclosure.size.length > index ? enclosure.size[index] : fallback;
  return math.max(0, size - enclosure.wallThickness * 2);
}

double _quickPlacementEdgeOffset(double innerSize, double footprintSize) {
  const inset = 8.0;
  final offset = (innerSize - footprintSize) / 2 - inset;
  return math.max(0, offset);
}

double _normalizeRotationZ(double value) {
  var normalized = value % 360;
  if (normalized > 180) {
    normalized -= 360;
  } else if (normalized <= -180) {
    normalized += 360;
  }
  return normalized;
}

class _PlacementDialogCheck extends StatelessWidget {
  const _PlacementDialogCheck({required this.issue});

  final ValidationMessage? issue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasIssue = issue != null;
    final color = hasIssue
        ? _validationSeverityColor(theme, issue!.severity)
        : theme.colorScheme.primary;
    final icon = hasIssue
        ? _validationSeverityIcon(issue!.severity)
        : Icons.check_circle_outline_rounded;

    return Padding(
      key: const ValueKey('place-component-fit-check'),
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasIssue ? issue!.message : 'Плата помещается в текущий корпус.',
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsbCCutoutDialog extends StatefulWidget {
  const _UsbCCutoutDialog({required this.initialFeature});

  final SemanticFeature initialFeature;

  @override
  State<_UsbCCutoutDialog> createState() => _UsbCCutoutDialogState();
}

class _UsbCCutoutDialogState extends State<_UsbCCutoutDialog> {
  late double _width;
  late double _height;
  late double _cornerRadius;
  late String _clearanceProfile;

  static const _profiles = [
    _ClearanceProfileOption('fdm_normal', 'FDM обычный'),
    _ClearanceProfileOption('fdm_loose', 'FDM свободный'),
    _ClearanceProfileOption('resin_normal', 'Resin обычный'),
  ];

  @override
  void initState() {
    super.initState();
    final parameters = widget.initialFeature.parameters;
    _width = _featureDouble(parameters, 'width', 10.5);
    _height = _featureDouble(parameters, 'height', 4.2);
    _cornerRadius = _featureDouble(parameters, 'cornerRadius', 1.0);
    _clearanceProfile = _featureString(
      parameters,
      'clearanceProfile',
      'fdm_normal',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить USB-C'),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('usb-c-width'),
                      label: 'Ширина',
                      value: _width,
                      onChanged: (value) => setState(() => _width = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('usb-c-height'),
                      label: 'Высота',
                      value: _height,
                      onChanged: (value) => setState(() => _height = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _DialogNumberField(
                key: const ValueKey('usb-c-corner-radius'),
                label: 'Радиус',
                value: _cornerRadius,
                onChanged: (value) => setState(() => _cornerRadius = value),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                key: const ValueKey('usb-c-clearance-profile'),
                initialValue: _clearanceProfile,
                isExpanded: true,
                items: [
                  for (final profile in _profiles)
                    DropdownMenuItem(
                      value: profile.id,
                      child: Text(profile.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _clearanceProfile = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Зазор',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('usb-c-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          key: const ValueKey('usb-c-confirm'),
          onPressed: () => Navigator.of(context).pop(
            SemanticFeature(
              id: widget.initialFeature.id,
              type: widget.initialFeature.type,
              targetSurface: widget.initialFeature.targetSurface,
              operation: widget.initialFeature.operation,
              source: widget.initialFeature.source,
              placement: widget.initialFeature.placement,
              metadata: widget.initialFeature.metadata,
              parameters: {
                'width': _clampDouble(_width, 4, 30),
                'height': _clampDouble(_height, 1, 14),
                'cornerRadius': _clampDouble(_cornerRadius, 0, 6),
                'clearanceProfile': _clearanceProfile,
              },
            ),
          ),
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}

class _CircularCutoutDialog extends StatefulWidget {
  const _CircularCutoutDialog({required this.initialFeature});

  final SemanticFeature initialFeature;

  @override
  State<_CircularCutoutDialog> createState() => _CircularCutoutDialogState();
}

class _CircularCutoutDialogState extends State<_CircularCutoutDialog> {
  late double _diameter;
  late double _depth;
  late double _positionX;
  late double _positionY;
  late String _clearanceProfile;

  static const _profiles = [
    _ClearanceProfileOption('fdm_normal', 'FDM обычный'),
    _ClearanceProfileOption('fdm_loose', 'FDM свободный'),
    _ClearanceProfileOption('resin_normal', 'Resin обычный'),
  ];

  @override
  void initState() {
    super.initState();
    final parameters = widget.initialFeature.parameters;
    _diameter = _featureDouble(parameters, 'diameter', 8.0);
    _depth = _featureDouble(parameters, 'depth', 3.0);
    _positionX = _featureDouble(parameters, 'positionX', 0.0);
    _positionY = _featureDouble(parameters, 'positionY', 0.0);
    _clearanceProfile = _featureString(
      parameters,
      'clearanceProfile',
      'fdm_normal',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Круглое отверстие'),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('circular-cutout-diameter'),
                      label: 'Диаметр',
                      value: _diameter,
                      onChanged: (value) => setState(() => _diameter = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('circular-cutout-depth'),
                      label: 'Глубина',
                      value: _depth,
                      onChanged: (value) => setState(() => _depth = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('circular-cutout-position-x'),
                      label: 'X',
                      value: _positionX,
                      onChanged: (value) => setState(() => _positionX = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('circular-cutout-position-y'),
                      label: 'Y',
                      value: _positionY,
                      onChanged: (value) => setState(() => _positionY = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                key: const ValueKey('circular-cutout-clearance-profile'),
                initialValue: _clearanceProfile,
                isExpanded: true,
                items: [
                  for (final profile in _profiles)
                    DropdownMenuItem(
                      value: profile.id,
                      child: Text(profile.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _clearanceProfile = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Зазор',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('circular-cutout-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          key: const ValueKey('circular-cutout-confirm'),
          onPressed: () => Navigator.of(context).pop(
            SemanticFeature(
              id: widget.initialFeature.id,
              type: widget.initialFeature.type,
              targetSurface: widget.initialFeature.targetSurface,
              operation: widget.initialFeature.operation,
              source: widget.initialFeature.source,
              placement: widget.initialFeature.placement,
              metadata: widget.initialFeature.metadata,
              parameters: {
                'diameter': _clampDouble(_diameter, 1, 80),
                'depth': _clampDouble(_depth, 0.2, 80),
                'positionX': _clampDouble(_positionX, -150, 150),
                'positionY': _clampDouble(_positionY, -150, 150),
                'clearanceProfile': _clearanceProfile,
              },
            ),
          ),
          child: const Text('Создать'),
        ),
      ],
    );
  }
}

class _ButtonGroupDialog extends StatefulWidget {
  const _ButtonGroupDialog({required this.initialGroup});

  final FeatureGroup initialGroup;

  @override
  State<_ButtonGroupDialog> createState() => _ButtonGroupDialogState();
}

class _ButtonGroupDialogState extends State<_ButtonGroupDialog> {
  late String _layout;
  late double _count;
  late double _diameter;
  late double _ringWidth;
  late double _ringProtrusion;
  late double _capDiameter;
  late double _capHeight;
  late double _stemDiameter;
  late double _stemDepth;
  late double _travel;
  late double _switchClearance;
  late double _guideClearance;
  late double _spacing;
  late String _mode;

  static const _layouts = [
    _ButtonLayoutOption('from_component_switches', 'От компонента'),
    _ButtonLayoutOption('diamond', 'Ромб'),
    _ButtonLayoutOption('row', 'Ряд'),
    _ButtonLayoutOption('grid', 'Сетка'),
  ];

  static const _modes = [
    _ButtonModeOption('plunger', 'Плунжеры'),
    _ButtonModeOption('cutout', 'Только отверстия'),
  ];

  @override
  void initState() {
    super.initState();
    final group = widget.initialGroup;
    _layout = _featureString(group.pattern, 'layout', 'diamond');
    _count = _featureDouble(group.pattern, 'count', 4);
    _spacing = _featureDouble(group.pattern, 'spacing', 14);
    _diameter = _featureDouble(group.itemPrototype, 'diameter', 8);
    _ringWidth = _featureDouble(group.itemPrototype, 'ringWidth', 1.2);
    _ringProtrusion = _featureDouble(
      group.itemPrototype,
      'ringProtrusion',
      0.45,
    );
    _capDiameter = _featureDouble(group.itemPrototype, 'capDiameter', 7.4);
    _capHeight = _featureDouble(group.itemPrototype, 'capHeight', 1.2);
    _stemDiameter = _featureDouble(group.itemPrototype, 'stemDiameter', 3.0);
    _stemDepth = _featureDouble(group.itemPrototype, 'stemDepth', 2.8);
    _travel = _featureDouble(group.itemPrototype, 'travel', 0.8);
    _switchClearance = _featureDouble(
      group.itemPrototype,
      'switchClearance',
      0.3,
    );
    _guideClearance = _featureDouble(
      group.itemPrototype,
      'guideClearance',
      0.25,
    );
    _mode = _featureString(group.itemPrototype, 'mode', 'plunger');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Группа кнопок'),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                key: const ValueKey('button-group-layout'),
                initialValue: _layout,
                isExpanded: true,
                items: [
                  for (final layout in _layouts)
                    DropdownMenuItem(
                      value: layout.id,
                      child: Text(layout.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _layout = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Раскладка',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('button-group-count'),
                      label: 'Кол-во',
                      value: _count,
                      suffixText: null,
                      onChanged: (value) => setState(() => _count = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('button-group-diameter'),
                      label: 'Диаметр',
                      value: _diameter,
                      onChanged: (value) => setState(() => _diameter = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _DialogNumberField(
                key: const ValueKey('button-group-spacing'),
                label: 'Шаг',
                value: _spacing,
                onChanged: (value) => setState(() => _spacing = value),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('button-group-ring-width'),
                      label: 'Ободок',
                      value: _ringWidth,
                      onChanged: (value) => setState(() => _ringWidth = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('button-group-ring-protrusion'),
                      label: 'Выступ',
                      value: _ringProtrusion,
                      onChanged: (value) =>
                          setState(() => _ringProtrusion = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('button-group-cap-diameter'),
                      label: 'Колпачок',
                      value: _capDiameter,
                      onChanged: (value) =>
                          setState(() => _capDiameter = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('button-group-cap-height'),
                      label: 'Высота',
                      value: _capHeight,
                      onChanged: (value) => setState(() => _capHeight = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('button-group-stem-diameter'),
                      label: 'Ножка',
                      value: _stemDiameter,
                      onChanged: (value) =>
                          setState(() => _stemDiameter = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('button-group-stem-depth'),
                      label: 'Глубина',
                      value: _stemDepth,
                      onChanged: (value) => setState(() => _stemDepth = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('button-group-travel'),
                      label: 'Ход',
                      value: _travel,
                      onChanged: (value) => setState(() => _travel = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('button-group-switch-clearance'),
                      label: 'Зазор',
                      value: _switchClearance,
                      onChanged: (value) =>
                          setState(() => _switchClearance = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _DialogNumberField(
                key: const ValueKey('button-group-guide-clearance'),
                label: 'Зазор направляющей',
                value: _guideClearance,
                onChanged: (value) => setState(() => _guideClearance = value),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                key: const ValueKey('button-group-mode'),
                initialValue: _mode,
                isExpanded: true,
                items: [
                  for (final mode in _modes)
                    DropdownMenuItem(value: mode.id, child: Text(mode.label)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _mode = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Тип',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('button-group-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          key: const ValueKey('button-group-confirm'),
          onPressed: () => Navigator.of(context).pop(
            FeatureGroup(
              id: widget.initialGroup.id,
              type: widget.initialGroup.type,
              targetSurface: widget.initialGroup.targetSurface,
              pattern: {
                ...widget.initialGroup.pattern,
                'layout': _layout,
                'count': _clampDouble(_count, 1, 16).round(),
                'spacing': _clampDouble(_spacing, 4, 60),
              },
              itemPrototype: {
                ...widget.initialGroup.itemPrototype,
                'type': 'button',
                'shape': 'circle',
                'diameter': _clampDouble(_diameter, 2, 30),
                'ringWidth': _clampDouble(_ringWidth, 0.2, 8),
                'ringProtrusion': _clampDouble(_ringProtrusion, 0.1, 6),
                'capDiameter': _clampDouble(
                  _capDiameter,
                  0.8,
                  math.max(0.8, _diameter - 0.2),
                ),
                'capHeight': _clampDouble(_capHeight, 0.2, 8),
                'stemDiameter': _clampDouble(
                  _stemDiameter,
                  0.8,
                  math.max(0.8, math.min(_capDiameter, _diameter - 0.2)),
                ),
                'stemDepth': _clampDouble(_stemDepth, 0.5, 12),
                'travel': _clampDouble(
                  _travel,
                  0.1,
                  math.max(0.1, _stemDepth - 0.1),
                ),
                'switchClearance': _clampDouble(
                  _switchClearance,
                  0,
                  math.max(0, _stemDepth - _travel),
                ),
                'guideClearance': _clampDouble(_guideClearance, 0.05, 1.5),
                'mode': _mode,
              },
              placement: widget.initialGroup.placement,
              overrides: widget.initialGroup.overrides,
              metadata: widget.initialGroup.metadata,
            ),
          ),
          child: const Text('Создать'),
        ),
      ],
    );
  }
}

class _ButtonLayoutOption {
  const _ButtonLayoutOption(this.id, this.label);

  final String id;
  final String label;
}

class _ButtonModeOption {
  const _ButtonModeOption(this.id, this.label);

  final String id;
  final String label;
}

class _MountGenerationDialog extends StatefulWidget {
  const _MountGenerationDialog({
    required this.componentName,
    required this.mountingHoleCount,
    required this.initialGroup,
  });

  final String componentName;
  final int mountingHoleCount;
  final FeatureGroup initialGroup;

  @override
  State<_MountGenerationDialog> createState() => _MountGenerationDialogState();
}

class _MountGenerationDialogState extends State<_MountGenerationDialog> {
  late double _diameter;
  late double _height;
  late double _holeDiameter;
  late String _clearanceProfile;
  late String _screw;

  static const _profiles = [
    _ClearanceProfileOption('fdm_normal', 'FDM обычный'),
    _ClearanceProfileOption('fdm_loose', 'FDM свободный'),
    _ClearanceProfileOption('resin_normal', 'Resin обычный'),
  ];

  @override
  void initState() {
    super.initState();
    final itemPrototype = widget.initialGroup.itemPrototype;
    _diameter = _featureDouble(itemPrototype, 'diameter', 5);
    _height = _featureDouble(itemPrototype, 'height', 4);
    _holeDiameter = _featureDouble(itemPrototype, 'holeDiameter', 2.2);
    _clearanceProfile = _featureString(
      itemPrototype,
      'clearanceProfile',
      'fdm_normal',
    );
    _screw = _featureString(itemPrototype, 'screw', 'M2');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Крепёж'),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.componentName} · ${widget.mountingHoleCount} отв.',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('mount-diameter'),
                      label: 'Стойка',
                      value: _diameter,
                      onChanged: (value) => setState(() => _diameter = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('mount-hole-diameter'),
                      label: 'Отверстие',
                      value: _holeDiameter,
                      onChanged: (value) =>
                          setState(() => _holeDiameter = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _DialogNumberField(
                key: const ValueKey('mount-height'),
                label: 'Высота',
                value: _height,
                onChanged: (value) => setState(() => _height = value),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                key: const ValueKey('mount-clearance-profile'),
                initialValue: _clearanceProfile,
                isExpanded: true,
                items: [
                  for (final profile in _profiles)
                    DropdownMenuItem(
                      value: profile.id,
                      child: Text(profile.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _clearanceProfile = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Зазор',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('mount-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          key: const ValueKey('mount-confirm'),
          onPressed: () {
            final diameter = _clampDouble(_diameter, 3, 20);
            final holeDiameter = _clampDouble(
              _holeDiameter,
              0.8,
              diameter - 0.8,
            );

            Navigator.of(context).pop(
              FeatureGroup(
                id: widget.initialGroup.id,
                type: widget.initialGroup.type,
                targetSurface: widget.initialGroup.targetSurface,
                pattern: widget.initialGroup.pattern,
                itemPrototype: {
                  'type': 'standoff',
                  'diameter': diameter,
                  'height': _clampDouble(_height, 1, 30),
                  'holeDiameter': holeDiameter,
                  'screw': _screw,
                  'clearanceProfile': _clearanceProfile,
                },
                placement: widget.initialGroup.placement,
                overrides: widget.initialGroup.overrides,
                metadata: widget.initialGroup.metadata,
              ),
            );
          },
          child: const Text('Создать'),
        ),
      ],
    );
  }
}

class _GlassRecessDialog extends StatefulWidget {
  const _GlassRecessDialog({required this.initialFeature});

  final SemanticFeature initialFeature;

  @override
  State<_GlassRecessDialog> createState() => _GlassRecessDialogState();
}

class _GlassRecessDialogState extends State<_GlassRecessDialog> {
  late double _width;
  late double _height;
  late double _recessDepth;
  late double _ledgeWidth;
  late double _cornerRadius;
  late double _insertThickness;
  late String _clearanceProfile;

  static const _profiles = [
    _ClearanceProfileOption('fdm_normal', 'FDM обычный'),
    _ClearanceProfileOption('fdm_loose', 'FDM свободный'),
    _ClearanceProfileOption('resin_normal', 'Resin обычный'),
  ];

  @override
  void initState() {
    super.initState();
    final parameters = widget.initialFeature.parameters;
    _width = _featureDouble(parameters, 'width', 42);
    _height = _featureDouble(parameters, 'height', 24);
    _recessDepth = _featureDouble(parameters, 'recessDepth', 1.2);
    _ledgeWidth = _featureDouble(parameters, 'ledgeWidth', 1.5);
    _cornerRadius = _featureDouble(parameters, 'cornerRadius', 2);
    _insertThickness = _featureDouble(parameters, 'insertThickness', 1);
    _clearanceProfile = _featureString(
      parameters,
      'clearanceProfile',
      'fdm_normal',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Посадка под стекло'),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('glass-recess-width'),
                      label: 'Ширина',
                      value: _width,
                      onChanged: (value) => setState(() => _width = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('glass-recess-height'),
                      label: 'Высота',
                      value: _height,
                      onChanged: (value) => setState(() => _height = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('glass-recess-depth'),
                      label: 'Глубина',
                      value: _recessDepth,
                      onChanged: (value) =>
                          setState(() => _recessDepth = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('glass-recess-ledge'),
                      label: 'Полка',
                      value: _ledgeWidth,
                      onChanged: (value) => setState(() => _ledgeWidth = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('glass-recess-radius'),
                      label: 'Радиус',
                      value: _cornerRadius,
                      onChanged: (value) =>
                          setState(() => _cornerRadius = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DialogNumberField(
                      key: const ValueKey('glass-recess-thickness'),
                      label: 'Стекло',
                      value: _insertThickness,
                      onChanged: (value) =>
                          setState(() => _insertThickness = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                key: const ValueKey('glass-recess-clearance-profile'),
                initialValue: _clearanceProfile,
                isExpanded: true,
                items: [
                  for (final profile in _profiles)
                    DropdownMenuItem(
                      value: profile.id,
                      child: Text(profile.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _clearanceProfile = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Зазор',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('glass-recess-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          key: const ValueKey('glass-recess-confirm'),
          onPressed: () => Navigator.of(context).pop(
            SemanticFeature(
              id: widget.initialFeature.id,
              type: widget.initialFeature.type,
              targetSurface: widget.initialFeature.targetSurface,
              operation: widget.initialFeature.operation,
              parameters: {
                'width': _clampDouble(_width, 8, 180),
                'height': _clampDouble(_height, 8, 140),
                'recessDepth': _clampDouble(_recessDepth, 0.2, 8),
                'ledgeWidth': _clampDouble(_ledgeWidth, 0.2, 12),
                'cornerRadius': _clampDouble(_cornerRadius, 0, 24),
                'insertThickness': _clampDouble(_insertThickness, 0.2, 8),
                'clearanceProfile': _clearanceProfile,
              },
            ),
          ),
          child: const Text('Создать'),
        ),
      ],
    );
  }
}

class _ClearanceProfileOption {
  const _ClearanceProfileOption(this.id, this.label);

  final String id;
  final String label;
}

class _MountingSideOption {
  const _MountingSideOption(this.id, this.label);

  final String id;
  final String label;
}

class _DialogNumberField extends StatefulWidget {
  const _DialogNumberField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.suffixText = 'mm',
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final String? suffixText;

  @override
  State<_DialogNumberField> createState() => _DialogNumberFieldState();
}

class _DialogNumberFieldState extends State<_DialogNumberField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formattedValue());
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _DialogNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = _formattedValue();
    if (!_focusNode.hasFocus && _controller.text != nextText) {
      _controller.text = nextText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formattedValue() => _formatNumber(widget.value);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      onChanged: (rawValue) {
        final parsed = double.tryParse(rawValue.trim().replaceAll(',', '.'));
        if (parsed != null) {
          widget.onChanged(parsed);
        }
      },
      decoration: InputDecoration(
        labelText: widget.label,
        suffixText: widget.suffixText,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      ),
    );
  }
}

double _positionAt(List<double> values, int index) {
  return values.length > index ? values[index] : 0;
}

double _featureDouble(
  Map<String, Object?> parameters,
  String key,
  double fallback,
) {
  final value = parameters[key];
  return value is num ? value.toDouble() : fallback;
}

String _featureString(
  Map<String, Object?> parameters,
  String key,
  String fallback,
) {
  final value = parameters[key];
  return value is String ? value : fallback;
}

double _clampDouble(double value, double min, double max) {
  return value.clamp(min, max).toDouble();
}

class _ParameterNumberField extends StatefulWidget {
  const _ParameterNumberField({
    required this.parameter,
    required this.value,
    required this.onSubmitted,
    this.onChanged,
    this.keyPrefix = 'enclosure-param',
    this.enabled = true,
  });

  final ParameterDefinition parameter;
  final Object? value;
  final ValueChanged<double> onSubmitted;
  final ValueChanged<double>? onChanged;
  final String keyPrefix;
  final bool enabled;

  @override
  State<_ParameterNumberField> createState() => _ParameterNumberFieldState();
}

class _ParameterNumberFieldState extends State<_ParameterNumberField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatParameterValue());
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _ParameterNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = _formatParameterValue();
    if (!_focusNode.hasFocus && _controller.text != nextText) {
      _controller.text = nextText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed != null) {
      widget.onSubmitted(parsed);
      _focusNode.unfocus();
    } else {
      _controller.text = _formatParameterValue();
    }
  }

  void _change(String value) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed != null) {
      widget.onChanged?.call(parsed);
    }
  }

  String _formatParameterValue() {
    final value = widget.value;
    if (value is num) {
      if (value == value.roundToDouble()) {
        return value.toStringAsFixed(0);
      }
      final step = widget.parameter.range?.step;
      if (step != null && step > 0 && step < 0.1) {
        return value.toStringAsFixed(2);
      }
      return value.toStringAsFixed(1);
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final parameter = widget.parameter;
    final range = parameter.range;
    final suffix = parameter.unit;
    final helperText = range == null
        ? null
        : '${_formatNumber(range.min)}-${_formatNumber(range.max)}';

    return TextFormField(
      key: ValueKey('${widget.keyPrefix}-${parameter.id}'),
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      onChanged: widget.enabled && widget.onChanged != null ? _change : null,
      onFieldSubmitted: widget.enabled ? _submit : null,
      decoration: InputDecoration(
        labelText: parameter.label,
        helperText: helperText,
        suffixText: suffix,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      ),
    );
  }
}

class _ParameterChoiceField extends StatelessWidget {
  const _ParameterChoiceField({
    required this.parameter,
    required this.value,
    required this.onChanged,
    this.keyPrefix = 'enclosure-param',
    this.enabled = true,
  });

  final ParameterDefinition parameter;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String keyPrefix;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final selectedValue = parameter.options.any((option) => option.id == value)
        ? value
        : null;

    return DropdownButtonFormField<String>(
      key: ValueKey('$keyPrefix-${parameter.id}'),
      initialValue: selectedValue,
      isExpanded: true,
      items: [
        for (final option in parameter.options)
          DropdownMenuItem(value: option.id, child: Text(option.label)),
      ],
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: parameter.label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      ),
    );
  }
}

class _ParameterBoolField extends StatelessWidget {
  const _ParameterBoolField({
    required this.parameter,
    required this.value,
    required this.onChanged,
    this.keyPrefix = 'enclosure-param',
  });

  final ParameterDefinition parameter;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      type: MaterialType.transparency,
      child: CheckboxListTile(
        key: ValueKey('$keyPrefix-${parameter.id}'),
        value: value,
        onChanged: (value) => onChanged(value ?? false),
        dense: true,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(parameter.label, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}

String _formatNumber(num value) {
  final normalized = value.abs() < 0.0001 ? 0.0 : value.toDouble();
  if (normalized == normalized.roundToDouble()) {
    return normalized.toStringAsFixed(0);
  }
  if ((normalized * 10).roundToDouble() == normalized * 10) {
    return normalized.toStringAsFixed(1);
  }

  return normalized.toStringAsFixed(2);
}

class _InspectorValue extends StatelessWidget {
  const _InspectorValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.report,
    required this.selectionDetails,
    required this.fileStatusMessage,
    required this.fileBusy,
    required this.hasUnsavedChanges,
    required this.onShowValidationDetails,
  });

  final ValidationReport? report;
  final ProjectSelectionDetails selectionDetails;
  final String? fileStatusMessage;
  final bool fileBusy;
  final bool hasUnsavedChanges;
  final VoidCallback? onShowValidationDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasErrors = report?.hasErrors ?? false;
    final hasWarnings = !hasErrors && (report?.hasWarnings ?? false);
    final primaryIssue = report?.primaryIssue;
    final statusColor = hasErrors
        ? theme.colorScheme.error
        : hasWarnings
        ? Colors.amber
        : theme.colorScheme.primary;

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.18)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasErrors
                ? Icons.error_outline_rounded
                : hasWarnings
                ? Icons.warning_amber_rounded
                : Icons.check_circle_rounded,
            size: 18,
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Text(
            fileBusy
                ? 'Файл...'
                : hasErrors
                ? 'Ошибка'
                : hasWarnings
                ? 'Предупреждение'
                : AppStrings.previewReady,
            style: theme.textTheme.labelMedium,
          ),
          if (onShowValidationDetails != null) ...[
            const SizedBox(width: 6),
            IconButton(
              key: const ValueKey('status-validation-details'),
              tooltip: 'Показать проверки',
              onPressed: onShowValidationDetails,
              icon: const Icon(Icons.fact_check_rounded),
              iconSize: 17,
              color: statusColor,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 28, height: 28),
              visualDensity: VisualDensity.compact,
            ),
          ],
          const Spacer(),
          Flexible(
            child: Text(
              hasErrors
                  ? primaryIssue?.message ?? AppStrings.viewportHint
                  : hasWarnings
                  ? primaryIssue?.message ?? AppStrings.viewportHint
                  : hasUnsavedChanges
                  ? 'Есть несохранённые изменения'
                  : fileStatusMessage ?? selectionDetails.status,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationDetailsSheet extends StatelessWidget {
  const _ValidationDetailsSheet({
    required this.report,
    required this.selectionForTarget,
    required this.onSelectionRequested,
  });

  final ValidationReport report;
  final SelectionModel? Function(String? targetId) selectionForTarget;
  final ValueChanged<SelectionModel> onSelectionRequested;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final issues = report.issues;
    final listHeight = math.min(issues.length * 78.0, 360.0);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fact_check_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Проверка проекта',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  key: const ValueKey('validation-details-close'),
                  tooltip: 'Закрыть',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ValidationCountBadge(
                  label: 'Ошибки',
                  count: report.errors.length,
                  color: theme.colorScheme.error,
                ),
                _ValidationCountBadge(
                  label: 'Предупреждения',
                  count: report.warnings.length,
                  color: Colors.amber,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: listHeight,
              child: ListView.separated(
                itemCount: issues.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.16),
                ),
                itemBuilder: (context, index) {
                  final message = issues[index];
                  return _ValidationMessageRow(
                    key: ValueKey('validation-issue-${message.code}-$index'),
                    message: message,
                    selection: selectionForTarget(message.targetId),
                    onSelectionRequested: onSelectionRequested,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValidationCountBadge extends StatelessWidget {
  const _ValidationCountBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $count',
        style: theme.textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _ValidationMessageRow extends StatelessWidget {
  const _ValidationMessageRow({
    super.key,
    required this.message,
    required this.selection,
    required this.onSelectionRequested,
  });

  final ValidationMessage message;
  final SelectionModel? selection;
  final ValueChanged<SelectionModel> onSelectionRequested;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _validationSeverityColor(theme, message.severity);
    final target = message.targetId ?? message.code;
    final canSelect = selection != null;

    return InkWell(
      onTap: canSelect ? () => onSelectionRequested(selection!) : null,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _validationSeverityIcon(message.severity),
              color: color,
              size: 19,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message.message, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    target,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (canSelect) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 17,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Color _validationSeverityColor(ThemeData theme, ValidationSeverity severity) {
  return switch (severity) {
    ValidationSeverity.error => theme.colorScheme.error,
    ValidationSeverity.warning => Colors.amber,
    ValidationSeverity.info => theme.colorScheme.primary,
  };
}

IconData _validationSeverityIcon(ValidationSeverity severity) {
  return switch (severity) {
    ValidationSeverity.error => Icons.error_outline_rounded,
    ValidationSeverity.warning => Icons.warning_amber_rounded,
    ValidationSeverity.info => Icons.info_outline_rounded,
  };
}

class _ViewportPainter extends CustomPainter {
  const _ViewportPainter({
    required this.colorScheme,
    required this.previewMesh,
    required this.bodyDimensions,
    required this.componentPlacementPreviews,
    required this.activeSnapPlacementPreview,
    required this.activeSnapPlacementIssue,
    required this.workplaneOverlay,
    required this.activeSnapTarget,
    required this.featurePreviews,
    required this.featureGroupPreviews,
    required this.selection,
    required this.viewportState,
  });

  final ColorScheme colorScheme;
  final PreviewMesh? previewMesh;
  final MockViewportBodyDimensions bodyDimensions;
  final List<MockViewportComponentPlacementPreview> componentPlacementPreviews;
  final MockViewportComponentPlacementPreview? activeSnapPlacementPreview;
  final ValidationMessage? activeSnapPlacementIssue;
  final MockViewportWorkplaneOverlay? workplaneOverlay;
  final _ActiveSnapTarget? activeSnapTarget;
  final List<MockViewportFeaturePreview> featurePreviews;
  final List<MockViewportFeatureGroupPreview> featureGroupPreviews;
  final SelectionModel selection;
  final ViewportState viewportState;

  @override
  void paint(Canvas canvas, Size size) {
    final layout = MockViewportLayout.fromSize(
      size,
      viewportState,
      bodyDimensions: bodyDimensions,
    );
    final gridStep = 32 * viewportState.zoom;
    final gridOrigin = Offset(
      viewportState.panOffset.dx % gridStep,
      viewportState.panOffset.dy % gridStep,
    );
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1;

    for (var x = gridOrigin.dx - gridStep; x < size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = gridOrigin.dy - gridStep; y < size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final bodyPaint = Paint()..color = const Color(0xFF3D474D);
    final topPaint = Paint()..color = const Color(0xFF657179);
    final accentPaint = Paint()..color = colorScheme.primary;
    final portPaint = Paint()..color = colorScheme.secondary;
    final previewMeshRendered = _paintPreviewMesh(canvas, layout);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        layout.shadowRect,
        Radius.circular(layout.bodyRadius),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.24),
    );

    if (!previewMeshRendered) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          layout.bodyRect,
          Radius.circular(layout.bodyRadius),
        ),
        bodyPaint,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          layout.lidRect,
          Radius.circular(layout.lidRadius),
        ),
        topPaint,
      );
    }

    final previewSelectionRendered =
        previewMeshRendered &&
        _hasSelectedPreviewSurface(previewMesh, selection);

    _paintComponentPlacements(
      canvas,
      layout,
      annotationMode: previewMeshRendered,
    );
    _paintActiveSnapPlacementPreview(canvas, layout);

    if (!previewMeshRendered) {
      for (final center in layout.buttonCenters) {
        canvas.drawCircle(center, layout.buttonRadius, accentPaint);
        canvas.drawCircle(
          center,
          layout.buttonRadius * 0.44,
          Paint()..color = Colors.black26,
        );
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          layout.portRect,
          Radius.circular(layout.portRadius),
        ),
        portPaint,
      );
    }

    _paintFeatures(canvas, layout, annotationMode: previewMeshRendered);
    _paintFeatureGroups(canvas, layout, annotationMode: previewMeshRendered);
    _paintWorkplaneOverlay(canvas, layout, annotationMode: previewMeshRendered);
    _paintGhostPreview(canvas, layout);

    final highlightPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final secondaryHighlightPaint = Paint()
      ..color = colorScheme.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    if (selection.kind == SelectionKind.enclosure) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          layout.bodyRect.inflate(4),
          Radius.circular(layout.bodyRadius + 3),
        ),
        highlightPaint,
      );
    }

    if (selection.kind == SelectionKind.surface && !previewSelectionRendered) {
      final selectedSurface = selection.id ?? '';
      if (selectedSurface.contains('top_lid')) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            layout.lidRect.inflate(4),
            Radius.circular(layout.lidRadius + 3),
          ),
          highlightPaint,
        );
      } else if (selectedSurface.contains('front_wall')) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            layout.portRect.inflate(8),
            Radius.circular(layout.portRadius + 4),
          ),
          highlightPaint,
        );
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            layout.bodyRect.inflate(4),
            Radius.circular(layout.bodyRadius + 3),
          ),
          highlightPaint,
        );
      }
    }

    if (selection.kind == SelectionKind.componentPlacement) {
      final placement = componentPlacementPreviews
          .where((placement) => placement.semanticId == selection.id)
          .firstOrNull;
      if (placement != null) {
        _drawRotatedRRect(
          canvas,
          layout.componentPlacementRect(placement).inflate(5),
          placement.rotationZDegrees,
          Radius.circular(layout.boardRadius + 3),
          secondaryHighlightPaint,
        );
      }
    }

    if (selection.kind == SelectionKind.componentTemplate) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          layout.boardRect.inflate(5),
          Radius.circular(layout.boardRadius + 3),
        ),
        secondaryHighlightPaint,
      );
    }

    if (selection.kind == SelectionKind.feature &&
        !previewSelectionRendered &&
        selection.id == 'front_usb_c') {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          layout.portRect.inflate(8),
          Radius.circular(layout.portRadius + 4),
        ),
        secondaryHighlightPaint,
      );
    }

    if (selection.kind == SelectionKind.feature && !previewSelectionRendered) {
      final feature = featurePreviews
          .where((feature) => feature.semanticId == selection.id)
          .firstOrNull;
      if (feature != null) {
        final rect = layout.featureRect(feature).inflate(6);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(layout.featureCornerRadius(feature) + 4),
          ),
          secondaryHighlightPaint,
        );
      }
    }

    if (selection.kind == SelectionKind.feature &&
        !previewSelectionRendered &&
        selection.id == 'abxy_buttons') {
      for (final center in layout.buttonCenters) {
        canvas.drawCircle(
          center,
          layout.buttonRadius + 5,
          secondaryHighlightPaint,
        );
      }
    }

    if (selection.kind == SelectionKind.featureGroup &&
        !previewSelectionRendered) {
      final group = featureGroupPreviews
          .where((group) => group.semanticId == selection.id)
          .firstOrNull;
      if (group != null) {
        final radius = layout.featureGroupRadius(group);
        for (final center in layout.featureGroupCenters(group)) {
          canvas.drawCircle(center, radius + 5, secondaryHighlightPaint);
        }
      }
    }
  }

  bool _paintPreviewMesh(Canvas canvas, MockViewportLayout layout) {
    final mesh = previewMesh;
    if (!_hasPreviewMesh(mesh)) {
      return false;
    }

    final vertices = _projectPreviewMeshVertices(
      mesh: mesh!,
      viewportState: viewportState,
      layout: layout,
    );
    if (vertices == null) {
      return false;
    }

    final selectedTriangleIndices =
        _selectionUsesPreviewSurfaceRanges(selection)
        ? _previewSurfaceTriangleIndices(mesh, selection.id)
        : const <int>{};
    final meshBoundaryEdges = previewMeshBoundaryEdges(
      triangles: mesh.triangles,
      vertexCount: mesh.vertexCount,
    );
    final selectedBoundaryEdges = selectedTriangleIndices.isEmpty
        ? const <PreviewMeshEdgeKey>{}
        : previewMeshBoundaryEdges(
            triangles: mesh.triangles,
            vertexCount: mesh.vertexCount,
            triangleIndices: selectedTriangleIndices,
          );
    final selectionTone = _PreviewMeshSelectionTone.fromSelection(
      colorScheme: colorScheme,
      selection: selection,
    );
    final triangles = <_PreviewMeshTriangle>[];
    for (var index = 0; index < mesh.triangleCount; index++) {
      final base = index * 3;
      final a = mesh.triangles[base];
      final b = mesh.triangles[base + 1];
      final c = mesh.triangles[base + 2];
      if (!_validPreviewMeshIndex(a, mesh.vertexCount) ||
          !_validPreviewMeshIndex(b, mesh.vertexCount) ||
          !_validPreviewMeshIndex(c, mesh.vertexCount)) {
        continue;
      }

      triangles.add(
        _PreviewMeshTriangle(
          a: a,
          b: b,
          c: c,
          depth:
              (vertices[a].depth + vertices[b].depth + vertices[c].depth) / 3,
          shade: _previewTriangleShade(mesh, a, b, c),
          selectedSurface: selectedTriangleIndices.contains(index),
        ),
      );
    }

    if (triangles.isEmpty) {
      return false;
    }

    triangles.sort((left, right) => left.depth.compareTo(right.depth));

    final fillPaint = Paint()..style = PaintingStyle.fill;
    final meshBoundaryPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.055)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.55;
    final selectedStrokePaint = Paint()
      ..color = selectionTone.color.withValues(alpha: selectionTone.edgeAlpha)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = selectionTone.edgeWidth;
    final selectedHaloShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = selectionTone.haloWidth + 3.2;
    final selectedHaloPaint = Paint()
      ..color = selectionTone.color.withValues(alpha: selectionTone.haloAlpha)
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = selectionTone.haloWidth;
    const shadowColor = Color(0xFF334047);
    const litColor = Color(0xFF74838A);
    Rect? selectedBounds;

    for (final triangle in triangles) {
      final a = vertices[triangle.a].point;
      final b = vertices[triangle.b].point;
      final c = vertices[triangle.c].point;
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(c.dx, c.dy)
        ..close();
      final baseColor = Color.lerp(shadowColor, litColor, triangle.shade)!;
      fillPaint.color = triangle.selectedSurface
          ? Color.alphaBlend(
              selectionTone.color.withValues(alpha: selectionTone.fillAlpha),
              baseColor,
            )
          : baseColor;
      canvas.drawPath(path, fillPaint);
      _drawPreviewMeshTriangleEdges(
        canvas: canvas,
        vertices: vertices,
        triangle: triangle,
        edges: meshBoundaryEdges,
        paint: meshBoundaryPaint,
      );
      if (triangle.selectedSurface) {
        final triangleBounds = Rect.fromLTRB(
          math.min(a.dx, math.min(b.dx, c.dx)),
          math.min(a.dy, math.min(b.dy, c.dy)),
          math.max(a.dx, math.max(b.dx, c.dx)),
          math.max(a.dy, math.max(b.dy, c.dy)),
        );
        selectedBounds = selectedBounds == null
            ? triangleBounds
            : selectedBounds.expandToInclude(triangleBounds);
        _drawPreviewMeshTriangleEdges(
          canvas: canvas,
          vertices: vertices,
          triangle: triangle,
          edges: selectedBoundaryEdges,
          paint: selectedStrokePaint,
        );
      }
    }

    final haloBounds = selectedBounds;
    if (haloBounds != null) {
      final haloRect = haloBounds.inflate(selectionTone.haloPadding);
      final haloRadius = Radius.circular(selectionTone.haloRadius);
      canvas.drawRRect(
        RRect.fromRectAndRadius(haloRect, haloRadius),
        selectedHaloShadowPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(haloRect, haloRadius),
        selectedHaloPaint,
      );
    }

    return true;
  }

  void _paintWorkplaneOverlay(
    Canvas canvas,
    MockViewportLayout layout, {
    required bool annotationMode,
  }) {
    final workplane = workplaneOverlay;
    if (workplane == null) {
      return;
    }

    final focused =
        !annotationMode ||
        _nativeWorkplaneOverlayFocused(
          selection: selection,
          workplane: workplane,
          activeSnapTarget: activeSnapTarget,
        );
    if (annotationMode && !focused) {
      return;
    }
    final rect = layout.workplaneRect(workplane);
    final rotation =
        workplane.kind == MockViewportWorkplaneKind.componentPlacement
        ? workplane.rotationZDegrees
        : 0.0;
    final radius = Radius.circular(
      workplane.kind == MockViewportWorkplaneKind.componentPlacement
          ? layout.boardRadius + 2
          : 8 * layout.zoom,
    );
    final fill = Paint()
      ..color = colorScheme.primary.withValues(
        alpha: annotationMode ? 0.035 : 0.08,
      )
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = colorScheme.primary.withValues(
        alpha: annotationMode ? 0.44 : 0.62,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = annotationMode ? 1.4 : 2;
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: annotationMode ? 0.07 : 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final snapFill = Paint()
      ..color = colorScheme.primary.withValues(alpha: annotationMode ? 0.70 : 1)
      ..style = PaintingStyle.fill;
    final activeSnapFill = Paint()
      ..color = colorScheme.secondary
      ..style = PaintingStyle.fill;
    final snapStroke = Paint()
      ..color = const Color(0xFF151719).withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(rotation * math.pi / 180);
    canvas.translate(-rect.center.dx, -rect.center.dy);

    final rrect = RRect.fromRectAndRadius(rect, radius);
    canvas.drawRRect(rrect, fill);
    canvas.save();
    canvas.clipRRect(rrect);
    for (var index = 1; index < 4; index++) {
      final dx = rect.left + rect.width * index / 4;
      final dy = rect.top + rect.height * index / 4;
      canvas.drawLine(Offset(dx, rect.top), Offset(dx, rect.bottom), gridPaint);
      canvas.drawLine(Offset(rect.left, dy), Offset(rect.right, dy), gridPaint);
    }
    canvas.restore();
    canvas.drawRRect(rrect, outline);
    canvas.restore();

    final snapPoints = layout.workplaneSnapPoints(workplane);
    final localPoints = workplane.effectiveSnapPoints;
    for (var index = 0; index < snapPoints.length; index++) {
      final active = _snapTargetMatches(
        activeSnapTarget,
        workplane,
        localPoints[index],
      );
      final radius =
          (active ? 7.0 : (annotationMode ? 3.6 : 4.5)) * layout.zoom;
      canvas.drawCircle(
        snapPoints[index],
        radius,
        active ? activeSnapFill : snapFill,
      );
      canvas.drawCircle(snapPoints[index], radius, snapStroke);
    }
  }

  void _paintComponentPlacements(
    Canvas canvas,
    MockViewportLayout layout, {
    required bool annotationMode,
  }) {
    final selectedPlacementId =
        selection.kind == SelectionKind.componentPlacement
        ? selection.id
        : null;
    final boardFill = Paint()
      ..color = const Color(
        0xFF243F3D,
      ).withValues(alpha: annotationMode ? 0.18 : 1)
      ..style = PaintingStyle.fill;
    final boardStroke = Paint()
      ..color = colorScheme.secondary.withValues(
        alpha: annotationMode ? 0.22 : 0.28,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = annotationMode ? 1.2 : 1.5;
    final selectedBoardFill = Paint()
      ..color = const Color(
        0xFF243F3D,
      ).withValues(alpha: annotationMode ? 0.46 : 1)
      ..style = PaintingStyle.fill;
    final selectedBoardStroke = Paint()
      ..color = colorScheme.secondary.withValues(
        alpha: annotationMode ? 0.62 : 0.28,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = annotationMode ? 1.5 : 1.5;

    for (final placement in componentPlacementPreviews) {
      final selected = placement.semanticId == selectedPlacementId;
      final rect = layout.componentPlacementRect(placement);
      final radius = Radius.circular(layout.boardRadius);
      _drawRotatedRRect(
        canvas,
        rect,
        placement.rotationZDegrees,
        radius,
        selected ? selectedBoardFill : boardFill,
      );
      _drawRotatedRRect(
        canvas,
        rect,
        placement.rotationZDegrees,
        radius,
        selected ? selectedBoardStroke : boardStroke,
      );
    }
  }

  void _paintActiveSnapPlacementPreview(
    Canvas canvas,
    MockViewportLayout layout,
  ) {
    final placement = activeSnapPlacementPreview;
    if (placement == null) {
      return;
    }

    final baseColor = switch (activeSnapPlacementIssue?.severity) {
      ValidationSeverity.error => colorScheme.error,
      ValidationSeverity.warning => Colors.amber,
      ValidationSeverity.info || null => colorScheme.secondary,
    };
    final fill = Paint()
      ..color = baseColor.withValues(alpha: 0.13)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = baseColor.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rect = layout.componentPlacementRect(placement);
    final radius = Radius.circular(layout.boardRadius + 2);

    _drawRotatedRRect(canvas, rect, placement.rotationZDegrees, radius, fill);
    _drawRotatedRRect(
      canvas,
      rect.inflate(2),
      placement.rotationZDegrees,
      radius,
      stroke,
    );
  }

  void _paintFeatures(
    Canvas canvas,
    MockViewportLayout layout, {
    required bool annotationMode,
  }) {
    for (final feature in featurePreviews) {
      final selected =
          selection.kind == SelectionKind.feature &&
          selection.id == feature.semanticId;
      final usbFill = Paint()
        ..color = colorScheme.secondary.withValues(
          alpha: annotationMode ? (selected ? 0.28 : 0.055) : 1,
        )
        ..style = PaintingStyle.fill;
      final usbStroke = Paint()
        ..color = colorScheme.secondary.withValues(
          alpha: annotationMode ? (selected ? 0.82 : 0.20) : 0,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = annotationMode ? (selected ? 1.8 : 1.1) : 0;
      final glassFill = Paint()
        ..color = const Color(
          0xFF92C9D8,
        ).withValues(alpha: annotationMode ? (selected ? 0.16 : 0.028) : 0.24)
        ..style = PaintingStyle.fill;
      final glassStroke = Paint()
        ..color = const Color(
          0xFF92C9D8,
        ).withValues(alpha: annotationMode ? (selected ? 0.72 : 0.18) : 0.86)
        ..style = PaintingStyle.stroke
        ..strokeWidth = annotationMode ? (selected ? 1.7 : 1.0) : 2;
      final circularFill = Paint()
        ..color = colorScheme.secondary.withValues(
          alpha: annotationMode ? (selected ? 0.24 : 0.05) : 0.20,
        )
        ..style = PaintingStyle.fill;
      final circularStroke = Paint()
        ..color = colorScheme.secondary.withValues(
          alpha: annotationMode ? (selected ? 0.88 : 0.24) : 0.86,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = annotationMode ? (selected ? 1.9 : 1.1) : 2;
      final darkInset = Paint()
        ..color = Colors.black.withValues(
          alpha: annotationMode ? (selected ? 0.12 : 0.035) : 0.25,
        )
        ..style = PaintingStyle.fill;
      final rect = layout.featureRect(feature);
      final radius = Radius.circular(layout.featureCornerRadius(feature));
      final rrect = RRect.fromRectAndRadius(rect, radius);

      switch (feature.kind) {
        case MockViewportFeatureKind.usbC:
          canvas.drawRRect(rrect, usbFill);
          if (annotationMode) {
            canvas.drawRRect(rrect, usbStroke);
          }
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect.deflate(3), radius),
            darkInset,
          );
        case MockViewportFeatureKind.glassRecess:
          canvas.drawRRect(rrect, glassFill);
          canvas.drawRRect(rrect, glassStroke);
          if (!annotationMode || selected) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(rect.deflate(6), radius),
              Paint()
                ..color = Colors.black.withValues(alpha: 0.12)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1,
            );
          }
        case MockViewportFeatureKind.circularCutout:
          canvas.drawOval(rect, circularFill);
          canvas.drawOval(rect, circularStroke);
          if (!annotationMode || selected) {
            canvas.drawLine(
              Offset(rect.center.dx, rect.top + 3),
              Offset(rect.center.dx, rect.bottom - 3),
              circularStroke,
            );
            canvas.drawLine(
              Offset(rect.left + 3, rect.center.dy),
              Offset(rect.right - 3, rect.center.dy),
              circularStroke,
            );
          }
      }
    }
  }

  void _paintFeatureGroups(
    Canvas canvas,
    MockViewportLayout layout, {
    required bool annotationMode,
  }) {
    final buttonFill = Paint()
      ..color = colorScheme.primary.withValues(
        alpha: annotationMode ? 0.028 : 0.92,
      )
      ..style = PaintingStyle.fill;
    final buttonHole = Paint()
      ..color = Colors.black.withValues(alpha: annotationMode ? 0.12 : 0.28)
      ..style = PaintingStyle.fill;
    final buttonStroke = Paint()
      ..color = colorScheme.primary.withValues(alpha: annotationMode ? 0.20 : 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = annotationMode ? 1.1 : 0;
    final selectedButtonStroke = Paint()
      ..color = colorScheme.secondary.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final mountFill = Paint()
      ..color = const Color(
        0xFFE6C35A,
      ).withValues(alpha: annotationMode ? 0.20 : 1)
      ..style = PaintingStyle.fill;
    final mountStroke = Paint()
      ..color =
          (annotationMode ? colorScheme.secondary : const Color(0xFF151719))
              .withValues(alpha: annotationMode ? 0.24 : 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = annotationMode ? 1.1 : 2;
    final mountHole = Paint()
      ..color = const Color(
        0xFF151719,
      ).withValues(alpha: annotationMode ? 0.20 : 0.62)
      ..style = PaintingStyle.fill;
    final selectedMountFill = Paint()
      ..color = const Color(
        0xFFE6C35A,
      ).withValues(alpha: annotationMode ? 0.55 : 1)
      ..style = PaintingStyle.fill;
    final selectedMountStroke = Paint()
      ..color = colorScheme.secondary.withValues(
        alpha: annotationMode ? 0.78 : 0.7,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = annotationMode ? 1.7 : 2;
    final selectedMountHole = Paint()
      ..color = const Color(
        0xFF151719,
      ).withValues(alpha: annotationMode ? 0.42 : 0.62)
      ..style = PaintingStyle.fill;

    for (final group in featureGroupPreviews) {
      final radius = layout.featureGroupRadius(group);
      final centers = layout.featureGroupCenters(group);
      final selected =
          selection.kind == SelectionKind.featureGroup &&
          selection.id == group.semanticId;

      switch (group.kind) {
        case MockViewportFeatureGroupKind.buttonGroup:
          for (final center in centers) {
            canvas.drawCircle(center, radius, buttonFill);
            canvas.drawCircle(center, radius * 0.44, buttonHole);
            if (annotationMode) {
              canvas.drawCircle(
                center,
                radius,
                selected ? selectedButtonStroke : buttonStroke,
              );
            }
          }
        case MockViewportFeatureGroupKind.standoffMounts:
          for (final center in centers) {
            canvas.drawCircle(
              center,
              radius,
              selected ? selectedMountFill : mountFill,
            );
            canvas.drawCircle(
              center,
              radius * 0.46,
              selected ? selectedMountHole : mountHole,
            );
            canvas.drawCircle(
              center,
              radius,
              selected ? selectedMountStroke : mountStroke,
            );
          }
      }
    }
  }

  void _paintGhostPreview(Canvas canvas, MockViewportLayout layout) {
    final ghost = viewportState.ghostPreview;
    if (ghost == null) {
      return;
    }

    final ghostFill = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final ghostStroke = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.56)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (ghost.kind == GhostPreviewKind.usbC) {
      final rect = layout.portRect.shift(Offset(0, -22 * viewportState.zoom));
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(layout.portRadius)),
        ghostFill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(layout.portRadius)),
        ghostStroke,
      );
      return;
    }

    final ghostCenter = layout.lidRect.center.translate(
      layout.lidRect.width * 0.22,
      -layout.lidRect.height * 0.18,
    );
    final distance = 22 * viewportState.zoom;
    final radius = 7 * viewportState.zoom;
    final centers = [
      ghostCenter + Offset(distance, 0),
      ghostCenter + Offset(0, -distance),
      ghostCenter + Offset(0, distance),
      ghostCenter + Offset(-distance, 0),
    ];
    for (final center in centers) {
      canvas.drawCircle(center, radius, ghostFill);
      canvas.drawCircle(center, radius, ghostStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _ViewportPainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme ||
        oldDelegate.previewMesh != previewMesh ||
        oldDelegate.bodyDimensions != bodyDimensions ||
        oldDelegate.componentPlacementPreviews != componentPlacementPreviews ||
        oldDelegate.activeSnapPlacementPreview != activeSnapPlacementPreview ||
        oldDelegate.activeSnapPlacementIssue != activeSnapPlacementIssue ||
        oldDelegate.workplaneOverlay != workplaneOverlay ||
        oldDelegate.activeSnapTarget != activeSnapTarget ||
        oldDelegate.featurePreviews != featurePreviews ||
        oldDelegate.featureGroupPreviews != featureGroupPreviews ||
        oldDelegate.selection != selection ||
        oldDelegate.viewportState != viewportState;
  }
}

class _PreviewMeshBounds {
  const _PreviewMeshBounds({
    required this.minX,
    required this.minY,
    required this.minZ,
    required this.maxX,
    required this.maxY,
    required this.maxZ,
  });

  factory _PreviewMeshBounds.fromMesh(PreviewMesh mesh) {
    if (_validBoundsList(mesh.bounds.min) &&
        _validBoundsList(mesh.bounds.max)) {
      final declaredBounds = _PreviewMeshBounds(
        minX: mesh.bounds.min[0],
        minY: mesh.bounds.min[1],
        minZ: mesh.bounds.min[2],
        maxX: mesh.bounds.max[0],
        maxY: mesh.bounds.max[1],
        maxZ: mesh.bounds.max[2],
      );
      if (declaredBounds.isUsable) {
        return declaredBounds;
      }
    }

    var minX = double.infinity;
    var minY = double.infinity;
    var minZ = double.infinity;
    var maxX = -double.infinity;
    var maxY = -double.infinity;
    var maxZ = -double.infinity;
    for (var index = 0; index < mesh.vertexCount; index++) {
      final base = index * 3;
      final x = mesh.vertices[base];
      final y = mesh.vertices[base + 1];
      final z = mesh.vertices[base + 2];
      minX = math.min(minX, x);
      minY = math.min(minY, y);
      minZ = math.min(minZ, z);
      maxX = math.max(maxX, x);
      maxY = math.max(maxY, y);
      maxZ = math.max(maxZ, z);
    }

    return _PreviewMeshBounds(
      minX: minX,
      minY: minY,
      minZ: minZ,
      maxX: maxX,
      maxY: maxY,
      maxZ: maxZ,
    );
  }

  final double minX;
  final double minY;
  final double minZ;
  final double maxX;
  final double maxY;
  final double maxZ;

  double get centerX => (minX + maxX) / 2;
  double get centerY => (minY + maxY) / 2;
  double get centerZ => (minZ + maxZ) / 2;

  bool get isUsable {
    final values = [minX, minY, minZ, maxX, maxY, maxZ];
    return values.every((value) => value.isFinite) &&
        maxX > minX &&
        maxY > minY &&
        maxZ >= minZ;
  }
}

class _PreviewMeshVertex {
  const _PreviewMeshVertex({required this.point, required this.depth});

  final Offset point;
  final double depth;
}

class _PreviewMeshTriangle {
  const _PreviewMeshTriangle({
    required this.a,
    required this.b,
    required this.c,
    required this.depth,
    required this.shade,
    required this.selectedSurface,
  });

  final int a;
  final int b;
  final int c;
  final double depth;
  final double shade;
  final bool selectedSurface;
}

class _PreviewMeshSelectionTone {
  const _PreviewMeshSelectionTone({
    required this.color,
    required this.fillAlpha,
    required this.edgeAlpha,
    required this.edgeWidth,
    required this.haloAlpha,
    required this.haloWidth,
    required this.haloPadding,
    required this.haloRadius,
  });

  factory _PreviewMeshSelectionTone.fromSelection({
    required ColorScheme colorScheme,
    required SelectionModel selection,
  }) {
    return switch (selection.kind) {
      SelectionKind.feature ||
      SelectionKind.featureGroup => _PreviewMeshSelectionTone(
        color: colorScheme.secondary,
        fillAlpha: 0.28,
        edgeAlpha: 0.54,
        edgeWidth: 1.0,
        haloAlpha: 0.90,
        haloWidth: 2.4,
        haloPadding: 7,
        haloRadius: 11,
      ),
      SelectionKind.surface => _PreviewMeshSelectionTone(
        color: colorScheme.primary,
        fillAlpha: 0.16,
        edgeAlpha: 0.30,
        edgeWidth: 0.8,
        haloAlpha: 0.64,
        haloWidth: 1.8,
        haloPadding: 6,
        haloRadius: 12,
      ),
      _ => _PreviewMeshSelectionTone(
        color: colorScheme.primary,
        fillAlpha: 0.18,
        edgeAlpha: 0.36,
        edgeWidth: 0.8,
        haloAlpha: 0.62,
        haloWidth: 1.8,
        haloPadding: 6,
        haloRadius: 12,
      ),
    };
  }

  final Color color;
  final double fillAlpha;
  final double edgeAlpha;
  final double edgeWidth;
  final double haloAlpha;
  final double haloWidth;
  final double haloPadding;
  final double haloRadius;
}

bool _hasPreviewMesh(PreviewMesh? mesh) {
  return mesh != null && mesh.vertexCount > 0 && mesh.triangleCount > 0;
}

void _drawPreviewMeshTriangleEdges({
  required Canvas canvas,
  required List<_PreviewMeshVertex> vertices,
  required _PreviewMeshTriangle triangle,
  required Set<PreviewMeshEdgeKey> edges,
  required Paint paint,
}) {
  _drawPreviewMeshEdgeIfPresent(
    canvas: canvas,
    vertices: vertices,
    edges: edges,
    first: triangle.a,
    second: triangle.b,
    paint: paint,
  );
  _drawPreviewMeshEdgeIfPresent(
    canvas: canvas,
    vertices: vertices,
    edges: edges,
    first: triangle.b,
    second: triangle.c,
    paint: paint,
  );
  _drawPreviewMeshEdgeIfPresent(
    canvas: canvas,
    vertices: vertices,
    edges: edges,
    first: triangle.c,
    second: triangle.a,
    paint: paint,
  );
}

void _drawPreviewMeshEdgeIfPresent({
  required Canvas canvas,
  required List<_PreviewMeshVertex> vertices,
  required Set<PreviewMeshEdgeKey> edges,
  required int first,
  required int second,
  required Paint paint,
}) {
  if (!edges.contains(PreviewMeshEdgeKey(first, second))) {
    return;
  }

  canvas.drawLine(vertices[first].point, vertices[second].point, paint);
}

List<_PreviewMeshVertex>? _projectPreviewMeshVertices({
  required PreviewMesh mesh,
  required ViewportState viewportState,
  required MockViewportLayout layout,
}) {
  final bounds = _PreviewMeshBounds.fromMesh(mesh);
  if (!bounds.isUsable) {
    return null;
  }

  final rawVertices = <_PreviewMeshVertex>[];
  var minX = double.infinity;
  var minY = double.infinity;
  var maxX = -double.infinity;
  var maxY = -double.infinity;

  final yaw = viewportState.yawDegrees * math.pi / 180;
  final pitch = viewportState.pitchDegrees * math.pi / 180;
  final cosYaw = math.cos(yaw);
  final sinYaw = math.sin(yaw);
  final cosPitch = math.cos(pitch);
  final sinPitch = math.sin(pitch);

  for (var index = 0; index < mesh.vertexCount; index++) {
    final base = index * 3;
    final x = mesh.vertices[base] - bounds.centerX;
    final y = mesh.vertices[base + 1] - bounds.centerY;
    final z = mesh.vertices[base + 2] - bounds.centerZ;
    final yawX = x * cosYaw - y * sinYaw;
    final yawY = x * sinYaw + y * cosYaw;
    final pitchY = yawY * cosPitch - z * sinPitch;
    final depth = yawY * sinPitch + z * cosPitch;
    final point = Offset(yawX, -pitchY);

    minX = math.min(minX, point.dx);
    minY = math.min(minY, point.dy);
    maxX = math.max(maxX, point.dx);
    maxY = math.max(maxY, point.dy);
    rawVertices.add(_PreviewMeshVertex(point: point, depth: depth));
  }

  final projectedWidth = maxX - minX;
  final projectedHeight = maxY - minY;
  if (projectedWidth <= 0 || projectedHeight <= 0) {
    return null;
  }

  final targetRect = layout.bodyRect.inflate(18 * layout.zoom);
  final scale = math.min(
    targetRect.width / projectedWidth,
    targetRect.height / projectedHeight,
  );
  if (!scale.isFinite || scale <= 0) {
    return null;
  }

  final rawCenter = Offset((minX + maxX) / 2, (minY + maxY) / 2);
  return [
    for (final vertex in rawVertices)
      _PreviewMeshVertex(
        point: targetRect.center + (vertex.point - rawCenter) * scale,
        depth: vertex.depth,
      ),
  ];
}

ViewportHitResult? _hitTestPreviewMesh({
  required PreviewMesh? previewMesh,
  required Offset position,
  required Size size,
  required ViewportState state,
  required ProjectModel project,
  required MockViewportBodyDimensions bodyDimensions,
}) {
  final mesh = previewMesh;
  if (!_hasPreviewMesh(mesh) || mesh?.metadata['source'] != 'occt_brep') {
    return null;
  }

  final layout = MockViewportLayout.fromSize(
    size,
    state,
    bodyDimensions: bodyDimensions,
  );
  final vertices = _projectPreviewMeshVertices(
    mesh: mesh!,
    viewportState: state,
    layout: layout,
  );
  if (vertices == null) {
    return null;
  }

  String? bestSemanticId;
  var bestDepth = -double.infinity;
  for (final surface in mesh.surfaces) {
    for (final range in surface.triangleRanges) {
      final start = range.start.clamp(0, mesh.triangleCount).toInt();
      final end = (range.start + range.count)
          .clamp(0, mesh.triangleCount)
          .toInt();
      for (var index = start; index < end; index++) {
        final base = index * 3;
        final a = mesh.triangles[base];
        final b = mesh.triangles[base + 1];
        final c = mesh.triangles[base + 2];
        if (!_validPreviewMeshIndex(a, mesh.vertexCount) ||
            !_validPreviewMeshIndex(b, mesh.vertexCount) ||
            !_validPreviewMeshIndex(c, mesh.vertexCount)) {
          continue;
        }

        final aPoint = vertices[a].point;
        final bPoint = vertices[b].point;
        final cPoint = vertices[c].point;
        if (!_pointInPreviewTriangle(position, aPoint, bPoint, cPoint)) {
          continue;
        }

        final depth =
            (vertices[a].depth + vertices[b].depth + vertices[c].depth) / 3;
        if (depth >= bestDepth) {
          bestDepth = depth;
          bestSemanticId = surface.semanticId;
        }
      }
    }
  }

  return _previewMeshHitResult(project, bestSemanticId);
}

ViewportHitResult? _previewMeshHitResult(
  ProjectModel project,
  String? semanticId,
) {
  if (semanticId == null || semanticId.isEmpty) {
    return null;
  }

  if (project.features.any((feature) => feature.id == semanticId)) {
    return ViewportHitResult(
      kind: ViewportHitKind.feature,
      semanticId: semanticId,
    );
  }

  if (project.featureGroups.any((group) => group.id == semanticId)) {
    return ViewportHitResult(
      kind: ViewportHitKind.featureGroup,
      semanticId: semanticId,
    );
  }

  if (project.componentPlacements.any(
    (placement) => placement.id == semanticId,
  )) {
    return ViewportHitResult(
      kind: ViewportHitKind.componentPlacement,
      semanticId: semanticId,
    );
  }

  for (final body in project.bodies) {
    if (semanticId == body.id) {
      return ViewportHitResult(
        kind: ViewportHitKind.enclosure,
        semanticId: semanticId,
      );
    }
    if (semanticId.startsWith('${body.id}.')) {
      return ViewportHitResult(
        kind: ViewportHitKind.surface,
        semanticId: semanticId,
        parentId: body.id,
      );
    }
  }

  return null;
}

bool _pointInPreviewTriangle(Offset point, Offset a, Offset b, Offset c) {
  final denominator =
      (b.dy - c.dy) * (a.dx - c.dx) + (c.dx - b.dx) * (a.dy - c.dy);
  if (denominator.abs() < 0.000001) {
    return false;
  }

  final alpha =
      ((b.dy - c.dy) * (point.dx - c.dx) + (c.dx - b.dx) * (point.dy - c.dy)) /
      denominator;
  final beta =
      ((c.dy - a.dy) * (point.dx - c.dx) + (a.dx - c.dx) * (point.dy - c.dy)) /
      denominator;
  final gamma = 1 - alpha - beta;
  const tolerance = -0.001;
  return alpha >= tolerance && beta >= tolerance && gamma >= tolerance;
}

bool _nativeSemanticAnnotationsFocused(SelectionModel selection) {
  return selection.kind == SelectionKind.componentPlacement ||
      selection.kind == SelectionKind.componentTemplate ||
      selection.kind == SelectionKind.feature ||
      selection.kind == SelectionKind.featureGroup;
}

bool _nativeWorkplaneOverlayFocused({
  required SelectionModel selection,
  required MockViewportWorkplaneOverlay workplane,
  required _ActiveSnapTarget? activeSnapTarget,
}) {
  if (selection.kind == SelectionKind.componentPlacement &&
      selection.id == workplane.semanticId) {
    return true;
  }

  return activeSnapTarget != null &&
      activeSnapTarget.workplaneId == workplane.semanticId &&
      activeSnapTarget.workplaneKind == workplane.kind;
}

bool _hasSelectedPreviewSurface(PreviewMesh? mesh, SelectionModel selection) {
  if (!_hasPreviewMesh(mesh) ||
      !_selectionUsesPreviewSurfaceRanges(selection)) {
    return false;
  }

  return _previewSurfaceTriangleIndices(mesh!, selection.id).isNotEmpty;
}

bool _selectionUsesPreviewSurfaceRanges(SelectionModel selection) {
  return selection.kind == SelectionKind.surface ||
      selection.kind == SelectionKind.feature ||
      selection.kind == SelectionKind.featureGroup;
}

Set<int> _previewSurfaceTriangleIndices(PreviewMesh mesh, String? semanticId) {
  if (semanticId == null || semanticId.isEmpty) {
    return const {};
  }

  final indices = <int>{};
  for (final surface in mesh.surfaces) {
    if (surface.semanticId != semanticId) {
      continue;
    }

    for (final range in surface.triangleRanges) {
      final start = range.start.clamp(0, mesh.triangleCount).toInt();
      final end = (range.start + range.count)
          .clamp(0, mesh.triangleCount)
          .toInt();
      for (var index = start; index < end; index++) {
        indices.add(index);
      }
    }
  }

  return indices;
}

bool _validPreviewMeshIndex(int index, int vertexCount) {
  return index >= 0 && index < vertexCount;
}

bool _validBoundsList(List<double> values) {
  return values.length >= 3 && values.take(3).every((value) => value.isFinite);
}

double _previewTriangleShade(PreviewMesh mesh, int a, int b, int c) {
  final ax = _previewMeshX(mesh, a);
  final ay = _previewMeshY(mesh, a);
  final az = _previewMeshZ(mesh, a);
  final ux = _previewMeshX(mesh, b) - ax;
  final uy = _previewMeshY(mesh, b) - ay;
  final uz = _previewMeshZ(mesh, b) - az;
  final vx = _previewMeshX(mesh, c) - ax;
  final vy = _previewMeshY(mesh, c) - ay;
  final vz = _previewMeshZ(mesh, c) - az;
  final nx = uy * vz - uz * vy;
  final ny = uz * vx - ux * vz;
  final nz = ux * vy - uy * vx;
  final normalLength = math.sqrt(nx * nx + ny * ny + nz * nz);
  if (normalLength <= 0 || !normalLength.isFinite) {
    return 0.52;
  }

  const lightX = -0.35;
  const lightY = -0.48;
  const lightZ = 0.80;
  final dot = (nx * lightX + ny * lightY + nz * lightZ) / normalLength;
  return (0.54 + dot.abs() * 0.22).clamp(0.42, 0.78).toDouble();
}

double _previewMeshX(PreviewMesh mesh, int index) => mesh.vertices[index * 3];

double _previewMeshY(PreviewMesh mesh, int index) {
  return mesh.vertices[index * 3 + 1];
}

double _previewMeshZ(PreviewMesh mesh, int index) {
  return mesh.vertices[index * 3 + 2];
}

void _drawRotatedRRect(
  Canvas canvas,
  Rect rect,
  double rotationZDegrees,
  Radius radius,
  Paint paint,
) {
  canvas.save();
  canvas.translate(rect.center.dx, rect.center.dy);
  canvas.rotate(rotationZDegrees * math.pi / 180);
  canvas.translate(-rect.center.dx, -rect.center.dy);
  canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);
  canvas.restore();
}

MockViewportBodyDimensions _mockViewportBodyDimensions(ProjectModel project) {
  final enclosure = project.bodies.firstOrNull;
  if (enclosure == null) {
    return const MockViewportBodyDimensions();
  }

  return MockViewportBodyDimensions(
    width: _sizeAt(enclosure, 0, 120),
    depth: _sizeAt(enclosure, 1, 70),
    height: _sizeAt(enclosure, 2, 28),
    cornerRadius: enclosure.cornerRadius,
  );
}

List<MockViewportComponentPlacementPreview> _mockComponentPlacementPreviews(
  ProjectModel project,
) {
  final enclosure = project.bodies.firstOrNull;
  final referenceWidth = enclosure == null ? 120.0 : _sizeAt(enclosure, 0, 120);
  final referenceDepth = enclosure == null ? 70.0 : _sizeAt(enclosure, 1, 70);

  return [
    for (final placement in project.componentPlacements)
      if (placement.visible)
        MockViewportComponentPlacementPreview(
          semanticId: placement.id,
          width:
              _componentTemplateForProjectPlacement(
                project,
                placement,
              )?.board.outline.width ??
              40,
          depth:
              _componentTemplateForProjectPlacement(
                project,
                placement,
              )?.board.outline.height ??
              30,
          referenceWidth: referenceWidth,
          referenceDepth: referenceDepth,
          position: Offset(
            _positionAt(placement.position, 0),
            _positionAt(placement.position, 1),
          ),
          rotationZDegrees: _positionAt(placement.rotation, 2),
        ),
  ];
}

MockViewportComponentPlacementPreview? _mockActiveSnapPlacementPreview(
  ProjectModel project,
  _ActiveSnapTarget? snapTarget,
) {
  final placement = _activeSnapProspectivePlacement(project, snapTarget);
  return _mockPlacementCandidatePreview(project, placement);
}

MockViewportComponentPlacementPreview? _mockPlacementCandidatePreview(
  ProjectModel project,
  ComponentPlacement? placement,
) {
  if (placement == null) {
    return null;
  }

  final template = _componentTemplateForProjectPlacement(project, placement);
  if (template == null) {
    return null;
  }

  final enclosure = project.bodies.firstOrNull;
  final referenceWidth = enclosure == null ? 120.0 : _sizeAt(enclosure, 0, 120);
  final referenceDepth = enclosure == null ? 70.0 : _sizeAt(enclosure, 1, 70);

  return MockViewportComponentPlacementPreview(
    semanticId: placement.id,
    width: template.board.outline.width,
    depth: template.board.outline.height,
    referenceWidth: referenceWidth,
    referenceDepth: referenceDepth,
    position: Offset(
      _positionAt(placement.position, 0),
      _positionAt(placement.position, 1),
    ),
    rotationZDegrees: _positionAt(placement.rotation, 2),
  );
}

ComponentTemplate? _componentTemplateForProjectPlacement(
  ProjectModel project,
  ComponentPlacement placement,
) {
  return project.componentTemplates
      .where((template) => template.id == placement.templateId)
      .firstOrNull;
}

MockViewportWorkplaneOverlay? _mockWorkplaneOverlay(
  ProjectModel project,
  SelectionModel selection,
) {
  final enclosure = project.bodies.firstOrNull;
  final referenceWidth = enclosure == null ? 120.0 : _sizeAt(enclosure, 0, 120);
  final referenceDepth = enclosure == null ? 70.0 : _sizeAt(enclosure, 1, 70);
  final referenceHeight = enclosure == null ? 28.0 : _sizeAt(enclosure, 2, 28);

  if (selection.kind == SelectionKind.surface) {
    final surfaceId = selection.id ?? '';
    if (surfaceId.contains('top_lid')) {
      return MockViewportWorkplaneOverlay(
        semanticId: surfaceId,
        kind: MockViewportWorkplaneKind.topLid,
        width: referenceWidth,
        height: referenceDepth,
        referenceWidth: referenceWidth,
        referenceHeight: referenceDepth,
        snapPoints: _mockSurfaceSnapPoints(referenceWidth, referenceDepth),
      );
    }
    if (surfaceId.contains('front_wall')) {
      return MockViewportWorkplaneOverlay(
        semanticId: surfaceId,
        kind: MockViewportWorkplaneKind.frontWall,
        width: referenceWidth,
        height: referenceHeight,
        referenceWidth: referenceWidth,
        referenceHeight: referenceHeight,
        snapPoints: _mockSurfaceSnapPoints(referenceWidth, referenceHeight),
      );
    }
  }

  if (selection.kind == SelectionKind.componentPlacement) {
    final placement = project.componentPlacements
        .where((placement) => placement.id == selection.id)
        .firstOrNull;
    if (placement == null || !placement.visible) {
      return null;
    }

    final template = _componentTemplateForProjectPlacement(project, placement);
    final outline = template?.board.outline;
    final boardWidth = outline?.width ?? 40.0;
    final boardHeight = outline?.height ?? 30.0;
    final mountingPoints = [
      Offset.zero,
      for (final hole in template?.mountingHoles ?? const [])
        Offset(_positionAt(hole.position, 0), _positionAt(hole.position, 1)),
    ];

    return MockViewportWorkplaneOverlay(
      semanticId: placement.id,
      kind: MockViewportWorkplaneKind.componentPlacement,
      width: boardWidth,
      height: boardHeight,
      referenceWidth: referenceWidth,
      referenceHeight: referenceDepth,
      position: Offset(
        _positionAt(placement.position, 0),
        _positionAt(placement.position, 1),
      ),
      rotationZDegrees: _positionAt(placement.rotation, 2),
      snapPoints: mountingPoints,
    );
  }

  return null;
}

List<Offset> _mockSurfaceSnapPoints(double width, double height) {
  return [
    Offset.zero,
    Offset(width / 4, 0),
    Offset(-width / 4, 0),
    Offset(0, height / 4),
    Offset(0, -height / 4),
  ];
}

bool _snapTargetMatches(
  _ActiveSnapTarget? target,
  MockViewportWorkplaneOverlay workplane,
  Offset localPoint,
) {
  if (target == null || target.workplaneId != workplane.semanticId) {
    return false;
  }

  return (target.localPosition - localPoint).distance < 0.001;
}

List<MockViewportFeaturePreview> _mockFeaturePreviews(ProjectModel project) {
  final previews = <MockViewportFeaturePreview>[];
  final slotsBySurface = <String, int>{};

  for (final feature in project.features) {
    final slotKey = '${feature.type}:${feature.targetSurface}';
    final slotIndex = slotsBySurface[slotKey] ?? 0;
    final preview = _mockFeaturePreview(project, feature, slotIndex);
    if (preview != null) {
      previews.add(preview);
      slotsBySurface[slotKey] = slotIndex + 1;
    }
  }

  return previews;
}

MockViewportFeaturePreview? _mockFeaturePreview(
  ProjectModel project,
  SemanticFeature feature,
  int slotIndex,
) {
  final enclosure = project.bodies.firstOrNull;
  final referenceWidth = enclosure == null ? 120.0 : _sizeAt(enclosure, 0, 120);
  final referenceHeight = enclosure == null
      ? 70.0
      : feature.targetSurface.contains('front_wall')
      ? _sizeAt(enclosure, 2, 28)
      : _sizeAt(enclosure, 1, 70);

  return switch (feature.type) {
    'usb_c_cutout' => MockViewportFeaturePreview(
      semanticId: feature.id,
      kind: MockViewportFeatureKind.usbC,
      targetSurfaceId: feature.targetSurface,
      width: _featureDouble(feature.parameters, 'width', 10.5),
      height: _featureDouble(feature.parameters, 'height', 4.2),
      cornerRadius: _featureDouble(feature.parameters, 'cornerRadius', 1.0),
      referenceWidth: referenceWidth,
      referenceHeight: referenceHeight,
      slotIndex: slotIndex,
    ),
    'glass_recess' => MockViewportFeaturePreview(
      semanticId: feature.id,
      kind: MockViewportFeatureKind.glassRecess,
      targetSurfaceId: feature.targetSurface,
      width: _featureDouble(feature.parameters, 'width', 42),
      height: _featureDouble(feature.parameters, 'height', 24),
      cornerRadius: _featureDouble(feature.parameters, 'cornerRadius', 2),
      referenceWidth: referenceWidth,
      referenceHeight: referenceHeight,
      slotIndex: slotIndex,
    ),
    'circular_cutout' => MockViewportFeaturePreview(
      semanticId: feature.id,
      kind: MockViewportFeatureKind.circularCutout,
      targetSurfaceId: feature.targetSurface,
      width: _featureDouble(feature.parameters, 'diameter', 8),
      height: _featureDouble(feature.parameters, 'diameter', 8),
      cornerRadius: _featureDouble(feature.parameters, 'diameter', 8) / 2,
      position: Offset(
        _featureDouble(feature.parameters, 'positionX', 0),
        _featureDouble(feature.parameters, 'positionY', 0),
      ),
      referenceWidth: referenceWidth,
      referenceHeight: referenceHeight,
      slotIndex: slotIndex,
    ),
    _ => null,
  };
}

List<MockViewportFeatureGroupPreview> _mockFeatureGroupPreviews(
  ProjectModel project,
) {
  final previews = <MockViewportFeatureGroupPreview>[];

  for (final group in project.featureGroups) {
    final preview = _mockFeatureGroupPreview(project, group);
    if (preview != null) {
      previews.add(preview);
    }
  }

  return previews;
}

MockViewportFeatureGroupPreview? _mockFeatureGroupPreview(
  ProjectModel project,
  FeatureGroup group,
) {
  return switch (group.type) {
    'button_group' => _mockButtonGroupPreview(project, group),
    'standoff_mounts' => _mockStandoffMountPreview(project, group),
    _ => null,
  };
}

MockViewportFeatureGroupPreview? _mockButtonGroupPreview(
  ProjectModel project,
  FeatureGroup group,
) {
  final positions = _buttonGroupPatternPositions(group);
  if (positions.isEmpty) {
    return null;
  }

  final enclosure = project.bodies.firstOrNull;
  return MockViewportFeatureGroupPreview(
    semanticId: group.id,
    kind: MockViewportFeatureGroupKind.buttonGroup,
    sourcePositions: positions,
    referenceWidth: enclosure == null ? 120 : _sizeAt(enclosure, 0, 120),
    referenceHeight: enclosure == null ? 70 : _sizeAt(enclosure, 1, 70),
    itemDiameter: _featureDouble(group.itemPrototype, 'diameter', 8),
  );
}

MockViewportFeatureGroupPreview? _mockStandoffMountPreview(
  ProjectModel project,
  FeatureGroup group,
) {
  final template = _templateForMockFeatureGroup(project, group);
  final positions = [
    for (final point in PatternLayoutEngine.standoffMountPositions(
      group,
      fallbackTemplate: template,
    ))
      Offset(point.x, point.y),
  ];

  if (positions.isEmpty) {
    return null;
  }

  return MockViewportFeatureGroupPreview(
    semanticId: group.id,
    kind: MockViewportFeatureGroupKind.standoffMounts,
    sourcePositions: positions,
    referenceWidth: template?.board.outline.width ?? 48,
    referenceHeight: template?.board.outline.height ?? 32,
    itemDiameter: _featureDouble(group.itemPrototype, 'diameter', 5),
  );
}

ComponentTemplate? _templateForMockFeatureGroup(
  ProjectModel project,
  FeatureGroup group,
) {
  final sourceTemplateId = _featureString(
    group.pattern,
    'sourceTemplateId',
    '',
  );
  if (sourceTemplateId.isNotEmpty) {
    final template = project.componentTemplates
        .where((template) => template.id == sourceTemplateId)
        .firstOrNull;
    if (template != null) {
      return template;
    }
  }

  final sourcePlacementId = _featureString(
    group.placement,
    'componentPlacementId',
    _featureString(group.pattern, 'sourcePlacementId', ''),
  );
  final placement = project.componentPlacements
      .where((placement) => placement.id == sourcePlacementId)
      .firstOrNull;
  if (placement == null) {
    return null;
  }

  return project.componentTemplates
      .where((template) => template.id == placement.templateId)
      .firstOrNull;
}

List<Offset> _buttonGroupPatternPositions(FeatureGroup group) {
  return [
    for (final point in PatternLayoutEngine.buttonGroupPositions(group))
      Offset(point.x, point.y),
  ];
}

double _sizeAt(Enclosure enclosure, int index, double fallback) {
  return enclosure.size.length > index ? enclosure.size[index] : fallback;
}
