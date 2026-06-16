import 'package:isar/isar.dart';

part 'local_models.g.dart';

@collection
class LocalAssignment {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String assignmentId;
  
  late String standId;
  late String standName;
  late String standNumber;
  late String roleInStand; // JURADO o DELEGADO

  // Lista de miembros codificada en JSON para el modo offline
  String membersJson = '[]'; 
}

@collection
class LocalCriterion {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String criterionId;

  late String areaId;
  late String areaName;
  late String name;
  late double maxScore;
}

@collection
class PendingScore {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uniqueKey; // standId_criterionId o memberId_criterionId

  late String targetId; // Puede ser standId o memberId
  late String criterionId;
  late double rawScore;
  String comments = '';

  late bool isMemberScore; // true si evalúa a un miembro, false si evalúa al stand
}

@collection
class LocalStand {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String standId;

  late String name;
  late String number;

  // Lista de miembros codificada en JSON
  String membersJson = '[]';
}

