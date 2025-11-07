class OpsAlert {
  final String id;
  final String title;
  final String severity; // e.g. info, warning, critical
  final DateTime createdAt;
  final String description;
  final bool acknowledged;

  const OpsAlert({
    required this.id,
    required this.title,
    required this.severity,
    required this.createdAt,
    required this.description,
    this.acknowledged = false,
  });

  factory OpsAlert.fromMap(Map<String, dynamic> map) {
    return OpsAlert(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled alert',
      severity: map['severity'] as String? ?? 'info',
      createdAt: DateTime.parse((map['created_at'] as String?) ?? DateTime.now().toIso8601String()),
      description: map['description'] as String? ?? '',
      acknowledged: map['acknowledged'] as bool? ?? false,
    );
  }

  OpsAlert copyWith({
    String? id,
    String? title,
    String? severity,
    DateTime? createdAt,
    String? description,
    bool? acknowledged,
  }) {
    return OpsAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      acknowledged: acknowledged ?? this.acknowledged,
    );
  }

  bool get isCritical => severity.toLowerCase() == 'critical';
  bool get isWarning => severity.toLowerCase() == 'warning';
}
