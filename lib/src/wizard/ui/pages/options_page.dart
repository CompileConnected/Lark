import 'package:flutter/material.dart';
import 'package:openapi_generator/openapi_generator.dart';

import '../../config/wizard_config.dart';

class OptionsPage extends StatelessWidget {
  final WizardConfig config;
  final VoidCallback onChanged;

  const OptionsPage({super.key, required this.config, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Options', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Choose the libraries and tools for your project.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              _sectionCard(
                context,
                Icons.layers,
                'State Management',
                _smSection(),
              ),
              _sectionCard(context, Icons.palette, 'UI Toolkit', _uiSection()),
              _sectionCard(context, Icons.wifi, 'Network', _networkSection()),
              _openApiSection(context),
              _sectionCard(
                context,
                Icons.storage,
                'Local Storage',
                _storageSection(),
              ),
              _sectionCard(
                context,
                Icons.vpn_key,
                'Environment Variables',
                _envSection(),
              ),
              _diCard(context),
              _sectionCard(
                context,
                Icons.article,
                'Logging',
                _loggingSection(),
              ),
              _sectionCard(
                context,
                Icons.bug_report,
                'DB Debugger',
                _dbDebuggerSection(),
              ),
              _sectionCard(context, Icons.code, 'Linting', _lintingSection()),
              _autoIncludedNotice(),
              _platformConflictNotice(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context,
    IconData icon,
    String title,
    Widget child,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: ExpansionTile(
          leading: Icon(icon, size: 18, color: colorScheme.primary),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [child],
        ),
      ),
    );
  }

  Widget _radioGroup<T>({
    required List<T> options,
    required T selected,
    required String Function(T) labelBuilder,
    required void Function(T) onChanged,
    String? Function(T)? infoBuilder,
    bool Function(T)? disabledBuilder,
    String? Function(T)? disabledInfoBuilder,
  }) {
    // Automatically skip any enum value that opts out of the UI via UiOption.hidden
    final visibleOptions = options
        .where((e) => e is! UiOption || !(e as UiOption).hidden)
        .toList();
    return Column(
      children: visibleOptions.map((e) {
        final isDisabled = disabledBuilder?.call(e) ?? false;
        final info = infoBuilder?.call(e);
        final disabledInfo = disabledInfoBuilder?.call(e);
        final allInfo = <String>[
          ?info,
          if (isDisabled) ?disabledInfo,
        ].join(' — ');

        return RadioListTile<T>(
          title: Text(labelBuilder(e)),
          subtitle: allInfo.isNotEmpty
              ? Text(allInfo, style: const TextStyle(fontSize: 12))
              : null,
          value: e,
          groupValue: selected,
          onChanged: isDisabled
              ? null
              : (v) {
                  if (v != null) onChanged(v);
                },
          dense: true,
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }

  // --- Sections ---

  Widget _smSection() => _radioGroup<StateManagement>(
    options: StateManagement.values,
    selected: config.stateManagement,
    labelBuilder: (e) => e.label,
    onChanged: (v) {
      config.stateManagement = v;
      onChanged();
    },
    infoBuilder: (e) => _smInfo(e),
  );

  Widget _uiSection() => _radioGroup<UiToolkit>(
    options: UiToolkit.values,
    selected: config.uiToolkit,
    labelBuilder: (e) => e.label,
    onChanged: (v) {
      config.uiToolkit = v;
      onChanged();
    },
  );

  Widget _networkSection() => _radioGroup<NetworkClient>(
    options: NetworkClient.values,
    selected: config.networkClient,
    labelBuilder: (e) => e.label,
    onChanged: (v) {
      config.networkClient = v;
      _autoResetAttachLogger();
      onChanged();
    },
    infoBuilder: (e) => _networkInfo(e),
    disabledBuilder: (e) => _isPlatformIncompatible(e.unsupportedPlatforms),
    disabledInfoBuilder: (e) =>
        _platformUnavailableMessage(e.unsupportedPlatforms),
  );

  Widget _openApiSection(BuildContext context) {
    return _sectionCard(
      context,
      Icons.api,
      'API Generation (OpenAPI)',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _radioGroup<ApiGeneration>(
            options: ApiGeneration.values,
            selected: config.apiGeneration,
            labelBuilder: (e) => e.label,
            onChanged: (v) {
              config.apiGeneration = v;
              if (v == ApiGeneration.openApi) {
                // Sync network client with the generator choice
                config.networkClient =
                    config.openApiClientGenerator.networkClient;
              }
              onChanged();
            },
            infoBuilder: (e) => _apiGenInfo(e),
          ),
          if (config.isOpenApiEnabled) ...[
            const SizedBox(height: 8),
            _infoBox(
              'Uses openapi_generator (requires Java). Select which HTTP library the generated client will use:',
            ),
            const SizedBox(height: 8),
            Text(
              'Generator / HTTP Library:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            _radioGroup<OpenApiClientGenerator>(
              options: OpenApiClientGenerator.values,
              selected: config.openApiClientGenerator,
              labelBuilder: (e) => e.label,
              onChanged: (v) {
                config.openApiClientGenerator = v;
                // Sync network client with generator choice
                config.networkClient = v.networkClient;
                _autoResetAttachLogger();
                onChanged();
              },
              infoBuilder: (e) => _openApiGenTypeInfo(e),
            ),
            const SizedBox(height: 8),
            if (config.openApiClientGenerator.needsSourceGen)
              _infoBox(
                'Dio generator requires build_runner source gen after openapi-generator runs.',
              ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'OpenAPI Spec URL',
                hintText: 'https://petstore3.swagger.io/api/v3/openapi.json',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link, size: 18),
                isDense: true,
              ),
              onChanged: (v) {
                config.openApiSpecUrl = v;
                onChanged();
              },
            ),
            const SizedBox(height: 8),
            Text(
              'or paste spec content (JSON/YAML):',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              decoration: const InputDecoration(
                hintText: '{ "openapi": "3.0.0", ... }',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 5,
              minLines: 3,
              onChanged: (v) {
                config.openApiSpecContent = v;
                onChanged();
              },
            ),
            if (config.hasOpenApiSpec) ...[
              const SizedBox(height: 8),
              _openApiQuickPreview(context),
            ],
          ],
        ],
      ),
    );
  }

  Widget _openApiQuickPreview(BuildContext context) {
    return FutureBuilder<GenResult>(
      future: _validateSpecAsync(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Validating spec...', style: TextStyle(fontSize: 12)),
              ],
            ),
          );
        }
        if (!snapshot.hasData) return const SizedBox.shrink();
        final result = snapshot.data!;
        final errors = result.errors;
        final warnings = result.warnings;
        final infos = result.infos;

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: errors.isNotEmpty
                ? Colors.red.shade50
                : warnings.isNotEmpty
                ? Colors.orange.shade50
                : Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: errors.isNotEmpty
                  ? Colors.red.shade200
                  : warnings.isNotEmpty
                  ? Colors.orange.shade200
                  : Colors.green.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    errors.isNotEmpty
                        ? Icons.error_outline
                        : warnings.isNotEmpty
                        ? Icons.warning_amber
                        : Icons.check_circle,
                    size: 16,
                    color: errors.isNotEmpty
                        ? Colors.red.shade700
                        : warnings.isNotEmpty
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      errors.isNotEmpty
                          ? '${errors.length} error(s) found'
                          : warnings.isNotEmpty
                          ? '${warnings.length} warning(s), spec OK'
                          : 'Spec valid: ${infos.where((d) => d.phase == 'Parse').map((d) => d.message).join('; ')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: errors.isNotEmpty
                            ? Colors.red.shade700
                            : warnings.isNotEmpty
                            ? Colors.orange.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              if (errors.isNotEmpty) ...[
                const SizedBox(height: 4),
                ...errors
                    .take(3)
                    .map(
                      (d) => Padding(
                        padding: const EdgeInsets.only(left: 22, top: 1),
                        child: Text(
                          '[${d.phase}] ${d.message}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ),
                if (errors.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(left: 22, top: 2),
                    child: Text(
                      '+${errors.length - 3} more error(s)...',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
              ],
              if (warnings.isNotEmpty) ...[
                const SizedBox(height: 4),
                ...warnings
                    .take(3)
                    .map(
                      (d) => Padding(
                        padding: const EdgeInsets.only(left: 22, top: 1),
                        child: Text(
                          '[${d.phase}] ${d.message}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<GenResult> _validateSpecAsync() async {
    try {
      return DartGenerator.generateWithDiagnostics(
        config.openApiSpecContent,
        clientName: 'ApiClient',
      );
    } catch (e) {
      return GenResult(
        success: false,
        diagnostics: [
          GenDiagnostic(GenSeverity.error, 'Validate', e.toString()),
        ],
      );
    }
  }

  Widget _storageSection() => _radioGroup<LocalStorage>(
    options: LocalStorage.values,
    selected: config.localStorage,
    labelBuilder: (e) => e.label,
    onChanged: (v) {
      config.localStorage = v;
      _autoResetDbDebugger();
      onChanged();
    },
    infoBuilder: (e) => _storageInfo(e),
    disabledBuilder: (e) => _isPlatformIncompatible(e.unsupportedPlatforms),
    disabledInfoBuilder: (e) =>
        _platformUnavailableMessage(e.unsupportedPlatforms),
  );

  Widget _envSection() => _radioGroup<EnvConfig>(
    options: EnvConfig.values,
    selected: config.envConfig,
    labelBuilder: (e) => e.label,
    onChanged: (v) {
      config.envConfig = v;
      onChanged();
    },
    infoBuilder: (e) => _envInfo(e),
  );

  Widget _diCard(BuildContext context) {
    final smHandlesDI =
        config.stateManagement == StateManagement.provider ||
        config.stateManagement == StateManagement.riverpod ||
        config.stateManagement == StateManagement.getx;

    return _sectionCard(
      context,
      Icons.account_tree,
      'Dependency Injection',
      smHandlesDI
          ? _infoBox(
              '${config.stateManagement.label} handles DI internally. No external DI needed.',
            )
          : _radioGroup<DependencyInjection>(
              options: DependencyInjection.values,
              selected: config.dependencyInjection,
              labelBuilder: (e) => e.label,
              onChanged: (v) {
                config.dependencyInjection = v;
                onChanged();
              },
            ),
    );
  }

  Widget _loggingSection() {
    final hasNetwork = config.networkClient != NetworkClient.none;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _radioGroup<Logging>(
          options: Logging.values,
          selected: config.logging,
          labelBuilder: (e) => e.label,
          onChanged: (v) {
            config.logging = v;
            _autoResetAttachLogger();
            onChanged();
          },
          infoBuilder: (e) => _loggingInfo(e),
        ),
        if (config.logging != Logging.none) ...[
          const SizedBox(height: 4),
          CheckboxListTile(
            title: const Text('Attach logger to HTTP client'),
            subtitle: Text(
              hasNetwork
                  ? 'Adds logging interceptor to ${config.networkClient.label}'
                  : 'Select a network client first',
              style: const TextStyle(fontSize: 12),
            ),
            value: config.attachLoggerToHttp,
            onChanged: hasNetwork
                ? (v) {
                    config.attachLoggerToHttp = v ?? false;
                    onChanged();
                  }
                : null,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    );
  }

  Widget _dbDebuggerSection() => _radioGroup<DbDebugger>(
    options: DbDebugger.values,
    selected: config.dbDebugger,
    labelBuilder: (e) => e.label,
    onChanged: (v) {
      config.dbDebugger = v;
      onChanged();
    },
    infoBuilder: (e) => _dbDebuggerInfo(e),
    disabledBuilder: (e) =>
        e == DbDebugger.driftDbViewer &&
        config.localStorage != LocalStorage.drift,
    disabledInfoBuilder: (e) => e == DbDebugger.driftDbViewer
        ? 'Requires Drift as local storage'
        : null,
  );

  Widget _lintingSection() => _radioGroup<Linting>(
    options: Linting.values,
    selected: config.linting,
    labelBuilder: (e) => e.label,
    onChanged: (v) {
      config.linting = v;
      onChanged();
    },
  );

  // --- Helpers ---

  Widget _infoBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  bool _isPlatformIncompatible(Set<Platform> unsupported) {
    if (unsupported.isEmpty) return false;
    return config.platforms.any((p) => unsupported.contains(p));
  }

  String? _platformUnavailableMessage(Set<Platform> unsupported) {
    final conflict = unsupported.intersection(config.platforms);
    if (conflict.isEmpty) return null;
    return 'Not available on ${conflict.map((p) => p.label).join(', ')}';
  }

  void _autoResetAttachLogger() {
    if (!config.canAttachLoggerToHttp) config.attachLoggerToHttp = false;
  }

  void _autoResetDbDebugger() {
    if (config.dbDebugger == DbDebugger.driftDbViewer &&
        config.localStorage != LocalStorage.drift) {
      config.dbDebugger = DbDebugger.none;
    }
  }

  // --- Info ---

  String? _smInfo(StateManagement sm) => switch (sm) {
    StateManagement.none => 'Use StatefulWidget + setState',
    StateManagement.provider => 'Provider + ChangeNotifier, most established',
    StateManagement.riverpod =>
      'Compile-time safe, auto-includes freezed + build_runner',
    StateManagement.bloc =>
      'Event-driven, auto-includes freezed + build_runner',
    StateManagement.getx => 'All-in-one: state, routing, DI',
    StateManagement.mobx => 'Observable-based, requires build_runner',
    StateManagement.signals => 'Lightweight reactive signals',
  };

  String? _networkInfo(NetworkClient nc) => switch (nc) {
    NetworkClient.none => null,
    NetworkClient.http => 'Official, basic HTTP client',
    NetworkClient.dio => 'Feature-rich: interceptors, FormData, retry',
    NetworkClient.rhttp => 'Rust-based via FFI, HTTP/2 & HTTP/3, fast (no Web)',
  };

  String? _storageInfo(LocalStorage ls) => switch (ls) {
    LocalStorage.none => null,
    LocalStorage.sharedPreferences => 'Key-value store, simple',
    LocalStorage.hiveCe => 'NoSQL, fast, actively maintained community fork',
    LocalStorage.isarCommunity =>
      'NoSQL, queries, indexed, community maintained (no Web)',
    LocalStorage.drift => 'Type-safe SQLite, code-gen (no Web)',
  };

  String? _envInfo(EnvConfig e) => switch (e) {
    EnvConfig.none => null,
    EnvConfig.flutterDotenv => 'Load .env files via Flutter asset bundle',
    EnvConfig.dotenv => 'Pure Dart .env loader, works on all platforms',
  };

  String? _loggingInfo(Logging l) => switch (l) {
    Logging.none => null,
    Logging.logging => 'Dart built-in, lightweight, hierarchical log levels',
    Logging.logger => 'Beautiful console output, file logging support',
  };

  String? _dbDebuggerInfo(DbDebugger d) => switch (d) {
    DbDebugger.none => null,
    DbDebugger.driftDbViewer => 'Visual in-app Drift database inspector',
  };

  // --- Notices ---

  String? _apiGenInfo(ApiGeneration a) => switch (a) {
    ApiGeneration.none => null,
    ApiGeneration.openApi =>
      'Generate Dart models + API client from OpenAPI spec (requires Java)',
  };

  String? _openApiGenTypeInfo(OpenApiClientGenerator g) => switch (g) {
    OpenApiClientGenerator.dart => 'Uses http package, simple and lightweight',
    OpenApiClientGenerator.dio => 'Uses Dio, feature-rich with interceptors',
    OpenApiClientGenerator.dioAlt =>
      'Uses dart-openapi-maven generator with Dio',
  };

  Widget _autoIncludedNotice() {
    final notes = <String>[];
    notes.add('Navigation: GoRouter (always included)');
    if (config.needsCodeGeneration)
      notes.add('build_runner (auto-included for code generation)');
    if (config.needsFreezed)
      notes.add(
        'freezed + json_serializable (recommended for ${config.stateManagement.label})',
      );
    if (config.isRhttpSelected)
      notes.add(
        'rhttp requires Rust toolchain (rustup.rs) and latest NDK for Android',
      );
    if (config.isOpenApiEnabled)
      notes.add(
        'OpenAPI: openapi_generator + ${config.openApiClientGenerator.label} (auto-included, requires Java)',
      );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_fix_high,
                  size: 18,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Auto-included dependencies & notes',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...notes.map(
              (n) => Padding(
                padding: const EdgeInsets.only(left: 26, top: 2),
                child: Text(
                  n,
                  style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _platformConflictNotice() {
    if (!config.hasPlatformConflict) return const SizedBox.shrink();
    final conflicts = config.conflictingPlatforms;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 18, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Platform conflict: selected options don\'t support ${conflicts.map((p) => p.label).join(', ')}. The generated project may not build for those platforms.',
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
