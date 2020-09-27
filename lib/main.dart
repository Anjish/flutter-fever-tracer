import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:fever_tracer/routes/scan_page.dart';
import 'package:fever_tracer/routes/history_page.dart';

// void main() => runApp(MyApp());
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      title: 'Fever Tracer',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Fever Tracer'),
      routes: {
        "/scan": (_) => TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
        "/history": (_) => FaceDetctionPage(),
        "/facedet": (_) => FaceDetctionPage(),
        "/temp": (_) => FaceDetctionPage(),
      },
    ),
  );
} 


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ItemTile(Icons.remove_red_eye, 'Scan', Color(0XFF53CEDB), "/scan"),
            ItemTile(
                Icons.person_outline, 'Face Detection', Color(0XFF2BD093), "/facedet"),
            ItemTile(Icons.history, 'History', Color(0XFF53CEDB), "/history"),
            ItemList(
                Icons.assessment, 'Temparature', Color(0XFF2BD093)),
          ],
        ),
      ),
    );
  }
}

class ItemTile extends StatelessWidget {
  final icon;
  final String name;
  final tileColor;
  final String route;
  const ItemTile(this.icon, this.name, this.tileColor, this.route);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.deepPurple,
          ),
          title: Text(name),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            color: Colors.deepPurple,
          ),
          onTap: () {
            Navigator.pushNamed(context, route);
          },
        ),
      ),
    );
  }
}

class ItemList extends StatelessWidget {
  final icon;
  final String name;
  final tileColor;
  const ItemList(this.icon, this.name, this.tileColor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.deepPurple,
          ),
          title: Text(name),
          subtitle: Text('Sub'),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            color: Colors.deepPurple,
          ),
          onTap: () {},
        ),
      ),
    );
  }
}
