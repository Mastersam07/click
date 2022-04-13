import 'package:click/parser/parser.dart';
import 'package:flutter/material.dart';

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
  List<Path> _selectedPaths;
  final svgPath = "images/ng.svg";
  List<Path> paths = [];

  @override
  void initState() {
    _selectedPaths = [];
    parseSvgToPath();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vibes n Insha'allah")),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.5, // full screen here, you can change size to see different effect
              height: MediaQuery.of(context).size.height * 0.5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomPaint(
                  painter: PathPainter(
                    context: context,
                    paths: paths,
                    selectedPath: _selectedPaths,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 70,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPaths.contains(paths[index])
                              ? _selectedPaths.remove(paths[index])
                              : _selectedPaths.add(paths[index]);
                        });
                      },
                      child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _selectedPaths.contains(paths[index])
                                  ? Colors.green
                                  : Colors.grey),
                          child: Text(index.toString())),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 8);
                  },
                  itemCount: paths.length,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void parseSvgToPath() {
    SvgParser parser = SvgParser();
    parser.loadFromFile(svgPath).then((value) {
      setState(() {
        paths = parser.getPaths();
      });
    });
  }
}
