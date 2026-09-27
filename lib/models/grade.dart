enum GradeType {
  quiz('Quiz'),
  assignment('Assignment'),
  project('Project'),
  midExam('Mid exam'),
  finalExam('Final exam');

  const GradeType(this.label);

  final String label;
}

/// One assessed item, e.g. Mid exam 16 / 20.
class Grade {
  const Grade({
    required this.id,
    required this.type,
    required this.label,
    required this.score,
    required this.outOf,
  });

  final String id;
  final GradeType type;
  final String label;
  final double score;
  final double outOf;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'label': label,
        'score': score,
        'outOf': outOf,
      };

  factory Grade.fromJson(Map<String, dynamic> json) => Grade(
        id: json['id'] as String,
        type: GradeType.values.byName(json['type'] as String),
        label: json['label'] as String,
        score: (json['score'] as num).toDouble(),
        outOf: (json['outOf'] as num).toDouble(),
      );
}
