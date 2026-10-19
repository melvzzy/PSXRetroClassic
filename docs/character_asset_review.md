# Full-Body-Kandidaten: Entscheidung vor einer Integration

**Für die Ego-Hand-/Waffendarstellung Drillimpact behalten. Keiner der beiden
Ganzkörperkandidaten liefert dafür einen klaren Qualitätsgewinn.** Als spätere
sichtbare Körperbasis würde ich optisch `male_casual` weiterverfolgen; noch keine
Integration. Simple ist modularer und besitzt den besseren Zeigefingeransatz,
seine Handgeometrie bleibt aber ebenfalls zu grob für überzeugende Nahaufnahmen.

## Tatsächlich geprüfte Dateien

| | Simple Character PSX / JashiPSX | male_casual / Vinrax |
| --- | --- | --- |
| Export | GLB; zusätzlich FBX binär geprüft | FBX mit lokalem PNG |
| Gemessene Dreiecke in Godot | 762: Arme 214, Körper 324, Kopf 224 | 952; Hersteller nennt 954 |
| Texturen | 256×256 für gesamten Körper, extra Glasmaterial | 256×256 für gesamten Körper |
| Mesh-Aufteilung | Kopf, Körper und Arme getrennt | Ein skinnbares Körpermesh |
| Tatsächliche Quellhöhe in Skin-Pose | ca. 2,052 m | ca. 1,726 m |
| Preview-Kalibrierung | 1,80 m, Faktor ca. 0,877 | 1,80 m, Faktor ca. 1,043 |
| Skelett | 64 Bones, inkl. Hand-/Finger-/Fußketten | 25 Bones, einfaches Humanoid-Rig |
| Exportierte Animationen | keine, auch im FBX keine Stacks/Curves | keine Stacks/Curves/Clips |

Die Bilder und Mengen wurden unter Godot 4.6.3 geprüft. Beide liefern gültige
Skin-Bindings und auflösbare Gewichte. Das beweist keine fertige Waffenhaltung.
Bei Simple gehören .blend/.blend1 zum ZIP; ohne Blender wurden eventuell nur in
Blender gespeicherte Actions nicht geprüft. Die nutzbaren Godot-Exporte haben
keine Idle-/Walk-/Run-/Fire-/ADS-/Reload-Clips.

## Hände und tatsächlich nutzbare Gelenke

Simple: Schulter/Oberarm/Unterarm/Hand plus nominal drei Gelenke pro Finger,
Palm-Bones und Daumenketten. Der rechte Zeigefinger hat echte gewichtete Vertices
an allen drei Gelenken und bewegt sich in der reversiblen Probe sichtbar. Die
Ringfingerketten haben **keinen direkten Hautgewichtseinfluss**; mehrere weitere
Fingersegmente sind ebenfalls nicht direkt gewichtet. Die drei übrigen Finger
erscheinen in der Nahaufnahme als grob zusammengefasste Fläche. 64 Bones dürfen
nicht mit fünf vollständig unabhängig modellierten Fingern verwechselt werden.

Male: Handgelenke, je zwei Daumen-Bones und `f_middle.01.L/R`. Letztere verformen
je eine gemeinsame Fingergruppe; keine eigene Zeigefingerkette. Die vier
Daumen-Bones besitzen keine direkten gewichteten Vertices/gewichteten Nachfolger.
Eine saubere getrennte Triggerfinger-/Daumenhaltung lässt sich damit nicht nur
über vorhandene Bones herstellen. Das Modell sieht aus der Körperdistanz gut
aus, die Handsilhouette ist aus FPS-Nähe blockartig.

Eine einfache grobe Haltepose wäre mit beiden Handgelenken/Unterarmen grundsätzlich
autorenbar. Pistolengriff, Gewehrstützhand, ADS, Magazinkontakt und Reload wären
aber neue, waffenspezifische Arbeit. Davon wurde nichts eingebaut oder behauptet.
Beide Körperrigs erlauben das spätere Animieren von Beinen/Wirbelsäule; ohne Clips
oder geprüftes Retargeting gibt es jetzt keine lauffertige Bewegung.

## Vergleich mit bestehendem Projekt

Male mit dunklem Shirt/Jeans und relativ natürlichen Proportionen passt optisch
besser zu neutralen Waffen, Industriehof und gedämpftem Naturboden. Simple wirkt
mit Brille, weitem Shirt, Shorts und dünnen Gliedmaßen ziviler/stilisierter.
Beide passen in die Low-Poly-/256er-Ästhetik, ersetzen aber keine Ausrüstung oder
passende zukünftige Bekleidung.

Drillimpact besitzt bereits einen FP-spezifischen Arm-Mesh mit 1.176 Dreiecken,
512er Hand-/Armtexturen, 52 Bindings und 18 geprüften exportierten Clips. Das ist
mehr Nahbereichsdetail als Simple mit 214 Arm-Dreiecken und einem 256er Ganzkörper-
atlas; bei Male müssen Kopf/Arme aus dem einzelnen Mesh erst separat vorbereitet
werden. Die Namen `hand.R` machen Simple nicht automatisch mit Drillimpact oder
den bestehenden Makarov-Posen kompatibel: Proportionen, Bind-Pose und Bone-Achsen
müssten geprüft/angepasst werden.

## Empfehlung und nächster Schritt

1. Aktuelle weapon-only FPS-Grundlage und optionales Drillimpact unverändert lassen.
2. Falls sichtbarer Körper wirklich als Nächstes nötig ist: Male als Körper-
   Kandidat in einem separaten DCC-/Rig-Test weiterverfolgen. Kopf-/Armtrennung
   und ein sauberer einzelner Bewegungsclip müssten erst vorbereitet werden.
3. Für FPS-Hände Drillimpact weiterverwenden. Eine Kombination benötigt später
   eine bewusste Anschluss-/Materiallösung, keine automatische Rig-Übernahme.
   Simple bleibt die Reserve, wenn Modularität und editierbarer Zeigefinger
   wichtiger als Kleidung/Proportionen sind; zusätzliche Gewichtungsarbeit nötig.

## Vorschau und Lizenzgrenzen

`scenes/previews/character_comparison.tscn` öffnen und **F6** drücken.
**0** beide, **1/2** Körper, **3/4** rechte Hand, **RMB ziehen** Orbit,
**Mausrad** Zoom, **B** reversible Fingergelenk-Probe, **Esc** schließen.
Die Probe ist keine Animation und keine Waffenhaltung. Keine IK-/Gameplay-
Komponenten, keine Waffen angebunden. F5 bleibt der Außenposten.

Quellen/Lizenznachweise und Wiederherstellung des nur lokal enthaltenen
Simple-Modells: [Asset-README](../assets/source/character_candidates/README.md).
Vinrax verlangt Credit. Simple erlaubt Spielnutzung, verbietet Rohdatenweitergabe;
seine Originaldateien sind daher in Git ausgeschlossen. Originalarchive bleiben
unverändert; weder riggende Quelldateien noch Texturen wurden überschrieben.


## Verifikation

Godot **4.6.3.stable.official.7d41c59c4**, Forward+/Vulkan/RTX 5060 Ti.
Import, grafischer Hauptszenenstart und vollständiger Runner: **648 Checks**,
kein Fehler. Charakter-Grafiktest: **26 Checks / sieben Aufnahmen**, inklusive
Handnahansichten und sichtbarer Probe-Verformung. Fehlende lokale Simple-Datei
separat mit elf Checks und explizitem SKIP fehlerfrei geprüft; danach wiederhergestellt.
Nur bekannte Windows-Zertifikatsspeicher-Meldung. Source-Originale per SHA-256
unverändert; keine Gameplay-Datei, Waffe oder Umgebung geändert. Keine Aussage
über einen praktisch getesteten Pistolen-/Gewehrgriff oder Waffenanimationen:
diese wurden ausdrücklich nicht integriert.
