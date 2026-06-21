import '../config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class FeriaAdminDashboard extends StatefulWidget {
  const FeriaAdminDashboard({super.key});

  @override
  State<FeriaAdminDashboard> createState() => _FeriaAdminDashboardState();
}

class _FeriaAdminDashboardState extends State<FeriaAdminDashboard> {
  int _currentIndex = 0;
  bool _isLoading = true;
  
  // Tab 0 Data
  Map<String, dynamic>? _feriaData;
  
  // Tab 1 Data
  List<dynamic> _stands = [];
  final TextEditingController _standFilterController = TextEditingController();
  
  // Tab 2 Data
  List<dynamic> _evaluators = [];
  List<dynamic> _areas = [];
  
  // Tab 3 Data
  Map<String, dynamic>? _resultsData;

  @override
  void initState() {
    super.initState();
    _loadTab(_currentIndex);
  }

  Future<void> _loadTab(int index) async {
    setState(() => _isLoading = true);
    try {
      if (index == 0) {
        await _fetchMyFeria();
      } else if (index == 1) {
        await _fetchStands();
      } else if (index == 2) {
        await _fetchEvaluators();
        await _fetchAreas();
      } else if (index == 3) {
        await _fetchResults();
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMyFeria() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/api/ferias/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      _feriaData = jsonDecode(response.body);
    }
  }

  Future<void> _fetchStands() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/api/management/stands'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      _stands = jsonDecode(response.body);
    }
  }

  Future<void> _fetchEvaluators() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/api/management/evaluators'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      _evaluators = jsonDecode(response.body);
    }
  }

  Future<void> _fetchAreas() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/api/management/areas'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      _areas = jsonDecode(response.body);
    }
  }

  Future<void> _fetchResults() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/api/management/results'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      _resultsData = jsonDecode(response.body);
    }
  }

  void _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

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

  // Filtrar stands por buscador dinámico (incluyendo Curso en los metadatos de miembros)
  List<dynamic> get _filteredStands {
    final query = _standFilterController.text.toLowerCase().trim();
    if (query.isEmpty) return _stands;
    return _stands.where((stand) {
      final name = (stand['name'] ?? '').toString().toLowerCase();
      final numStr = (stand['number'] ?? '').toString().toLowerCase();
      final members = stand['members'] as List<dynamic>? ?? [];
      
      final matchesMembers = members.any((m) {
        final mName = (m['fullName'] ?? '').toString().toLowerCase();
        final mMeta = m['metadata'];
        if (mMeta != null && mMeta is Map) {
          final mMetaStr = mMeta.values.map((v) => v.toString().toLowerCase()).join(' ');
          if (mMetaStr.contains(query)) return true;
        }
        return mName.contains(query);
      });

      final meta = stand['metadata'];
      bool matchesStandMeta = false;
      if (meta != null && meta is Map) {
        final metaStr = meta.values.map((v) => v.toString().toLowerCase()).join(' ');
        matchesStandMeta = metaStr.contains(query);
      }

      return name.contains(query) || numStr.contains(query) || matchesMembers || matchesStandMeta;
    }).toList();
  }

  String _getMemberMetadataText(dynamic member) {
    final meta = member['metadata'];
    if (meta == null || meta is! Map || meta.isEmpty) return '';
    return meta.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  // Eliminar una asignación
  Future<void> _deleteAssignment(String assignmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar desasignación'),
        content: const Text('¿Estás seguro de que deseas quitar este evaluador de este stand?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/api/management/assignments/$assignmentId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evaluador desasignado con éxito'), backgroundColor: Colors.green),
        );
        _loadTab(_currentIndex);
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al desasignar')));
    }
  }

  // Mostrar el diálogo de asignación en Tabs
  void _showAssignEvaluatorDialog(String standId, String standName) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'JURADO';
    List<String> selectedAreaIds = [];
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Asignar Evaluador a $standName'),
        content: StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Usuario del Evaluador')),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setModalState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: 'Rol en este Stand'),
                    items: const [
                      DropdownMenuItem(value: 'JURADO', child: Text('Jurado (Evalúa Stand)')),
                      DropdownMenuItem(value: 'DELEGADO', child: Text('Delegado (Evalúa Miembros)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedRole = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Áreas asignadas (vacío = todas):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  if (_areas.isEmpty)
                    const Text('No hay áreas creadas en la feria.', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12))
                  else
                    ..._areas.map((area) {
                      final areaId = area['id'].toString();
                      final isChecked = selectedAreaIds.contains(areaId);
                      return CheckboxListTile(
                        title: Text(area['name']),
                        value: isChecked,
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (val) {
                          setModalState(() {
                            if (val == true) {
                              selectedAreaIds.add(areaId);
                            } else {
                              selectedAreaIds.remove(areaId);
                            }
                          });
                        },
                      );
                    }).toList(),
                ],
              ),
            );
          }
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (usernameController.text.trim().isEmpty) return;
              Navigator.pop(context);
              await _assignEvaluator(
                standId, 
                usernameController.text.trim(), 
                passwordController.text.trim(), 
                selectedRole,
                selectedAreaIds,
              );
            },
            child: const Text('Asignar'),
          ),
        ],
      ),
    );
  }

  Future<void> _assignEvaluator(
    String standId, 
    String username, 
    String password, 
    String roleInStand,
    List<String> areaIds,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/management/assignments'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'standId': standId,
          'username': username,
          'password': password,
          'roleInStand': roleInStand,
          'areaIds': areaIds,
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('¡Evaluador Asignado!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Las credenciales han sido creadas con éxito. Cópialas ahora, ya que no se volverán a mostrar de forma directa:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SelectableText(
                    'Usuario: $username\nContraseña: $password',
                    style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copiar'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: 'Usuario: $username, Contraseña: $password'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Credenciales copiadas al portapapeles')),
                  );
                },
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
        _loadTab(_currentIndex);
      } else {
        final error = jsonDecode(response.body)['error'];
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Error al asignar'), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión')));
    }
  }

  // VISTA 1: Configuración de la Feria ("Mi Feria")
  Widget _buildConfigTab() {
    final metadata = _feriaData?['metadata'] ?? {};
    final String type = metadata['type'] ?? 'Configuración General';
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      children: [
        // Tarjeta Cabecera de Bienvenida
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _feriaData?['name'] ?? 'Mi Feria',
                              style: const TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 22,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              type,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8), 
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isSetupComplete 
                          ? Colors.greenAccent.withOpacity(0.15) 
                          : const Color(0xFFFDB913).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isSetupComplete ? Colors.greenAccent : const Color(0xFFFDB913),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isSetupComplete ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                          color: _isSetupComplete ? Colors.greenAccent : const Color(0xFFFDB913),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isSetupComplete ? 'Configuración Completada' : 'Configuración Pendiente',
                          style: TextStyle(
                            color: _isSetupComplete ? Colors.greenAccent : const Color(0xFFFDB913),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Sección Métricas Resumen
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Stands',
                value: _stands.length.toString(),
                icon: Icons.storefront_rounded,
                color: Colors.blue.shade600,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Jurados',
                value: _evaluators.length.toString(),
                icon: Icons.people_alt_rounded,
                color: Colors.green.shade600,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Áreas',
                value: _areas.length.toString(),
                icon: Icons.grid_view_rounded,
                color: Colors.deepPurple.shade400,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        _buildSheetsIntegrationCard(metadata, isDark, colorScheme),
        const SizedBox(height: 24),

        // Sección Módulos de Gestión
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 14),
          child: Text(
            'Módulos de Gestión',
            style: TextStyle(
              fontWeight: FontWeight.w800, 
              fontSize: 16, 
              letterSpacing: 0.5,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
        
        _buildConfigItem(
          title: 'Configurar Feria',
          description: 'Identidad, fechas y rubro general de la feria.',
          icon: Icons.settings_applications_rounded,
          color: colorScheme.primary,
          onTap: () async {
            final result = await context.push('/feria_admin/settings', extra: _feriaData);
            if (result == true) _loadTab(0);
          },
        ),
        _buildConfigItem(
          title: 'Áreas y Criterios',
          description: 'Define qué evaluar y el puntaje mínimo/máximo.',
          icon: Icons.assignment_turned_in_rounded,
          color: Colors.deepPurple,
          onTap: () => context.push('/feria_admin/areas'),
        ),
        _buildConfigItem(
          title: 'Stands y Miembros',
          description: 'Agrega stands, alumnos, expositores y sus cursos.',
          icon: Icons.storefront_rounded,
          color: const Color(0xFFFDB913),
          onTap: () async {
            await context.push('/feria_admin/stands');
            _loadTab(0);
          },
        ),
        _buildConfigItem(
          title: 'Asignaciones de Evaluadores',
          description: 'Gestiona evaluadores y vinculaciones por área.',
          icon: Icons.person_add_alt_rounded,
          color: Colors.green,
          onTap: () async {
            await context.push('/feria_admin/evaluators');
            _loadTab(0);
          },
        ),
        
        const SizedBox(height: 20),
        // BOTÓN CERRAR SESIÓN ERGONÓMICO
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: TextButton.icon(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.redAccent.withOpacity(0.35), width: 1.2),
              ),
              backgroundColor: Colors.redAccent.withOpacity(0.04),
            ),
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text(
              'Cerrar Sesión de la Feria',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.2),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800, 
                fontSize: 22,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, 
                fontSize: 12, 
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final outlineColor = isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left accent vertical line
                Container(
                  width: 5,
                  color: color,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: TextStyle(
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // VISTA 2: Stands & Integrantes
  Widget _buildStandsTab() {
    final filtered = _filteredStands;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Buscador de Stands
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _standFilterController,
            decoration: InputDecoration(
              hintText: 'Buscar por stand, integrante, curso...',
              hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.grey.shade400 : colorScheme.primary, size: 20),
              suffixIcon: _standFilterController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _standFilterController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (val) => setState(() {}),
          ),
        ),
        
        // Listado de Stands
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.storefront_rounded, size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No se encontraron stands',
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final stand = filtered[index];
                    final members = stand['members'] as List<dynamic>? ?? [];
                    final assignments = stand['assignments'] as List<dynamic>? ?? [];
                    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
                    final outlineColor = isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: outlineColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.15 : 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                stand['number'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            title: Text(
                              stand['name'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 15,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '${members.length} integrantes • ${assignments.length} evaluadores',
                                style: TextStyle(
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, 
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(color: outlineColor, height: 1),
                                    const SizedBox(height: 16),
                                    
                                    // Integrantes
                                    Row(
                                      children: [
                                        Icon(Icons.people_rounded, size: 16, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Integrantes (${members.length})', 
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold, 
                                            fontSize: 13, 
                                            color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (members.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          'Sin integrantes registrados.', 
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic, 
                                            fontSize: 12,
                                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                          ),
                                        ),
                                      )
                                    else
                                      ...members.map((m) {
                                        final metaText = _getMemberMetadataText(m);
                                        return Container(
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.person_rounded, size: 14, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  m['fullName'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: isDark ? Colors.grey.shade200 : const Color(0xFF334155),
                                                  ),
                                                ),
                                              ),
                                              if (metaText.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: colorScheme.primary.withOpacity(0.08),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    metaText,
                                                    style: TextStyle(
                                                      fontSize: 10, 
                                                      fontWeight: FontWeight.w600,
                                                      color: colorScheme.primary,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }),
                                    
                                    const SizedBox(height: 16),
                                    
                                    // Evaluadores
                                    Row(
                                      children: [
                                        Icon(Icons.gavel_rounded, size: 16, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Evaluadores Asignados (${assignments.length})', 
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold, 
                                            fontSize: 13, 
                                            color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (assignments.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                        child: Text(
                                          'Ningún jurado o delegado asignado.', 
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic, 
                                            fontSize: 12,
                                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                          ),
                                        ),
                                      )
                                    else
                                      ...assignments.map((a) {
                                        final user = a['user'] ?? {};
                                        final areas = a['areas'] as List<dynamic>? ?? [];
                                        final areasText = areas.map((ar) => ar['name']).join(', ');
                                        final isJurado = a['roleInStand'] == 'JURADO';

                                        return Container(
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: (isJurado ? Colors.green : Colors.teal).withOpacity(0.06),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: (isJurado ? Colors.green : Colors.teal).withOpacity(0.15),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: (isJurado ? Colors.green : Colors.teal).withOpacity(0.12),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  isJurado ? Icons.gavel_rounded : Icons.badge_rounded,
                                                  size: 14,
                                                  color: isJurado ? Colors.green.shade700 : Colors.teal.shade700,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          user['username'] ?? 'S/U',
                                                          style: TextStyle(
                                                            fontSize: 13, 
                                                            fontWeight: FontWeight.bold,
                                                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: (isJurado ? Colors.green : Colors.teal).withOpacity(0.15),
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          child: Text(
                                                            a['roleInStand'] ?? '',
                                                            style: TextStyle(
                                                              fontSize: 9,
                                                              fontWeight: FontWeight.w800,
                                                              color: isJurado ? Colors.green : Colors.teal,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      areasText.isNotEmpty ? 'Áreas: $areasText' : 'Todas las Áreas',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                                onPressed: () => _deleteAssignment(a['id']),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                tooltip: 'Eliminar Asignación',
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    
                                    const SizedBox(height: 16),
                                    // Botón de Asignación
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: FilledButton.icon(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: () => _showAssignEvaluatorDialog(stand['id'], stand['name']),
                                        icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                                        label: const Text('Asignar Evaluador', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // VISTA 3: Evaluadores Asignados a la Feria
  Widget _buildEvaluatorsTab() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _evaluators.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline_rounded, size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'No hay evaluadores registrados',
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _evaluators.length,
            itemBuilder: (context, index) {
              final eval = _evaluators[index];
              final assignments = eval['assignments'] as List<dynamic>? ?? [];
              final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
              final outlineColor = isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: outlineColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.15 : 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_rounded, color: colorScheme.primary, size: 20),
                      ),
                      title: Text(
                        eval['username'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 15,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '${assignments.length} stands asignados',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, 
                            fontSize: 12,
                          ),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(color: outlineColor, height: 1),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(Icons.storefront_rounded, size: 16, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Stands Asignados:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 13, 
                                      color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (assignments.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                  child: Text(
                                    'Sin stands asignados actualmente.', 
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic, 
                                      fontSize: 12,
                                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                    ),
                                  ),
                                )
                              else
                                ...assignments.map((a) {
                                  final stand = a['stand'] ?? {};
                                  final areas = a['areas'] as List<dynamic>? ?? [];
                                  final areasText = areas.map((ar) => ar['name']).join(', ');
                                  final isJurado = a['roleInStand'] == 'JURADO';

                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: (isJurado ? Colors.green : Colors.teal).withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: (isJurado ? Colors.green : Colors.teal).withOpacity(0.15),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: (isJurado ? Colors.green : Colors.teal).withOpacity(0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isJurado ? Icons.gavel_rounded : Icons.badge_rounded,
                                            size: 14,
                                            color: isJurado ? Colors.green.shade700 : Colors.teal.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Stand ${stand['number'] ?? ""}: ${stand['name'] ?? ""}',
                                                    style: TextStyle(
                                                      fontSize: 13, 
                                                      fontWeight: FontWeight.bold,
                                                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: (isJurado ? Colors.green : Colors.teal).withOpacity(0.15),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      a['roleInStand'] ?? '',
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight: FontWeight.w800,
                                                        color: isJurado ? Colors.green : Colors.teal,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                areasText.isNotEmpty ? 'Áreas: $areasText' : 'Todas las Áreas',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                          onPressed: () => _deleteAssignment(a['id']),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          tooltip: 'Eliminar Asignación',
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  // VISTA 4: Reporte de Resultados y Avance
  Widget _buildResultsTab() {
    if (_resultsData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text(
              'No hay datos de resultados disponibles.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      );
    }

    final results = _resultsData!['results'] as List<dynamic>? ?? [];
    final calcType = _resultsData!['calculationType'] ?? 'SUMATIVE';
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de Método de Cálculo
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.primary.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Icon(Icons.analytics_rounded, color: colorScheme.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Método de Cálculo General',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      calcType == 'SUMATIVE'
                          ? 'Sumativo (Suma de notas de criterios)'
                          : 'Ponderado (Ponderado por porcentaje de Áreas)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.storefront_rounded, size: 64, color: Colors.grey.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No hay stands evaluados o registrados.',
                        style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final res = results[index];
                    final jurados = res['jurados'] as List<dynamic>? ?? [];
                    final delegados = res['delegados'] as List<dynamic>? ?? [];
                    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
                    final outlineColor = isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;

                    int totalAssigned = 0;
                    int totalCompleted = 0;
                    for (var j in jurados) {
                      totalAssigned += (j['totalAssignedCount'] as num? ?? 0).toInt();
                      totalCompleted += (j['completedCount'] as num? ?? 0).toInt();
                    }
                    for (var d in delegados) {
                      totalAssigned += (d['totalAssignedCount'] as num? ?? 0).toInt();
                      totalCompleted += (d['completedCount'] as num? ?? 0).toInt();
                    }
                    final double progress = totalAssigned > 0 ? (totalCompleted / totalAssigned) : 0.0;
                    final int percent = (progress * 100).round();

                    Color progressColor = Colors.grey;
                    if (progress == 1.0) {
                      progressColor = Colors.green;
                    } else if (progress > 0.0) {
                      progressColor = const Color(0xFFFDB913);
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: outlineColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.15 : 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                res['number'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            title: Text(
                              res['name'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        'Jurados: ${res['avgJuradoScore']} pts',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                                      ),
                                      Text(
                                        'Delegados: ${res['avgDelegadoScore']} pts',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Avance de evaluación:',
                                        style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                                      ),
                                      Text(
                                        '$percent%',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: progressColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100,
                                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                      minHeight: 5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(color: outlineColor, height: 1),
                                    const SizedBox(height: 16),
                                    
                                    // Detalle Jurados
                                    Row(
                                      children: [
                                        const Icon(Icons.gavel_rounded, size: 14, color: Colors.green),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Evaluación de Jurados',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: isDark ? Colors.grey.shade300 : const Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (jurados.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          'Sin jurados asignados.',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 11,
                                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                          ),
                                        ),
                                      )
                                    else
                                      ...jurados.map((j) {
                                        final bool comp = j['isCompleted'] == true;
                                        return Container(
                                          margin: const EdgeInsets.symmetric(vertical: 3),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: (comp ? Colors.green : Colors.orange).withOpacity(0.04),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: (comp ? Colors.green : Colors.orange).withOpacity(0.12),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                comp ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                                                size: 14,
                                                color: comp ? Colors.green : Colors.orange,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '${j['username']}: ${j['score']} pts (${j['completedCount']}/${j['totalAssignedCount']} criterios)',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDark ? Colors.grey.shade200 : const Color(0xFF334155),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    
                                    const SizedBox(height: 16),
                                    
                                    // Detalle Delegados
                                    Row(
                                      children: [
                                        const Icon(Icons.badge_rounded, size: 14, color: Colors.teal),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Evaluación de Delegados por Integrante',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: isDark ? Colors.grey.shade300 : const Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (delegados.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          'Sin delegados asignados.',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 11,
                                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                          ),
                                        ),
                                      )
                                    else
                                      ...delegados.map((d) {
                                        final bool comp = d['isCompleted'] == true;
                                        return Container(
                                          margin: const EdgeInsets.symmetric(vertical: 3),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: (comp ? Colors.teal : Colors.orange).withOpacity(0.04),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: (comp ? Colors.teal : Colors.orange).withOpacity(0.12),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                comp ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                                                size: 14,
                                                color: comp ? Colors.teal : Colors.orange,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '${d['username']} ➔ ${d['memberName']}: ${d['score']} pts (${d['completedCount']}/${d['totalAssignedCount']} criterios)',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDark ? Colors.grey.shade200 : const Color(0xFF334155),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent = const Center(child: CircularProgressIndicator());

    if (!_isLoading) {
      if (_currentIndex == 0) {
        bodyContent = _buildConfigTab();
      } else if (_currentIndex == 1) {
        bodyContent = _buildStandsTab();
      } else if (_currentIndex == 2) {
        bodyContent = _buildEvaluatorsTab();
      } else if (_currentIndex == 3) {
        bodyContent = _buildResultsTab();
      }
    }

    final String appBarTitle = _currentIndex == 0
        ? 'Mi Feria'
        : _currentIndex == 1
            ? 'Stands y Miembros'
            : _currentIndex == 2
                ? 'Jurados & Delegados'
                : 'Puntajes y Avance';

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          appBarTitle, 
          style: TextStyle(
            fontWeight: FontWeight.w800, 
            fontSize: 18,
            letterSpacing: 0.3,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadTab(_currentIndex),
            tooltip: 'Refrescar datos',
          ),
        ],
      ),
      body: bodyContent,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            _loadTab(index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_rounded),
              label: 'Mi Feria',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront),
              label: 'Stands',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt),
              label: 'Evaluadores',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Resultados',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetsIntegrationCard(Map<dynamic, dynamic> metadata, bool isDark, ColorScheme colorScheme) {
    final String? spreadsheetUrl = metadata['spreadsheetUrl']?.toString();

    if (spreadsheetUrl == null || spreadsheetUrl.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
            width: 1,
          ),
        ),
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Google Sheets no vinculado',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Acceso directo no disponible',
                          style: TextStyle(
                            color: Colors.amber.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Esta feria no tiene un Google Sheet asociado. Crea uno automáticamente para poder cargar la configuración y volcar las notas directamente desde el documento.',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _createGoogleSheetForFeria,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF003264), // Azul UAB
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add_to_drive_rounded, size: 18),
                  label: const Text(
                    'Vincular Google Sheet',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google Sheets de la Feria',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Vinculado automáticamente',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Configura los stands y la rúbrica desde la plantilla de Google Sheets. Las evaluaciones de jurados y delegados se sincronizan automáticamente en pestañas dedicadas.',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openGoogleSheet(spreadsheetUrl),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF003264), // Azul UAB
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text(
                      'Abrir Google Sheets',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _syncConfigFromSheets,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                          side: BorderSide(
                            color: isDark ? Colors.white.withOpacity(0.15) : Colors.grey.shade300,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: const Text(
                          'Cargar Config',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _syncResultsToSheets,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                          side: BorderSide(
                            color: isDark ? Colors.white.withOpacity(0.15) : Colors.grey.shade300,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.sync_rounded, size: 16),
                        label: const Text(
                          'Volcar Notas',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGoogleSheet(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace en el navegador.')),
        );
      }
    }
  }

  Future<void> _syncConfigFromSheets() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cargar Configuración'),
        content: const Text(
          'Se eliminarán todas las asignaciones, stands, criterios y notas existentes en la base de datos de esta feria para sobrescribirlas con la plantilla del Google Sheet. ¿Deseas continuar?'
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sobrescribir'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/management/sheets/sync-config'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configuración cargada exitosamente'), backgroundColor: Colors.green),
          );
        }
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Error al cargar la configuración';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err), backgroundColor: Colors.red),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de red al sincronizar'), backgroundColor: Colors.red),
        );
      }
    } finally {
      _loadTab(0);
    }
  }

  Future<void> _syncResultsToSheets() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/management/sheets/sync-results'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Resultados volcados a Google Sheets exitosamente'), backgroundColor: Colors.green),
          );
        }
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Error al volcar resultados';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err), backgroundColor: Colors.red),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de red al sincronizar'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createGoogleSheetForFeria() async {
    final gmailController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vincular Google Sheet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Se creará un documento de Google Sheets en Google Drive para esta feria. Ingresa un correo Gmail si deseas compartirle acceso de edición de forma directa (Opcional):',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: gmailController,
              decoration: const InputDecoration(
                labelText: 'Correo Gmail (Opcional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vincular'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final gmail = gmailController.text.trim();

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/management/sheets/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'gmail': gmail.isEmpty ? null : gmail,
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google Sheet creado y vinculado con éxito'), backgroundColor: Colors.green),
          );
        }
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Error al vincular el Google Sheet';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err), backgroundColor: Colors.red),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de red al crear el Google Sheet'), backgroundColor: Colors.red),
        );
      }
    } finally {
      _loadTab(0);
    }
  }
}
