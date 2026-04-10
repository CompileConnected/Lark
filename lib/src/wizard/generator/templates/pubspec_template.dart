import '../../config/wizard_config.dart';
import '../../config/option_dependencies.dart';

String generatePubspec(WizardConfig config) {
  final deps = resolveDependencies(config);
  final prodDeps = deps.where((d) => !d.isDev).toList();
  final devDeps = deps.where((d) => d.isDev).toList();

  final usesShadcn = config.uiToolkit == UiToolkit.shadcn;

  final buffer = StringBuffer();
  buffer.writeln('name: ${config.dartPackageName}');
  buffer.writeln('description: "A new Flutter project."');
  buffer.writeln("publish_to: 'none'");
  buffer.writeln('version: 1.0.0+1');
  buffer.writeln();
  buffer.writeln('environment:');
  buffer.writeln('  sdk: ^3.7.2');
  buffer.writeln();
  buffer.writeln('dependencies:');
  buffer.writeln('  flutter:');
  buffer.writeln('    sdk: flutter');

  if (!usesShadcn) {
    buffer.writeln('  cupertino_icons: ^1.0.8');
  }

  for (final dep in prodDeps) {
    buffer.writeln('  ${dep.package}: ${dep.version}');
  }

  buffer.writeln();
  buffer.writeln('dev_dependencies:');
  buffer.writeln('  flutter_test:');
  buffer.writeln('    sdk: flutter');

  if (config.linting == Linting.flutterLints) {
    buffer.writeln('  flutter_lints: ^5.0.0');
  }

  for (final dep in devDeps) {
    buffer.writeln('  ${dep.package}: ${dep.version}');
  }

  buffer.writeln();
  buffer.writeln('flutter:');
  buffer.writeln('  uses-material-design: true');

  return buffer.toString();
}
