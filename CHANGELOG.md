## 0.1.0-2

* Fixed README screenshot URLs to use `raw.githubusercontent.com` for better compatibility with pub.dev external image proxy rendering.

## 0.1.0-1

* Improved rendering abstraction by introducing shared measure layout utilities used by `SheetMusicView` and `TablatureView`.
* Fixed fretboard tap mapping and marker positioning when using non-zero `startFret` ranges.
* Improved `CustomPainter.shouldRepaint` stability with value-based comparisons for lists/maps.
* Added value equality for core models (`Note`, `Measure`, `ChordPlacement`, `ChordDefinition`) and `FretboardStyle`.
* Added `ChordDefinition.effectiveStringMarkers` to support open-string marker inference from `fret: 0` placements.
* Updated example app chord tab layout to be more responsive on narrow screens.
* Updated README snippets and screenshot links to align with current API and documentation paths.

## 0.0.1

* Initial release.
