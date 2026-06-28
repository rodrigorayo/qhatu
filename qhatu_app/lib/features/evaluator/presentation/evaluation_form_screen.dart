import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qhatu_app/core/database/isar_service.dart';
import 'package:qhatu_app/core/database/models/local_models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qhatu_app/core/config/config.dart';

class EvaluationFormScreen extends StatefulWidget {
  final LocalAssignment assignment;
  
  const EvaluationFormScreen({super.key, required this.assignment});

  @override
  State<EvaluationFormScreen> createState() => _EvaluationFormScreenState();
}

class _EvaluationFormScreenState extends State<EvaluationFormScreen> {
  final IsarService _isarService = IsarService();
  List<LocalCriterion> _criteria = [];
  bool _isLoading = true;

  // Mapa de ID del Criterio -> Puntaje seleccionado
  final Map<String, double> _scores = {};
  final Map<String, String> _comments = {};
  final Map<String, TextEditingController> _scoreControllers = {};
  
  // Mapa de ID del Criterio -> Si muestra el deslizador
  final Map<String, bool> _showSlider = {};

  String? _selectedMemberId;
  List<dynamic> _members = [];

  @override
  void initState() {
    super.initState();
    _loadCriteria();
    if (widget.assignment.roleInStand == 'DELEGADO') {
      try {
        _members = jsonDecode(widget.assignment.membersJson);
      } catch (e) {
        _members = [];
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _scoreControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCriteria() async {
    try {
      final criteria = await _isarService.getCriteria();
      
      // Si la asignación tiene áreas específicas, filtrar los criterios
      List<String> assignedAreaIds = [];
      try {
        final jsonStr = widget.assignment.assignedAreaIdsJson;
        if (jsonStr.isNotEmpty) {
          assignedAreaIds = List<String>.from(jsonDecode(jsonStr));
        }
      } catch (_) {}
      
      List<LocalCriterion> filteredCriteria = criteria;
      
      // Filtrar por rol de evaluación (JURADO / DELEGADO)
      final userRole = widget.assignment.roleInStand; // JURADO o DELEGADO
      filteredCriteria = filteredCriteria.where((c) {
        final appRole = c.applicableRole;
        if (appRole == 'BOTH') return true;
        return appRole == userRole;
      }).toList();

      if (assignedAreaIds.isNotEmpty) {
        filteredCriteria = filteredCriteria.where((c) {
          final aId = c.areaId;
          return assignedAreaIds.contains(aId);
        }).toList();
      }
      
      setState(() {
        _criteria = filteredCriteria;
        for (var c in filteredCriteria) {
          // Sanitize values to ensure they are finite and valid
          if (!c.minScore.isFinite) c.minScore = 0.0;
          if (!c.maxScore.isFinite) c.maxScore = 100.0;
          if (!c.weight.isFinite) c.weight = 10.0;

          double defScore = c.minScore;
          _scores[c.criterionId] = defScore;
          _scoreControllers[c.criterionId] = TextEditingController(text: defScore.round().toString());
          _showSlider[c.criterionId] = false;
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading criteria: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveLocalScores() async {
    if (widget.assignment.roleInStand == 'DELEGADO' && _selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona a un miembro primero')));
      return;
    }

    // Validar rango de notas
    for (var criterion in _criteria) {
      final score = _scores[criterion.criterionId] ?? criterion.minScore;
      if (score < criterion.minScore || score > criterion.maxScore) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('La nota para "${criterion.name}" debe estar entre ${criterion.minScore.round()} y ${criterion.maxScore.round()}'),
          backgroundColor: Colors.red,
        ));
        return;
      }
    }

    final standName = widget.assignment.standName;
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Calificación'),
        content: Text('¿Estás seguro de subir las calificaciones del stand "$standName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, guardar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final targetId = widget.assignment.roleInStand == 'DELEGADO' 
        ? _selectedMemberId! 
        : widget.assignment.standId;

    setState(() => _isLoading = true);

    bool isSavedOnline = false;
    String errorMessage = 'No se pudo conectar con el servidor. Verifica tu conexión a Internet.';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      List<dynamic> standScores = [];
      List<dynamic> memberScores = [];

      for (var criterion in _criteria) {
        final score = _scores[criterion.criterionId] ?? criterion.minScore;
        final comment = _comments[criterion.criterionId] ?? '';
        if (widget.assignment.roleInStand == 'DELEGADO') {
          memberScores.add({
            'memberId': targetId,
            'criterionId': criterion.criterionId,
            'rawScore': score,
            'comments': comment,
          });
        } else {
          standScores.add({
            'standId': targetId,
            'criterionId': criterion.criterionId,
            'rawScore': score,
            'comments': comment,
          });
        }
      }

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/evaluation/sync'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'standScores': standScores,
          'memberScores': memberScores,
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        isSavedOnline = true;
      } else {
        try {
          final body = jsonDecode(response.body);
          if (body['message'] != null) {
            errorMessage = body['message'].toString();
          }
        } catch (_) {}
      }
    } catch (e) {
      errorMessage = 'Error de conexión: $e';
    }

    setState(() => _isLoading = false);

    if (isSavedOnline) {
      // Guardar localmente la asignación como calificada ya que se subió correctamente al servidor
      try {
        final localAssignments = await _isarService.getAssignments();
        final existing = localAssignments.firstWhere(
          (a) => a.assignmentId == widget.assignment.assignmentId
        );
        existing.isEvaluated = true;
        await _isarService.saveAssignment(existing);
      } catch (_) {
        // Asignación libre (select_stand_screen)
        final newAssignment = LocalAssignment()
          ..assignmentId = widget.assignment.assignmentId
          ..standId = widget.assignment.standId
          ..standName = widget.assignment.standName
          ..standNumber = widget.assignment.standNumber
          ..roleInStand = widget.assignment.roleInStand
          ..membersJson = widget.assignment.membersJson
          ..assignedAreaIdsJson = widget.assignment.assignedAreaIdsJson
          ..isEvaluated = true;
        await _isarService.saveAssignment(newAssignment);
      }

      if (mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green),
                SizedBox(width: 8),
                Text('Calificación Guardada'),
              ],
            ),
            content: Text(
              'La calificación del stand "$standName" ha sido guardada con éxito en el servidor.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
        if (mounted) {
          context.pop();
        }
      }
    } else {
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                const Text('Error al Guardar'),
              ],
            ),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Agrupar criterios por área
    final Map<String, List<LocalCriterion>> groupedCriteria = {};
    for (var c in _criteria) {
      groupedCriteria.putIfAbsent(c.areaName, () => []).add(c);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluando a ${widget.assignment.standName}'),
      ),
      body: Column(
        children: [
          if (widget.assignment.roleInStand == 'DELEGADO')
            Container(
              padding: const EdgeInsets.all(16),
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Selecciona al Miembro a Evaluar',
                  border: OutlineInputBorder(),
                ),
                items: _members.map((m) => DropdownMenuItem<String>(
                  value: m['id'],
                  child: Text(
                    m['fullName'],
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
                onChanged: (val) {
                  setState(() => _selectedMemberId = val);
                },
              ),
            ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: groupedCriteria.entries.map((entry) {
                final areaName = entry.key;
                final criteriaList = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    title: Text(
                      areaName.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                    initiallyExpanded: true,
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: criteriaList.map((criterion) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    criterion.name,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                  ),
                                ),
                                // Caja de puntaje numérica
                                Container(
                                  width: 75,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                                  ),
                                  alignment: Alignment.center,
                                  child: TextField(
                                    controller: _scoreControllers[criterion.criterionId],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: colorScheme.primary,
                                    ),
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                    onChanged: (val) {
                                      final parsed = double.tryParse(val);
                                      if (parsed != null) {
                                        double target = parsed;
                                        if (parsed > criterion.maxScore) {
                                          target = criterion.maxScore;
                                          _scoreControllers[criterion.criterionId]?.text =
                                              criterion.maxScore.round().toString();
                                          _scoreControllers[criterion.criterionId]?.selection =
                                              TextSelection.fromPosition(
                                            TextPosition(offset: _scoreControllers[criterion.criterionId]!.text.length),
                                          );
                                        } else if (parsed < criterion.minScore) {
                                          target = criterion.minScore;
                                        }
                                        setState(() {
                                          _scores[criterion.criterionId] = target;
                                        });
                                      } else {
                                        setState(() {
                                          _scores[criterion.criterionId] = criterion.minScore;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Fila de Slider con - y + botones
                            Row(
                              children: [
                                // Botón Menos
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline, color: colorScheme.primary),
                                  onPressed: () {
                                    final current = _scores[criterion.criterionId] ?? criterion.minScore;
                                    if (current > criterion.minScore) {
                                      final next = current - 1;
                                      setState(() {
                                        _scores[criterion.criterionId] = next;
                                        _scoreControllers[criterion.criterionId]?.text = next.round().toString();
                                      });
                                    }
                                  },
                                ),
                                // Slider
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 6,
                                      activeTrackColor: colorScheme.primary,
                                      inactiveTrackColor: colorScheme.primary.withOpacity(0.15),
                                      thumbColor: colorScheme.secondary,
                                      overlayColor: colorScheme.secondary.withOpacity(0.12),
                                      valueIndicatorColor: colorScheme.primary,
                                      valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    child: Slider(
                                      value: (_scores[criterion.criterionId] ?? criterion.minScore).clamp(criterion.minScore, criterion.maxScore),
                                      min: criterion.minScore,
                                      max: criterion.maxScore,
                                      divisions: (criterion.maxScore - criterion.minScore).toInt() > 0 
                                          ? (criterion.maxScore - criterion.minScore).toInt() 
                                          : 1,
                                      label: _scores[criterion.criterionId]?.round().toString(),
                                      onChanged: (val) {
                                        setState(() {
                                          _scores[criterion.criterionId] = val;
                                          _scoreControllers[criterion.criterionId]?.text = val.round().toString();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                // Botón Más
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline, color: colorScheme.primary),
                                  onPressed: () {
                                    final current = _scores[criterion.criterionId] ?? criterion.minScore;
                                    if (current < criterion.maxScore) {
                                      final next = current + 1;
                                      setState(() {
                                        _scores[criterion.criterionId] = next;
                                        _scoreControllers[criterion.criterionId]?.text = next.round().toString();
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            
                            // Mostrar Rango de nota de forma elegante
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Mín: ${criterion.minScore.round()} pts',
                                    style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                                  ),
                                  Text(
                                    'Peso real ponderado: ${(((_scores[criterion.criterionId] ?? criterion.minScore) - criterion.minScore) / (criterion.maxScore - criterion.minScore) * criterion.weight).toStringAsFixed(1)} / ${criterion.weight.toStringAsFixed(1)} pts',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.secondary),
                                  ),
                                  Text(
                                    'Máx: ${criterion.maxScore.round()} pts',
                                    style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            
                            // Comentario
                            TextField(
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.comment_outlined, size: 16, color: colorScheme.primary.withOpacity(0.6)),
                                labelText: 'Observaciones / Comentario (Opcional)',
                                labelStyle: const TextStyle(fontSize: 13),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              onChanged: (val) => _comments[criterion.criterionId] = val,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: _saveLocalScores,
            icon: const Icon(Icons.save),
            label: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Guardar Evaluación', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ),
    );
  }
}
