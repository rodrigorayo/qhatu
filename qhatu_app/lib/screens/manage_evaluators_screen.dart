import '../config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ManageEvaluatorsScreen extends StatefulWidget {
  const ManageEvaluatorsScreen({super.key});

  @override
  State<ManageEvaluatorsScreen> createState() => _ManageEvaluatorsScreenState();
}

class _ManageEvaluatorsScreenState extends State<ManageEvaluatorsScreen> {
  List<dynamic> _stands = [];
  List<dynamic> _areas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStands();
    _fetchAreas();
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al cargar stands para asignación')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAreas() async {
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
    } catch (_) {}
  }

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
      } else {
        final error = jsonDecode(response.body)['error'];
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Error al asignar'), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asignación de Jurados')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stands.isEmpty
              ? const Center(child: Text('Primero debes registrar Stands.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _stands.length,
                  itemBuilder: (context, index) {
                    final stand = _stands[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.storefront)),
                        title: Text(stand['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('ID: ${stand['number']}'),
                        trailing: OutlinedButton.icon(
                          icon: const Icon(Icons.person_add),
                          label: const Text('Asignar Jurado'),
                          onPressed: () => _showAssignEvaluatorDialog(stand['id'], stand['name']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
