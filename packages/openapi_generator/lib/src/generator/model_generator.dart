import '../parser/openapi_spec.dart';

/// Generates Dart model classes from OpenAPI schemas.
class ModelGenerator {
  final OpenApiSpec spec;

  ModelGenerator(this.spec);

  /// Generate all model files as a map of filename -> content.
  Map<String, String> generate() {
    final files = <String, String>{};
    for (final schema in spec.schemas.values) {
      if (schema.isEnum) {
        files['${_toSnakeCase(schema.name)}.dart'] = _generateEnum(schema);
      } else {
        files['${_toSnakeCase(schema.name)}.dart'] = _generateModel(schema);
      }
    }
    return files;
  }

  /// Generate a single model class file.
  String _generateModel(OpenApiSchema schema) {
    final buffer = StringBuffer();

    // Imports
    final imports = <String>{};
    for (final field in schema.fields) {
      if (field.ref != null && field.ref != schema.name) {
        imports.add("import '${_toSnakeCase(field.ref!)}.dart';");
      }
      if (field.itemType != null && _isModelType(field.itemType!)) {
        imports.add("import '${_toSnakeCase(field.itemType!)}.dart';");
      }
    }
    for (final import in imports.toList()..sort()) {
      buffer.writeln(import);
    }
    if (imports.isNotEmpty) buffer.writeln();

    // Class declaration
    buffer.writeln('class ${schema.name} {');

    // Fields
    for (final field in schema.fields) {
      if (field.description != null) {
        buffer.writeln('  /// ${field.description}');
      }
      final dartType = _fieldType(field);
      final nullable = field.isNullable ? '?' : '';
      buffer.writeln('  final $dartType$nullable ${field.name};');
    }
    buffer.writeln();

    // Constructor
    buffer.writeln('  const ${schema.name}({');
    for (final field in schema.fields) {
      if (field.isRequired && !field.isNullable) {
        buffer.writeln('    required this.${field.name},');
      } else {
        buffer.writeln('    this.${field.name},');
      }
    }
    buffer.writeln('  });');
    buffer.writeln();

    // fromJson
    buffer.writeln('  factory ${schema.name}.fromJson(Map<String, dynamic> json) {');
    buffer.writeln('    return ${schema.name}(');
    for (final field in schema.fields) {
      final parseExpr = _fromJsonParse('json[\'${field.name}\']', field);
      buffer.writeln('      ${field.name}: $parseExpr,');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();

    // toJson
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer.writeln('    return {');
    for (final field in schema.fields) {
      final value = field.isNullable
          ? '${field.name}?.${_toJsonExpr(field)}'
          : _toJsonExpr(field);
      buffer.writeln("      '${field.name}': $value,");
    }
    buffer.writeln('    };');
    buffer.writeln('  }');
    buffer.writeln();

    // copyWith
    buffer.writeln('  ${schema.name} copyWith({');
    for (final field in schema.fields) {
      final dartType = _fieldType(field);
      final nullable = field.isNullable ? '?' : '';
      buffer.writeln('    $dartType$nullable? ${field.name},');
    }
    buffer.writeln('  }) {');
    buffer.writeln('    return ${schema.name}(');
    for (final field in schema.fields) {
      buffer.writeln('      ${field.name}: ${field.name} ?? this.${field.name},');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();

    // toString
    buffer.writeln('  @override');
    buffer.writeln('  String toString() {');
    buffer.writeln("    return '${schema.name}(${schema.fields.map((f) => '${f.name}: \${${f.name}}').join(', ')}';");
    buffer.writeln('  }');

    buffer.writeln('}');
    return buffer.toString();
  }

  /// Generate an enum.
  String _generateEnum(OpenApiSchema schema) {
    final buffer = StringBuffer();
    buffer.writeln('enum ${schema.name} {');
    for (final value in schema.enumValues) {
      final dartName = _enumValue(value);
      buffer.writeln("  $dartName('${value}'),");
    }
    buffer.writeln('  ;');
    buffer.writeln();
    buffer.writeln('  final String value;');
    buffer.writeln('  const ${schema.name}(this.value);');
    buffer.writeln();
    buffer.writeln('  static ${schema.name} fromString(String value) {');
    buffer.writeln('    return ${schema.name}.values.firstWhere(');
    buffer.writeln('      (e) => e.value == value,');
    buffer.writeln("      orElse: () => throw ArgumentError('Unknown \$value for ${schema.name}'),");
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');
    return buffer.toString();
  }

  String _fieldType(OpenApiField field) {
    if (field.isList) {
      final item = field.itemType ?? 'dynamic';
      return 'List<$item>';
    }
    if (field.ref != null) return field.ref!;
    return field.type;
  }

  String _fromJsonParse(String access, OpenApiField field) {
    if (field.isList) {
      final item = field.itemType ?? 'dynamic';
      final cast = _isModelType(item) ? '$item.fromJson(e as Map<String, dynamic>)' : 'e as $item';
      return '($access as List<dynamic>?)?.map((e) => $cast).toList()';
    }
    if (field.ref != null) {
      if (field.isNullable) {
        return '$access != null ? ${field.ref}.fromJson($access as Map<String, dynamic>) : null';
      }
      return '${field.ref}.fromJson($access as Map<String, dynamic>)';
    }
    switch (field.type) {
      case 'int':
        return '${field.isNullable ? '($access as int?)' : '($access as int)'}';
      case 'double':
        return '${field.isNullable ? '($access as double?)' : '($access as double)'}';
      case 'bool':
        return '${field.isNullable ? '($access as bool?)' : '($access as bool)'}';
      case 'DateTime':
        return field.isNullable
            ? '($access as String?) == null ? null : DateTime.parse($access as String)'
            : 'DateTime.parse($access as String)';
      case 'String':
        return '${field.isNullable ? '($access as String?)' : '($access as String)'}';
      default:
        return '$access as ${field.type}${field.isNullable ? '?' : ''}';
    }
  }

  String _toJsonExpr(OpenApiField field) {
    if (field.isList) {
      return 'map((e) => ${_isModelType(field.itemType ?? '') ? 'e.toJson()' : 'e'}).toList()';
    }
    if (field.ref != null) return 'toJson()';
    if (field.type == 'DateTime') return 'toIso8601String()';
    return '';
  }

  bool _isModelType(String type) {
    return spec.schemas.containsKey(type);
  }

  String _enumValue(String value) {
    final name = value
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9_]'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return name.isEmpty ? 'UNKNOWN' : name;
  }

  String _toSnakeCase(String input) {
    return input
        .replaceAll(RegExp(r'([A-Z])'), r'_$1')
        .toLowerCase()
        .replaceAll(RegExp(r'^_+'), '');
  }
}
