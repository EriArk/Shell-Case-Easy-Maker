import 'json_helpers.dart';
import 'schema.dart';

class ProjectMigration {
  const ProjectMigration._();

  static Map<String, Object?> migrate(Map<String, Object?> source) {
    final version = readInt(
      source['version'],
      fallback: ProjectSchema.currentVersion,
    );
    if (version > ProjectSchema.currentVersion) {
      throw UnsupportedError(
        'Project version $version is newer than supported version '
        '${ProjectSchema.currentVersion}.',
      );
    }

    return {
      'schema': readString(source['schema'], fallback: ProjectSchema.name),
      'version': version,
      'units': readString(source['units'], fallback: 'mm'),
      'projectName': readString(
        source['projectName'],
        fallback: 'Untitled Device',
      ),
      'printerProfile': readString(
        source['printerProfile'],
        fallback: 'fdm_04_normal',
      ),
      'bodies': source['bodies'] ?? const [],
      'componentTemplates': source['componentTemplates'] ?? const [],
      'componentPlacements': source['componentPlacements'] ?? const [],
      'features': source['features'] ?? const [],
      'featureGroups': source['featureGroups'] ?? const [],
      'constraints': source['constraints'] ?? const [],
      'exports': source['exports'] ?? const [],
      'metadata': withoutKeys(source, const {
        'schema',
        'version',
        'units',
        'projectName',
        'printerProfile',
        'bodies',
        'componentTemplates',
        'componentPlacements',
        'features',
        'featureGroups',
        'constraints',
        'exports',
      }),
    };
  }
}
