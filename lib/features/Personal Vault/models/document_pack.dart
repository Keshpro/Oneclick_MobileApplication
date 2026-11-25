
class DocumentRequirement {
  final String id;
  final String name;
  final String? vaultRecordId;

  const DocumentRequirement({
    required this.id,
    required this.name,
    this.vaultRecordId,
  });

  bool get isMatched =>
      vaultRecordId != null && vaultRecordId!.isNotEmpty;

  DocumentRequirement copyWith({
    String? name,
    String? vaultRecordId,
    bool clearMatch = false,
  }) {
    return DocumentRequirement(
      id: id,
      name: name ?? this.name,
      vaultRecordId: clearMatch
          ? null
          : vaultRecordId ?? this.vaultRecordId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'vaultRecordId': vaultRecordId,
    };
  }

  factory DocumentRequirement.fromMap(
    Map<String, dynamic> map,
  ) {
    return DocumentRequirement(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      vaultRecordId: map['vaultRecordId']?.toString(),
    );
  }
}

class DocumentPack {
  final String name;
  final List<DocumentRequirement> requirements;
  // Firestore document ID; null for a pack that has never been saved.
  final String? savedId;

  const DocumentPack({
    required this.name,
    required this.requirements,
    this.savedId,
  });

  int get totalRequirements => requirements.length;

  int get matchedRequirements =>
      requirements.where((item) => item.isMatched).length;

  int get missingRequirements =>
      totalRequirements - matchedRequirements;

  double get completionPercentage {
    if (requirements.isEmpty) return 0;

    return matchedRequirements / totalRequirements * 100;
  }

  DocumentPack copyWith({
    String? name,
    List<DocumentRequirement>? requirements,
    String? savedId,
  }) {
    return DocumentPack(
      name: name ?? this.name,
      requirements: requirements ?? this.requirements,
      savedId: savedId ?? this.savedId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'requirements': requirements
          .map((requirement) => requirement.toMap())
          .toList(),
    };
  }

  factory DocumentPack.fromMap(Map<String, dynamic> map) {
    final rawRequirements = map['requirements'];

    return DocumentPack(
      name: map['name']?.toString() ?? '',
      requirements: rawRequirements is List
          ? rawRequirements
              .whereType<Map>()
              .map(
                (item) => DocumentRequirement.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : [],
    );
  }
}
