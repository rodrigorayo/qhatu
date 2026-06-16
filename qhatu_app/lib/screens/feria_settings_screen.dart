import '../config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class FeriaSettingsScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const FeriaSettingsScreen({super.key, this.initialData});

  @override
  State<FeriaSettingsScreen> createState() => _FeriaSettingsScreenState();
}

class _FeriaSettingsScreenState extends State<FeriaSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _locationCtrl;
  
  String? _selectedType;
  String? _selectedCalculationType;
  DateTimeRange? _dateRange;
  bool _isLoading = false;

  final List<String> _feriaTypes = [
    'Feria Escolar / Colegial',
    'Feria Científica',
    'Feria Universitaria',
    'Feria Empresarial / Negocios',
    'Feria Gastronómica',
    'Feria Tecnológica / Hackathon',
    'Otra'
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialData?['name'] ?? '');
    _descCtrl = TextEditingController(text: widget.initialData?['description'] ?? '');
    
    final metadata = widget.initialData?['metadata'] ?? {};
    _locationCtrl = TextEditingController(text: metadata['location'] ?? '');
    
    if (metadata['type'] != null && _feriaTypes.contains(metadata['type'])) {
      _selectedType = metadata['type'];
    }

    _selectedCalculationType = widget.initialData?['calculationType'] ?? 'SUMATIVE';

    if (widget.initialData?['startDate'] != null && widget.initialData?['endDate'] != null) {
      _dateRange = DateTimeRange(
        start: DateTime.parse(widget.initialData!['startDate']),
        end: DateTime.parse(widget.initialData!['endDate']),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final metadata = {
        'type': _selectedType,
        'location': _locationCtrl.text.trim(),
        'setupComplete': true
      };

      final response = await http.put(
        Uri.parse('${Config.baseUrl}/api/ferias/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': _nameCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'startDate': _dateRange?.start.toIso8601String(),
          'endDate': _dateRange?.end.toIso8601String(),
          'calculationType': _selectedCalculationType,
          'metadata': metadata,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configuración guardada exitosamente'), backgroundColor: Colors.green),
          );
          context.pop(true); // Retorna true para recargar el dashboard
        }
      } else {
        throw Exception('Error al guardar');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al conectar con el servidor'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fase 1: Configuración'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Identidad de la Feria',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Estos datos serán visibles para los jurados y participantes.'),
                  const SizedBox(height: 24),
                  
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nombre Oficial de la Feria *',
                      prefixIcon: const Icon(Icons.festival),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Tipo / Rubro de la Feria *',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                    ),
                    items: _feriaTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _selectedType = val),
                    validator: (val) => val == null ? 'Selecciona un rubro' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCalculationType,
                    decoration: InputDecoration(
                      labelText: 'Método de Calificación *',
                      prefixIcon: const Icon(Icons.calculate),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'SUMATIVE', child: Text('Suma de Puntos (Sumativo)')),
                      DropdownMenuItem(value: 'WEIGHTED', child: Text('Ponderado por Áreas (%)')),
                    ],
                    onChanged: (val) => setState(() => _selectedCalculationType = val),
                    validator: (val) => val == null ? 'Selecciona un método' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descripción / Lema',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text(
                    'Ubicación y Tiempo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _locationCtrl,
                    decoration: InputDecoration(
                      labelText: 'Ubicación Física (Ej. Coliseo Central)',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  InkWell(
                    onTap: _pickDateRange,
                    borderRadius: BorderRadius.circular(16),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Fechas del Evento',
                        prefixIcon: const Icon(Icons.date_range),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        filled: true,
                      ),
                      child: Text(
                        _dateRange == null 
                          ? 'Seleccionar fechas' 
                          : '${DateFormat('dd MMM').format(_dateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange!.end)}',
                        style: TextStyle(
                          color: _dateRange == null ? Colors.grey.shade600 : Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  FilledButton.icon(
                    onPressed: _saveSettings,
                    icon: const Icon(Icons.save),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Guardar Configuración', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
