import 'dart:math';

class OfflineActionType {
  static const String rpc = 'rpc';
  static const String tableInsert = 'table_insert';
  static const String tableUpdate = 'table_update';
  static const String tableDelete = 'table_delete';
  static const String tableUpsert = 'table_upsert';
  static const String taskCreate = 'task_create';
}

class OfflineFilter {
  final String column;
  final String op;
  final dynamic value;

  const OfflineFilter({
    required this.column,
    this.op = 'eq',
    required this.value,
  });

  Map<String, dynamic> toMap() => {
        'column': column,
        'op': op,
        'value': value,
      };

  factory OfflineFilter.fromMap(Map<String, dynamic> map) {
    return OfflineFilter(
      column: map['column'] as String,
      op: map['op'] as String? ?? 'eq',
      value: map['value'],
    );
  }
}

class OfflineAction {
  final String type;
  final String target;
  final Map<String, dynamic>? values;
  final List<OfflineFilter> filters;
  final Map<String, dynamic>? params;
  final Map<String, dynamic>? meta;

  const OfflineAction({
    required this.type,
    required this.target,
    this.values,
    this.filters = const [],
    this.params,
    this.meta,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'target': target,
        if (values != null) 'values': values,
        if (filters.isNotEmpty)
          'filters': filters.map((f) => f.toMap()).toList(),
        if (params != null) 'params': params,
        if (meta != null) 'meta': meta,
      };

  factory OfflineAction.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? toStringMap(dynamic value) {
      if (value == null) return null;
      return Map<String, dynamic>.from(value as Map);
    }

    return OfflineAction(
      type: map['type'] as String? ?? map['action'] as String? ?? '',
      target: map['target'] as String? ?? '',
      values: toStringMap(map['values']),
      filters: (map['filters'] as List<dynamic>? ?? [])
          .map((f) => OfflineFilter.fromMap(Map<String, dynamic>.from(f)))
          .toList(),
      params: toStringMap(map['params']),
      meta: toStringMap(map['meta']),
    );
  }
}

String generateOfflineRequestId() {
  final now = DateTime.now().millisecondsSinceEpoch;
  final rand = Random().nextInt(1000);
  return '$now-$rand';
}

