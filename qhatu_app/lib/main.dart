import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:qhatu_app/core/theme/theme_provider.dart';
import 'package:qhatu_app/features/auth/presentation/login_screen.dart';
import 'package:qhatu_app/features/super_admin/presentation/super_admin_dashboard.dart';
import 'package:qhatu_app/features/feria_admin/presentation/feria_admin_dashboard.dart';
import 'package:qhatu_app/features/feria_admin/presentation/manage_areas_screen.dart';
import 'package:qhatu_app/features/feria_admin/presentation/manage_stands_screen.dart';
import 'package:qhatu_app/features/feria_admin/presentation/manage_evaluators_screen.dart';
import 'package:qhatu_app/features/evaluator/presentation/evaluator_dashboard.dart';
import 'package:qhatu_app/features/evaluator/presentation/evaluation_form_screen.dart';
import 'package:qhatu_app/features/evaluator/presentation/select_stand_screen.dart';
import 'package:qhatu_app/features/super_admin/presentation/manage_ferias_screen.dart';
import 'package:qhatu_app/features/feria_admin/presentation/feria_settings_screen.dart';
import 'package:qhatu_app/core/database/models/local_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("QHATU APP MAIN STARTED SUCCESSFULLY");
  // Verificar si ya hay una sesión activa
  final prefs = await SharedPreferences.getInstance();
  final initialToken = prefs.getString('token');
  final initialRole = prefs.getString('role');
  print("Initial token: $initialToken, initial role: $initialRole");

  String initialRoute = '/login';
  if (initialToken != null) {
    if (initialRole == 'SUPER_ADMIN') initialRoute = '/super_admin';
    else if (initialRole == 'FERIA_ADMIN') initialRoute = '/feria_admin';
    else if (initialRole == 'EVALUADOR') initialRoute = '/evaluator';
  }
  print("Initial route resolved to: $initialRoute");

  final router = GoRouter(
    initialLocation: initialRoute,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/super_admin',
        builder: (context, state) => const SuperAdminDashboard(),
      ),
      GoRoute(
        path: '/super_admin/ferias',
        builder: (context, state) => const ManageFeriasScreen(),
      ),
      GoRoute(
        path: '/feria_admin',
        builder: (context, state) => const FeriaAdminDashboard(),
      ),
      GoRoute(
        path: '/feria_admin/settings',
        builder: (context, state) {
          final initialData = state.extra as Map<String, dynamic>?;
          return FeriaSettingsScreen(initialData: initialData);
        },
      ),
      GoRoute(
        path: '/feria_admin/areas',
        builder: (context, state) => const ManageAreasScreen(),
      ),
      GoRoute(
        path: '/feria_admin/stands',
        builder: (context, state) => const ManageStandsScreen(),
      ),
      GoRoute(
        path: '/feria_admin/evaluators',
        builder: (context, state) => const ManageEvaluatorsScreen(),
      ),
      GoRoute(
        path: '/evaluator',
        builder: (context, state) => const EvaluatorDashboard(),
      ),
      GoRoute(
        path: '/evaluator/select_stand',
        builder: (context, state) => const SelectStandScreen(),
      ),
      GoRoute(
        path: '/evaluator/form',
        builder: (context, state) {
          final assignment = state.extra as LocalAssignment;
          return EvaluationFormScreen(assignment: assignment);
        },
      ),
    ],
  );

  final themeProvider = ThemeProvider();
  await themeProvider.loadThemeMode();

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: QhatuApp(router: router),
    ),
  );
}

class QhatuApp extends StatelessWidget {
  final GoRouter router;
  
  const QhatuApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF003264);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Qhatu - Ferias',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ).copyWith(
          primary: seedColor,
          onPrimary: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ).copyWith(
          primary: seedColor,
          onPrimary: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      themeMode: themeProvider.themeMode,
    );
  }
}
