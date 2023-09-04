import 'package:flutter/material.dart';

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
import 'screens/screen1_navigation.dart';

void main() => runApp(const PHRoomNavigation());

// Definition einer benutzerdefinierten Farbpalette (in color.dart anpassbar)
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
  List<int> outputdijkstra = []; //Liste für Dijkstra-Algorithmus
  List<Color> pathColors = [];

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

  // Festlegung der Anfangsfarben für die Pfade
  pathColors = List<Color>.generate( //Festlegung der Farbe der Pfade
    SvgData.paths.length,
    (index) {
      String pathValue = SvgData.paths[index][2]; // Wert im Pfad
      if (pathValue == '0000') {
        return SvgData.paths[index][1]; // Pfad mit Wert '0000'
      } else {
        return Colors.transparent;
      }
    },
  );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void changeColors() { //bei drücken des Buttons werden die benötigten Pfade eingeblendet 
  // Aktualisieren der Pfadfarben basierend auf dem berechneten Dijkstra-Pfad
    setState(() {
      pathColors = List<Color>.generate(SvgData.paths.length, (index) {
        if (outputdijkstra.contains(int.parse(SvgData.paths[index][2]))) {
          return SvgData.paths[index][1]; // Undurchsichtige Farbe für Pfade in outputdijkstra
        } else if (SvgData.paths[index][2] != '0000') {
        return Colors.transparent; // Transparente Farbe für andere Pfade, die nicht '0000' sind
        } else {
          return pathColors[index];
        }
      });
    });
  }

  // String für Dropdown Buttons
  String selectedValueFrom = '20200'; // Standardauswahl (Wert, nicht Klartext)
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
                        //Navigationsbereich
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            //Dropdown Von
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
                            //Dropdown Bis
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
                            FilledButton( //Button Pfad anzeigen
                              onPressed: () 
                                {// Dijkstra
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
                            //Text('Start: $selectedValueFrom'),
                            //Text('Ziel: $selectedValueTo'),
                          ],
                        ),
                        Expanded(
                          child: Center(
                            child: InteractiveViewer( //Darstellung SVG
                              boundaryMargin: EdgeInsets.all(500),
                              minScale: 0.5, // Mindestzoom-Faktor
                              maxScale: 4.0, // Maximaler Zoom-Faktor
                              child: Container(
                                width: 500, //Bildbreite
                                height: 1000, //Bildhöhe
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
                // Hier kann der Inhalt für Seite 2 hinzugefügt werden
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavyBar( 
            //Bottom-Navigation
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
      ..strokeWidth = 5.0;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
