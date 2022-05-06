import 'package:click/parser/parser.dart';
import 'package:flutter/material.dart';
import 'package:touchable/touchable.dart';

import 'paints/path_painter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final svgPath = "images/ng.svg";
  List<Path> paths = [];
  Path _selectedPath;
  double heightSvg;
  double widthSvg;

  @override
  void initState() {
    parseSvgToPath();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vibes n Insha'allah")),
      body: Center(
        child: SizedBox(
          width: double
              .infinity, // full screen here, you can change size to see different effect
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CanvasTouchDetector(
              builder: (context) => CustomPaint(
                painter: PathPainter(
                  context: context,
                  paths: paths,
                  curPath: _selectedPath,
                  onPressed: (curPath) {
                    setState(() {
                      _selectedPath = curPath;
                    });
                  },
                  height: heightSvg,
                  width: widthSvg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void parseSvgToPath() {
    SvgParser parser = SvgParser();
    parser.loadFromFile(svgPath).then((value) {
      setState(() {
        paths = parser.getPaths();
        heightSvg = parser.svgHeight;
        widthSvg = parser.svgWidth;
      });
    });
  }
}
