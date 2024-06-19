import 'package:flutter/material.dart';
import 'package:movilsw2/src/pages/home/home_page.dart';
import 'package:provider/provider.dart';
import 'package:movilsw2/src/viewmodels/auth_viewmodel.dart';
import 'package:movilsw2/src/Pages/login/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

// Manejar mensajes en segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Colegio ABC',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        home: WelcomePages(),
      ),
    );
  }
}

class WelcomePages extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePages> {
  PageController _pageController = PageController(initialPage: 0);
  int currentPage = 0;

  @override
  void initState() {
    super.initState();

    // Suscribirse a un tema para recibir notificaciones
    FirebaseMessaging.instance.subscribeToTopic('all');

    // Manejar notificaciones cuando la aplicación está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    // Manejar notificaciones cuando la aplicación se abre desde una notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
    });

    // Verificar si la aplicación fue abierta desde una notificación
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from notification: ${message.notification}');
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      currentPage = page;
    });
  }

  Widget buildPageView() {
    return PageView(
      controller: _pageController,
      onPageChanged: onPageChanged,
      children: <Widget>[
        makePage(
          image: 'assets/img/welcome_image_1.jpg',
          title: 'Controla la Asistencia',
          description: 'Lleva un registro preciso y detallado de la asistencia de los estudiantes.',
        ),
        makePage(
          image: 'assets/img/welcome_image_2.jpg',
          title: 'Gestiona las Notas',
          description: 'Administra y consulta las calificaciones de los estudiantes fácilmente.',
        ),
        makePage(
          image: 'assets/img/welcome_image_3.jpg',
          title: 'Mejora la Comunicación',
          description: 'Facilita la comunicación entre profesores, estudiantes y padres de familia.',
        ),
      ],
    );
  }

  Widget makePage({required String image, required String title, required String description}) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.6),
              Colors.black.withOpacity(0.2),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: [0.1, 0.4, 0.7],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < 3; i++) {
      indicators.add(
        i == currentPage
            ? buildIndicatorItem(true)
            : buildIndicatorItem(false),
      );
    }
    return indicators;
  }

  Widget buildIndicatorItem(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      height: isActive ? 12.0 : 8.0,
      width: isActive ? 12.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey,
        borderRadius: BorderRadius.circular(6.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          buildPageView(),
          Positioned(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buildIndicator(),
                ),
                SizedBox(height: 20.0),
                currentPage == 2
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text('Comenzar', style: TextStyle(fontSize: 18.0)),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
