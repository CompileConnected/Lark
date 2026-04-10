import 'package:flutter/material.dart' hide Card;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Card;

import '../config/wizard_config.dart';
import 'pages/options_page.dart';
import 'pages/setup_page.dart';
import 'pages/summary_page.dart';

class WizardApp extends StatefulWidget {
  const WizardApp({super.key});

  @override
  State<WizardApp> createState() => _WizardAppState();
}

class _WizardAppState extends State<WizardApp> {
  shadcn.ThemeMode _themeMode = shadcn.ThemeMode.system;

  void _cycleThemeMode() {
    setState(() {
      switch (_themeMode) {
        case shadcn.ThemeMode.system:
          _themeMode = shadcn.ThemeMode.light;
        case shadcn.ThemeMode.light:
          _themeMode = shadcn.ThemeMode.dark;
        case shadcn.ThemeMode.dark:
          _themeMode = shadcn.ThemeMode.system;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return shadcn.ShadcnApp(
      title: 'Lark',
      theme: const shadcn.ThemeData(colorScheme: shadcn.ColorSchemes.lightZinc),
      darkTheme: const shadcn.ThemeData(
        colorScheme: shadcn.ColorSchemes.darkZinc,
      ),
      themeMode: _themeMode,
      home: _WizardContent(
        themeMode: _themeMode,
        onCycleTheme: _cycleThemeMode,
      ),
    );
  }
}

class _WizardContent extends StatefulWidget {
  final shadcn.ThemeMode themeMode;
  final VoidCallback onCycleTheme;

  const _WizardContent({required this.themeMode, required this.onCycleTheme});

  @override
  State<_WizardContent> createState() => _WizardContentState();
}

class _WizardContentState extends State<_WizardContent> {
  int _currentStep = 0;
  final WizardConfig _config = WizardConfig();

  static const _steps = ['Project Setup', 'Options', 'Summary & Download'];

  IconData _themeIcon() => switch (widget.themeMode) {
    shadcn.ThemeMode.system => Icons.brightness_auto,
    shadcn.ThemeMode.light => Icons.light_mode,
    shadcn.ThemeMode.dark => Icons.dark_mode,
  };

  String _themeLabel() => switch (widget.themeMode) {
    shadcn.ThemeMode.system => 'System',
    shadcn.ThemeMode.light => 'Light',
    shadcn.ThemeMode.dark => 'Dark',
  };

  @override
  Widget build(BuildContext context) {
    final t = shadcn.Theme.of(context);
    final materialTheme = ThemeData(
      brightness: t.brightness,
      scaffoldBackgroundColor: t.colorScheme.background,
      cardColor: t.colorScheme.card,
      canvasColor: t.colorScheme.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: t.colorScheme.primary,
        brightness: t.brightness,
        surface: t.colorScheme.background,
        primary: t.colorScheme.primary,
        secondary: t.colorScheme.secondary,
        error: t.colorScheme.destructive,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.colorScheme.background,
        border: const OutlineInputBorder(),
      ),
      dividerColor: t.colorScheme.border,
    );
    return Theme(
      data: materialTheme,
      child: Scaffold(
        backgroundColor: t.colorScheme.background,
        body: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: t.colorScheme.border)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flutter_dash,
                        size: 24,
                        color: t.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text('Flutter Project Wizard', style: t.typography.h3),
                      const Spacer(),
                      _themeToggle(t),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_steps.length, (i) {
                      final isActive = i == _currentStep;
                      final isCompleted = i < _currentStep;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (i < _currentStep)
                                setState(() => _currentStep = i);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: isActive
                                      ? t.colorScheme.primary
                                      : isCompleted
                                      ? t.colorScheme.primary.withValues(
                                          alpha: 0.6,
                                        )
                                      : t.colorScheme.muted,
                                  child: isCompleted && !isActive
                                      ? Icon(
                                          Icons.check,
                                          size: 14,
                                          color:
                                              t.colorScheme.primaryForeground,
                                        )
                                      : Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            color: isActive || isCompleted
                                                ? t
                                                      .colorScheme
                                                      .primaryForeground
                                                : t.colorScheme.mutedForeground,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _steps[i],
                                  style: TextStyle(
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isActive
                                        ? t.colorScheme.foreground
                                        : t.colorScheme.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (i < _steps.length - 1) ...[
                            const SizedBox(width: 12),
                            Container(
                              width: 40,
                              height: 1,
                              color: isCompleted
                                  ? t.colorScheme.primary
                                  : t.colorScheme.border,
                            ),
                            const SizedBox(width: 12),
                          ],
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: [
                  SetupPage(config: _config, onChanged: () => setState(() {})),
                  OptionsPage(
                    config: _config,
                    onChanged: () => setState(() {}),
                  ),
                  SummaryPage(config: _config),
                ],
              ),
            ),
            // Nav
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: t.colorScheme.border)),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      shadcn.Button.outline(
                        onPressed: _currentStep > 0
                            ? () => setState(() => _currentStep--)
                            : null,
                        leading: Icon(Icons.chevron_left, size: 16),
                        child: Text('Back'),
                      ),
                      shadcn.Button.primary(
                        onPressed: _currentStep < _steps.length - 1
                            ? () => setState(() => _currentStep++)
                            : null,
                        trailing: Icon(Icons.chevron_right, size: 16),
                        child: Text('Next'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeToggle(shadcn.ThemeData t) {
    return InkWell(
      onTap: widget.onCycleTheme,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: t.colorScheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_themeIcon(), size: 16),
            const SizedBox(width: 6),
            Text(_themeLabel(), style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
