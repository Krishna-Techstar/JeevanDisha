class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.prn = '',
    this.className = '',
    this.division = '',
    this.department = '',
    this.specialization = '',
    this.institutionName = '',
    this.currentWeek = 1,
    this.currentModule = 1,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String prn;
  final String className;
  final String division;
  final String department;
  final String specialization;
  final String institutionName;
  final int currentWeek;
  final int currentModule;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      prn: (json['prn'] ?? '').toString(),
      className: (json['className'] ?? '').toString(),
      division: (json['division'] ?? '').toString(),
      department: (json['department'] ?? '').toString(),
      specialization: (json['specialization'] ?? '').toString(),
      institutionName: (json['institutionName'] ?? '').toString(),
      currentWeek: (json['currentWeek'] as num?)?.toInt() ?? 1,
      currentModule: (json['currentModule'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'prn': prn,
        'className': className,
        'division': division,
        'department': department,
        'specialization': specialization,
        'institutionName': institutionName,
        'currentWeek': currentWeek,
        'currentModule': currentModule,
      };
}
