class StudentProfile {
  final String id;
  final String name;
  final String? surname;
  final String? institution;
  final String? studentNumber;
  final String? yearOfStudy;
  final DateTime? dob;
  final String role;

  const StudentProfile({
    required this.id,
    required this.name,
    this.surname,
    this.institution,
    this.studentNumber,
    this.yearOfStudy,
    this.dob,
    this.role = 'student',
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      surname: json['surname'] as String?,
      institution: json['institution'] as String?,
      studentNumber: json['student_number'] as String?,
      yearOfStudy: json['year_of_study'] as String?,
      dob: json['dob'] != null ? DateTime.tryParse(json['dob'].toString()) : null,
      role: json['role'] as String? ?? 'student',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'surname': surname,
        'institution': institution,
        'student_number': studentNumber,
        'year_of_study': yearOfStudy,
        'dob': dob?.toIso8601String(),
        'role': role,
      };

  StudentProfile copyWith({
    String? id,
    String? name,
    String? surname,
    String? institution,
    String? studentNumber,
    String? yearOfStudy,
    DateTime? dob,
    String? role,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      institution: institution ?? this.institution,
      studentNumber: studentNumber ?? this.studentNumber,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      dob: dob ?? this.dob,
      role: role ?? this.role,
    );
  }
}
