import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';
import 'screens/super_admin_dashboard.dart';
import 'screens/feria_admin_dashboard.dart';
import 'screens/manage_areas_screen.dart';
import 'screens/manage_stands_screen.dart';
import 'screens/manage_evaluators_screen.dart';
import 'screens/evaluator_dashboard.dart';
import 'screens/evaluation_form_screen.dart';
import 'screens/select_stand_screen.dart';
import 'screens/manage_ferias_screen.dart';
import 'screens/feria_settings_screen.dart';
import 'database/models/local_models.dart';

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

  runApp(QhatuApp(router: router));
}

class QhatuApp extends StatelessWidget {
  final GoRouter router;
  
  const QhatuApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF6B7C98);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Qhatu - Ferias',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
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
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      themeMode: ThemeMode.system,
    );
  }
}
