import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/isar_service.dart';
import '../database/models/local_models.dart';
import '../config.dart';

class EvaluatorDashboard extends StatefulWidget {
  const EvaluatorDashboard({super.key});

  @override
  State<EvaluatorDashboard> createState() => _EvaluatorDashboardState();
}

class _EvaluatorDashboardState extends State<EvaluatorDashboard> {
  final IsarService _isarService = IsarService();
  List<LocalAssignment> _assignments = [];
  bool _isSyncing = false;
  bool _isOffline = false;
  Timer? _offlineCheckTimer;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
    _syncData(showFeedback: false); // Sincronizar automáticamente al iniciar
    _offlineCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkConnectivity();
    });
  }

  @override
  void dispose() {
    _offlineCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/health')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        if (_isOffline) {
          setState(() {
            _isOffline = false;
          });
          // Si antes estábamos offline y ahora estamos online, intentamos sincronizar
          _syncData(showFeedback: false);
        }
      } else {
        throw Exception();
      }
    } catch (_) {
      if (!_isOffline) {
        setState(() {
          _isOffline = true;
        });
      }
    }
  }

  Future<void> _loadLocalData() async {
    final assignments = await _isarService.getAssignments();
    setState(() {
      _assignments = assignments;
    });
  }

  Future<void> _syncData({bool showFeedback = false}) async {
    if (mounted) setState(() => _isSyncing = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('No token');

      // 1. Enviar puntajes pendientes (Subida)
      final pendingScores = await _isarService.getPendingScores();
      if (pendingScores.isNotEmpty) {
        final standScores = pendingScores.where((s) => !s.isMemberScore).map((s) => {
          'standId': s.targetId,
          'criterionId': s.criterionId,
          'rawScore': s.rawScore,
          'comments': s.comments,
        }).toList();

        final memberScores = pendingScores.where((s) => s.isMemberScore).map((s) => {
          'memberId': s.targetId,
          'criterionId': s.criterionId,
          'rawScore': s.rawScore,
          'comments': s.comments,
        }).toList();

        final syncResponse = await http.post(
          Uri.parse('${Config.baseUrl}/api/evaluation/sync'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          body: jsonEncode({
            'standScores': standScores,
            'memberScores': memberScores,
          }),
        );

        if (syncResponse.statusCode == 200) {
          await _isarService.clearPendingScores();
        } else {
          throw Exception('Fallo al subir notas');
        }
      }

      // 2. Descargar Asignaciones (Bajada)
      final assignmentsRes = await http.get(
        Uri.parse('${Config.baseUrl}/api/evaluation/assignments'),
        headers: {'Authorization': 'Bearer $token'},
      );

      // 3. Descargar Rúbrica (Bajada)
      final rubricRes = await http.get(
        Uri.parse('${Config.baseUrl}/api/evaluation/rubric'),
        headers: {'Authorization': 'Bearer $token'},
      );

      // 4. Descargar Todos los Stands de la Feria (Bajada)
      final standsRes = await http.get(
        Uri.parse('${Config.baseUrl}/api/evaluation/stands'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (assignmentsRes.statusCode == 200 && rubricRes.statusCode == 200 && standsRes.statusCode == 200) {
        final assignmentsData = jsonDecode(assignmentsRes.body);
        final rubricData = jsonDecode(rubricRes.body);
        final standsData = jsonDecode(standsRes.body);

        await _isarService.saveAssignments(assignmentsData);
        await _isarService.saveRubric(rubricData);
        await _isarService.saveAllStands(standsData);

        await _loadLocalData();

        if (mounted) {
          setState(() {
            _isOffline = false;
          });
        }

        if (showFeedback && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sincronización Completada'), backgroundColor: Colors.green),
          );
        }
      } else {
        throw Exception('Fallo al descargar datos');
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isOffline = true;
        });
      }
      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de sincronización (Posible Offline)'), backgroundColor: Colors.orange),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = _assignments.isEmpty
        ? RefreshIndicator(
            onRefresh: () => _syncData(showFeedback: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No hay datos locales.'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.cloud_download),
                      label: const Text('Sincronizar Ahora'),
                      onPressed: () => _syncData(showFeedback: true),
                    )
                  ],
                ),
              ),
            ),
          )
        : RefreshIndicator(
            onRefresh: () => _syncData(showFeedback: true),
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 88),
              itemCount: _assignments.length,
              itemBuilder: (context, index) {
                final assignment = _assignments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: assignment.roleInStand == 'JURADO' ? Colors.blue : Colors.purple,
                      child: Icon(assignment.roleInStand == 'JURADO' ? Icons.storefront : Icons.person),
                    ),
                    title: Text(assignment.standName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('ID: ${assignment.standNumber}\nRol: ${assignment.roleInStand}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    isThreeLine: true,
                    onTap: () async {
                      await context.push('/evaluator/form', extra: assignment);
                      _syncData(showFeedback: false); // Sincronizar automáticamente al volver
                    },
                  ),
                );
              },
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Evaluaciones'),
        actions: [
          IconButton(
            icon: _isSyncing 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
              : const Icon(Icons.sync),
            onPressed: _isSyncing ? null : () => _syncData(showFeedback: true),
            tooltip: 'Sincronizar Datos',
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          if (_isOffline)
            Container(
              color: Colors.orange.shade800,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              width: double.infinity,
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sin conexión a Internet. Las notas se guardarán en el celular y se subirán al recuperar señal.',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(child: mainContent),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/evaluator/select_stand');
          _syncData(showFeedback: false); // Sincronizar automáticamente al volver
        },
        icon: const Icon(Icons.add),
        label: const Text('Calificar otros Stands'),
      ),
    );
  }
}

