import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './children_pages.dart';
import '../../models/student.dart';
import './student_report_page.dart';

class StudentGradesPage extends StatefulWidget {
  final Student child;

  StudentGradesPage({required this.child});

  @override
  _StudentGradesPageState createState() => _StudentGradesPageState();
}

class _StudentGradesPageState extends State<StudentGradesPage> {
  String selectedYear = '';
  String selectedTrimester = '';
  List<AcademicYear> academicYears = [];
  List<AcademicTerm> academicTerms = [];
  List<Grade> grades = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAcademicYears();
  }

  Future<void> fetchAcademicYears() async {
    final String url =
        'http://ec2-18-226-181-124.us-east-2.compute.amazonaws.com:3000/api/academic_years';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          academicYears =
              data.map((json) => AcademicYear.fromJson(json)).toList();
          if (academicYears.isNotEmpty) {
            selectedYear = academicYears[0].id.toString();
            fetchAcademicTerms(selectedYear);
          }
        });
      } else {
        throw Exception('Failed to load academic years');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchAcademicTerms(String academicYearId) async {
    final String url =
        'http://ec2-18-226-181-124.us-east-2.compute.amazonaws.com:3000/api/academic_terms?academic_year_id=$academicYearId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          academicTerms =
              data.map((json) => AcademicTerm.fromJson(json)).toList();
          if (academicTerms.isNotEmpty) {
            selectedTrimester = academicTerms[0].id.toString();
            fetchGrades();
          }
        });
      } else {
        throw Exception('Failed to load academic terms');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchGrades() async {
    final String studentId = widget.child.id.toString();
    final String url =
        'http://ec2-18-226-181-124.us-east-2.compute.amazonaws.com:3000/api/studentgrades?student_id=$studentId&academic_year_id=$selectedYear&term_id=$selectedTrimester';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          grades = data.map((json) => Grade.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load grades');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> generateAIReport() async {
    final String studentId = widget.child.id.toString();
    final String url =
        'http://ec2-18-226-181-124.us-east-2.compute.amazonaws.com:4322/report/$studentId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final String reportText = response.body;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentReportPage(reportText: reportText),
          ),
        );
      } else {
        throw Exception('Failed to generate report');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar el reporte')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notas de ${widget.child.name}'),
        backgroundColor: Colors.indigo,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.child.name,
                    style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo),
                  ),
                  SizedBox(height: 10.0),
                  _buildDropdown(
                    'Selecciona el Año',
                    selectedYear,
                    academicYears,
                    (String? newValue) {
                      setState(() {
                        selectedYear = newValue!;
                        selectedTrimester =
                            ''; // Resetea el trimestre seleccionado
                        fetchAcademicTerms(selectedYear);
                      });
                    },
                  ),
                  SizedBox(height: 10.0),
                  _buildDropdown(
                    'Selecciona el Trimestre',
                    selectedTrimester,
                    academicTerms,
                    (String? newValue) {
                      setState(() {
                        selectedTrimester = newValue!;
                        fetchGrades();
                      });
                    },
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Notas de $selectedTrimester $selectedYear',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: grades.length,
                      itemBuilder: (context, index) {
                        return buildGradeCard(grades[index]);
                      },
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: generateAIReport,
                      child: Text('Generar Reporte con IA'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.indigo,
                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        textStyle: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDropdown<T>(String label, String value, List<T> items,
      ValueChanged<String?> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: value.isNotEmpty ? value : null,
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down, color: Colors.indigo),
        iconSize: 24,
        underline: SizedBox(),
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((T item) {
          String displayValue;
          String itemValue;
          if (item is AcademicYear) {
            displayValue = item.name;
            itemValue = item.id.toString();
          } else if (item is AcademicTerm) {
            displayValue = item.name;
            itemValue = item.id.toString();
          } else {
            displayValue = item.toString();
            itemValue = item.toString();
          }
          return DropdownMenuItem<String>(
            value: itemValue,
            child: Text(displayValue),
          );
        }).toList(),
      ),
    );
  }

  Widget buildGradeCard(Grade grade) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  grade.subject,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.indigo,
                  ),
                ),
                Icon(
                  Icons.school,
                  color: Colors.indigo,
                )
              ],
            ),
            SizedBox(height: 5),
            Text(
              'Nota: ${grade.grade}',
              style: TextStyle(
                color: grade.grade >= 6 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AcademicYear {
  final int id;
  final String name;

  AcademicYear({required this.id, required this.name});

  factory AcademicYear.fromJson(Map<String, dynamic> json) {
    return AcademicYear(
      id: json['id'],
      name: json['name'],
    );
  }
}

class AcademicTerm {
  final int id;
  final String name;

  AcademicTerm({required this.id, required this.name});

  factory AcademicTerm.fromJson(Map<String, dynamic> json) {
    return AcademicTerm(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Grade {
  final String subject;
  final String teacher;
  final double grade;

  Grade({required this.subject, required this.teacher, required this.grade});

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      subject: json['subject_id'][1], // Ajusta según el formato de tu JSON
      teacher:
          '', // Añade lógica para obtener el nombre del profesor si está disponible
      grade: json['grade'].toDouble(), // Asegúrate de que el valor es un double
    );
  }
}
