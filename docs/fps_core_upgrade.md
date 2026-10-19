# FPS-Kern und Gunplay

Eine gemeinsame `TestFirearm` bleibt zuständig für Munition, Timer, Hitscan,
Impulse und Eingaben. Die vorhandenen acht Resource-Profile liefern jetzt auch
Feuermodus, ADS-Reaktion, Rückstoßerholung und maximalen Rückstoß. Es gibt kein
zweites Waffensystem, keinen zusätzlichen Manager und keine neue Eingabeaktion.

| Waffe | Modus | Abstand | ADS-Reaktion | Rückstoß pro Schuss |
| --- | --- | --- | --- | --- |
| Makarov | Einzelfeuer | 180 ms | 24 | 1,20° |
| AS Val | Automatisch | 75 ms | 21 | 0,85° |
| VSS | Einzelfeuer | 220 ms | 17 | 1,00° |
| SR-3 | Automatisch | 75 ms | 23 | 0,95° |
| M4A4 | Automatisch | 85 ms | 21 | 0,95° |
| EMP | Automatisch | 110 ms | 19 | 1,00° |
| MP40 | Automatisch | 120 ms | 20 | 0,90° |
| STG 44 | Automatisch | 105 ms | 18 | 1,15° |

Das sind veränderbare Testwerte. VSS bleibt bewusst kontrolliertes Einzelfeuer
mit den bisherigen offenen Visieren. Es gibt noch keinen Feuermodus-Umschalter.
ADS reduziert Rückstoß weiterhin auf 55 %. Mausbewegungen werden nicht geglättet.
Alle Treffer stammen weiterhin aus dem aktuellen Kamerastrahl vor dem neuen Kick.

## Bewegung und Darstellung

Bestehende Geschwindigkeiten, Boden-/Hangbehandlung, Kapselhöhen und direkte
Maussteuerung bleiben erhalten. Ein frischer Sprungdruck wird bis zu 100 ms vor
dem Landen gepuffert; beim Verlassen einer Kante gelten 80 ms Bodentoleranz.
Ducken und Fokuswechsel löschen den Puffer. OS-Tastenwiederholung erzeugt weder
neue Sprünge noch wiederholtes Schalterbedienen.

Der gemeinsame WeaponOnlyViewmodel bewegt nur die Waffe: maximal etwa 4 mm
Gehbewegung, eine profilabhängige diagonale Tragehaltung beim Sprint, Ausblenden der Bewegung beim
Zielen/Nachladen. Kein Kamera-Headbob oder Kamerawackeln ergänzt. Walk Motion
und Motion Response sind am Adapter konfigurierbar; die Tragepose steht im Profil. Im Stillstand bleibt die
Waffe ruhig. Der Placeholder folgt denselben Bewegungen.

Reload nutzt eine glatte, vom echten Reload-Fortschritt abhängige Absenk-/
Drehbewegung mit Rückkehr zur Ausgangslage. Magazine bleiben eingesetzt; dies ist
kein vorgetäuschter vollständiger Magazinwechsel. Vorhandene bewegliche Verschlüsse
reagieren weiter auf tatsächliche Schüsse. Holster/Draw und der abgesenkte Wechsel
bleiben erhalten. Beim Wechsel wird die vorherige Reload-Pose zurückgesetzt.
Die optionalen Makarov-Arme und Originalanimationen bleiben unverändert erhalten.

## Eingabesicherheit und Grenzen

Dauerfeuer startet ausschließlich durch ein akzeptiertes `_unhandled_input`-
Press-Event. Globaler Input-Zustand allein reicht nicht. Loslassen, Reload,
Wechsel, Holster, Fokusverlust und leeres Magazin stoppen den Feuerstoß. Nach
Reload/Draw/Recapture ist ein neuer Tastendruck nötig. Timer laufen in Physik;
pro Tick maximal ein Schuss, ohne nachträgliche Schusssalve bei Frame-Einbrüchen.
Bis zu ein Tick Restzeit wird zur gleichmäßigen Kadenz berücksichtigt.
Munitionspersistenz, Reload-Dauer und Ressourcen bleiben erhalten.

Außenhof, Werkstatt, Wege, Beleuchtung, 4× MSAA, Fallback und Assetdateien wurden
für diesen Durchgang nicht verändert. Keine neuen Sounds, detaillierten Reload-
Clips, Wand-Verdrängung des Viewmodels oder ballistische Simulation. Nahes
Wand-Clipping und einfache Modellvisiere bleiben Asset-/Präsentationsgrenzen.
Subjektives Spielgefühl und tatsächliche FPS brauchen einen manuellen F5-Test.

`tests/core_upgrade_checks.gd` lädt den echten F5-Startup und prüft alle acht
Feuermodi, Kadenz anhand tatsächlicher Physikticks, Munition, Rückstoß, ADS,
Mündung, Unterbrechungen, reine UI-Input-Zustände, leeres Magazin, Bewegung,
Sprungpuffer und Wiederholschutz. Im Grafikmodus (`-- --capture`) werden Hip,
ADS und Schuss für jede Waffe sowie Reload, Holster und Sprint gespeichert unter
`.godot/checks/core_upgrade/`. Bestehende Arm-/Waffen-/Outdoor-Suiten bleiben aktiv.

Aktuelle Verfeinerung der Übergänge und Prüfergebnisse: [Waffenbewegung](weapon_motion_polish.md).
