# Kleiner spielbarer Wartungshof

F5 lädt über `scenes/startup.tscn` direkt `scenes/environments/outdoor_test.tscn`.
Die Startwaffe bleibt AS Val; 1–8 wechseln wie bisher. Startup-Exporte Test Weapon,
Show Arms und Use Imported Visuals bleiben erhalten. Keine neue Waffenlogik,
keine zusätzlichen Gameplay-Skripte, keine Terrain-/Inventar-/Manager-Systeme.

## Aufbau

Etwa 40×40 m ebener Kernhof mit einem zusätzlich acht Meter breiten, leicht
erhöhten östlichen Wartungsstreifen (begehbar insgesamt ca. 54×40 m). Drei anschließende 8-m-Asphalt-
module führen vom geschlossenen Zugangstor zum Arbeitsbereich. Links steht die
Halle, rechts der offene Cargo-Unterstand. Generator und E-Schalter stehen
abseits des Durchgangs; Klimagerät sitzt an der Hallenwand. Kisten und Fässer
liegen im Arbeitsbereich. Wenige Baum-/Buschgruppen begrenzen die Freiflächen,
Gras bleibt am Rand. Alle 14 bereits importierten Asset-Typen sind enthalten;
drei zusätzliche kleine CC0-Werkstattmodelle ergänzen den Cargo. Drei ausgewählte CC0-Oberflächen
aus bereits gesichteten Screaming-Brain-Studios-Paketen ergänzen den Boden.

Generator und feste Props haben vereinfachte passende Box-Kollisionen.
Die statische Halle nutzt ihre Low-Poly-Geometrie als Dreieckskollision, damit
der vorstehende Ladevorplatz keine unsichtbare Box-Barriere erzeugt.
Die Halle bleibt eine geschlossene Außenhülle. Der Cargo besitzt eine eigene
Boden-/Seiten-/Dachhülle mit **beiden Enden offen** und kurzen flachen Schwellen-
rampen; normale Bewegung genügt zum Durchqueren. Nur Baumstämme blockieren,
Laub/Büsche/Gras bleiben durchlässig. Sichtbare Hofmauern samt geschlossenem
Zugangstor und eine echte Zaunbegrenzung am östlichen Rand verhindern Abstürze. Keine unsichtbare Weltgrenze.

Industrial-Holzkiste, Street-Fass und Street-Kiste verwenden RigidBody3D,
einfache Box-Kollisionen, 5/8/5 kg und den bisherigen Layer-/Maskenvertrag (2/7).
Ihre feste Vorschaukopie ist im Spiel verborgen. Schüsse bewegen die Props
über die unveränderten physikalischen Waffenimpulse. Der vorhandene E-Schalter
sitzt am Generator; Schießtafel und massiver Kugelfang stehen an der Nordseite.
Das ist ein Funktionstest, keine neue Generator-/Türmechanik.

Ein schlichter Godot-Himmel, neutrales Umgebungslicht, leicht warmes Sonnenlicht
und Richtungsschatten schaffen die Tagesbeleuchtung. Kein Fog, Postprocessing,
Retrofilter oder Kamerawackeln. Forward+ und 4× MSAA bleiben erhalten.

## Erhaltene Testfläche und Prüfbarkeit

`scenes/fps_test_fallback.tscn` bewahrt die bisherige Startup-Komposition mit
ursprünglichen Positionen, Licht und AS-Val-Auswahl. **Öffnen + F6** startet sie.
`scenes/fps_test.tscn` wurde ebenfalls nicht verändert. Die vorhandenen
positionsabhängigen Regressionen laden jetzt ausdrücklich diesen Fallback;
ihre Prüfungen wurden nicht entfernt oder an die neue Geometrie aufgeweicht.
Neue Outdoor-Prüfungen laden dagegen ausdrücklich den **echten F5-Startup**.
Die separate Asset-Vorschau bleibt unter `scenes/previews/environment_preview.tscn`.

Die importierten Visual-Instanzen und Materialien stehen unter
`scenes/environments/outdoor_assets.tscn`, Platzierung/Kollision/HUD/Player in
`outdoor_test.tscn`. Keine Platzierungslogik läuft pro Frame. Vorhandene
Material- und Quelldaten bleiben unverändert; Quellen und Lizenzbedingungen:
[Asset-Nachweise](../assets/source/environment_candidates/README.md).
Insbesondere Industrial bleibt godgoldfear / CC BY 4.0; die Montage und neuen
Kollisionshüllen ändern diese Attribution nicht. Bei späterem Build Credits
und Lizenz-/Änderungshinweise mitliefern.

## Prüfung und Grenzen

`tests/run_checks.ps1 -Godot <Godot.exe>` prüft Import, F5, Fallback, bestehende
Regressionssuiten und `tests/outdoor_checks.gd`. Der neue Test prüft Spawn,
sichtbare gespeicherte Modelle, Straße, Sprung/Ducken, beide Cargo-Enden ohne
Sprung, geschlossene Hallenwand und sichtbare Grenze, Generator-E, alle acht
Waffen mit echten Zieltreffern/ADS/Reload-Start sowie Schussimpuls und Holster.
Grafiklauf mit `--script res://tests/outdoor_checks.gd -- --capture`; native
Bilder in `.godot/checks/outdoor/`. Endgültige Ergebnisse in `tests/README.md`.

Die Halle lässt sich nicht betreten, das Zugangstor ist fest geschlossen.
Cargo ist kein abgeschlossener Hideout, es fehlen Rückwand und Tür. Der Kernboden bleibt eben, die östliche Böschung steigt auf bis zu 1,2 m.
Die Boden-/Betontexturen wiederholen sich noch sichtbar; eigene einfache Felsen
und weich auslaufende Erdstreifen lockern die Ränder auf.
Physikprops nutzen bewusst einfache Boxformen, auch das Fass. Nahes Waffen- /
Wand-Clipping ist die bestehende Viewmodel-Grenze. Kein manueller FPS-Benchmark.

F5 manuell: Straße ablaufen, Halle umrunden, Cargo in beiden Richtungen betreten,
springen/ducken/sprinten; E am Generator; 1–8, ADS, Einzel-/schnelle Schüsse,
Reload/Wechsel/X und Munitionserhalt; Props beschießen; Esc/Alt-Tab/Recapture
und Beenden testen. Abschließend F6-Fallback und tatsächliche FPS prüfen.


## Erste kleine Erweiterung

Der Hof wurde nicht ersetzt. Zwei freie Durchgänge an der östlichen Seite
verbinden ihn zu einem kurzen Rundweg. Die mittlere Mauer ist als niedrige
Abgrenzung ausgebildet; am äußeren Rand stehen echte Metallpfosten und drei
kollidierende Querholme. Der Zaun wurde anschließend um sechs Meter nach außen versetzt; die vorherige
Waldkulisse ist dort jetzt eine kleine begehbare Lichtung. Dahinter bleibt nur
ein schmaler Vegetationshintergrund, keine weitere Spielkarte.

Die Böschung besteht aus einem kleinen, statisch gespeicherten Mesh mit
passender Dreieckskollision. Höhe 0–1,2 m, geringe Neigung, unveränderte
Bewegungslogik. Der Weg folgt denselben Stützpunkten, damit Bild und Kollision
übereinstimmen und keine Flächen flimmern. Es gibt keinen Terrain-Generator,
keine laufende Platzierungslogik und keine neuen Gameplay-Skripte.

Dunkler Erd-/Moosboden ersetzt die einfarbige Plattform. Ein Betonvorplatz
ordnet den Arbeitsbereich um Halle, Cargo und Generator. Abgetretene Zugänge,
ein kleiner Wegweiser, wenige Poller und ein Materiallager aus vorhandenen
Kisten geben den Flächen einen Zweck. Weitere Bäume, Büsche und Gras nutzen
nur die vorhandenen Modelle; Stammkollisionen bleiben außerhalb des Laufwegs.
Schattenreichweite und Normal-Bias wurden passend zum kleinen Bereich angepasst.
Kein Nebel, künstlicher PSX-Filter oder Postprocessing.

Zusätzlich übernommen: Grass_12, Grass_13 und Mat_Concrete_Gray_01, jeweils
256×256, mit Mipmaps und anisotroper Filterung für schräge Weltflächen.
Originale, beide CC0-Lizenztexte und Datei-/Archivzuordnung:
[Oberflächen-Nachweise](../assets/source/sbs_outpost_surfaces/README.md).
Die ursprünglichen Bilder wurden nicht verändert. Alle acht Waffen, HUD,
Interaktion, drei Physikprops und F5-Einstieg bleiben erhalten, ebenso der
alte F6-Fallback.

Neue Prüfung: `tests/outpost_expansion_checks.gd` läuft zusätzlich im Runner.
Sie geht den Rundweg mit normaler Bewegung ab, prüft Höhenkollision, beide
Durchgänge, Zaun und Textur-Mipmaps. Die ursprünglichen Outdoor-/Gunplay-Tests
laufen weiter. Captures unter `.godot/checks/expansion/` zeigen Ankunft,
Blick vom Weg zurück in den Hof, nördlichen Weg und Gesamtaufbau.
Manuell zusätzlich: beide Zugänge vor/zurück laufen, am Zaun springen/ducken,
Schüsse vom erhöhten Weg und Props/Randbereiche prüfen. Tatsächliche FPS
separat messen; kein manueller Benchmark wird durch die Renderprüfung ersetzt.


## Abschließende Ergänzung: Lichtung und Werkstatt

Der vorhandene Rundweg führt in eine sechs Meter breitere Lichtung mit den
bestehenden Bäumen/Büschen und sechs eigenen niedrigen Felsgruppen. Drei neu
zugängliche Bäume besitzen Stammkollisionen; der Waldstreifen hat nun eine
passende statische Bodenkollision. Alle Zaunpfosten und Querholme wurden gemeinsam
versetzt, die seitlichen Begrenzungen geschlossen. Kein neuer Terrain-Generator.

Der bereits begehbare Cargo dient als kleine Wartungswerkstatt: eine 2-m-Werkbank,
ein offenes Regal mit Lagerkiste, Hammer, Flaschen, Abfallbehälter und eine ruhige
warme Deckenleuchte. Der Mittelgang und beide offenen Enden bleiben frei. Die Halle
bleibt geschlossen; zusätzliche Innenräume würden neue Gebäudegeometrie benötigen.
Die Einrichtung ist statisch, der Generator-Schalter und die drei bisherigen
Physikprops funktionieren unverändert. Erdstreifen mit normaler Material-
Vertextransparenz mildern einzelne Vorplatzkanten; keine eigenen Shader/Filter.

Drei weitere Kkryy-CC0-Modelle und zwei SBS-CC0-Texturen wurden gezielt ausgewählt.
[Originaldateien, Maßkorrekturen und Lizenznachweise](../assets/source/outpost_workshop/README.md).
Fels-/Innenraumpacks mit fehlender Lizenz oder untersagter Rohdatenweitergabe
bleiben unimportiert. Keine Änderungen an Controller, Waffen, Projektsettings,
Fallback oder bestehenden Quellmodellen.

`tests/final_area_checks.gd` prüft die echte F5-Szene: Einrichtung/Texturen,
Werkbank-/Regalkollision, freie Verbindung zur Lichtung, äußere Zaunbegrenzung und
unskalierte konvexe Felskollisionen. Grafikmodus `-- --capture` speichert Werkstatt,
Lichtung und Übersicht in `.godot/checks/final_area/`. Diese automatisierten
Windows-Renderläufe ersetzen keinen längeren manuellen F5-Spieltest oder FPS-Test.
