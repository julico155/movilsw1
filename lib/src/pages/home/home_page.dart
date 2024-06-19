import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../pagos/pagos_page.dart';
import '../notes/children_pages.dart';

class HomePage extends StatefulWidget {
  final String email;
  final String username;

  HomePage({required this.email, required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Announcement>> announcements;

  @override
  void initState() {
    super.initState();
    announcements = fetchAnnouncements();
  }

  Future<List<Announcement>> fetchAnnouncements() async {
    final response = await http.get(Uri.parse(
        'http://ec2-18-226-181-124.us-east-2.compute.amazonaws.com:3000/api/announcements')); // Reemplaza con la URL correcta

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Announcement.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load announcements');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página Principal'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(widget.username),
              accountEmail: Text(widget.email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  widget.username[0],
                  style: TextStyle(fontSize: 40.0, color: Colors.blue),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Pagos'),
              onTap: () {
                // Acción para la opción de Pagos
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PaymentPage(mobile: widget.username)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.grade),
              title: Text('Notas'),
              onTap: () {
                // Acción para la opción de Notas
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChildrenPage(mobile: widget.username)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notificaciones'),
              onTap: () {
                // Acción para la opción de Notificaciones
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configuración'),
              onTap: () {
                // Acción para la opción de Configuración
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Cerrar Sesión'),
              onTap: () {
                // Acción para cerrar sesión
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Bienvenido, ${widget.username}',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Text(
              'Correo: ${widget.email}',
              style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
            ),
            SizedBox(height: 20.0),
            Text(
              'Avisos',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: FutureBuilder<List<Announcement>>(
                future: announcements,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay anuncios disponibles.'));
                  } else {
                    return ListView(
                      children: snapshot.data!.map((announcement) {
                        return buildNotificationCard(
                          title: announcement.subject,
                          content: announcement.content,
                          date: announcement.dateCreated,
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNotificationCard({
    required String title,
    required String content,
    required String date,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(content),
            SizedBox(height: 10),
            Text(
              date,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward, color: Colors.blue),
      ),
    );
  }
}

class Announcement {
  final int id;
  final String subject;
  final String content;
  final String dateCreated;

  Announcement({
    required this.id,
    required this.subject,
    required this.content,
    required this.dateCreated,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      subject: json['subject'],
      content: json['content'],
      dateCreated: json['date_created'],
    );
  }
}
