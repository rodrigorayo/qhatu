import '../config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ManageFeriasScreen extends StatefulWidget {
  const ManageFeriasScreen({super.key});

  @override
  State<ManageFeriasScreen> createState() => _ManageFeriasScreenState();
}

class _ManageFeriasScreenState extends State<ManageFeriasScreen> {
  List<dynamic> _ferias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFerias();
  }

  Future<void> _fetchFerias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/ferias'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _ferias = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load ferias');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error cargando las ferias')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Ferias'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ferias.isEmpty
              ? const Center(child: Text('No hay ferias creadas aún.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ferias.length,
                  itemBuilder: (context, index) {
                    final feria = _ferias[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.business, color: Colors.white),
                        ),
                        title: Text(
                          feria['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          feria['description']?.isEmpty ?? true 
                            ? 'Sin descripción' 
                            : feria['description']
                        ),
                        trailing: Chip(
                          label: Text(feria['status']),
                          backgroundColor: feria['status'] == 'DRAFT' 
                            ? Colors.orange.shade100 
                            : Colors.green.shade100,
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchFerias,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
