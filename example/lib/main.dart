import 'package:flutter/material.dart';
import 'package:tenplum_music/tenplum_music.dart';

void main() {
  runApp(const TenplumMusicExampleApp());
}

class TenplumMusicExampleApp extends StatefulWidget {
  const TenplumMusicExampleApp({super.key});

  @override
  State<TenplumMusicExampleApp> createState() => _TenplumMusicExampleAppState();
}

class _TenplumMusicExampleAppState extends State<TenplumMusicExampleApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tenplum Music Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5), brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: ExampleDashboard(
        onToggleTheme: () {
          setState(() {
            _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
          });
        },
      ),
    );
  }
}

class ExampleDashboard extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const ExampleDashboard({super.key, required this.onToggleTheme});

  List<Measure> _buildMockScaleMeasures() {
    return [
      Measure(
        number: 1,
        notes: [
          Note(pitch: Pitch.d4, string: 5, fret: 5, duration: NoteDuration.quarter, startBeat: 0.0),
          Note(pitch: Pitch.e4, string: 4, fret: 2, duration: NoteDuration.quarter, startBeat: 1.0),
          Note(pitch: Pitch.f4, string: 4, fret: 3, duration: NoteDuration.quarter, startBeat: 2.0),
          Note(pitch: Pitch.g4, string: 4, fret: 5, duration: NoteDuration.quarter, startBeat: 3.0),
        ],
      ),
      Measure(
        number: 2,
        notes: [
          Note(pitch: Pitch.a4, string: 3, fret: 2, duration: NoteDuration.quarter, startBeat: 0.0),
          Note(pitch: Pitch.b4, string: 3, fret: 4, duration: NoteDuration.quarter, startBeat: 1.0),
          Note(pitch: Pitch.c5, string: 2, fret: 1, duration: NoteDuration.quarter, startBeat: 2.0),
          Note(pitch: Pitch.d5, string: 2, fret: 3, duration: NoteDuration.quarter, startBeat: 3.0),
        ],
      ),
    ];
  }

  // Mock Chord definitions
  ChordDefinition _buildDm7Chord() {
    return const ChordDefinition(
      name: 'Dm7',
      startFret: 1,
      placements: [
        ChordPlacement(string: 4, fret: 0), // Open D
        ChordPlacement(string: 3, fret: 2, finger: 2),
        ChordPlacement(string: 2, fret: 1, finger: 1),
        ChordPlacement(string: 1, fret: 1, finger: 1),
      ],
      stringMarkers: [ChordStringMarker.muted, ChordStringMarker.muted, ChordStringMarker.none, ChordStringMarker.none, ChordStringMarker.none, ChordStringMarker.none],
    );
  }

  ChordDefinition _buildCmaj7Chord() {
    return const ChordDefinition(
      name: 'Cmaj7',
      startFret: 1,
      placements: [ChordPlacement(string: 5, fret: 3, finger: 3), ChordPlacement(string: 4, fret: 2, finger: 2), ChordPlacement(string: 3, fret: 0), ChordPlacement(string: 2, fret: 0), ChordPlacement(string: 1, fret: 0)],
      stringMarkers: [
        ChordStringMarker.muted, // String 6
        ChordStringMarker.none,
        ChordStringMarker.none,
        ChordStringMarker.none,
        ChordStringMarker.none,
        ChordStringMarker.none,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Measure> measures = _buildMockScaleMeasures();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tenplum Music Lab Examples'),
          centerTitle: true,
          actions: [IconButton(icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode), onPressed: onToggleTheme)],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.music_note), text: 'Sheet Music'),
              Tab(icon: Icon(Icons.linear_scale), text: 'Tablature'),
              Tab(icon: Icon(Icons.grid_on), text: 'Fretboard'),
              Tab(icon: Icon(Icons.album), text: 'Chords'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TabBarView(
            children: [
              Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('SheetMusicView (D Doric Scale)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        Container(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          padding: const EdgeInsets.all(16.0),
                          child: SheetMusicView(measures: measures, lineColor: isDark ? Colors.white70 : Colors.black87, noteColor: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Tablature View
              Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('TablatureView (Aligned & Responsively Wrapped)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        Container(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          padding: const EdgeInsets.all(16.0),
                          child: TablatureView(measures: measures, lineColor: isDark ? Colors.white70 : Colors.black87, numberColor: isDark ? Colors.white : Colors.black87, backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Fretboard View
              Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('CustomFretboard (Interactive scale preview - Tap Notes!)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        CustomFretboard(
                          highlightedNotes: const ['D', 'E', 'F', 'G', 'A', 'B', 'C'],
                          rootNote: 'D',
                          noteDegrees: const {'D': 'R', 'E': '2', 'F': 'b3', 'G': '4', 'A': '5', 'B': '6', 'C': 'b7'},
                          showDegrees: true,
                          onNoteTapped: (note, string, fret) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Note: $note | String: $string | Fret: $fret', style: const TextStyle(fontWeight: FontWeight.bold)),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          },
                          style: FretboardStyle(markerColor: isDark ? const Color(0xFF4F46E5) : const Color(0xFF6366F1), glowColor: const Color(0xFF10B981)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Chord Diagram View
              Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('ChordDiagramView', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              padding: const EdgeInsets.all(16.0),
                              child: ChordDiagramView(chord: _buildDm7Chord(), lineColor: isDark ? Colors.white70 : Colors.black87, textColor: isDark ? Colors.white : Colors.black87, dotColor: const Color(0xFFEF4444)),
                            ),
                            Container(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              padding: const EdgeInsets.all(16.0),
                              child: ChordDiagramView(chord: _buildCmaj7Chord(), lineColor: isDark ? Colors.white70 : Colors.black87, textColor: isDark ? Colors.white : Colors.black87, dotColor: const Color(0xFF4F46E5)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
