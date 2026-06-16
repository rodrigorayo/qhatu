import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/isar_service.dart';
import '../database/models/local_models.dart';
import '../config.dart';

class SelectStandScreen extends StatefulWidget {
  const SelectStandScreen({super.key});

  @override
  State<SelectStandScreen> createState() => _SelectStandScreenState();
}

class _SelectStandScreenState extends State<SelectStandScreen> {
  final IsarService _isarService = IsarService();
  List<LocalStand> _allStands = [];
  List<LocalStand> _filteredStands = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStands();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStands() async {
    var stands = await _isarService.getAllStands();
    if (stands.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          final res = await http.get(
            Uri.parse('${Config.baseUrl}/api/evaluation/stands'),
            headers: {'Authorization': 'Bearer $token'},
          );
          if (res.statusCode == 200) {
            final standsData = jsonDecode(res.body);
            await _isarService.saveAllStands(standsData);
            stands = await _isarService.getAllStands();
          }
        }
      } catch (e) {
        debugPrint('Error al cargar stands remotamente: $e');
      }
    }

    // Filtrar stands que ya están asignados a este jurado
    final assignments = await _isarService.getAssignments();
    final assignedStandIds = assignments.map((a) => a.standId).toSet();
    final nonAssignedStands = stands.where((s) => !assignedStandIds.contains(s.standId)).toList();

    setState(() {
      _allStands = nonAssignedStands;
      _filteredStands = nonAssignedStands;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredStands = _allStands;
      } else {
        _filteredStands = _allStands.where((stand) {
          final nameMatch = stand.name.toLowerCase().contains(query);
          final numMatch = stand.number.toLowerCase().contains(query);
          return nameMatch || numMatch;
        }).toList();
      }
    });
  }

  void _selectRoleAndProceed(LocalStand stand) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Evaluar Stand: ${stand.name}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Elige el rol con el que deseas evaluar a este stand',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  icon: const Icon(Icons.storefront),
                  label: const Text(
                    'Evaluar como JURADO (Al Stand)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: () => _proceedWithRole(stand, 'JURADO'),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  icon: const Icon(Icons.people),
                  label: const Text(
                    'Evaluar como DELEGADO (A Miembros)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: () => _proceedWithRole(stand, 'DELEGADO'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _proceedWithRole(LocalStand stand, String role) {
    Navigator.pop(context); // Close bottom sheet

    // Create a temporary LocalAssignment
    final tempAssignment = LocalAssignment()
      ..assignmentId = 'temp_${stand.standId}_$role'
      ..standId = stand.standId
      ..standName = stand.name
      ..standNumber = stand.number
      ..roleInStand = role
      ..membersJson = stand.membersJson;

    context.push('/evaluator/form', extra: tempAssignment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos los Stands'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o número de stand...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredStands.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No se encontraron stands',
                                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredStands.length,
                          itemBuilder: (context, index) {
                            final stand = _filteredStands[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                                  child: Text(
                                    stand.number,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  stand.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _selectRoleAndProceed(stand),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
