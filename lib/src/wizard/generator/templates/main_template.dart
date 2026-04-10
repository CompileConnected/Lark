import '../../config/wizard_config.dart';

String generateMain(WizardConfig config) {
  final usesShadcn = config.uiToolkit == UiToolkit.shadcn;
  final sm = config.stateManagement;
  final usesRhttp = config.isRhttpSelected;

  final imports = <String>[];

  // Base imports
  if (usesShadcn) {
    imports.add("import 'package:shadcn_flutter/shadcn_flutter.dart';");
  } else {
    imports.add("import 'package:flutter/material.dart';");
  }

  // State management imports
  switch (sm) {
    case StateManagement.none:
      break;
    case StateManagement.changeNotifier:
      break;
    case StateManagement.provider:
      imports.add("import 'package:provider/provider.dart';");
    case StateManagement.riverpod:
      imports.add("import 'package:flutter_riverpod/flutter_riverpod.dart';");
    case StateManagement.bloc:
      imports.add("import 'package:flutter_bloc/flutter_bloc.dart';");
    case StateManagement.getx:
      imports.add("import 'package:get/get.dart';");
    case StateManagement.mobx:
      imports.add("import 'package:mobx/mobx.dart';");
      imports.add("import 'package:flutter_mobx/flutter_mobx.dart';");
    case StateManagement.signals:
      imports.add("import 'package:signals_flutter/signals_flutter.dart';");
  }

  // Navigation
  imports.add("import 'package:go_router/go_router.dart';");

  // DI imports
  final di = config.effectiveDI;
  switch (di) {
    case DependencyInjection.none:
      break;
    case DependencyInjection.getIt:
      imports.add("import 'package:get_it/get_it.dart';");
    case DependencyInjection.injectable:
      imports.add("import 'package:get_it/get_it.dart';");
      imports.add("import 'package:injectable/injectable.dart';");
  }

  // Network
  if (config.networkClient == NetworkClient.http) {
    imports.add("import 'package:http/http.dart' as http;");
  } else if (config.networkClient == NetworkClient.dio) {
    imports.add("import 'package:dio/dio.dart';");
  } else if (usesRhttp) {
    imports.add("import 'package:rhttp/rhttp.dart';");
  }

  // Local imports
  imports.add("import 'src/counter/counter.dart';");
  imports.add("import 'src/home/home_page.dart';");

  // --- Generate App class ---
  final appClass = _generateAppClass(config);
  final routerCode = _generateRouter(config);
  final counterCode = _generateCounter(config);
  final homePageCode = _generateHomePage(config);

  final allCode = StringBuffer();

  for (final imp in imports) {
    allCode.writeln(imp);
  }
  allCode.writeln();

  allCode.writeln(appClass);
  allCode.writeln();
  allCode.writeln(routerCode);
  allCode.writeln();
  allCode.writeln(counterCode);
  allCode.writeln();
  allCode.writeln(homePageCode);

  return allCode.toString();
}

String _generateAppClass(WizardConfig config) {
  final sm = config.stateManagement;
  final usesShadcn = config.uiToolkit == UiToolkit.shadcn;
  final isRiverpod = sm == StateManagement.riverpod;
  final isGetx = sm == StateManagement.getx;
  final usesRhttp = config.isRhttpSelected;

  final classDecl = isRiverpod
      ? 'class MyApp extends ConsumerWidget {'
      : 'class MyApp extends StatelessWidget {';

  final buffer = StringBuffer();
  buffer.writeln(classDecl);
  buffer.writeln('  const MyApp({super.key});');
  buffer.writeln();

  if (isRiverpod) {
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context, WidgetRef ref) {');
  } else {
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context) {');
  }

  // Provider wrapping
  if (sm == StateManagement.provider) {
    buffer.writeln('    return ChangeNotifierProvider(');
    buffer.writeln('      create: (_) => CounterNotifier(),');
    buffer.writeln('      child: _buildApp(),');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();
    buffer.writeln('  Widget _buildApp() {');
  }

  // rhttp init note
  if (usesRhttp) {
    buffer.writeln('    // Note: rhttp requires async init before runApp:');
    buffer.writeln('    // void main() async { await Rhttp.init(); runApp(MyApp()); }');
  }

  // GetX wrapping
  if (isGetx) {
    buffer.writeln('    return GetMaterialApp.router(');
    buffer.writeln('      title: \'${config.projectName}\',');
    buffer.writeln('      routerDelegate: router.routerDelegate,');
    buffer.writeln('      routeInformationParser: router.routeInformationParser,');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');
    return buffer.toString();
  }

  // Material/Shadcn app
  if (usesShadcn) {
    buffer.writeln('    return ShadcnApp.router(');
    buffer.writeln('      title: \'${config.projectName}\',');
    buffer.writeln('      routerConfig: router,');
    buffer.writeln('    );');
  } else {
    buffer.writeln('    return MaterialApp.router(');
    buffer.writeln('      title: \'${config.projectName}\',');
    buffer.writeln('      theme: ThemeData(');
    buffer.writeln('        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),');
    buffer.writeln('      ),');
    buffer.writeln('      routerConfig: router,');
    buffer.writeln('    );');
  }

  buffer.writeln('  }');
  buffer.writeln('}');

  return buffer.toString();
}

String _generateRouter(WizardConfig config) {
  final buffer = StringBuffer();
  buffer.writeln('final router = GoRouter(');
  buffer.writeln('  routes: [');
  buffer.writeln('    GoRoute(');
  buffer.writeln('      path: \'/\',');
  buffer.writeln('      builder: (context, state) => const HomePage(),');
  buffer.writeln('    ),');
  buffer.writeln('  ],');
  buffer.writeln(');');
  return buffer.toString();
}

String _generateCounter(WizardConfig config) {
  final sm = config.stateManagement;

  switch (sm) {
    case StateManagement.none:
      return _counterStatefulWidget();
    case StateManagement.changeNotifier:
      return _counterChangeNotifier();
    case StateManagement.provider:
      return _counterProvider();
    case StateManagement.riverpod:
      return _counterRiverpod();
    case StateManagement.bloc:
      return _counterBloc();
    case StateManagement.getx:
      return _counterGetx();
    case StateManagement.mobx:
      return _counterMobx();
    case StateManagement.signals:
      return _counterSignals();
  }
}

String _counterStatefulWidget() {
  return '''
class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;

  void _increment() => setState(() => _count++);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Count: \$_count', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        FilledButton(onPressed: _increment, child: const Text('Increment')),
      ],
    );
  }
}
''';
}

String _counterChangeNotifier() {
  return '''
class CounterNotifier extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

class Counter extends StatelessWidget {
  const Counter({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = context.watch<CounterNotifier>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Count: \${counter.count}', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: counter.increment,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
''';
}

String _counterProvider() {
  return '''
class CounterNotifier extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

class Counter extends StatelessWidget {
  const Counter({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = context.watch<CounterNotifier>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Count: \${counter.count}', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: counter.increment,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
''';
}

String _counterRiverpod() {
  return '''
final counterProvider = StateProvider<int>((ref) => 0);

class Counter extends ConsumerWidget {
  const Counter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Count: \$count', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => ref.read(counterProvider.notifier).state++,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
''';
}

String _counterBloc() {
  return '''
sealed class CounterEvent {}
class CounterIncrementPressed extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterIncrementPressed>((event, emit) => emit(state + 1));
  }
}

class Counter extends StatelessWidget {
  const Counter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, int>(
      builder: (context, count) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Count: \$count', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<CounterBloc>().add(CounterIncrementPressed()),
              child: const Text('Increment'),
            ),
          ],
        );
      },
    );
  }
}
''';
}

String _counterGetx() {
  return '''
class CounterController extends GetxController {
  final count = 0.obs;

  void increment() => count.value++;
}

class Counter extends StatelessWidget {
  const Counter({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CounterController());
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(() => Text('Count: \${controller.count.value}', style: Theme.of(context).textTheme.headlineMedium)),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: controller.increment,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
''';
}

String _counterMobx() {
  return '''
// Part directive for generated code - run: dart run build_runner build
// part of 'counter.g.dart';

class CounterStore = CounterStoreBase with _\$CounterStore;

abstract class CounterStoreBase with Store {
  @observable
  int count = 0;

  @action
  void increment() => count++;
}

class Counter extends StatelessWidget {
  const Counter({super.key});

  final store = CounterStore();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Observer(
          builder: (_) => Text('Count: \${store.count}', style: Theme.of(context).textTheme.headlineMedium),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: store.increment,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
''';
}

String _counterSignals() {
  return '''
final count = signal(0);

class Counter extends StatelessWidget {
  const Counter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Watch((_) => Text('Count: \${count.value}', style: Theme.of(context).textTheme.headlineMedium)),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => count.value++,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
''';
}

String _generateHomePage(WizardConfig config) {
  final sm = config.stateManagement;
  final isRiverpod = sm == StateManagement.riverpod;

  final classDecl = isRiverpod
      ? 'class HomePage extends ConsumerWidget {'
      : 'class HomePage extends StatelessWidget {';

  final buffer = StringBuffer();
  buffer.writeln(classDecl);
  buffer.writeln('  const HomePage({super.key});');
  buffer.writeln();

  if (isRiverpod) {
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context, WidgetRef ref) {');
  } else {
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context) {');
  }

  buffer.writeln('    return Scaffold(');
  buffer.writeln('      appBar: AppBar(');
  buffer.writeln('        title: const Text(\'${config.projectName}\'),');
  buffer.writeln('      ),');
  buffer.writeln('      body: const Center(');
  buffer.writeln('        child: Counter(),');
  buffer.writeln('      ),');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln('}');

  return buffer.toString();
}
