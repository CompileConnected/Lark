/// Parsed representation of an OpenAPI 3.x specification.
class OpenApiSpec {
  final String? title;
  final String? description;
  final String? version;
  final String? baseUrl;
  final Map<String, OpenApiSchema> schemas;
  final Map<String, OpenApiPath> paths;
  final Map<String, OpenApiSecurityScheme> securitySchemes;

  const OpenApiSpec({
    this.title,
    this.description,
    this.version,
    this.baseUrl,
    this.schemas = const {},
    this.paths = const {},
    this.securitySchemes = const {},
  });
}

/// A schema definition (model) from components/schemas.
class OpenApiSchema {
  final String name;
  final String? description;
  final List<OpenApiField> fields;
  final List<String> requiredFields;
  final bool isEnum;
  final List<String> enumValues;

  const OpenApiSchema({
    required this.name,
    this.description,
    this.fields = const [],
    this.requiredFields = const [],
    this.isEnum = false,
    this.enumValues = const [],
  });
}

/// A field/property within a schema.
class OpenApiField {
  final String name;
  final String type;
  final String? ref;
  final String? description;
  final bool isRequired;
  final bool isNullable;
  final bool isList;
  final String? itemType;
  final String? defaultValue;

  const OpenApiField({
    required this.name,
    required this.type,
    this.ref,
    this.description,
    this.isRequired = false,
    this.isNullable = false,
    this.isList = false,
    this.itemType,
    this.defaultValue,
  });
}

/// A path with its operations.
class OpenApiPath {
  final String path;
  final List<OpenApiOperation> operations;

  const OpenApiPath({
    required this.path,
    this.operations = const [],
  });
}

/// A single API operation (GET, POST, etc.).
class OpenApiOperation {
  final String method;
  final String path;
  final String? operationId;
  final String? summary;
  final String? description;
  final List<OpenApiParameter> parameters;
  final OpenApiRequestBody? requestBody;
  final Map<String, OpenApiResponse> responses;
  final List<List<String>> security;

  const OpenApiOperation({
    required this.method,
    required this.path,
    this.operationId,
    this.summary,
    this.description,
    this.parameters = const [],
    this.requestBody,
    this.responses = const {},
    this.security = const [],
  });

  String get dartName {
    final id = operationId;
    if (id != null) return _toCamelCase(id);
    return '${method.toLowerCase()}${_toPascalCase(_pathToName(path))}';
  }
}

/// A parameter (query, path, header).
class OpenApiParameter {
  final String name;
  final String? description;
  final String location; // query, path, header, cookie
  final bool isRequired;
  final String type;
  final String? ref;
  final bool isList;
  final String? itemType;

  const OpenApiParameter({
    required this.name,
    this.description,
    required this.location,
    this.isRequired = false,
    required this.type,
    this.ref,
    this.isList = false,
    this.itemType,
  });
}

/// Request body.
class OpenApiRequestBody {
  final String? description;
  final bool isRequired;
  final String? ref;
  final String? contentType;

  const OpenApiRequestBody({
    this.description,
    this.isRequired = false,
    this.ref,
    this.contentType,
  });
}

/// Response.
class OpenApiResponse {
  final String statusCode;
  final String? description;
  final String? ref;

  const OpenApiResponse({
    required this.statusCode,
    this.description,
    this.ref,
  });
}

/// Security scheme.
class OpenApiSecurityScheme {
  final String name;
  final String type; // apiKey, http, bearer, oauth2
  final String? scheme;
  final String? bearerFormat;
  final String? location; // header, query, cookie (for apiKey)

  const OpenApiSecurityScheme({
    required this.name,
    required this.type,
    this.scheme,
    this.bearerFormat,
    this.location,
  });
}

String _toCamelCase(String input) {
  if (input.isEmpty) return input;
  final pascal = _toPascalCase(input);
  return pascal[0].toLowerCase() + pascal.substring(1);
}

String _toPascalCase(String input) {
  if (input.isEmpty) return input;
  return input
      .split(RegExp(r'[-_\s]+'))
      .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join();
}

String _pathToName(String path) {
  return path
      .replaceAll(RegExp(r'\{[^}]+\}'), 'By')
      .replaceAll('//', '/')
      .split('/')
      .where((s) => s.isNotEmpty)
      .join('_');
}
