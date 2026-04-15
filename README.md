# Lark

A Flutter project wizard that lets you configure and scaffold new Flutter projects through a guided UI. Select your preferred state management, networking, storage, and other options, then download a ready-to-use project ZIP.

## Features

- **3-step wizard flow** — Project Setup, Options, Summary & Download
- **Platform selection** — Android, iOS, Web, Windows, macOS, Linux
- **Configurable options** — State management, UI toolkit, networking, local storage, dependency injection, environment config, logging, linting, and OpenAPI code generation
- **Automatic dependency resolution** — Packages are added based on your selections, including dev dependencies and code generation tools
- **OpenAPI spec support** — Paste or link an OpenAPI spec; the wizard validates it and generates a Dart API client
- **Dark/light/system theme** — Toggle the wizard UI theme
- **Download as ZIP** — Get a complete project archive with all generated files

## Quick Start

```bash
# Clone with submodules
git clone --recurse-submodules <repo-url>

# If already cloned without submodules
git submodule update --init

# Run the wizard (web)
flutter run -d chrome

# Or build for web
flutter build web
```

## Tech Stack

- **Flutter** (Dart SDK ^3.11.4)
- **shadcn_flutter** — UI components for the wizard itself
- **mustache_template** — Client-side mustache template rendering
- **archive** — ZIP generation for project download
- **openapi_generator** — OpenAPI client generation

## Project Structure

```
lib/
  main.dart                         # App entry point
  src/wizard/
    config/
      wizard_config.dart            # All option enums and WizardConfig model
      option_dependencies.dart      # Dependency resolution logic (for UI display)
    generator/
      project_generator.dart        # ZIP archive generation (delegates to BrickGenerator)
      brick_generator.dart          # WizardConfig → mustache vars → render → cleanup
      brick_templates.g.dart        # Auto-generated template constants (from lark_template brick)
      web_download.dart             # Conditional import for web/native download
    ui/
      app.dart                      # Wizard shell (steps, navigation, theme toggle)
      pages/
        setup_page.dart             # Step 1: project name, org, platforms
        options_page.dart           # Step 2: all configurable options
        summary_page.dart           # Step 3: review & download
packages/
  openapi_generator/                # Local OpenAPI generator package
bricks/
  lark_template/                    # Git submodule → lark_template repo
tools/
  sync_brick.dart                   # Re-generates brick_templates.g.dart from submodule
```

## Brick Template Sync

The project generation is powered by mustache templates from the
[lark_template](https://github.com/CompileConnected/lark_template) project's
`lark_note_app` Mason brick, linked as a git submodule at `bricks/lark_template`.
Templates are compiled into `brick_templates.g.dart` for web compatibility.

To sync templates after updating the brick:

```bash
dart run tools/sync_brick.dart
```

CI automatically verifies that `brick_templates.g.dart` is up-to-date on
every push/PR that touches the submodule or sync script.

## Available Options

See [OPTIONS.md](OPTIONS.md) for the full list of configurable options, their values, and descriptions.

## License

This project is private and not intended for publication.
