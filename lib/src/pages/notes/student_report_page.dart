import 'package:flutter/material.dart';

class StudentReportPage extends StatelessWidget {
  final String reportText;

  StudentReportPage({required this.reportText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte de IA'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            reportText,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ),
    );
  }
}
