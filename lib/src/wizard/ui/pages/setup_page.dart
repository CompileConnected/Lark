import 'package:flutter/material.dart';

import '../../config/wizard_config.dart';

class SetupPage extends StatelessWidget {
  final WizardConfig config;
  final VoidCallback onChanged;

  const SetupPage({super.key, required this.config, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Project Setup', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Configure your new Flutter project basics.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  hintText: 'my_app',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.folder_outlined, size: 18),
                ),
                onChanged: (v) {
                  config.projectName = v.isEmpty ? 'my_app' : v;
                  onChanged();
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Organization',
                  hintText: 'com.example',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business, size: 18),
                ),
                onChanged: (v) {
                  config.orgName = v.isEmpty ? 'com.example' : v;
                  onChanged();
                },
              ),
              const SizedBox(height: 24),
              Text('Platforms', style: theme.textTheme.labelSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Platform.values.map((p) {
                  final selected = config.platforms.contains(p);
                  return FilterChip(
                    label: Text(p.label),
                    selected: selected,
                    selectedColor: colorScheme.primary.withValues(alpha: 0.15),
                    checkmarkColor: colorScheme.primary,
                    onSelected: (val) {
                      if (selected && config.platforms.length > 1) {
                        config.platforms = config.platforms.difference({p});
                      } else if (!selected) {
                        config.platforms = {...config.platforms, p};
                      }
                      onChanged();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
