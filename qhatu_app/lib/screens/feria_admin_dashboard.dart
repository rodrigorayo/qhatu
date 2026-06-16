import '../config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class FeriaAdminDashboard extends StatefulWidget {
  const FeriaAdminDashboard({super.key});

  @override
  State<FeriaAdminDashboard> createState() => _FeriaAdminDashboardState();
}

class _FeriaAdminDashboardState extends State<FeriaAdminDashboard> {
  Map<String, dynamic>? _feriaData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyFeria();
  }

  Future<void> _fetchMyFeria() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/ferias/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _feriaData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) context.go('/login');
  }

  bool get _isSetupComplete {
    if (_feriaData == null) return false;
    final metadata = _feriaData!['metadata'];
    if (metadata == null) return false;
    return metadata['setupComplete'] == true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String name = _feriaData?['name'] ?? 'Mi Feria';
    final metadata = _feriaData?['metadata'] ?? {};
    final String type = metadata['type'] ?? 'Configuración Pendiente';
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchMyFeria),
              IconButton(icon: const Icon(Icons.logout), onPressed: () => _logout(context)),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(context, type),
                  const SizedBox(height: 32),
                  Text(
                    'Etapas de Gestión',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // FASE 1
                  _buildPhaseCard(
                    context,
                    phase: 'Fase 1',
                    title: 'Configuración de Feria',
                    description: 'Define la identidad, fechas y rubro del evento.',
                    icon: Icons.settings,
                    color: Colors.blue,
                    isCompleted: _isSetupComplete,
                    onTap: () async {
                      final result = await context.push('/feria_admin/settings', extra: _feriaData);
                      if (result == true) _fetchMyFeria();
                    },
                  ),
                  
                  // FASE 2
                  _buildPhaseCard(
                    context,
                    phase: 'Fase 2',
                    title: 'Áreas y Criterios',
                    description: 'Configura las métricas de evaluación.',
                    icon: Icons.rule_folder,
                    color: Colors.purple,
                    isCompleted: false, // Lógica para completar pendiente
                    onTap: () => context.push('/feria_admin/areas'),
                  ),

                  // FASE 3
                  _buildPhaseCard(
                    context,
                    phase: 'Fase 3',
                    title: 'Creación de Stands',
                    description: 'Registra los stands y sus miembros.',
                    icon: Icons.storefront,
                    color: Colors.orange,
                    isCompleted: false,
                    onTap: () => context.push('/feria_admin/stands'),
                  ),

                  // FASE 4
                  _buildPhaseCard(
                    context,
                    phase: 'Fase 4',
                    title: 'Asignación de Jurados',
                    description: 'Crea evaluadores y asígnalos a los stands.',
                    icon: Icons.people_alt,
                    color: Colors.green,
                    isCompleted: false,
                    onTap: () => context.push('/feria_admin/evaluators'),
                  ),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, String type) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stars, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Estado Actual',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _isSetupComplete ? '¡Todo listo para arrancar!' : 'Requiere Configuración',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (!_isSetupComplete) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () async {
                  final result = await context.push('/feria_admin/settings', extra: _feriaData);
                  if (result == true) _fetchMyFeria();
                },
                icon: const Icon(Icons.rocket_launch),
                label: const Text('Iniciar Fase 1'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseCard(
    BuildContext context, {
    required String phase,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phase.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check_circle, color: Colors.green, size: 28)
              else
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
