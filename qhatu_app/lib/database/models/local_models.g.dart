// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalAssignmentCollection on Isar {
  IsarCollection<LocalAssignment> get localAssignments => this.collection();
}

const LocalAssignmentSchema = CollectionSchema(
  name: r'LocalAssignment',
  id: 3377249982102375126,
  properties: {
    r'assignedAreaIdsJson': PropertySchema(
      id: 0,
      name: r'assignedAreaIdsJson',
      type: IsarType.string,
    ),
    r'assignmentId': PropertySchema(
      id: 1,
      name: r'assignmentId',
      type: IsarType.string,
    ),
    r'isEvaluated': PropertySchema(
      id: 2,
      name: r'isEvaluated',
      type: IsarType.bool,
    ),
    r'membersJson': PropertySchema(
      id: 3,
      name: r'membersJson',
      type: IsarType.string,
    ),
    r'roleInStand': PropertySchema(
      id: 4,
      name: r'roleInStand',
      type: IsarType.string,
    ),
    r'standId': PropertySchema(
      id: 5,
      name: r'standId',
      type: IsarType.string,
    ),
    r'standName': PropertySchema(
      id: 6,
      name: r'standName',
      type: IsarType.string,
    ),
    r'standNumber': PropertySchema(
      id: 7,
      name: r'standNumber',
      type: IsarType.string,
    )
  },
  estimateSize: _localAssignmentEstimateSize,
  serialize: _localAssignmentSerialize,
  deserialize: _localAssignmentDeserialize,
  deserializeProp: _localAssignmentDeserializeProp,
  idName: r'id',
  indexes: {
    r'assignmentId': IndexSchema(
      id: -2077143699295136292,
      name: r'assignmentId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'assignmentId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _localAssignmentGetId,
  getLinks: _localAssignmentGetLinks,
  attach: _localAssignmentAttach,
  version: '3.1.0+1',
);

int _localAssignmentEstimateSize(
  LocalAssignment object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.assignedAreaIdsJson.length * 3;
  bytesCount += 3 + object.assignmentId.length * 3;
  bytesCount += 3 + object.membersJson.length * 3;
  bytesCount += 3 + object.roleInStand.length * 3;
  bytesCount += 3 + object.standId.length * 3;
  bytesCount += 3 + object.standName.length * 3;
  bytesCount += 3 + object.standNumber.length * 3;
  return bytesCount;
}

void _localAssignmentSerialize(
  LocalAssignment object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.assignedAreaIdsJson);
  writer.writeString(offsets[1], object.assignmentId);
  writer.writeBool(offsets[2], object.isEvaluated);
  writer.writeString(offsets[3], object.membersJson);
  writer.writeString(offsets[4], object.roleInStand);
  writer.writeString(offsets[5], object.standId);
  writer.writeString(offsets[6], object.standName);
  writer.writeString(offsets[7], object.standNumber);
}

LocalAssignment _localAssignmentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalAssignment();
  object.assignedAreaIdsJson = reader.readString(offsets[0]);
  object.assignmentId = reader.readString(offsets[1]);
  object.id = id;
  object.isEvaluated = reader.readBool(offsets[2]);
  object.membersJson = reader.readString(offsets[3]);
  object.roleInStand = reader.readString(offsets[4]);
  object.standId = reader.readString(offsets[5]);
  object.standName = reader.readString(offsets[6]);
  object.standNumber = reader.readString(offsets[7]);
  return object;
}

P _localAssignmentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _localAssignmentGetId(LocalAssignment object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localAssignmentGetLinks(LocalAssignment object) {
  return [];
}

void _localAssignmentAttach(
    IsarCollection<dynamic> col, Id id, LocalAssignment object) {
  object.id = id;
}

extension LocalAssignmentByIndex on IsarCollection<LocalAssignment> {
  Future<LocalAssignment?> getByAssignmentId(String assignmentId) {
    return getByIndex(r'assignmentId', [assignmentId]);
  }

  LocalAssignment? getByAssignmentIdSync(String assignmentId) {
    return getByIndexSync(r'assignmentId', [assignmentId]);
  }

  Future<bool> deleteByAssignmentId(String assignmentId) {
    return deleteByIndex(r'assignmentId', [assignmentId]);
  }

  bool deleteByAssignmentIdSync(String assignmentId) {
    return deleteByIndexSync(r'assignmentId', [assignmentId]);
  }

  Future<List<LocalAssignment?>> getAllByAssignmentId(
      List<String> assignmentIdValues) {
    final values = assignmentIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'assignmentId', values);
  }

  List<LocalAssignment?> getAllByAssignmentIdSync(
      List<String> assignmentIdValues) {
    final values = assignmentIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'assignmentId', values);
  }

  Future<int> deleteAllByAssignmentId(List<String> assignmentIdValues) {
    final values = assignmentIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'assignmentId', values);
  }

  int deleteAllByAssignmentIdSync(List<String> assignmentIdValues) {
    final values = assignmentIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'assignmentId', values);
  }

  Future<Id> putByAssignmentId(LocalAssignment object) {
    return putByIndex(r'assignmentId', object);
  }

  Id putByAssignmentIdSync(LocalAssignment object, {bool saveLinks = true}) {
    return putByIndexSync(r'assignmentId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByAssignmentId(List<LocalAssignment> objects) {
    return putAllByIndex(r'assignmentId', objects);
  }

  List<Id> putAllByAssignmentIdSync(List<LocalAssignment> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'assignmentId', objects, saveLinks: saveLinks);
  }
}

extension LocalAssignmentQueryWhereSort
    on QueryBuilder<LocalAssignment, LocalAssignment, QWhere> {
  QueryBuilder<LocalAssignment, LocalAssignment, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocalAssignmentQueryWhere
    on QueryBuilder<LocalAssignment, LocalAssignment, QWhereClause> {
  QueryBuilder<LocalAssignment, LocalAssignment, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterWhereClause>
      assignmentIdEqualTo(String assignmentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'assignmentId',
        value: [assignmentId],
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterWhereClause>
      assignmentIdNotEqualTo(String assignmentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assignmentId',
              lower: [],
              upper: [assignmentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assignmentId',
              lower: [assignmentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assignmentId',
              lower: [assignmentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assignmentId',
              lower: [],
              upper: [assignmentId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LocalAssignmentQueryFilter
    on QueryBuilder<LocalAssignment, LocalAssignment, QFilterCondition> {
  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignedAreaIdsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedAreaIdsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignedAreaIdsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedAreaIdsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignedAreaIdsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedAreaIdsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignedAreaIdsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedAreaIdsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignedAreaIdsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedAreaIdsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignedAreaIdsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedAreaIdsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignedAreaIdsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedAreaIdsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignedAreaIdsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedAreaIdsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignedAreaIdsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedAreaIdsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignedAreaIdsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedAreaIdsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignmentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignmentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignmentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignmentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignmentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignmentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignmentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignmentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignmentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignmentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignmentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      assignmentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      isEvaluatedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEvaluated',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      membersJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      membersJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'membersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      membersJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'membersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      membersJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'membersJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      membersJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'membersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      membersJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'membersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      membersJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'membersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      membersJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'membersJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      membersJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membersJson',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      membersJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'membersJson',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      roleInStandEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roleInStand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      roleInStandGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'roleInStand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      roleInStandLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'roleInStand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      roleInStandBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'roleInStand',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      roleInStandStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'roleInStand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      roleInStandEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'roleInStand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      roleInStandContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'roleInStand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      roleInStandMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'roleInStand',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      roleInStandIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roleInStand',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      roleInStandIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'roleInStand',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'standId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'standId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'standId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'standId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'standId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'standId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'standId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'standId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'standId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'standId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'standName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'standName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'standName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'standName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'standName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'standName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'standName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'standName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'standName',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'standName',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'standNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'standNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'standNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'standNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'standNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'standNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'standNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'standNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'standNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterFilterCondition>
      standNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'standNumber',
        value: '',
      ));
    });
  }
}

extension LocalAssignmentQueryObject
    on QueryBuilder<LocalAssignment, LocalAssignment, QFilterCondition> {}

extension LocalAssignmentQueryLinks
    on QueryBuilder<LocalAssignment, LocalAssignment, QFilterCondition> {}

extension LocalAssignmentQuerySortBy
    on QueryBuilder<LocalAssignment, LocalAssignment, QSortBy> {
  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      sortByAssignedAreaIdsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedAreaIdsJson', Sort.asc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      sortByAssignedAreaIdsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedAreaIdsJson', Sort.desc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      sortByAssignmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignmentId', Sort.asc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      sortByAssignmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignmentId', Sort.desc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      sortByIsEvaluated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEvaluated', Sort.asc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      sortByIsEvaluatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEvaluated', Sort.desc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      sortByMembersJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membersJson', Sort.asc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      sortByMembersJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membersJson', Sort.desc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      sortByRoleInStand() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleInStand', Sort.asc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      sortByRoleInStandDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleInStand', Sort.desc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy> sortByStandId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standId', Sort.asc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      sortByStandIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standId', Sort.desc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      sortByStandName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standName', Sort.asc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      sortByStandNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standName', Sort.desc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      sortByStandNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standNumber', Sort.asc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      sortByStandNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standNumber', Sort.desc);
    });
  }
}

extension LocalAssignmentQuerySortThenBy
    on QueryBuilder<LocalAssignment, LocalAssignment, QSortThenBy> {
  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      thenByAssignedAreaIdsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedAreaIdsJson', Sort.asc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      thenByAssignedAreaIdsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedAreaIdsJson', Sort.desc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      thenByAssignmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignmentId', Sort.asc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      thenByAssignmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignmentId', Sort.desc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      thenByIsEvaluated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEvaluated', Sort.asc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      thenByIsEvaluatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEvaluated', Sort.desc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      thenByMembersJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membersJson', Sort.asc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      thenByMembersJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membersJson', Sort.desc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      thenByRoleInStand() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleInStand', Sort.asc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      thenByRoleInStandDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleInStand', Sort.desc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy> thenByStandId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standId', Sort.asc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      thenByStandIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standId', Sort.desc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      thenByStandName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standName', Sort.asc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      thenByStandNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standName', Sort.desc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      thenByStandNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standNumber', Sort.asc);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QAfterSortBy>
      thenByStandNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standNumber', Sort.desc);
    });
  }
}

extension LocalAssignmentQueryWhereDistinct
    on QueryBuilder<LocalAssignment, LocalAssignment, QDistinct> {
  QueryBuilder<LocalAssignment, LocalAssignment, QDistinct>
      distinctByAssignedAreaIdsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedAreaIdsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QDistinct>
      distinctByAssignmentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignmentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QDistinct>
      distinctByIsEvaluated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEvaluated');
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QDistinct>
      distinctByMembersJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'membersJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QDistinct>
      distinctByRoleInStand({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roleInStand', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QDistinct> distinctByStandId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'standId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QDistinct> distinctByStandName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'standName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalAssignment, LocalAssignment, QDistinct>
      distinctByStandNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'standNumber', caseSensitive: caseSensitive);
    });
  }
}

extension LocalAssignmentQueryProperty
    on QueryBuilder<LocalAssignment, LocalAssignment, QQueryProperty> {
  QueryBuilder<LocalAssignment, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalAssignment, String, QQueryOperations>
      assignedAreaIdsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedAreaIdsJson');
    });
  }

  QueryBuilder<LocalAssignment, String, QQueryOperations>
      assignmentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignmentId');
    });
  }

  QueryBuilder<LocalAssignment, bool, QQueryOperations> isEvaluatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEvaluated');
    });
  }

  QueryBuilder<LocalAssignment, String, QQueryOperations>
      membersJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'membersJson');
    });
  }

  QueryBuilder<LocalAssignment, String, QQueryOperations>
      roleInStandProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roleInStand');
    });
  }

  QueryBuilder<LocalAssignment, String, QQueryOperations> standIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'standId');
    });
  }

  QueryBuilder<LocalAssignment, String, QQueryOperations> standNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'standName');
    });
  }

  QueryBuilder<LocalAssignment, String, QQueryOperations>
      standNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'standNumber');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalCriterionCollection on Isar {
  IsarCollection<LocalCriterion> get localCriterions => this.collection();
}

const LocalCriterionSchema = CollectionSchema(
  name: r'LocalCriterion',
  id: -201649215205507621,
  properties: {
    r'areaId': PropertySchema(
      id: 0,
      name: r'areaId',
      type: IsarType.string,
    ),
    r'areaName': PropertySchema(
      id: 1,
      name: r'areaName',
      type: IsarType.string,
    ),
    r'criterionId': PropertySchema(
      id: 2,
      name: r'criterionId',
      type: IsarType.string,
    ),
    r'maxScore': PropertySchema(
      id: 3,
      name: r'maxScore',
      type: IsarType.double,
    ),
    r'minScore': PropertySchema(
      id: 4,
      name: r'minScore',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 5,
      name: r'name',
      type: IsarType.string,
    ),
    r'weight': PropertySchema(
      id: 6,
      name: r'weight',
      type: IsarType.double,
    )
  },
  estimateSize: _localCriterionEstimateSize,
  serialize: _localCriterionSerialize,
  deserialize: _localCriterionDeserialize,
  deserializeProp: _localCriterionDeserializeProp,
  idName: r'id',
  indexes: {
    r'criterionId': IndexSchema(
      id: -7068526076926448102,
      name: r'criterionId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'criterionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _localCriterionGetId,
  getLinks: _localCriterionGetLinks,
  attach: _localCriterionAttach,
  version: '3.1.0+1',
);

int _localCriterionEstimateSize(
  LocalCriterion object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.areaId.length * 3;
  bytesCount += 3 + object.areaName.length * 3;
  bytesCount += 3 + object.criterionId.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _localCriterionSerialize(
  LocalCriterion object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.areaId);
  writer.writeString(offsets[1], object.areaName);
  writer.writeString(offsets[2], object.criterionId);
  writer.writeDouble(offsets[3], object.maxScore);
  writer.writeDouble(offsets[4], object.minScore);
  writer.writeString(offsets[5], object.name);
  writer.writeDouble(offsets[6], object.weight);
}

LocalCriterion _localCriterionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalCriterion();
  object.areaId = reader.readString(offsets[0]);
  object.areaName = reader.readString(offsets[1]);
  object.criterionId = reader.readString(offsets[2]);
  object.id = id;
  object.maxScore = reader.readDouble(offsets[3]);
  object.minScore = reader.readDouble(offsets[4]);
  object.name = reader.readString(offsets[5]);
  object.weight = reader.readDouble(offsets[6]);
  return object;
}

P _localCriterionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _localCriterionGetId(LocalCriterion object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localCriterionGetLinks(LocalCriterion object) {
  return [];
}

void _localCriterionAttach(
    IsarCollection<dynamic> col, Id id, LocalCriterion object) {
  object.id = id;
}

extension LocalCriterionByIndex on IsarCollection<LocalCriterion> {
  Future<LocalCriterion?> getByCriterionId(String criterionId) {
    return getByIndex(r'criterionId', [criterionId]);
  }

  LocalCriterion? getByCriterionIdSync(String criterionId) {
    return getByIndexSync(r'criterionId', [criterionId]);
  }

  Future<bool> deleteByCriterionId(String criterionId) {
    return deleteByIndex(r'criterionId', [criterionId]);
  }

  bool deleteByCriterionIdSync(String criterionId) {
    return deleteByIndexSync(r'criterionId', [criterionId]);
  }

  Future<List<LocalCriterion?>> getAllByCriterionId(
      List<String> criterionIdValues) {
    final values = criterionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'criterionId', values);
  }

  List<LocalCriterion?> getAllByCriterionIdSync(
      List<String> criterionIdValues) {
    final values = criterionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'criterionId', values);
  }

  Future<int> deleteAllByCriterionId(List<String> criterionIdValues) {
    final values = criterionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'criterionId', values);
  }

  int deleteAllByCriterionIdSync(List<String> criterionIdValues) {
    final values = criterionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'criterionId', values);
  }

  Future<Id> putByCriterionId(LocalCriterion object) {
    return putByIndex(r'criterionId', object);
  }

  Id putByCriterionIdSync(LocalCriterion object, {bool saveLinks = true}) {
    return putByIndexSync(r'criterionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCriterionId(List<LocalCriterion> objects) {
    return putAllByIndex(r'criterionId', objects);
  }

  List<Id> putAllByCriterionIdSync(List<LocalCriterion> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'criterionId', objects, saveLinks: saveLinks);
  }
}

extension LocalCriterionQueryWhereSort
    on QueryBuilder<LocalCriterion, LocalCriterion, QWhere> {
  QueryBuilder<LocalCriterion, LocalCriterion, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocalCriterionQueryWhere
    on QueryBuilder<LocalCriterion, LocalCriterion, QWhereClause> {
  QueryBuilder<LocalCriterion, LocalCriterion, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterWhereClause>
      criterionIdEqualTo(String criterionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'criterionId',
        value: [criterionId],
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterWhereClause>
      criterionIdNotEqualTo(String criterionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'criterionId',
              lower: [],
              upper: [criterionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'criterionId',
              lower: [criterionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'criterionId',
              lower: [criterionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'criterionId',
              lower: [],
              upper: [criterionId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LocalCriterionQueryFilter
    on QueryBuilder<LocalCriterion, LocalCriterion, QFilterCondition> {
  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'areaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'areaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'areaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'areaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'areaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'areaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'areaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'areaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'areaId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'areaId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'areaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'areaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'areaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'areaName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'areaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'areaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'areaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'areaName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'areaName',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      areaNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'areaName',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      criterionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'criterionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      criterionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'criterionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      criterionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'criterionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      criterionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'criterionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      criterionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'criterionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      criterionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'criterionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      criterionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'criterionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      criterionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'criterionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      criterionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'criterionId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      criterionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'criterionId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      maxScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      maxScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      maxScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      maxScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      minScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      minScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      minScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      minScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      weightEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      weightGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      weightLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterFilterCondition>
      weightBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension LocalCriterionQueryObject
    on QueryBuilder<LocalCriterion, LocalCriterion, QFilterCondition> {}

extension LocalCriterionQueryLinks
    on QueryBuilder<LocalCriterion, LocalCriterion, QFilterCondition> {}

extension LocalCriterionQuerySortBy
    on QueryBuilder<LocalCriterion, LocalCriterion, QSortBy> {
  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy> sortByAreaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaId', Sort.asc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy>
      sortByAreaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaId', Sort.desc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy> sortByAreaName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaName', Sort.asc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy>
      sortByAreaNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaName', Sort.desc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy>
      sortByCriterionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criterionId', Sort.asc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy>
      sortByCriterionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criterionId', Sort.desc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy> sortByMaxScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxScore', Sort.asc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy>
      sortByMaxScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxScore', Sort.desc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy> sortByMinScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minScore', Sort.asc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy>
      sortByMinScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minScore', Sort.desc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy> sortByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy>
      sortByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension LocalCriterionQuerySortThenBy
    on QueryBuilder<LocalCriterion, LocalCriterion, QSortThenBy> {
  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy> thenByAreaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaId', Sort.asc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy>
      thenByAreaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaId', Sort.desc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy> thenByAreaName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaName', Sort.asc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy>
      thenByAreaNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaName', Sort.desc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy>
      thenByCriterionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criterionId', Sort.asc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy>
      thenByCriterionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criterionId', Sort.desc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy> thenByMaxScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxScore', Sort.asc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy>
      thenByMaxScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxScore', Sort.desc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy> thenByMinScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minScore', Sort.asc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy>
      thenByMinScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minScore', Sort.desc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy> thenByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QAfterSortBy>
      thenByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension LocalCriterionQueryWhereDistinct
    on QueryBuilder<LocalCriterion, LocalCriterion, QDistinct> {
  QueryBuilder<LocalCriterion, LocalCriterion, QDistinct> distinctByAreaId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'areaId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QDistinct> distinctByAreaName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'areaName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QDistinct> distinctByCriterionId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'criterionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QDistinct> distinctByMaxScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxScore');
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QDistinct> distinctByMinScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minScore');
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalCriterion, LocalCriterion, QDistinct> distinctByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weight');
    });
  }
}

extension LocalCriterionQueryProperty
    on QueryBuilder<LocalCriterion, LocalCriterion, QQueryProperty> {
  QueryBuilder<LocalCriterion, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalCriterion, String, QQueryOperations> areaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'areaId');
    });
  }

  QueryBuilder<LocalCriterion, String, QQueryOperations> areaNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'areaName');
    });
  }

  QueryBuilder<LocalCriterion, String, QQueryOperations> criterionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'criterionId');
    });
  }

  QueryBuilder<LocalCriterion, double, QQueryOperations> maxScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxScore');
    });
  }

  QueryBuilder<LocalCriterion, double, QQueryOperations> minScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minScore');
    });
  }

  QueryBuilder<LocalCriterion, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<LocalCriterion, double, QQueryOperations> weightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weight');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPendingScoreCollection on Isar {
  IsarCollection<PendingScore> get pendingScores => this.collection();
}

const PendingScoreSchema = CollectionSchema(
  name: r'PendingScore',
  id: -3332557035710221363,
  properties: {
    r'comments': PropertySchema(
      id: 0,
      name: r'comments',
      type: IsarType.string,
    ),
    r'criterionId': PropertySchema(
      id: 1,
      name: r'criterionId',
      type: IsarType.string,
    ),
    r'isMemberScore': PropertySchema(
      id: 2,
      name: r'isMemberScore',
      type: IsarType.bool,
    ),
    r'rawScore': PropertySchema(
      id: 3,
      name: r'rawScore',
      type: IsarType.double,
    ),
    r'targetId': PropertySchema(
      id: 4,
      name: r'targetId',
      type: IsarType.string,
    ),
    r'uniqueKey': PropertySchema(
      id: 5,
      name: r'uniqueKey',
      type: IsarType.string,
    )
  },
  estimateSize: _pendingScoreEstimateSize,
  serialize: _pendingScoreSerialize,
  deserialize: _pendingScoreDeserialize,
  deserializeProp: _pendingScoreDeserializeProp,
  idName: r'id',
  indexes: {
    r'uniqueKey': IndexSchema(
      id: -866995956150369819,
      name: r'uniqueKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uniqueKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _pendingScoreGetId,
  getLinks: _pendingScoreGetLinks,
  attach: _pendingScoreAttach,
  version: '3.1.0+1',
);

int _pendingScoreEstimateSize(
  PendingScore object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.comments.length * 3;
  bytesCount += 3 + object.criterionId.length * 3;
  bytesCount += 3 + object.targetId.length * 3;
  bytesCount += 3 + object.uniqueKey.length * 3;
  return bytesCount;
}

void _pendingScoreSerialize(
  PendingScore object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.comments);
  writer.writeString(offsets[1], object.criterionId);
  writer.writeBool(offsets[2], object.isMemberScore);
  writer.writeDouble(offsets[3], object.rawScore);
  writer.writeString(offsets[4], object.targetId);
  writer.writeString(offsets[5], object.uniqueKey);
}

PendingScore _pendingScoreDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PendingScore();
  object.comments = reader.readString(offsets[0]);
  object.criterionId = reader.readString(offsets[1]);
  object.id = id;
  object.isMemberScore = reader.readBool(offsets[2]);
  object.rawScore = reader.readDouble(offsets[3]);
  object.targetId = reader.readString(offsets[4]);
  object.uniqueKey = reader.readString(offsets[5]);
  return object;
}

P _pendingScoreDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pendingScoreGetId(PendingScore object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pendingScoreGetLinks(PendingScore object) {
  return [];
}

void _pendingScoreAttach(
    IsarCollection<dynamic> col, Id id, PendingScore object) {
  object.id = id;
}

extension PendingScoreByIndex on IsarCollection<PendingScore> {
  Future<PendingScore?> getByUniqueKey(String uniqueKey) {
    return getByIndex(r'uniqueKey', [uniqueKey]);
  }

  PendingScore? getByUniqueKeySync(String uniqueKey) {
    return getByIndexSync(r'uniqueKey', [uniqueKey]);
  }

  Future<bool> deleteByUniqueKey(String uniqueKey) {
    return deleteByIndex(r'uniqueKey', [uniqueKey]);
  }

  bool deleteByUniqueKeySync(String uniqueKey) {
    return deleteByIndexSync(r'uniqueKey', [uniqueKey]);
  }

  Future<List<PendingScore?>> getAllByUniqueKey(List<String> uniqueKeyValues) {
    final values = uniqueKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'uniqueKey', values);
  }

  List<PendingScore?> getAllByUniqueKeySync(List<String> uniqueKeyValues) {
    final values = uniqueKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uniqueKey', values);
  }

  Future<int> deleteAllByUniqueKey(List<String> uniqueKeyValues) {
    final values = uniqueKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uniqueKey', values);
  }

  int deleteAllByUniqueKeySync(List<String> uniqueKeyValues) {
    final values = uniqueKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uniqueKey', values);
  }

  Future<Id> putByUniqueKey(PendingScore object) {
    return putByIndex(r'uniqueKey', object);
  }

  Id putByUniqueKeySync(PendingScore object, {bool saveLinks = true}) {
    return putByIndexSync(r'uniqueKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUniqueKey(List<PendingScore> objects) {
    return putAllByIndex(r'uniqueKey', objects);
  }

  List<Id> putAllByUniqueKeySync(List<PendingScore> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uniqueKey', objects, saveLinks: saveLinks);
  }
}

extension PendingScoreQueryWhereSort
    on QueryBuilder<PendingScore, PendingScore, QWhere> {
  QueryBuilder<PendingScore, PendingScore, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PendingScoreQueryWhere
    on QueryBuilder<PendingScore, PendingScore, QWhereClause> {
  QueryBuilder<PendingScore, PendingScore, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterWhereClause> uniqueKeyEqualTo(
      String uniqueKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uniqueKey',
        value: [uniqueKey],
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterWhereClause>
      uniqueKeyNotEqualTo(String uniqueKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueKey',
              lower: [],
              upper: [uniqueKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueKey',
              lower: [uniqueKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueKey',
              lower: [uniqueKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueKey',
              lower: [],
              upper: [uniqueKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PendingScoreQueryFilter
    on QueryBuilder<PendingScore, PendingScore, QFilterCondition> {
  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      commentsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'comments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      commentsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'comments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      commentsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'comments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      commentsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'comments',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      commentsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'comments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      commentsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'comments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      commentsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'comments',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      commentsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'comments',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      commentsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'comments',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      commentsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'comments',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      criterionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'criterionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      criterionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'criterionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      criterionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'criterionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      criterionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'criterionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      criterionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'criterionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      criterionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'criterionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      criterionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'criterionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      criterionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'criterionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      criterionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'criterionId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      criterionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'criterionId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      isMemberScoreEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMemberScore',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      rawScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      rawScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rawScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      rawScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rawScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      rawScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rawScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      targetIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      targetIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      targetIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      targetIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      targetIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'targetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      targetIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'targetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      targetIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'targetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      targetIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'targetId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      targetIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      targetIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'targetId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      uniqueKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      uniqueKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      uniqueKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      uniqueKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uniqueKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      uniqueKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      uniqueKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      uniqueKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      uniqueKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uniqueKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      uniqueKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uniqueKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterFilterCondition>
      uniqueKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uniqueKey',
        value: '',
      ));
    });
  }
}

extension PendingScoreQueryObject
    on QueryBuilder<PendingScore, PendingScore, QFilterCondition> {}

extension PendingScoreQueryLinks
    on QueryBuilder<PendingScore, PendingScore, QFilterCondition> {}

extension PendingScoreQuerySortBy
    on QueryBuilder<PendingScore, PendingScore, QSortBy> {
  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> sortByComments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comments', Sort.asc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> sortByCommentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comments', Sort.desc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> sortByCriterionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criterionId', Sort.asc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy>
      sortByCriterionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criterionId', Sort.desc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> sortByIsMemberScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMemberScore', Sort.asc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy>
      sortByIsMemberScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMemberScore', Sort.desc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> sortByRawScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawScore', Sort.asc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> sortByRawScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawScore', Sort.desc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> sortByTargetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetId', Sort.asc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> sortByTargetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetId', Sort.desc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> sortByUniqueKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueKey', Sort.asc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> sortByUniqueKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueKey', Sort.desc);
    });
  }
}

extension PendingScoreQuerySortThenBy
    on QueryBuilder<PendingScore, PendingScore, QSortThenBy> {
  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> thenByComments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comments', Sort.asc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> thenByCommentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comments', Sort.desc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> thenByCriterionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criterionId', Sort.asc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy>
      thenByCriterionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criterionId', Sort.desc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> thenByIsMemberScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMemberScore', Sort.asc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy>
      thenByIsMemberScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMemberScore', Sort.desc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> thenByRawScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawScore', Sort.asc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> thenByRawScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawScore', Sort.desc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> thenByTargetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetId', Sort.asc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> thenByTargetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetId', Sort.desc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> thenByUniqueKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueKey', Sort.asc);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QAfterSortBy> thenByUniqueKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueKey', Sort.desc);
    });
  }
}

extension PendingScoreQueryWhereDistinct
    on QueryBuilder<PendingScore, PendingScore, QDistinct> {
  QueryBuilder<PendingScore, PendingScore, QDistinct> distinctByComments(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'comments', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QDistinct> distinctByCriterionId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'criterionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QDistinct>
      distinctByIsMemberScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMemberScore');
    });
  }

  QueryBuilder<PendingScore, PendingScore, QDistinct> distinctByRawScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawScore');
    });
  }

  QueryBuilder<PendingScore, PendingScore, QDistinct> distinctByTargetId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingScore, PendingScore, QDistinct> distinctByUniqueKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uniqueKey', caseSensitive: caseSensitive);
    });
  }
}

extension PendingScoreQueryProperty
    on QueryBuilder<PendingScore, PendingScore, QQueryProperty> {
  QueryBuilder<PendingScore, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PendingScore, String, QQueryOperations> commentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'comments');
    });
  }

  QueryBuilder<PendingScore, String, QQueryOperations> criterionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'criterionId');
    });
  }

  QueryBuilder<PendingScore, bool, QQueryOperations> isMemberScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMemberScore');
    });
  }

  QueryBuilder<PendingScore, double, QQueryOperations> rawScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawScore');
    });
  }

  QueryBuilder<PendingScore, String, QQueryOperations> targetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetId');
    });
  }

  QueryBuilder<PendingScore, String, QQueryOperations> uniqueKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uniqueKey');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalStandCollection on Isar {
  IsarCollection<LocalStand> get localStands => this.collection();
}

const LocalStandSchema = CollectionSchema(
  name: r'LocalStand',
  id: 7771061803321546913,
  properties: {
    r'membersJson': PropertySchema(
      id: 0,
      name: r'membersJson',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    ),
    r'number': PropertySchema(
      id: 2,
      name: r'number',
      type: IsarType.string,
    ),
    r'standId': PropertySchema(
      id: 3,
      name: r'standId',
      type: IsarType.string,
    )
  },
  estimateSize: _localStandEstimateSize,
  serialize: _localStandSerialize,
  deserialize: _localStandDeserialize,
  deserializeProp: _localStandDeserializeProp,
  idName: r'id',
  indexes: {
    r'standId': IndexSchema(
      id: 2127603122869375727,
      name: r'standId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'standId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _localStandGetId,
  getLinks: _localStandGetLinks,
  attach: _localStandAttach,
  version: '3.1.0+1',
);

int _localStandEstimateSize(
  LocalStand object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.membersJson.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.number.length * 3;
  bytesCount += 3 + object.standId.length * 3;
  return bytesCount;
}

void _localStandSerialize(
  LocalStand object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.membersJson);
  writer.writeString(offsets[1], object.name);
  writer.writeString(offsets[2], object.number);
  writer.writeString(offsets[3], object.standId);
}

LocalStand _localStandDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalStand();
  object.id = id;
  object.membersJson = reader.readString(offsets[0]);
  object.name = reader.readString(offsets[1]);
  object.number = reader.readString(offsets[2]);
  object.standId = reader.readString(offsets[3]);
  return object;
}

P _localStandDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _localStandGetId(LocalStand object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localStandGetLinks(LocalStand object) {
  return [];
}

void _localStandAttach(IsarCollection<dynamic> col, Id id, LocalStand object) {
  object.id = id;
}

extension LocalStandByIndex on IsarCollection<LocalStand> {
  Future<LocalStand?> getByStandId(String standId) {
    return getByIndex(r'standId', [standId]);
  }

  LocalStand? getByStandIdSync(String standId) {
    return getByIndexSync(r'standId', [standId]);
  }

  Future<bool> deleteByStandId(String standId) {
    return deleteByIndex(r'standId', [standId]);
  }

  bool deleteByStandIdSync(String standId) {
    return deleteByIndexSync(r'standId', [standId]);
  }

  Future<List<LocalStand?>> getAllByStandId(List<String> standIdValues) {
    final values = standIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'standId', values);
  }

  List<LocalStand?> getAllByStandIdSync(List<String> standIdValues) {
    final values = standIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'standId', values);
  }

  Future<int> deleteAllByStandId(List<String> standIdValues) {
    final values = standIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'standId', values);
  }

  int deleteAllByStandIdSync(List<String> standIdValues) {
    final values = standIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'standId', values);
  }

  Future<Id> putByStandId(LocalStand object) {
    return putByIndex(r'standId', object);
  }

  Id putByStandIdSync(LocalStand object, {bool saveLinks = true}) {
    return putByIndexSync(r'standId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStandId(List<LocalStand> objects) {
    return putAllByIndex(r'standId', objects);
  }

  List<Id> putAllByStandIdSync(List<LocalStand> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'standId', objects, saveLinks: saveLinks);
  }
}

extension LocalStandQueryWhereSort
    on QueryBuilder<LocalStand, LocalStand, QWhere> {
  QueryBuilder<LocalStand, LocalStand, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocalStandQueryWhere
    on QueryBuilder<LocalStand, LocalStand, QWhereClause> {
  QueryBuilder<LocalStand, LocalStand, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterWhereClause> standIdEqualTo(
      String standId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'standId',
        value: [standId],
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterWhereClause> standIdNotEqualTo(
      String standId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'standId',
              lower: [],
              upper: [standId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'standId',
              lower: [standId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'standId',
              lower: [standId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'standId',
              lower: [],
              upper: [standId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LocalStandQueryFilter
    on QueryBuilder<LocalStand, LocalStand, QFilterCondition> {
  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition>
      membersJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition>
      membersJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'membersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition>
      membersJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'membersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition>
      membersJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'membersJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition>
      membersJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'membersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition>
      membersJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'membersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition>
      membersJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'membersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition>
      membersJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'membersJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition>
      membersJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'membersJson',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition>
      membersJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'membersJson',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> numberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'number',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> numberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'number',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> numberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'number',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> numberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'number',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> numberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'number',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> numberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'number',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> numberContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'number',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> numberMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'number',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> numberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'number',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition>
      numberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'number',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> standIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'standId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition>
      standIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'standId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> standIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'standId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> standIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'standId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> standIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'standId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> standIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'standId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> standIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'standId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> standIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'standId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition> standIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'standId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterFilterCondition>
      standIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'standId',
        value: '',
      ));
    });
  }
}

extension LocalStandQueryObject
    on QueryBuilder<LocalStand, LocalStand, QFilterCondition> {}

extension LocalStandQueryLinks
    on QueryBuilder<LocalStand, LocalStand, QFilterCondition> {}

extension LocalStandQuerySortBy
    on QueryBuilder<LocalStand, LocalStand, QSortBy> {
  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> sortByMembersJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membersJson', Sort.asc);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> sortByMembersJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membersJson', Sort.desc);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> sortByNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.asc);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> sortByNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.desc);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> sortByStandId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standId', Sort.asc);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> sortByStandIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standId', Sort.desc);
    });
  }
}

extension LocalStandQuerySortThenBy
    on QueryBuilder<LocalStand, LocalStand, QSortThenBy> {
  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> thenByMembersJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membersJson', Sort.asc);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> thenByMembersJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'membersJson', Sort.desc);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> thenByNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.asc);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> thenByNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'number', Sort.desc);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> thenByStandId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standId', Sort.asc);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QAfterSortBy> thenByStandIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standId', Sort.desc);
    });
  }
}

extension LocalStandQueryWhereDistinct
    on QueryBuilder<LocalStand, LocalStand, QDistinct> {
  QueryBuilder<LocalStand, LocalStand, QDistinct> distinctByMembersJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'membersJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QDistinct> distinctByNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'number', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalStand, LocalStand, QDistinct> distinctByStandId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'standId', caseSensitive: caseSensitive);
    });
  }
}

extension LocalStandQueryProperty
    on QueryBuilder<LocalStand, LocalStand, QQueryProperty> {
  QueryBuilder<LocalStand, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalStand, String, QQueryOperations> membersJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'membersJson');
    });
  }

  QueryBuilder<LocalStand, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<LocalStand, String, QQueryOperations> numberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'number');
    });
  }

  QueryBuilder<LocalStand, String, QQueryOperations> standIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'standId');
    });
  }
}
