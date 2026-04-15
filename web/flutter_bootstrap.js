{{flutter_js}}
{{flutter_build_config}}

// Take manual control of the Flutter Engine load lifecycle
_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    // 1. Initialize the engine (downloads the core JS/assets in the background)
    const appRunner = await engineInitializer.initializeEngine();

    // 2. Destroy the pure HTML splash screen exactly when the engine is ready
    // 2. Destroy the pure HTML splash screen exactly when the engine is ready
    const splash = document.getElementById('flutter-splash');
    if (splash) {
      splash.remove();
    }

    // 3. Mount and run the actual Flutter application
    await appRunner.runApp();
  }
});