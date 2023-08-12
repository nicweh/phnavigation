//import packages
import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:dijkstra/dijkstra.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

//import documents
import 'color.dart';
import 'svg_data/svg_gebeaude2.dart';
import 'widget/dijkstra/namevaluemap.dart';
import 'widget/dijkstra/shortest_path.dart';

void main() => runApp(const PHRoomNavigation());

//custom color theme, edit in color.dart
ThemeData meinBasisTheme() {
  final basisTheme = ThemeData.light();
  return basisTheme.copyWith(
    primaryColor: meinePrimFarbe,
    primaryColorDark: meinePrimDunke,
    primaryColorLight: meinePrimLight,
    scaffoldBackgroundColor: meineSekuFarbe,
  );
}

class PHRoomNavigation extends StatefulWidget {

  @override
  const PHRoomNavigation({super.key});

  State<PHRoomNavigation> createState() => _PHRoomNavigationState();
}

class _PHRoomNavigationState extends State<PHRoomNavigation> {
  int _currentIndex = 0;
  late PageController _pageController;
  List<int> outputdijkstra = [];
  List<Color> pathColors = [];

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    pathColors = List<Color>.generate(
      SvgData.paths.length,
      (index) {
        if (index == 0) {
          return SvgData.paths[index][1]; // Erster Pfad nicht transparent
        } else {
          return Colors.transparent; // Andere Pfade transparent
        }
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void changeColors() {
    setState(() {
      pathColors = List<Color>.generate(SvgData.paths.length, (index) {
        if (outputdijkstra.contains(int.parse(SvgData.paths[index][2]))) {
          return SvgData.paths[index][1]; // Undurchsichtige Farbe für Pfade in outputdijkstra
        } else {
          return Colors.transparent; // Transparente Farbe für andere Pfade
        }
      });
    });
  }

  bool showBorder = false; //später entfernen

  void toggleBorder() { //später entfernen
      setState(() {
        showBorder = !showBorder;
      });
    }

// String für Dropdown Buttons
  String selectedValueFrom = '20200'; // Standardauswahl hier kommt die die zweite Zahl hinein und nicht der Klartext
  String selectedValueTo = '20200'; // Standardauswahl

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: "PH Navi",
      theme: meinBasisTheme(),
      home: Scaffold(
        appBar: new AppBar(centerTitle: true, title: const Text("PH Navi")),
        body: SizedBox.expand(
          //Inhaltsbereich
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            //Children hier können mehrere Container untereinander gesetzt werden
            children: [
              //Seite 1
              Container(
                color: meineSekuDunke,
                child: 
                  Center(
                      child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            //Dropdown
                            DropdownButton<String>(
                              value: selectedValueFrom,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedValueFrom = newValue!;
                                });
                              },
                              items: nameValueMap.keys.map((String key) {
                                return DropdownMenuItem<String>(
                                  value: nameValueMap[key],
                                  child: Text(key),
                                );
                              }).toList(),
                            ),
                            const SizedBox(width: 20),
                            //dropdown
                            DropdownButton<String>(
                              value: selectedValueTo,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedValueTo = newValue!;
                                });
                              },
                              items: nameValueMap.keys.map((String key) {
                                return DropdownMenuItem<String>(
                                  value: nameValueMap[key],
                                  child: Text(key),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            FilledButton(
                              onPressed: () 
                                {// Dein Dijkstra-Code hier
                                  int from = int.parse(selectedValueFrom);
                                  int to = int.parse(selectedValueTo);
                                  outputdijkstra = Dijkstra.findPathFromGraph(graph, from, to).map((dynamic value) => value as int).toList();
                                  //outputdijkstra = Dijkstra.findPathFromGraph(graph, from, to); //Generierter Pfad in Form [Start, Knoten1, Knoten2, Ziel]
                                  changeColors ();
                                  print("output:");
                                  print(outputdijkstra);
                                },
                              child: const Text('Starten')
                            ),
                            Text('Start: $selectedValueFrom'),
                            Text('Ziel: $selectedValueTo'),
                          ],
                        ),
                        Expanded(
                          child: Center(
                            child: InteractiveViewer(
                              boundaryMargin: EdgeInsets.all(20),
                              minScale: 0.5, // Mindestzoom-Faktor
                              maxScale: 5.0, // Maximaler Zoom-Faktor
                              child: Container(
                                width: 400,
                                height: 400,
                                child: Stack(
                                  children: List.generate(SvgData.paths.length, (index) {
                                    return CustomPaint(
                                      painter: MyPainter(
                                        parseSvgPath(SvgData.paths[index][0] as String),
                                        pathColors[index],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ), 
                      ],
                      ),
                    ),
              ),
              //Seite 2
              Container(
                color: meineSekuDunke,
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavyBar(
            selectedIndex: _currentIndex,
            backgroundColor: meinePrimLight,
            onItemSelected: (index) {
              setState(() {
                _pageController.jumpToPage(index);
              });
            },
            items: <BottomNavyBarItem>[
              BottomNavyBarItem(
                  title: Text("Navigation"),
                  icon: Icon(Icons.assistant_direction, color: meinePrimFarbe),
                  activeColor: meinePrimDunke),
              BottomNavyBarItem(
                  title: Text("Pläne"),
                  icon: Icon(Icons.map_outlined, color: meinePrimFarbe),
                  activeColor: meinePrimFarbe),
            ]),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final Path path;
  final Color color;

  MyPainter(this.path, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 4.0;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}