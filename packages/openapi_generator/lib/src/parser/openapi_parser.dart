import 'dart:convert';
import 'package:yaml/yaml.dart';
import 'openapi_spec.dart';

/// Parses OpenAPI 3.x specs from JSON or YAML strings.
class OpenApiParser {
  final Map<String, dynamic> _doc;

  OpenApiParser._(this._doc);

  /// Parse from a JSON string.
  factory OpenApiParser.fromJson(String json) {
    return OpenApiParser._(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Parse from a YAML string.
  factory OpenApiParser.fromYaml(String yaml) {
    final doc = loadYaml(yaml);
    return OpenApiParser._(_yamlToMap(doc));
  }

  /// Auto-detect format and parse.
  factory OpenApiParser.parse(String content) {
    final trimmed = content.trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      return OpenApiParser.fromJson(content);
    }
    return OpenApiParser.fromYaml(content);
  }

  /// Parse the full spec.
  OpenApiSpec parse() {
    final info = _doc['info'] as Map<String, dynamic>? ?? {};
    final servers = _doc['servers'] as List<dynamic>? ?? [];

    String? baseUrl;
    if (servers.isNotEmpty) {
      final first = servers[0];
      if (first is Map<String, dynamic>) {
        baseUrl = first['url'] as String?;
      } else if (first is String) {
        baseUrl = first;
      }
    }

    return OpenApiSpec(
      title: info['title'] as String?,
      description: info['description'] as String?,
      version: info['version'] as String?,
      baseUrl: baseUrl,
      schemas: _parseSchemas(),
      paths: _parsePaths(),
      securitySchemes: _parseSecuritySchemes(),
    );
  }

  Map<String, OpenApiSchema> _parseSchemas() {
    final components = _doc['components'] as Map<String, dynamic>?;
    final schemas = components?['schemas'] as Map<String, dynamic>? ?? {};

    // Also handle Swagger 2.0 definitions
    final definitions = _doc['definitions'] as Map<String, dynamic>? ?? {};

    final all = {...definitions, ...schemas};
    return all.map((name, schema) {
      final m = schema as Map<String, dynamic>;
      return MapEntry(name, _parseSchema(name, m));
    });
  }

  OpenApiSchema _parseSchema(String name, Map<String, dynamic> m) {
    // Check for enum
    if (m.containsKey('enum')) {
      return OpenApiSchema(
        name: name,
        description: m['description'] as String?,
        isEnum: true,
        enumValues: (m['enum'] as List<dynamic>).map((e) => e.toString()).toList(),
      );
    }

    final props = m['properties'] as Map<String, dynamic>? ?? {};
    final required = (m['required'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    final fields = props.entries.map((entry) {
      return _parseField(entry.key, entry.value as Map<String, dynamic>, required.contains(entry.key));
    }).toList();

    // Handle allOf (merge fields from referenced schemas)
    if (m.containsKey('allOf')) {
      for (final item in m['allOf'] as List<dynamic>) {
        final itemMap = item as Map<String, dynamic>;
        if (itemMap.containsKey('\$ref')) {
          final refName = _refName(itemMap['\$ref'] as String);
          fields.insert(0, OpenApiField(
            name: _toFieldName(refName),
            type: refName,
            ref: refName,
            isRequired: true,
          ));
        }
        if (itemMap.containsKey('properties')) {
          final subProps = itemMap['properties'] as Map<String, dynamic>;
          final subRequired = (itemMap['required'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[];
          for (final entry in subProps.entries) {
            fields.add(_parseField(entry.key, entry.value as Map<String, dynamic>, subRequired.contains(entry.key)));
          }
        }
      }
    }

    return OpenApiSchema(
      name: name,
      description: m['description'] as String?,
      fields: fields,
      requiredFields: required,
    );
  }

  OpenApiField _parseField(String name, Map<String, dynamic> m, bool isRequired) {
    final type = _resolveType(m);
    final ref = m['\$ref'] as String?;
    final refName = ref != null ? _refName(ref) : null;

    // Handle allOf in field (inline object merge)
    if (m.containsKey('allOf')) {
      final allOf = m['allOf'] as List<dynamic>;
      if (allOf.length == 1) {
        final item = allOf[0] as Map<String, dynamic>;
        if (item.containsKey('\$ref')) {
          final rn = _refName(item['\$ref'] as String);
          return OpenApiField(
            name: name,
            type: rn,
            ref: rn,
            isRequired: isRequired,
            isNullable: m['nullable'] == true,
          );
        }
      }
    }

    return OpenApiField(
      name: name,
      type: type,
      ref: refName,
      description: m['description'] as String?,
      isRequired: isRequired,
      isNullable: m['nullable'] == true || m['x-nullable'] == true,
      isList: type == 'List',
      itemType: m['items'] != null ? _resolveType(m['items'] as Map<String, dynamic>) : null,
      defaultValue: m['default']?.toString(),
    );
  }

  Map<String, OpenApiPath> _parsePaths() {
    final paths = _doc['paths'] as Map<String, dynamic>? ?? {};
    return paths.map((path, methods) {
      final m = methods as Map<String, dynamic>;
      final operations = <OpenApiOperation>[];

      for (final method in ['get', 'post', 'put', 'patch', 'delete', 'head', 'options']) {
        if (m.containsKey(method)) {
          final op = m[method] as Map<String, dynamic>;
          operations.add(_parseOperation(method, path, op));
        }
      }

      return MapEntry(path, OpenApiPath(path: path, operations: operations));
    });
  }

  OpenApiOperation _parseOperation(String method, String path, Map<String, dynamic> m) {
    final params = (m['parameters'] as List<dynamic>?)?.map((p) {
      final pm = p as Map<String, dynamic>;
      final ref = pm['\$ref'] as String?;
      if (ref != null) {
        // Inline resolve parameter reference
        final parts = ref.split('/');
        final paramName = parts.last;
        final components = _doc['components'] as Map<String, dynamic>?;
        final paramDef = components?['parameters'] as Map<String, dynamic>?;
        if (paramDef != null && paramDef.containsKey(paramName)) {
          return _parseParameter(paramDef[paramName] as Map<String, dynamic>);
        }
      }
      return _parseParameter(pm);
    }).toList() ?? [];

    final requestBody = _parseRequestBody(m['requestBody'] as Map<String, dynamic>?);
    final responses = _parseResponses(m['responses'] as Map<String, dynamic>?);
    final security = (m['security'] as List<dynamic>?)?.map((s) {
      if (s is Map<String, dynamic>) {
        return s.keys.map((k) => k).toList();
      }
      return <String>[];
    }).toList();

    return OpenApiOperation(
      method: method.toUpperCase(),
      path: path,
      operationId: m['operationId'] as String?,
      summary: m['summary'] as String?,
      description: m['description'] as String?,
      parameters: params,
      requestBody: requestBody,
      responses: responses,
      security: security ?? [],
    );
  }

  OpenApiParameter _parseParameter(Map<String, dynamic> m) {
    final schema = m['schema'] as Map<String, dynamic>?;
    return OpenApiParameter(
      name: m['name'] as String? ?? '',
      description: m['description'] as String?,
      location: m['in'] as String? ?? 'query',
      isRequired: m['required'] == true,
      type: schema != null ? _resolveType(schema) : 'dynamic',
      ref: schema?['\$ref'] != null ? _refName(schema!['\$ref'] as String) : null,
      isList: schema?['type'] == 'array',
      itemType: schema?['items'] != null ? _resolveType(schema!['items'] as Map<String, dynamic>) : null,
    );
  }

  OpenApiRequestBody? _parseRequestBody(Map<String, dynamic>? m) {
    if (m == null) return null;

    final content = m['content'] as Map<String, dynamic>?;
    String? ref;
    String? contentType;

    if (content != null) {
      for (final entry in content.entries) {
        contentType = entry.key;
        final mediaType = entry.value as Map<String, dynamic>;
        final schema = mediaType['schema'] as Map<String, dynamic>?;
        if (schema != null) {
          if (schema.containsKey('\$ref')) {
            ref = _refName(schema['\$ref'] as String);
          } else if (schema.containsKey('allOf')) {
            final allOf = schema['allOf'] as List<dynamic>;
            for (final item in allOf) {
              if ((item as Map<String, dynamic>).containsKey('\$ref')) {
                ref = _refName(item['\$ref'] as String);
                break;
              }
            }
          }
        }
        break; // Use first content type
      }
    }

    return OpenApiRequestBody(
      description: m['description'] as String?,
      isRequired: m['required'] == true,
      ref: ref,
      contentType: contentType,
    );
  }

  Map<String, OpenApiResponse> _parseResponses(Map<String, dynamic>? m) {
    if (m == null) return {};
    return m.map((status, resp) {
      final rm = resp as Map<String, dynamic>;
      String? ref;
      final content = rm['content'] as Map<String, dynamic>?;
      if (content != null) {
        for (final entry in content.entries) {
          final mediaType = entry.value as Map<String, dynamic>;
          final schema = mediaType['schema'] as Map<String, dynamic>?;
          if (schema != null && schema.containsKey('\$ref')) {
            ref = _refName(schema['\$ref'] as String);
          }
          break;
        }
      }
      return MapEntry(status, OpenApiResponse(
        statusCode: status,
        description: rm['description'] as String?,
        ref: ref,
      ));
    });
  }

  Map<String, OpenApiSecurityScheme> _parseSecuritySchemes() {
    final components = _doc['components'] as Map<String, dynamic>?;
    final schemes = components?['securitySchemes'] as Map<String, dynamic>? ??
        _doc['securityDefinitions'] as Map<String, dynamic>? ??
        {};

    return schemes.map((name, scheme) {
      final m = scheme as Map<String, dynamic>;
      return MapEntry(name, OpenApiSecurityScheme(
        name: name,
        type: m['type'] as String? ?? 'http',
        scheme: m['scheme'] as String?,
        bearerFormat: m['bearerFormat'] as String?,
        location: m['in'] as String?,
      ));
    });
  }

  // --- Type Resolution ---

  String _resolveType(Map<String, dynamic> m) {
    // $ref takes priority
    if (m.containsKey('\$ref')) {
      return _refName(m['\$ref'] as String);
    }

    final type = m['type'] as String?;
    switch (type) {
      case 'integer':
        return m['format'] == 'int64' ? 'int' : 'int';
      case 'number':
        return m['format'] == 'float' ? 'double' : 'double';
      case 'boolean':
        return 'bool';
      case 'string':
        switch (m['format']) {
          case 'date':
          case 'date-time':
            return 'DateTime';
          case 'binary':
            return 'Uint8List';
          case 'byte':
            return 'String';
          default:
            return 'String';
        }
      case 'array':
        return 'List';
      case 'object':
        if (m.containsKey('additionalProperties')) {
          return 'Map';
        }
        return 'Map<String, dynamic>';
      default:
        return 'dynamic';
    }
  }

  String _refName(String ref) => ref.split('/').last;

  String _toFieldName(String refName) {
    return refName[0].toLowerCase() + refName.substring(1);
  }

  // --- YAML Helpers ---

  static Map<String, dynamic> _yamlToMap(dynamic yaml) {
    if (yaml is YamlMap) {
      return yaml.map((k, v) => MapEntry(k.toString(), _yamlToMap(v)));
    }
    if (yaml is YamlList) {
      return {for (var i = 0; i < yaml.length; i++) '$i': _yamlToMap(yaml[i])};
    }
    return {'_value': yaml};
  }
}
