import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:openapi_generator/openapi_generator.dart';
import '../../config/wizard_config.dart';
import '../../config/option_dependencies.dart';
import '../../generator/project_generator.dart';
import '../../generator/web_download.dart';

class SummaryPage extends StatefulWidget {
  final WizardConfig config;

  const SummaryPage({super.key, required this.config});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  GenResult? _validationResult;
  bool _isValidating = false;

  WizardConfig get config => widget.config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final deps = resolveDependencies(config);
    final prodDeps = deps.where((d) => !d.isDev).toList();
    final devDeps = deps.where((d) => d.isDev).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Summary & Download', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('Review your project configuration and download.',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline)),
              const SizedBox(height: 24),
              // Project info card
              _card(context, Icons.folder_open, config.projectName, [
                _kv(context, 'Organization', config.orgName),
                _kv(context, 'Platforms', config.platforms.map((p) => p.label).join(', ')),
              ]),
              const SizedBox(height: 16),
              // Config card
              _card(context, Icons.settings, 'Configuration', [
                _kv(context, 'State Management', config.stateManagement.label),
                _kv(context, 'Navigation', 'GoRouter'),
                _kv(context, 'DI', config.effectiveDI.label),
                _kv(context, 'Network', config.networkClient.label),
                _kv(context, 'Local Storage', config.localStorage.label),
                _kv(context, 'UI Toolkit', config.uiToolkit.label),
                _kv(context, 'Environment', config.envConfig.label),
                _kv(context, 'Logging', config.logging.label),
                if (config.attachLoggerToHttp)
                  _kv(context, 'HTTP Logging', 'Enabled (interceptor on ${config.networkClient.label})'),
                _kv(context, 'DB Debugger', config.dbDebugger.label),
                _kv(context, 'Linting', config.linting.label),
                _kv(context, 'API Generation', config.apiGeneration.label),
                if (config.isOpenApiEnabled) ...[
                  _kv(context, 'Generator Type', config.openApiClientGenerator.label),
                  if (config.openApiSpecUrl.isNotEmpty)
                    _kv(context, 'OpenAPI URL', config.openApiSpecUrl),
                  if (config.hasOpenApiSpec)
                    _kv(context, 'Spec Content', '${config.openApiSpecContent.length} chars'),
                ],
                if (config.needsCodeGeneration)
                  _kv(context, 'Code Generation', 'Yes (build_runner)'),
              ]),
              // OpenAPI validation
              if (config.isOpenApiEnabled && config.hasOpenApiSpec) ...[
                const SizedBox(height: 16),
                _openApiDiagnosticsCard(context),
              ],
              if (config.hasPlatformConflict) ...[
                const SizedBox(height: 16),
                _errorBox(
                  'Selected options don\'t support ${config.conflictingPlatforms.map((p) => p.label).join(', ')}. The project may not build for those platforms.',
                ),
              ],
              const SizedBox(height: 16),
              // Dependencies card
              _card(context, Icons.inventory_2, 'Dependencies', [
                ...prodDeps.map((d) => _depRow(d, false)),
                if (devDeps.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Dev Dependencies', style: theme.textTheme.labelSmall),
                  const SizedBox(height: 4),
                  ...devDeps.map((d) => _depRow(d, true)),
                ],
              ]),
              const SizedBox(height: 24),
              Center(
                child: FilledButton.icon(
                  onPressed: _canDownload() ? () => _downloadZip(context) : null,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download Project ZIP'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  bool _canDownload() {
    if (!config.isOpenApiEnabled || !config.hasOpenApiSpec) return true;
    // Allow download even with warnings, but block on errors
    if (_validationResult != null && _validationResult!.errors.isNotEmpty) return false;
    return true;
  }

  Widget _openApiDiagnosticsCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.api, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('OpenAPI Diagnostics', style: theme.textTheme.titleMedium),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: _isValidating ? null : _validateSpec,
                  child: _isValidating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Validate Spec'),
                ),
              ],
            ),
            if (_validationResult != null) ...[
              const SizedBox(height: 12),
              _diagnosticSummary(context, _validationResult!),
              const SizedBox(height: 8),
              ..._validationResult!.diagnostics.map((d) => _diagnosticRow(context, d)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _diagnosticSummary(BuildContext context, GenResult result) {
    if (result.success) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
            const SizedBox(width: 6),
            Expanded(child: Text(result.summary, style: TextStyle(color: Colors.green.shade700, fontSize: 13))),
          ],
        ),
      );
    }
    return _errorBox(result.summary);
  }

  Widget _diagnosticRow(BuildContext context, GenDiagnostic d) {
    final (icon, color) = switch (d.severity) {
      GenSeverity.error => (Icons.error_outline, Colors.red.shade700),
      GenSeverity.warning => (Icons.warning_amber, Colors.orange.shade700),
      GenSeverity.info => (Icons.info_outline, Colors.blue.shade700),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text('[${d.phase}]', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: color)),
          const SizedBox(width: 4),
          Expanded(child: Text(d.message, style: TextStyle(fontSize: 12, color: color))),
        ],
      ),
    );
  }

  void _validateSpec() async {
    setState(() => _isValidating = true);
    try {
      final generator = ProjectGenerator(config);
      final result = generator.validateOpenApi();
      setState(() {
        _validationResult = result;
        _isValidating = false;
      });
    } catch (e) {
      setState(() {
        _validationResult = GenResult(
          success: false,
          diagnostics: [GenDiagnostic(GenSeverity.error, 'Validate', e.toString())],
        );
        _isValidating = false;
      });
    }
  }

  Widget _errorBox(String message) {
    return Container(
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
          Expanded(child: Text(message, style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, IconData icon, String title, List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _kv(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 13)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _depRow(DepEntry dep, bool isDev) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          if (isDev) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey),
              ),
              child: const Text('dev', style: TextStyle(fontSize: 10)),
            ),
            const SizedBox(width: 6),
          ],
          Expanded(child: Text('${dep.package}: ${dep.version}',
              style: TextStyle(fontSize: 13, color: isDev ? Colors.grey : null))),
        ],
      ),
    );
  }

  void _downloadZip(BuildContext context) {
    try {
      final generator = ProjectGenerator(config);
      final archive = generator.generateZipArchive();
      final zipData = ZipEncoder().encode(archive);

      if (generator.lastDiagnostics.isNotEmpty) {
        final hasErrors = generator.lastDiagnostics.any((d) => d.severity == GenSeverity.error);
        if (hasErrors) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Generation had errors: ${generator.lastDiagnostics.where((d) => d.severity == GenSeverity.error).map((d) => d.message).join('; ')}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      downloadZip(zipData, '${config.projectName}.zip');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download started!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
