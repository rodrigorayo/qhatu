import '../config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ManageStandsScreen extends StatefulWidget {
  const ManageStandsScreen({super.key});

  @override
  State<ManageStandsScreen> createState() => _ManageStandsScreenState();
}

class _ManageStandsScreenState extends State<ManageStandsScreen> {
  List<dynamic> _stands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStands();
  }

  Future<void> _fetchStands() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/management/stands'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() => _stands = jsonDecode(response.body));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al cargar stands')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddStandDialog() {
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    final categoryController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Stand'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController, 
                decoration: const InputDecoration(
                  labelText: 'Nombre del Stand / Proyecto *',
                  prefixIcon: Icon(Icons.store),
                )
              ),
              const SizedBox(height: 8),
              TextField(
                controller: numberController, 
                decoration: const InputDecoration(
                  labelText: 'Número o Identificador (ej. A-12)',
                  prefixIcon: Icon(Icons.tag),
                )
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Datos Opcionales', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                controller: categoryController, 
                decoration: const InputDecoration(
                  labelText: 'Categoría o Nivel (ej. Robótica, 4to A)',
                  prefixIcon: Icon(Icons.category),
                )
              ),
              const SizedBox(height: 8),
              TextField(
                controller: locationController, 
                decoration: const InputDecoration(
                  labelText: 'Ubicación Específica (ej. Pabellón B)',
                  prefixIcon: Icon(Icons.place),
                )
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre es obligatorio')));
                return;
              }
              
              Map<String, dynamic> metadata = {};
              if (categoryController.text.trim().isNotEmpty) {
                metadata['categoría'] = categoryController.text.trim();
              }
              if (locationController.text.trim().isNotEmpty) {
                metadata['ubicación'] = locationController.text.trim();
              }

              Navigator.pop(context);
              await _createStand(nameController.text.trim(), numberController.text.trim(), metadata);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _createStand(String name, String number, Map<String, dynamic> metadata) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/management/stands'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'name': name,
          'number': number,
          'metadata': metadata,
        }),
      );

      if (response.statusCode == 201) {
        _fetchStands();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión al crear stand')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Stands')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStandDialog,
        icon: const Icon(Icons.storefront),
        label: const Text('Nuevo Stand'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stands.isEmpty
              ? const Center(child: Text('No hay stands registrados.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _stands.length,
                  itemBuilder: (context, index) {
                    final stand = _stands[index];
                    final members = stand['members'] as List<dynamic>;
                    final metadata = stand['metadata'] as Map<String, dynamic>? ?? {};

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        leading: CircleAvatar(child: Text(stand['number'] ?? 'S')),
                        title: Text(stand['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${members.length} miembros - Datos extra: ${metadata.keys.join(", ")}'),
                        children: [
                          ...members.map((m) {
                            final memberMetadata = m['metadata'] as Map<String, dynamic>? ?? {};
                            final hasMetadata = memberMetadata.isNotEmpty;
                            
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(m['fullName']),
                              subtitle: hasMetadata ? Text(memberMetadata.values.join(" - ")) : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                    onPressed: () => _showEditMemberDialog(m['id'], m['fullName'], m['metadata']?['cargo'] ?? ''),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                    onPressed: () => _deleteMember(m['id']),
                                  ),
                                ],
                              ),
                            );
                          }),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton.icon(
                              onPressed: () => _showAddMemberDialog(stand['id']),
                              icon: const Icon(Icons.person_add),
                              label: const Text('Añadir Miembro'),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  void _showAddMemberDialog(String standId) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final massiveController = TextEditingController();
    int _selectedIndex = 0; // 0 = Individual, 1 = Masivo

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Añadir Miembro'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Individual'), icon: Icon(Icons.person)),
                      ButtonSegment(value: 1, label: Text('Masivo (Copiar)'), icon: Icon(Icons.group)),
                    ],
                    selected: {_selectedIndex},
                    onSelectionChanged: (Set<int> newSelection) {
                      setStateDialog(() => _selectedIndex = newSelection.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_selectedIndex == 0) ...[
                    TextField(
                      controller: nameController, 
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'))],
                      decoration: const InputDecoration(labelText: 'Nombre Completo *', prefixIcon: Icon(Icons.person))
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: roleController, 
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'))],
                      decoration: const InputDecoration(labelText: 'Cargo o Rol (Opcional)', prefixIcon: Icon(Icons.work))
                    ),
                  ] else ...[
                    const Text('Pega la lista desde Excel o Word (Un nombre por línea):', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: massiveController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Jose\\nJuan\\nPedro\\nLucas',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              FilledButton(
                onPressed: () async {
                  if (_selectedIndex == 0) {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre es obligatorio')));
                      return;
                    }
                    Navigator.pop(context);
                    await _addMember(standId, nameController.text.trim(), roleController.text.trim());
                  } else {
                    if (massiveController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La lista está vacía')));
                      return;
                    }
                    // Dividir por saltos de línea y filtrar líneas vacías
                    final names = massiveController.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                    if (names.isEmpty) return;
                    Navigator.pop(context);
                    await _addMembersBatch(standId, names);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _addMember(String standId, String fullName, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/management/stands/$standId/members'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'fullName': fullName,
          'metadata': role.isNotEmpty ? {'cargo': role} : {},
        }),
      );

      if (response.statusCode == 201) {
        _fetchStands();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al guardar el miembro')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión al añadir miembro')));
    }
  }

  Future<void> _addMembersBatch(String standId, List<String> names) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/management/stands/$standId/members/batch'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'names': names,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${data['count']} miembros añadidos masivamente'), backgroundColor: Colors.green));
        _fetchStands();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al procesar la lista masiva')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión al añadir miembros')));
    }
  }

  void _showEditMemberDialog(String memberId, String currentName, String currentRole) {
    final nameController = TextEditingController(text: currentName);
    final roleController = TextEditingController(text: currentRole);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Miembro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController, 
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'))],
              decoration: const InputDecoration(labelText: 'Nombre Completo *', prefixIcon: Icon(Icons.person))
            ),
            const SizedBox(height: 8),
            TextField(
              controller: roleController, 
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'))],
              decoration: const InputDecoration(labelText: 'Cargo o Rol (Opcional)', prefixIcon: Icon(Icons.work))
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre es obligatorio')));
                return;
              }
              Navigator.pop(context);
              await _editMember(memberId, nameController.text.trim(), roleController.text.trim());
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _editMember(String memberId, String fullName, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('${Config.baseUrl}/api/management/members/$memberId'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'fullName': fullName,
          'metadata': role.isNotEmpty ? {'cargo': role} : {},
        }),
      );

      if (response.statusCode == 200) {
        _fetchStands();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar el miembro')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión al actualizar miembro')));
    }
  }

  Future<void> _deleteMember(String memberId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar miembro?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/api/management/members/$memberId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _fetchStands();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al eliminar el miembro')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión al eliminar miembro')));
    }
  }
}
