// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_rate_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExchangeRateModelCollection on Isar {
  IsarCollection<ExchangeRateModel> get exchangeRateModels => this.collection();
}

const ExchangeRateModelSchema = CollectionSchema(
  name: r'ExchangeRateModel',
  id: -8488539567208408544,
  properties: {
    r'lastUpdated': PropertySchema(
      id: 0,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'ratesJson': PropertySchema(
      id: 1,
      name: r'ratesJson',
      type: IsarType.string,
    )
  },
  estimateSize: _exchangeRateModelEstimateSize,
  serialize: _exchangeRateModelSerialize,
  deserialize: _exchangeRateModelDeserialize,
  deserializeProp: _exchangeRateModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _exchangeRateModelGetId,
  getLinks: _exchangeRateModelGetLinks,
  attach: _exchangeRateModelAttach,
  version: '3.1.0+1',
);

int _exchangeRateModelEstimateSize(
  ExchangeRateModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.ratesJson.length * 3;
  return bytesCount;
}

void _exchangeRateModelSerialize(
  ExchangeRateModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.lastUpdated);
  writer.writeString(offsets[1], object.ratesJson);
}

ExchangeRateModel _exchangeRateModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExchangeRateModel();
  object.id = id;
  object.lastUpdated = reader.readDateTime(offsets[0]);
  object.ratesJson = reader.readString(offsets[1]);
  return object;
}

P _exchangeRateModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _exchangeRateModelGetId(ExchangeRateModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _exchangeRateModelGetLinks(
    ExchangeRateModel object) {
  return [];
}

void _exchangeRateModelAttach(
    IsarCollection<dynamic> col, Id id, ExchangeRateModel object) {
  object.id = id;
}

extension ExchangeRateModelQueryWhereSort
    on QueryBuilder<ExchangeRateModel, ExchangeRateModel, QWhere> {
  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ExchangeRateModelQueryWhere
    on QueryBuilder<ExchangeRateModel, ExchangeRateModel, QWhereClause> {
  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterWhereClause>
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

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterWhereClause>
      idBetween(
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
}

extension ExchangeRateModelQueryFilter
    on QueryBuilder<ExchangeRateModel, ExchangeRateModel, QFilterCondition> {
  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
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

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
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

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
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

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
      ratesJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ratesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
      ratesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ratesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
      ratesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ratesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
      ratesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ratesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
      ratesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ratesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
      ratesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ratesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
      ratesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ratesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
      ratesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ratesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
      ratesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ratesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterFilterCondition>
      ratesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ratesJson',
        value: '',
      ));
    });
  }
}

extension ExchangeRateModelQueryObject
    on QueryBuilder<ExchangeRateModel, ExchangeRateModel, QFilterCondition> {}

extension ExchangeRateModelQueryLinks
    on QueryBuilder<ExchangeRateModel, ExchangeRateModel, QFilterCondition> {}

extension ExchangeRateModelQuerySortBy
    on QueryBuilder<ExchangeRateModel, ExchangeRateModel, QSortBy> {
  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterSortBy>
      sortByRatesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesJson', Sort.asc);
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterSortBy>
      sortByRatesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesJson', Sort.desc);
    });
  }
}

extension ExchangeRateModelQuerySortThenBy
    on QueryBuilder<ExchangeRateModel, ExchangeRateModel, QSortThenBy> {
  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterSortBy>
      thenByRatesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesJson', Sort.asc);
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QAfterSortBy>
      thenByRatesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratesJson', Sort.desc);
    });
  }
}

extension ExchangeRateModelQueryWhereDistinct
    on QueryBuilder<ExchangeRateModel, ExchangeRateModel, QDistinct> {
  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<ExchangeRateModel, ExchangeRateModel, QDistinct>
      distinctByRatesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ratesJson', caseSensitive: caseSensitive);
    });
  }
}

extension ExchangeRateModelQueryProperty
    on QueryBuilder<ExchangeRateModel, ExchangeRateModel, QQueryProperty> {
  QueryBuilder<ExchangeRateModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExchangeRateModel, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<ExchangeRateModel, String, QQueryOperations>
      ratesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ratesJson');
    });
  }
}
