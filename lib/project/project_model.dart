import 'dart:convert';

import 'component_placement.dart';
import 'component_template.dart';
import 'enclosure.dart';
import 'feature.dart';
import 'feature_group.dart';
import 'json_helpers.dart';
import 'project_migration.dart';
import 'schema.dart';

export 'component_placement.dart';
export 'component_template.dart';
export 'enclosure.dart';
export 'feature.dart';
export 'feature_group.dart';
export 'project_file_service.dart';
export 'project_migration.dart';
export 'schema.dart';

class ProjectModel {
  const ProjectModel({
    this.schema = ProjectSchema.name,
    this.version = ProjectSchema.currentVersion,
    this.units = 'mm',
    required this.projectName,
    required this.printerProfile,
    required this.bodies,
    this.componentTemplates = const [],
    required this.componentPlacements,
    required this.features,
    this.featureGroups = const [],
    this.constraints = const [],
    this.exports = const [],
    this.metadata = const {},
  });

  static const currentSchema = ProjectSchema.name;
  static const currentVersion = ProjectSchema.currentVersion;

  final String schema;
  final int version;
  final String units;
  final String projectName;
  final String printerProfile;
  final List<Enclosure> bodies;
  final List<ComponentTemplate> componentTemplates;
  final List<ComponentPlacement> componentPlacements;
  final List<SemanticFeature> features;
  final List<FeatureGroup> featureGroups;
  final List<Map<String, Object?>> constraints;
  final List<Map<String, Object?>> exports;
  final Map<String, Object?> metadata;

  ProjectModel copyWith({
    String? schema,
    int? version,
    String? units,
    String? projectName,
    String? printerProfile,
    List<Enclosure>? bodies,
    List<ComponentTemplate>? componentTemplates,
    List<ComponentPlacement>? componentPlacements,
    List<SemanticFeature>? features,
    List<FeatureGroup>? featureGroups,
    List<Map<String, Object?>>? constraints,
    List<Map<String, Object?>>? exports,
    Map<String, Object?>? metadata,
  }) {
    return ProjectModel(
      schema: schema ?? this.schema,
      version: version ?? this.version,
      units: units ?? this.units,
      projectName: projectName ?? this.projectName,
      printerProfile: printerProfile ?? this.printerProfile,
      bodies: bodies ?? this.bodies,
      componentTemplates: componentTemplates ?? this.componentTemplates,
      componentPlacements: componentPlacements ?? this.componentPlacements,
      features: features ?? this.features,
      featureGroups: featureGroups ?? this.featureGroups,
      constraints: constraints ?? this.constraints,
      exports: exports ?? this.exports,
      metadata: metadata ?? this.metadata,
    );
  }

  ProjectModel replaceEnclosure(Enclosure enclosure) {
    var replaced = false;
    final nextBodies = <Enclosure>[];

    for (final body in bodies) {
      if (body.id == enclosure.id) {
        nextBodies.add(enclosure);
        replaced = true;
      } else {
        nextBodies.add(body);
      }
    }

    return copyWith(bodies: replaced ? nextBodies : [...bodies, enclosure]);
  }

  ProjectModel replaceComponentPlacement(ComponentPlacement placement) {
    var replaced = false;
    final nextPlacements = <ComponentPlacement>[];

    for (final existing in componentPlacements) {
      if (existing.id == placement.id) {
        nextPlacements.add(placement);
        replaced = true;
      } else {
        nextPlacements.add(existing);
      }
    }

    return copyWith(
      componentPlacements: replaced
          ? nextPlacements
          : [...componentPlacements, placement],
    );
  }

  ProjectModel replaceFeature(SemanticFeature feature) {
    var replaced = false;
    final nextFeatures = <SemanticFeature>[];

    for (final existing in features) {
      if (existing.id == feature.id) {
        nextFeatures.add(feature);
        replaced = true;
      } else {
        nextFeatures.add(existing);
      }
    }

    return copyWith(features: replaced ? nextFeatures : [...features, feature]);
  }

  ProjectModel replaceFeatureGroup(FeatureGroup group) {
    var replaced = false;
    final nextGroups = <FeatureGroup>[];

    for (final existing in featureGroups) {
      if (existing.id == group.id) {
        nextGroups.add(group);
        replaced = true;
      } else {
        nextGroups.add(existing);
      }
    }

    return copyWith(
      featureGroups: replaced ? nextGroups : [...featureGroups, group],
    );
  }

  factory ProjectModel.initial() {
    return ProjectModel(
      projectName: 'Sample Button Board Case',
      printerProfile: 'fdm_04_normal',
      bodies: const [
        Enclosure(
          id: 'main_enclosure',
          shape: 'rounded_box',
          size: [120, 70, 28],
          wallThickness: 2,
          cornerRadius: 4,
          lid: LidSpec(type: 'top_screw_lid', clearanceProfile: 'fdm_normal'),
        ),
      ],
      componentTemplates: [ComponentTemplate.buttonBoard()],
      componentPlacements: const [
        ComponentPlacement(
          id: 'button_board_placement',
          templateId: 'custom_button_board_v1',
          position: [0, 0, 4],
          rotation: [0, 0, 0],
          mountingSide: 'bottom_inside',
          locked: false,
        ),
      ],
      features: const [
        SemanticFeature(
          id: 'front_usb_c',
          type: 'usb_c_cutout',
          targetSurface: 'main_enclosure.front_wall.outer',
          operation: 'negative',
          parameters: {
            'width': 10.5,
            'height': 4.2,
            'cornerRadius': 1.0,
            'clearanceProfile': 'fdm_normal',
          },
        ),
        SemanticFeature(
          id: 'abxy_buttons',
          type: 'button_group',
          targetSurface: 'main_enclosure.top_lid.outer',
          operation: 'composite',
          parameters: {
            'pattern': 'diamond',
            'count': 4,
            'diameter': 8.0,
            'travel': 0.8,
            'switchClearance': 0.3,
            'guideClearance': 0.25,
            'mode': 'plunger',
          },
        ),
      ],
    );
  }

  factory ProjectModel.fromJson(Map<String, Object?> json) {
    final migrated = ProjectMigration.migrate(json);

    return ProjectModel(
      schema: readString(migrated['schema'], fallback: ProjectSchema.name),
      version: readInt(
        migrated['version'],
        fallback: ProjectSchema.currentVersion,
      ),
      units: readString(migrated['units'], fallback: 'mm'),
      projectName: readString(
        migrated['projectName'],
        fallback: 'Untitled Device',
      ),
      printerProfile: readString(
        migrated['printerProfile'],
        fallback: 'fdm_04_normal',
      ),
      bodies: readObjectList(migrated['bodies'], Enclosure.fromJson),
      componentTemplates: readObjectList(
        migrated['componentTemplates'],
        ComponentTemplate.fromJson,
      ),
      componentPlacements: readObjectList(
        migrated['componentPlacements'],
        ComponentPlacement.fromJson,
      ),
      features: readObjectList(migrated['features'], SemanticFeature.fromJson),
      featureGroups: readObjectList(
        migrated['featureGroups'],
        FeatureGroup.fromJson,
      ),
      constraints: readJsonMapList(migrated['constraints']),
      exports: readJsonMapList(migrated['exports']),
      metadata: readJsonMap(migrated['metadata']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'schema': schema,
      'version': version,
      'units': units,
      'projectName': projectName,
      'printerProfile': printerProfile,
      'bodies': bodies.map((body) => body.toJson()).toList(),
      'componentTemplates': componentTemplates
          .map((template) => template.toJson())
          .toList(),
      'componentPlacements': componentPlacements
          .map((placement) => placement.toJson())
          .toList(),
      'features': features.map((feature) => feature.toJson()).toList(),
      'featureGroups': featureGroups.map((group) => group.toJson()).toList(),
      'constraints': constraints,
      'exports': exports,
      ...metadata,
    };
  }

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
