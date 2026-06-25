import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../database/isar_service.dart';
import '../database/models/local_models.dart';
import '../config.dart';
import '../providers/theme_provider.dart';

class EvaluatorDashboard extends StatefulWidget {
  const EvaluatorDashboard({super.key});

  @override
  State<EvaluatorDashboard> createState() => _EvaluatorDashboardState();
}

class _EvaluatorDashboardState extends State<EvaluatorDashboard> {
  final IsarService _isarService = IsarService();
  List<LocalAssignment> _assignments = [];
  List<PendingScore> _pendingScores = [];
  bool _isSyncing = false;
  String _username = 'Evaluador';

  @override
  void initState() {
    super.initState();
    _loadLocalData();
    _syncData(showFeedback: false); // Sincronizar automáticamente al iniciar
  }

  Future<void> _loadLocalData() async {
    final assignments = await _isarService.getAssignments();
    final pending = await _isarService.getPendingScores();
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username') ?? 'Evaluador';
    setState(() {
      _assignments = assignments;
      _pendingScores = pending;
      _username = savedUsername;
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

        if (showFeedback && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sincronización Completada'), backgroundColor: Colors.green),
          );
        }
      } else {
        throw Exception('Fallo al descargar datos');
      }

    } catch (e) {
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) context.go('/login');
  }

  // Status pill removed for online-only demo

  Widget _buildAssignmentCard(BuildContext context, LocalAssignment assignment, bool isGraded, ColorScheme colorScheme, bool isDark) {
    final cardBorderColor = isGraded 
        ? Colors.green.shade400 
        : (assignment.roleInStand == 'JURADO' ? colorScheme.primary : const Color(0xFFFDB913));

    final badgeColor = isGraded 
        ? Colors.green.withOpacity(0.1) 
        : (assignment.roleInStand == 'JURADO' ? colorScheme.primary.withOpacity(0.1) : const Color(0xFFFDB913).withOpacity(0.1));

    final iconColor = isGraded 
        ? Colors.green 
        : (assignment.roleInStand == 'JURADO' ? colorScheme.primary : const Color(0xFFFDB913));

    final isJurado = assignment.roleInStand == 'JURADO';

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
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isGraded 
                    ? Icons.check_circle_rounded 
                    : (isJurado ? Icons.storefront_rounded : Icons.person_search_rounded),
                color: iconColor,
                size: 26,
              ),
            ),
            title: Text(
              assignment.standName,
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
                          'Stand #${assignment.standNumber}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isJurado 
                              ? colorScheme.primary.withOpacity(0.08) 
                              : const Color(0xFFFDB913).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isJurado ? 'Jurado (Stand)' : 'Delegado (Miembros)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isJurado 
                                ? (isDark ? Colors.blueAccent : colorScheme.primary) 
                                : (isDark ? Colors.amberAccent : const Color(0xFFE5A100)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isGraded) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Evaluación Completa',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            trailing: isGraded
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
            onTap: () async {
              if (isGraded) {
                await showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        const Text('Ya Calificado'),
                      ],
                    ),
                    content: const Text(
                      'Has calificado este stand con éxito. Las calificaciones no pueden modificarse una vez enviadas.',
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
              if (!context.mounted) return;
              await context.push('/evaluator/form', extra: assignment);
              _syncData(showFeedback: false); // Sincronizar automáticamente al volver
            },
          ),
        ),
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final totalAssignments = _assignments.length;
    final evaluatedCount = _assignments.where((a) {
      final isPendingGraded = a.roleInStand == 'JURADO'
          ? _pendingScores.any((s) => s.targetId == a.standId && !s.isMemberScore)
          : _pendingScores.any((s) => (jsonDecode(a.membersJson) as List).map((m) => m['id'].toString()).contains(s.targetId) && s.isMemberScore);
      return a.isEvaluated || isPendingGraded;
    }).length;
    final progressFraction = totalAssignments > 0 ? (evaluatedCount / totalAssignments) : 0.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          children: [
            const Text(
              'English Department', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)
            ),
            Text(
              'UAB • Panel de Jurado',
              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.wb_sunny_rounded
                  : Icons.nightlight_round,
              color: Colors.white,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            tooltip: 'Cambiar tema',
          ),
          IconButton(
            icon: _isSyncing 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
              : const Icon(Icons.sync, color: Colors.white),
            onPressed: _isSyncing ? null : () => _syncData(showFeedback: true),
            tooltip: 'Sincronizar Datos',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white), 
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _syncData(showFeedback: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.85),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + kToolbarHeight + 10,
                    20,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola, $_username!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                      const SizedBox(height: 4),
                      Text(
                        'Feria de Innovación y Tecnología',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 6,
                        shadowColor: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: isDark ? colorScheme.surface.withOpacity(0.95) : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progreso de Evaluaciones',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$evaluatedCount de $totalAssignments stands calificados',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white70 : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: LinearProgressIndicator(
                                            value: progressFraction,
                                            backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              progressFraction == 1.0 ? Colors.green : colorScheme.primary,
                                            ),
                                            minHeight: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${(progressFraction * 100).toInt()}%',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              // Offline sync disabled for demo
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                    ],
                  ),
                ),
              ),
            ),
            if (_assignments.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off_rounded, size: 80, color: colorScheme.onSurfaceVariant.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No hay asignaciones cargadas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Por favor, conéctate a internet y presiona el botón para sincronizar tus stands.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        icon: const Icon(Icons.cloud_download),
                        label: const Text('Sincronizar Ahora'),
                        onPressed: () => _syncData(showFeedback: true),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      )
                    ],
                  ),
                ),
              )
            else ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Text(
                    'Mis Stands Asignados',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final assignment = _assignments[index];
                      final isPendingGraded = assignment.roleInStand == 'JURADO'
                          ? _pendingScores.any((s) => s.targetId == assignment.standId && !s.isMemberScore)
                          : _pendingScores.any((s) => (jsonDecode(assignment.membersJson) as List).map((m) => m['id'].toString()).contains(s.targetId) && s.isMemberScore);
                      final isGraded = assignment.isEvaluated || isPendingGraded;

                      return _buildAssignmentCard(context, assignment, isGraded, colorScheme, isDark);
                    },
                    childCount: _assignments.length,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/evaluator/select_stand');
          _syncData(showFeedback: false);
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Calificar otros Stands', style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ).animate().fadeIn(delay: 400.ms).scale(),
    );
  }
}
