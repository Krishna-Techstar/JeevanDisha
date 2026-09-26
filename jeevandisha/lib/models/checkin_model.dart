class CheckinModel {
  const CheckinModel({
    required this.id,
    required this.feeling,
    required this.date,
  });

  final String id;
  final String feeling;
  final DateTime date;

  DateTime get createdAt => date;
  String get note => '';

  factory CheckinModel.fromJson(Map<String, dynamic> json) {
    return CheckinModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      feeling: (json['feeling'] ?? '').toString(),
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'feeling': feeling,
        'date': date.toIso8601String(),
      };
}
