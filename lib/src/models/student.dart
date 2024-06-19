class Student {
  final String name;
  final int id;

  Student({required this.name, required this.id});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['name'],
      id: json['id'],
    );
  }
}
