import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'studentnote_page.dart';
import '../../models/student.dart';

class ChildrenPage extends StatefulWidget {
  final String mobile;

  ChildrenPage({required this.mobile});

  @override
  _ChildrenPageState createState() => _ChildrenPageState();
}

class _ChildrenPageState extends State<ChildrenPage> {
  List<Student> children = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChildren();
  }

  Future<void> fetchChildren() async {
    final String mobile =
        '12345678'; // Reemplaza esto con el número de móvil del padre
    final String url =
        'http://ec2-18-226-181-124.us-east-2.compute.amazonaws.com:3000/api/children?mobile=$mobile'; // Reemplaza 'tu-servidor' con la URL de tu servidor

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          children = data.map((json) => Student.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load children');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hijos'),
        backgroundColor: Colors.indigo,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: children.length,
                itemBuilder: (context, index) {
                  return buildChildCard(context, children[index]);
                },
              ),
            ),
    );
  }

  Widget buildChildCard(BuildContext context, Student child) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentGradesPage(child: child),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.indigo,
                child: Text(
                  child.name[0],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                radius: 30,
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'ID: ${child.id}',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.indigo),
            ],
          ),
        ),
      ),
    );
  }
}
