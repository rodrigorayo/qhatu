import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'models/local_models.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [LocalAssignmentSchema, LocalCriterionSchema, PendingScoreSchema, LocalStandSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  // Guardar asignaciones descargadas de internet
  Future<void> saveAssignments(List<dynamic> assignmentsData) async {
    final isar = await db;
    final newAssignments = assignmentsData.map((data) {
      final stand = data['stand'];
      return LocalAssignment()
        ..assignmentId = data['id']
        ..standId = stand['id']
        ..standName = stand['name']
        ..standNumber = stand['number']
        ..roleInStand = data['roleInStand']
        ..membersJson = jsonEncode(stand['members']);
    }).toList();

    await isar.writeTxn(() async {
      await isar.localAssignments.clear(); // Limpiar viejas
      await isar.localAssignments.putAll(newAssignments);
    });
  }

  // Guardar todos los stands descargados
  Future<void> saveAllStands(List<dynamic> standsData) async {
    final isar = await db;
    final newStands = standsData.map((data) {
      return LocalStand()
        ..standId = data['id']
        ..name = data['name']
        ..number = data['number']
        ..membersJson = jsonEncode(data['members']);
    }).toList();

    await isar.writeTxn(() async {
      await isar.localStands.clear(); // Limpiar viejas
      await isar.localStands.putAll(newStands);
    });
  }

  // Obtener todos los stands locales
  Future<List<LocalStand>> getAllStands() async {
    final isar = await db;
    return await isar.localStands.where().findAll();
  }


  // Guardar la rúbrica descargada
  Future<void> saveRubric(List<dynamic> areasData) async {
    final isar = await db;
    List<LocalCriterion> newCriteria = [];

    for (var area in areasData) {
      final criteriaList = area['criteria'] as List<dynamic>;
      for (var c in criteriaList) {
        newCriteria.add(
          LocalCriterion()
            ..criterionId = c['id']
            ..areaId = area['id']
            ..areaName = area['name']
            ..name = c['name']
            ..maxScore = (c['maxScore'] as num).toDouble()
        );
      }
    }

    await isar.writeTxn(() async {
      await isar.localCriterions.clear();
      await isar.localCriterions.putAll(newCriteria);
    });
  }

  Future<List<LocalAssignment>> getAssignments() async {
    final isar = await db;
    return await isar.localAssignments.where().findAll();
  }

  Future<List<LocalCriterion>> getCriteria() async {
    final isar = await db;
    return await isar.localCriterions.where().findAll();
  }

  Future<void> savePendingScore(PendingScore score) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.pendingScores.put(score);
    });
  }

  Future<List<PendingScore>> getPendingScores() async {
    final isar = await db;
    return await isar.pendingScores.where().findAll();
  }

  Future<void> clearPendingScores() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.pendingScores.clear();
    });
  }
}
