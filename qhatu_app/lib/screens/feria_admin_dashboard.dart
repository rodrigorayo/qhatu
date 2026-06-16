import '../config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evaluador asignado correctamente'), backgroundColor: Colors.green));
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

  // VISTA 1: Configuración de la Feria
  Widget _buildConfigTab() {
    final metadata = _feriaData?['metadata'] ?? {};
    final String type = metadata['type'] ?? 'Configuración Pendiente';

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Card(
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
                      'Estado de Feria',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _isSetupComplete ? '¡Configuración Lista!' : 'Configuración Incompleta',
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
                      if (result == true) _loadTab(0);
                    },
                    icon: const Icon(Icons.rocket_launch),
                    label: const Text('Iniciar Configuración'),
                  )
                ]
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Configurar Módulos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildConfigItem(
          title: 'Configurar Feria',
          description: 'Identidad, fechas y rubro general de la feria.',
          icon: Icons.settings_applications,
          color: Colors.blue,
          onTap: () async {
            final result = await context.push('/feria_admin/settings', extra: _feriaData);
            if (result == true) _loadTab(0);
          },
        ),
        _buildConfigItem(
          title: 'Áreas y Criterios',
          description: 'Define qué evaluar y el puntaje mínimo/máximo.',
          icon: Icons.assignment_turned_in,
          color: Colors.purple,
          onTap: () => context.push('/feria_admin/areas'),
        ),
        _buildConfigItem(
          title: 'Stands y Miembros',
          description: 'Agrega stands, alumnos, expositores y sus cursos.',
          icon: Icons.storefront,
          color: Colors.orange,
          onTap: () async {
            await context.push('/feria_admin/stands');
            _loadTab(0);
          },
        ),
        _buildConfigItem(
          title: 'Asignaciones de Evaluadores',
          description: 'Gestiona evaluadores y vinculaciones por área.',
          icon: Icons.person_add_alt,
          color: Colors.green,
          onTap: () async {
            await context.push('/feria_admin/evaluators');
            _loadTab(0);
          },
        ),
        const SizedBox(height: 32),
        // BOTÓN CERRAR SESIÓN ERGONÓMICO (FÁCIL ALCANZE AL PULGAR)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              side: const BorderSide(color: Colors.redAccent),
              foregroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildConfigItem({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(description, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  // VISTA 2: Stands & Integrantes (Buscador formal & avanzado)
  Widget _buildStandsTab() {
    final filtered = _filteredStands;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _standFilterController,
            decoration: InputDecoration(
              labelText: 'Filtrar stands (ej: "1ro B", nombre, etc.)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _standFilterController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _standFilterController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onChanged: (val) => setState(() {}),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No se encontraron stands con ese criterio.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final stand = filtered[index];
                    final members = stand['members'] as List<dynamic>? ?? [];
                    final assignments = stand['assignments'] as List<dynamic>? ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  child: Text(
                                    stand['number'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    stand['name'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            
                            // Integrantes
                            const Text('Integrantes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                            const SizedBox(height: 4),
                            if (members.isEmpty)
                              const Text('Sin integrantes registrados.', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12))
                            else
                              ...members.map((m) {
                                final metaText = _getMemberMetadataText(m);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.person, size: 14, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        m['fullName'] + (metaText.isNotEmpty ? ' ($metaText)' : ''),
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            const SizedBox(height: 12),

                            // Evaluadores
                            const Text('Evaluadores Asignados:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                            const SizedBox(height: 4),
                            if (assignments.isEmpty)
                              const Text('Ningún jurado o delegado asignado.', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12))
                            else
                              ...assignments.map((a) {
                                final user = a['user'] ?? {};
                                final areas = a['areas'] as List<dynamic>? ?? [];
                                final areasText = areas.map((ar) => ar['name']).join(', ');

                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (a['roleInStand'] == 'JURADO' ? Colors.green : Colors.teal).withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: (a['roleInStand'] == 'JURADO' ? Colors.green : Colors.teal).withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        a['roleInStand'] == 'JURADO' ? Icons.gavel : Icons.badge,
                                        size: 14,
                                        color: a['roleInStand'] == 'JURADO' ? Colors.green : Colors.teal,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${user['username'] ?? 'S/U'} (${a['roleInStand']})' +
                                          (areasText.isNotEmpty ? ' - Áreas: $areasText' : ' - Todas las Áreas'),
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                        onPressed: () => _deleteAssignment(a['id']),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            
                            const SizedBox(height: 12),
                            // Botones de Acción Ergonómicos
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _showAssignEvaluatorDialog(stand['id'], stand['name']),
                                icon: const Icon(Icons.person_add_alt_1, size: 16),
                                label: const Text('Asignar Evaluador', style: TextStyle(fontSize: 12)),
                              ),
                            )
                          ],
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
    return _evaluators.isEmpty
        ? const Center(child: Text('No hay evaluadores (Jurados/Delegados) registrados en esta feria.'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _evaluators.length,
            itemBuilder: (context, index) {
              final eval = _evaluators[index];
              final assignments = eval['assignments'] as List<dynamic>? ?? [];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blueGrey.shade100,
                            child: const Icon(Icons.person, color: Colors.blueGrey),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              eval['username'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Chip(
                            label: const Text('EVALUADOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.blueGrey.shade50,
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      const Text('Stands Asignados:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                      const SizedBox(height: 8),
                      if (assignments.isEmpty)
                        const Text('Sin stands asignados actualmente.', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12))
                      else
                        ...assignments.map((a) {
                          final stand = a['stand'] ?? {};
                          final areas = a['areas'] as List<dynamic>? ?? [];
                          final areasText = areas.map((ar) => ar['name']).join(', ');

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  a['roleInStand'] == 'JURADO' ? Icons.gavel : Icons.badge,
                                  size: 14,
                                  color: a['roleInStand'] == 'JURADO' ? Colors.green : Colors.teal,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Stand ${stand['number']}: ${stand['name']} (${a['roleInStand']})',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        areasText.isNotEmpty ? 'Áreas: $areasText' : 'Áreas: Todas las Áreas',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                  onPressed: () => _deleteAssignment(a['id']),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              );
            },
          );
  }

  // VISTA 4: Reporte de Resultados y Avance
  Widget _buildResultsTab() {
    if (_resultsData == null) {
      return const Center(child: Text('No hay datos de resultados disponibles.'));
    }

    final results = _resultsData!['results'] as List<dynamic>? ?? [];
    final calcType = _resultsData!['calculationType'] ?? 'SUMATIVE';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.analytics, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(
                'Método de Cálculo: ${calcType == 'SUMATIVE' ? 'Sumativo' : 'Ponderado por Área'}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo),
              ),
            ],
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? const Center(child: Text('No hay stands evaluados o registrados.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final res = results[index];
                    final jurados = res['jurados'] as List<dynamic>? ?? [];
                    final delegados = res['delegados'] as List<dynamic>? ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.shade50,
                          child: Text(res['number'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                        ),
                        title: Text(res['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Row(
                          children: [
                            Text('Jurados: ${res['avgJuradoScore']} pts', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green)),
                            const SizedBox(width: 12),
                            Text('Delegados: ${res['avgDelegadoScore']} pts', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.teal)),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Detalle Jurados
                                const Text('Evaluación de Jurados:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                                const SizedBox(height: 4),
                                if (jurados.isEmpty)
                                  const Text('Sin jurados asignados.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic))
                                else
                                  ...jurados.map((j) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Row(
                                        children: [
                                          Icon(j['isCompleted'] ? Icons.check_circle : Icons.pending, size: 14, color: j['isCompleted'] ? Colors.green : Colors.orange),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${j['username']}: ${j['score']} pts (${j['completedCount']}/${j['totalAssignedCount']} criterios)',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                
                                const Divider(height: 24),
                                
                                // Detalle Delegados
                                const Text('Evaluación de Delegados por Integrante:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.teal)),
                                const SizedBox(height: 4),
                                if (delegados.isEmpty)
                                  const Text('Sin delegados asignados.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic))
                                else
                                  ...delegados.map((d) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Row(
                                        children: [
                                          Icon(d['isCompleted'] ? Icons.check_circle : Icons.pending, size: 14, color: d['isCompleted'] ? Colors.teal : Colors.orange),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              '${d['username']} -> ${d['memberName']}: ${d['score']} pts (${d['completedCount']}/${d['totalAssignedCount']} criterios)',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          )
                        ],
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
        ? 'Panel Administrativo'
        : _currentIndex == 1
            ? 'Stands y Miembros'
            : _currentIndex == 2
                ? 'Jurados & Delegados'
                : 'Puntajes y Avance';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(appBarTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadTab(_currentIndex),
          ),
        ],
      ),
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _loadTab(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurar',
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
    );
  }
}
