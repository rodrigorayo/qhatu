import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../database/isar_service.dart';
import '../database/models/local_models.dart';
import 'dart:convert';

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
        if (jsonStr != null && jsonStr.isNotEmpty) {
          assignedAreaIds = List<String>.from(jsonDecode(jsonStr));
        }
      } catch (_) {}
      
      List<LocalCriterion> filteredCriteria = criteria;
      if (assignedAreaIds.isNotEmpty) {
        filteredCriteria = criteria.where((c) {
          final aId = c.areaId;
          if (aId == null) return false;
          return assignedAreaIds.contains(aId);
        }).toList();
      }
      
      setState(() {
        _criteria = filteredCriteria;
        for (var c in filteredCriteria) {
          double defScore = 0.0;
          try {
            defScore = c.minScore;
          } catch (_) {}
          _scores[c.criterionId] = defScore;
          _scoreControllers[c.criterionId] = TextEditingController(text: defScore.round().toString());
          _showSlider[c.criterionId] = false;
        }
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading criteria: $e");
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

    final targetId = widget.assignment.roleInStand == 'DELEGADO' 
        ? _selectedMemberId! 
        : widget.assignment.standId;

    for (var criterion in _criteria) {
      final score = _scores[criterion.criterionId] ?? criterion.minScore;
      final comment = _comments[criterion.criterionId] ?? '';

      final pendingScore = PendingScore()
        ..uniqueKey = '${targetId}_${criterion.criterionId}'
        ..targetId = targetId
        ..criterionId = criterion.criterionId
        ..rawScore = score
        ..comments = comment
        ..isMemberScore = widget.assignment.roleInStand == 'DELEGADO';

      await _isarService.savePendingScore(pendingScore);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calificaciones guardadas localmente. ¡Recuerda Sincronizar!'), backgroundColor: Colors.green),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Selecciona al Miembro a Evaluar',
                  border: OutlineInputBorder(),
                ),
                items: _members.map((m) => DropdownMenuItem<String>(
                  value: m['id'],
                  child: Text(m['fullName']),
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    initiallyExpanded: true,
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: criteriaList.map((criterion) {
                      final sliderEnabled = _showSlider[criterion.criterionId] ?? false;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              criterion.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                // Entrada Numérica directa
                                SizedBox(
                                  width: 110,
                                  child: TextField(
                                    controller: _scoreControllers[criterion.criterionId],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Nota (${criterion.minScore.round()}-${criterion.maxScore.round()})',
                                      border: const OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                    ),
                                    onChanged: (val) {
                                      final parsed = double.tryParse(val);
                                      if (parsed != null) {
                                        if (parsed > criterion.maxScore) {
                                          _scoreControllers[criterion.criterionId]?.text =
                                              criterion.maxScore.round().toString();
                                          _scoreControllers[criterion.criterionId]?.selection =
                                              TextSelection.fromPosition(
                                            TextPosition(
                                                offset: _scoreControllers[criterion.criterionId]!
                                                    .text
                                                    .length),
                                          );
                                          setState(() {
                                            _scores[criterion.criterionId] = criterion.maxScore;
                                          });
                                        } else {
                                          setState(() {
                                            _scores[criterion.criterionId] = parsed;
                                          });
                                        }
                                      } else {
                                        setState(() {
                                          _scores[criterion.criterionId] = criterion.minScore;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const Spacer(),
                                // Etiqueta e Interruptor para mostrar Slider
                                Text(
                                  'Usar barra',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Switch(
                                  value: sliderEnabled,
                                  onChanged: (val) {
                                    setState(() {
                                      _showSlider[criterion.criterionId] = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                            
                            // Deslizador opcional si el switch está encendido
                            if (sliderEnabled) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(criterion.minScore.round().toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Expanded(
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
                                          _scoreControllers[criterion.criterionId]?.text =
                                              val.round().toString();
                                        });
                                      },
                                    ),
                                  ),
                                  Text(
                                    criterion.maxScore.round().toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                            
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                'Puntaje: ${_scores[criterion.criterionId]?.round() ?? 0} / ${criterion.maxScore.round()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Comentario (Opcional)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (val) => _comments[criterion.criterionId] = val,
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
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
