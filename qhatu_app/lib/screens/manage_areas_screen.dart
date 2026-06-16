import '../config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ManageAreasScreen extends StatefulWidget {
  const ManageAreasScreen({super.key});

  @override
  State<ManageAreasScreen> createState() => _ManageAreasScreenState();
}

class _ManageAreasScreenState extends State<ManageAreasScreen> {
  List<dynamic> _areas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAreas();
  }

  Future<void> _fetchAreas() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/management/areas'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() => _areas = jsonDecode(response.body));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al cargar áreas')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddAreaDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Área'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nombre del Área (ej. Innovación)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              Navigator.pop(context);
              await _createArea(nameController.text.trim());
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _createArea(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/management/areas'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode == 201) {
        _fetchAreas();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión')));
    }
  }

  void _showAddCriterionDialog(String areaId) {
    final nameController = TextEditingController();
    final maxController = TextEditingController(text: '100');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Criterio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Criterio (ej. Fluidez verbal)')),
            TextField(
              controller: maxController, 
              decoration: const InputDecoration(labelText: 'Puntaje Máximo'), 
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              Navigator.pop(context);
              await _createCriterion(areaId, nameController.text.trim(), double.parse(maxController.text.trim()));
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  Future<void> _createCriterion(String areaId, String name, double maxScore) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/management/criteria'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'areaId': areaId, 'name': name, 'minScore': 0, 'maxScore': maxScore}),
      );

      if (response.statusCode == 201) {
        _fetchAreas();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al añadir criterio')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Áreas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAreaDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Área'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _areas.isEmpty
              ? const Center(child: Text('No hay áreas creadas. ¡Empieza creando una!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _areas.length,
                  itemBuilder: (context, index) {
                    final area = _areas[index];
                    final criteria = area['criteria'] as List<dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(area['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text('${criteria.length} criterios asociados'),
                        children: [
                          ...criteria.map((c) => ListTile(
                                leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                                title: Text(c['name']),
                                trailing: Text('Máx: ${c['maxScore']} pts', style: const TextStyle(fontWeight: FontWeight.bold)),
                              )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton.icon(
                              onPressed: () => _showAddCriterionDialog(area['id']),
                              icon: const Icon(Icons.add_task),
                              label: const Text('Añadir Criterio'),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
