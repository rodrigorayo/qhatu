import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qhatu_app/core/database/isar_service.dart';
import 'package:qhatu_app/core/database/models/local_models.dart';
import 'package:qhatu_app/core/config/config.dart';

class SelectStandScreen extends StatefulWidget {
  const SelectStandScreen({super.key});

  @override
  State<SelectStandScreen> createState() => _SelectStandScreenState();
}

class _SelectStandScreenState extends State<SelectStandScreen> {
  final IsarService _isarService = IsarService();
  List<LocalStand> _allStands = [];
  List<LocalStand> _filteredStands = [];
  List<LocalAssignment> _assignments = [];
  List<PendingScore> _pendingScores = [];
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

    final assignments = await _isarService.getAssignments();
    final pending = await _isarService.getPendingScores();

    // Filtrar stands que ya están PRE-ASIGNADOS a este jurado (los de la vista principal)
    final preAssignedStandIds = assignments
        .where((a) => !a.assignmentId.startsWith('temp_'))
        .map((a) => a.standId)
        .toSet();

    final nonPreAssignedStands = stands.where((s) => !preAssignedStandIds.contains(s.standId)).toList();

    setState(() {
      _allStands = nonPreAssignedStands;
      _filteredStands = nonPreAssignedStands;
      _assignments = assignments;
      _pendingScores = pending;
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

  Future<void> _selectRoleAndProceed(
    LocalStand stand,
    bool isGradedJurado,
    bool isGradedDelegado,
  ) async {
    if (isGradedJurado && isGradedDelegado) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green.shade600),
              const SizedBox(width: 8),
              const Text('Stand Evaluado'),
            ],
          ),
          content: const Text(
            'Ya has calificado este stand como Jurado y como Delegado. No se permiten más calificaciones.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    if (!mounted) return;

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: isDark ? colorScheme.surface : Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Evaluar Stand: ${stand.name}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Elige el rol con el que deseas evaluar este stand',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                
                // Botón Jurado
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isGradedJurado 
                        ? (isDark ? Colors.white10 : Colors.grey.shade100)
                        : colorScheme.primary,
                    foregroundColor: isGradedJurado 
                        ? (isDark ? Colors.white30 : Colors.grey.shade400)
                        : Colors.white,
                    elevation: isGradedJurado ? 0 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(
                    isGradedJurado ? Icons.check_circle_rounded : Icons.storefront_rounded,
                    color: isGradedJurado ? Colors.green : Colors.white,
                  ),
                  label: Text(
                    isGradedJurado 
                        ? 'Ya evaluado como JURADO' 
                        : 'Evaluar como JURADO (Al Stand)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isGradedJurado 
                          ? (isDark ? Colors.white30 : Colors.grey.shade500)
                          : Colors.white,
                    ),
                  ),
                  onPressed: isGradedJurado 
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ya has calificado a este stand como Jurado.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      : () => _proceedWithRole(stand, 'JURADO'),
                ),
                const SizedBox(height: 12),
                
                // Botón Delegado
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isGradedDelegado 
                        ? (isDark ? Colors.white10 : Colors.grey.shade100)
                        : const Color(0xFFFDB913),
                    foregroundColor: isGradedDelegado 
                        ? (isDark ? Colors.white30 : Colors.grey.shade400)
                        : Colors.black87,
                    elevation: isGradedDelegado ? 0 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(
                    isGradedDelegado ? Icons.check_circle_rounded : Icons.people_alt_rounded,
                    color: isGradedDelegado ? Colors.green : Colors.black87,
                  ),
                  label: Text(
                    isGradedDelegado 
                        ? 'Ya evaluado como DELEGADO' 
                        : 'Evaluar como DELEGADO (A Miembros)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isGradedDelegado 
                          ? (isDark ? Colors.white30 : Colors.grey.shade500)
                          : Colors.black87,
                    ),
                  ),
                  onPressed: isGradedDelegado 
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ya has calificado a los miembros de este stand como Delegado.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      : () => _proceedWithRole(stand, 'DELEGADO'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _proceedWithRole(LocalStand stand, String role) {
    Navigator.pop(context); // Cerrar bottom sheet

    // Crear asignación temporal local
    final tempAssignment = LocalAssignment()
      ..assignmentId = 'temp_${stand.standId}_$role'
      ..standId = stand.standId
      ..standName = stand.name
      ..standNumber = stand.number
      ..roleInStand = role
      ..membersJson = stand.membersJson;

    context.push('/evaluator/form', extra: tempAssignment);
  }

  Widget _buildStandCard(
    BuildContext context, 
    LocalStand stand, 
    bool isGradedJurado, 
    bool isGradedDelegado, 
    ColorScheme colorScheme, 
    bool isDark,
  ) {
    final isFullyGraded = isGradedJurado && isGradedDelegado;

    // Color de acento izquierdo
    Color cardBorderColor = Colors.grey.shade300;
    if (isFullyGraded) {
      cardBorderColor = Colors.green;
    } else if (isGradedJurado) {
      cardBorderColor = colorScheme.primary;
    } else if (isGradedDelegado) {
      cardBorderColor = const Color(0xFFFDB913);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? colorScheme.outline.withOpacity(0.1) : Colors.transparent,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: cardBorderColor,
                width: 5,
              ),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isFullyGraded 
                    ? Colors.green.withOpacity(0.1) 
                    : colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFullyGraded 
                    ? Icons.check_circle_rounded 
                    : Icons.store_rounded,
                color: isFullyGraded ? Colors.green : colorScheme.primary,
                size: 26,
              ),
            ),
            title: Text(
              stand.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white12 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Stand #${stand.number}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      
                      // Chip Jurado
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isGradedJurado
                              ? Colors.green.withOpacity(0.1)
                              : (isDark ? Colors.white12 : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isGradedJurado) ...[
                              const Icon(Icons.check, size: 10, color: Colors.green),
                              const SizedBox(width: 2),
                            ],
                            Text(
                              'Jurado',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isGradedJurado 
                                    ? Colors.green.shade700 
                                    : (isDark ? Colors.white38 : Colors.grey.shade500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Chip Delegado
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isGradedDelegado
                              ? Colors.green.withOpacity(0.1)
                              : (isDark ? Colors.white12 : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isGradedDelegado) ...[
                              const Icon(Icons.check, size: 10, color: Colors.green),
                              const SizedBox(width: 2),
                            ],
                            Text(
                              'Delegado',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isGradedDelegado 
                                    ? Colors.green.shade700 
                                    : (isDark ? Colors.white38 : Colors.grey.shade500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: isFullyGraded
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 16,
                    ),
                  )
                : Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    size: 16,
                  ),
            onTap: () => _selectRoleAndProceed(stand, isGradedJurado, isGradedDelegado),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos los Stands', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : colorScheme.primary,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Campo de Búsqueda
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o número de stand...',
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade500),
                        prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? colorScheme.surfaceVariant.withOpacity(0.2) : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
                
                // Listado de Stands
                Expanded(
                  child: _filteredStands.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.storefront_rounded, 
                                size: 80, 
                                color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No se encontraron stands',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant, 
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredStands.length,
                          itemBuilder: (context, index) {
                            final stand = _filteredStands[index];
                            
                            // Determinar evaluaciones para este stand
                            final hasEvaluatedJurado = _assignments.any((a) => a.standId == stand.standId && a.roleInStand == 'JURADO' && a.isEvaluated);
                            final hasEvaluatedDelegado = _assignments.any((a) => a.standId == stand.standId && a.roleInStand == 'DELEGADO' && a.isEvaluated);
                            
                            final hasPendingJurado = _pendingScores.any((s) => s.targetId == stand.standId && !s.isMemberScore);
                            
                            List<dynamic> members = [];
                            try {
                              members = jsonDecode(stand.membersJson);
                            } catch (_) {}
                            final memberIds = members.map((m) => m['id'].toString()).toSet();
                            final hasPendingDelegado = _pendingScores.any((s) => memberIds.contains(s.targetId) && s.isMemberScore);

                            final isGradedJurado = hasEvaluatedJurado || hasPendingJurado;
                            final isGradedDelegado = hasEvaluatedDelegado || hasPendingDelegado;

                            return _buildStandCard(context, stand, isGradedJurado, isGradedDelegado, colorScheme, isDark);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
