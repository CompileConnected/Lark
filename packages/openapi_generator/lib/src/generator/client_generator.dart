import '../parser/openapi_spec.dart';

/// Generates a Dart API client class from OpenAPI paths.
class ClientGenerator {
  final OpenApiSpec spec;
  final String className;

  ClientGenerator(this.spec, {this.className = 'ApiClient'});

  /// Generate the API client file content.
  String generate() {
    final buffer = StringBuffer();

    // Imports
    buffer.writeln("import 'dart:convert';");
    buffer.writeln("import 'package:http/http.dart' as http;");
    buffer.writeln("import 'dart:typed_data';");

    // Import all model files
    for (final schema in spec.schemas.keys) {
      buffer.writeln("import 'models/${_toSnakeCase(schema)}.dart';");
    }
    buffer.writeln();

    // Security imports
    final hasBearer = spec.securitySchemes.values.any(
      (s) => s.type == 'http' && s.scheme == 'bearer' || s.type == 'bearer',
    );
    if (hasBearer) {
      // no extra import needed, just use a String token
    }

    // Class declaration
    buffer.writeln('class $className {');
    buffer.writeln('  final String baseUrl;');
    buffer.writeln('  final http.Client _httpClient;');
    buffer.writeln('  String? _bearerToken;');
    buffer.writeln();
    buffer.writeln('  $className({');
    buffer.writeln("    this.baseUrl = '${spec.baseUrl ?? 'https://api.example.com'}',");
    buffer.writeln('    http.Client? httpClient,');
    buffer.writeln('  }) : _httpClient = httpClient ?? http.Client();');
    buffer.writeln();

    // Auth methods
    buffer.writeln('  /// Set the Bearer token for authenticated requests.');
    buffer.writeln('  void setBearerToken(String token) => _bearerToken = token;');
    buffer.writeln();
    buffer.writeln('  /// Clear the Bearer token.');
    buffer.writeln('  void clearBearerToken() => _bearerToken = null;');
    buffer.writeln();

    // Generate methods for each operation
    for (final path in spec.paths.values) {
      for (final op in path.operations) {
        buffer.writeln(_generateMethod(op));
      }
    }

    // Helper methods
    buffer.writeln(_generateHelpers());

    buffer.writeln('}');
    return buffer.toString();
  }

  String _generateMethod(OpenApiOperation op) {
    final buffer = StringBuffer();
    final methodName = op.dartName;
    final returnRef = _successResponseRef(op);
    final returnType = returnRef != null ? 'Future<$returnRef>' : 'Future<void>';
    final returnList = _successResponseIsList(op);

    // Doc comment
    if (op.summary != null || op.description != null) {
      buffer.writeln('  /// ${op.summary ?? op.description}');
    }

    // Signature
    buffer.write('  $returnType $methodName({');
    final params = <String>[];

    // Path params
    for (final p in op.parameters.where((p) => p.location == 'path')) {
      final t = _paramType(p);
      params.add('required $t ${p.name},');
    }

    // Query params
    for (final p in op.parameters.where((p) => p.location == 'query')) {
      final t = _paramType(p);
      params.add('${p.isRequired ? 'required' : ''} $t${!p.isRequired ? '?' : ''} ${p.name},');
    }

    // Header params
    for (final p in op.parameters.where((p) => p.location == 'header')) {
      final t = _paramType(p);
      params.add('${p.isRequired ? 'required' : ''} $t${!p.isRequired ? '?' : ''} ${p.name},');
    }

    // Request body
    if (op.requestBody?.ref != null) {
      params.add('required ${op.requestBody!.ref} body,');
    }

    buffer.write(params.join(' '));
    buffer.writeln('}) async {');

    // Build URL with path params
    var pathTemplate = op.path;
    for (final p in op.parameters.where((p) => p.location == 'path')) {
      pathTemplate = pathTemplate.replaceAll('{${p.name}}', '\${${p.name}}');
    }
    buffer.writeln("    final path = '$pathTemplate';");

    // Query params
    final queryParams = op.parameters.where((p) => p.location == 'query').toList();
    if (queryParams.isNotEmpty) {
      buffer.writeln('    final queryParameters = <String, String>{');
      for (final p in queryParams) {
        if (p.isRequired) {
          buffer.writeln("      '${p.name}': ${p.name}.toString(),");
        } else {
          buffer.writeln("      if (${p.name} != null) '${p.name}': ${p.name}!.toString(),");
        }
      }
      buffer.writeln('    };');
    }

    // Build URI
    if (queryParams.isNotEmpty) {
      buffer.writeln('    final uri = Uri.parse(\$baseUrl\$path).replace(queryParameters: queryParameters);');
    } else {
      buffer.writeln('    final uri = Uri.parse(\$baseUrl\$path);');
    }

    // Headers
    buffer.writeln('    final headers = <String, String>{');
    buffer.writeln("      'Content-Type': 'application/json',");
    buffer.writeln("      'Accept': 'application/json',");
    if (op.security.isNotEmpty) {
      buffer.writeln("      if (_bearerToken != null) 'Authorization': 'Bearer \$_bearerToken',");
    }
    for (final p in op.parameters.where((p) => p.location == 'header')) {
      if (p.isRequired) {
        buffer.writeln("      '${p.name}': ${p.name},");
      } else {
        buffer.writeln("      if (${p.name} != null) '${p.name}': ${p.name}!,");
      }
    }
    buffer.writeln('    };');

    // Body
    if (op.requestBody?.ref != null) {
      buffer.writeln('    final bodyJson = jsonEncode(body.toJson());');
    }

    // HTTP call
    final httpMethod = op.method.toLowerCase();
    final httpCall = switch (httpMethod) {
      'get' => '_httpClient.get(uri, headers: headers)',
      'post' => "_httpClient.post(uri, headers: headers, body: bodyJson)",
      'put' => "_httpClient.put(uri, headers: headers, body: bodyJson)",
      'patch' => "_httpClient.patch(uri, headers: headers, body: bodyJson)",
      'delete' => op.requestBody?.ref != null
          ? "_httpClient.send(http.Request('DELETE', uri)..headers.addAll(headers)..body = bodyJson)"
          : "_httpClient.delete(uri, headers: headers)",
      'head' => '_httpClient.head(uri, headers: headers)',
      'options' => "_httpClient.send(http.Request('OPTIONS', uri)..headers.addAll(headers))",
      _ => "_httpClient.send(http.Request('${op.method}', uri)..headers.addAll(headers))",
    };

    buffer.writeln('    final response = await $httpCall;');

    // Handle delete/send which returns StreamedResponse
    if (httpMethod == 'delete' && op.requestBody?.ref != null ||
        httpMethod == 'options' ||
        (httpMethod != 'get' && httpMethod != 'post' && httpMethod != 'put' && httpMethod != 'patch' && httpMethod != 'delete' && httpMethod != 'head')) {
      buffer.writeln('    final responseBody = await response.stream.bytesToString();');
      buffer.writeln('    final statusCode = response.statusCode;');
    } else {
      buffer.writeln('    final responseBody = response.body;');
      buffer.writeln('    final statusCode = response.statusCode;');
    }

    // Error handling
    buffer.writeln('    if (statusCode >= 200 && statusCode < 300) {');
    if (returnRef != null) {
      if (returnList) {
        buffer.writeln('      final list = jsonDecode(responseBody) as List<dynamic>;');
        buffer.writeln('      return list.map((e) => $returnRef.fromJson(e as Map<String, dynamic>)).toList();');
      } else {
        buffer.writeln('      return $returnRef.fromJson(jsonDecode(responseBody) as Map<String, dynamic>);');
      }
    } else {
      buffer.writeln('      return;');
    }
    buffer.writeln('    }');
    buffer.writeln('    throw ApiException(statusCode, responseBody);');
    buffer.writeln('  }');
    buffer.writeln();

    return buffer.toString();
  }

  String _generateHelpers() {
    return '''
  /// Close the underlying HTTP client.
  void dispose() {
    _httpClient.close();
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException(\$statusCode): \$message';
}
''';
  }

  String _paramType(OpenApiParameter p) {
    if (p.isList) {
      final item = p.itemType ?? 'dynamic';
      return 'List<$item>';
    }
    if (p.ref != null) return p.ref!;
    return p.type;
  }

  String? _successResponseRef(OpenApiOperation op) {
    for (final resp in op.responses.values) {
      if (_isSuccess(resp.statusCode) && resp.ref != null) {
        return resp.ref;
      }
    }
    return null;
  }

  bool _successResponseIsList(OpenApiOperation op) {
    // Check if the operation summary or description mentions list/array
    // This is a heuristic; in a full implementation, we'd check the response schema
    return false;
  }

  bool _isSuccess(String status) =>
      status == '200' || status == '201' || status == '202' || status == 'default';

  String _toSnakeCase(String input) {
    return input
        .replaceAll(RegExp(r'([A-Z])'), r'_$1')
        .toLowerCase()
        .replaceAll(RegExp(r'^_+'), '');
  }
}
