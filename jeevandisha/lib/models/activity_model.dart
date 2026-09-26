class LearnContent {
  const LearnContent({
    this.heading = '',
    this.body = '',
    this.keyIdea = '',
  });

  final String heading;
  final String body;
  final String keyIdea;

  factory LearnContent.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LearnContent();
    return LearnContent(
      heading: (json['heading'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      keyIdea: (json['keyIdea'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'heading': heading,
        'body': body,
        'keyIdea': keyIdea,
      };
}

class UnderstandOption {
  const UnderstandOption({required this.text, this.isCorrect = false});

  final String text;
  final bool isCorrect;

  factory UnderstandOption.fromJson(Map<String, dynamic> json) {
    return UnderstandOption(
      text: (json['text'] ?? '').toString(),
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'isCorrect': isCorrect,
      };
}

class UnderstandContent {
  const UnderstandContent({
    this.scenario = '',
    this.options = const [],
    this.explanation = '',
  });

  final String scenario;
  final List<UnderstandOption> options;
  final String explanation;

  factory UnderstandContent.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UnderstandContent();
    final opts = json['options'] as List<dynamic>? ?? [];
    return UnderstandContent(
      scenario: (json['scenario'] ?? '').toString(),
      options: opts
          .map((e) => UnderstandOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      explanation: (json['explanation'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'scenario': scenario,
        'options': options.map((o) => o.toJson()).toList(),
        'explanation': explanation,
      };
}

class PracticeField {
  const PracticeField({required this.label, this.placeholder = ''});

  final String label;
  final String placeholder;

  factory PracticeField.fromJson(Map<String, dynamic> json) {
    return PracticeField(
      label: (json['label'] ?? '').toString(),
      placeholder: (json['placeholder'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'placeholder': placeholder,
      };
}

class ActivityModel {
  const ActivityModel({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.type,
    this.order = 0,
    this.learnContent = const LearnContent(),
    this.understandContent = const UnderstandContent(),
    this.practiceFields = const [],
    this.reflectionQuestions = const [],
    this.applyPrompt = '',
    this.estimatedMinutes = 5,
    this.status,
    this.completed = false,
  });

  final String id;
  final String moduleId;
  final String title;
  final String type; // learn | understand | practice | reflect | apply
  final int order;
  final LearnContent learnContent;
  final UnderstandContent understandContent;
  final List<PracticeField> practiceFields;
  final List<String> reflectionQuestions;
  final String applyPrompt;
  final int estimatedMinutes;
  final String? status;
  final bool completed;

  /// Back-compat alias used by older UI widgets.
  int get durationMinutes => estimatedMinutes;

  String get description {
    switch (type) {
      case 'learn':
        return learnContent.keyIdea.isNotEmpty
            ? learnContent.keyIdea
            : learnContent.heading;
      case 'understand':
        return understandContent.scenario;
      case 'practice':
        return '${practiceFields.length} fields to complete';
      case 'reflect':
        return '${reflectionQuestions.length} reflection prompts';
      case 'apply':
        return applyPrompt;
      default:
        return '';
    }
  }

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final fields = json['practiceFields'] as List<dynamic>? ?? [];
    final questions = json['reflectionQuestions'] as List<dynamic>? ?? [];
    return ActivityModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      moduleId: (json['moduleId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      type: (json['type'] ?? 'practice').toString(),
      order: (json['order'] as num?)?.toInt() ?? 0,
      learnContent: LearnContent.fromJson(
        json['learnContent'] as Map<String, dynamic>?,
      ),
      understandContent: UnderstandContent.fromJson(
        json['understandContent'] as Map<String, dynamic>?,
      ),
      practiceFields: fields
          .map((e) => PracticeField.fromJson(e as Map<String, dynamic>))
          .toList(),
      reflectionQuestions: questions.map((e) => e.toString()).toList(),
      applyPrompt: (json['applyPrompt'] ?? '').toString(),
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ??
          (json['durationMinutes'] as num?)?.toInt() ??
          5,
      status: json['status']?.toString(),
      completed: json['completed'] as bool? ??
          json['status']?.toString() == 'completed',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'moduleId': moduleId,
        'title': title,
        'type': type,
        'order': order,
        'learnContent': learnContent.toJson(),
        'understandContent': understandContent.toJson(),
        'practiceFields': practiceFields.map((f) => f.toJson()).toList(),
        'reflectionQuestions': reflectionQuestions,
        'applyPrompt': applyPrompt,
        'estimatedMinutes': estimatedMinutes,
        'status': status,
        'completed': completed,
      };

  ActivityModel copyWith({bool? completed, String? status}) {
    return ActivityModel(
      id: id,
      moduleId: moduleId,
      title: title,
      type: type,
      order: order,
      learnContent: learnContent,
      understandContent: understandContent,
      practiceFields: practiceFields,
      reflectionQuestions: reflectionQuestions,
      applyPrompt: applyPrompt,
      estimatedMinutes: estimatedMinutes,
      status: status ?? this.status,
      completed: completed ?? this.completed,
    );
  }
}
