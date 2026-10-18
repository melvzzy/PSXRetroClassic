# FPS-Prüfung

## Automatisch unter Windows

Mit Godot **4.6.3 Standard** im Repository-Verzeichnis:

```powershell
./tests/run_checks.ps1 -Godot 'C:\Pfad\Godot_v4.6.3-stable_win64_console.exe'
```

Der Pfad darf auch auf die normale Standard-EXE oder einen Befehl im PATH zeigen.
Das PowerShell-Skript führt nacheinander folgende Aufrufe aus, begrenzt jeden
Prozess auf 60 Sekunden und bricht bei Fehlern ab:

```text
godot --version
godot --headless --path . --editor --import
godot --headless --path . --quit-after 120
godot --headless --path . --script res://tests/fps_checks.gd
godot --headless --path . --script res://tests/weapon_checks.gd
godot --headless --path . res://scenes/previews/arms_preview.tscn --quit-after 120
godot --headless --path . --script res://tests/arms_import_checks.gd
```

Der Import muss vor dem direkten Testaufruf erfolgt sein, damit Godot die
GDScript-Klassen kennt. Skript- und Ressourcenfehler sind auch bei Exitcode 0
Fehler. Der bekannte Zertifikatsspeicherfehler der eingeschränkten Umgebung
wird ausdrücklich als Warnung ausgegeben, nicht als Projektfehler verschwiegen.
Versionen abweichend von 4.6.3 werden ausdrücklich gemeldet.

Die Tests instanziieren die echte Startszene und prüfen Bodenhaftung,
Beschleunigung, Stoppen, Bewegungsrichtung, Sprint, diagonale Geschwindigkeit,
Sprung, Schwerkraft, Duckhöhe, Aufstehblockierung, Rampenabstieg, Wandkollision,
Kamerawinkel, FOV, Strahlreichweite, Sichtblockierung, deaktivierte Ziele,
Schalterfeedback und das Aufsetzen aller drei Physikwürfel. Zusätzliche
Regressionsprüfungen decken Fokusverlust, HUD-Sichtbarkeit und Modell-Anker ab.
Der Qualitätsreview ergänzt drei gezielte Fälle: E/Space vor Maus-Wiederaufnahme
im selben Physiktakt sowie sofortiges Entfernen des Interaktionshinweises bei
Freigabe ohne weiteren Physiktakt. Sprung und E verwenden dabei echte Key-Events.
Standardausgabe und Fehlerausgabe werden auf Engine-Diagnosen geprüft.
Maus-Freigabe und erneute Aufnahme werden als Gameplay-Eingabestatus geprüft;
der Headless-Treiber bestätigt keine tatsächliche Windows-Cursoraufnahme.

Die Waffenprüfungen verwenden zusätzlich echte Input-Map-Maus-/Tastaturereignisse
für Schuss, ADS und R. Sie prüfen Schussrate, halbautomatische Eingabe, Munition,
volle/leere/partielle Magazine, wiederholtes und abgebrochenes Nachladen,
Rückstoßgrenze/Rückstellung, ADS samt FOV-Empfindlichkeit, Sprint/Duck-Integration,
Reichweite, Wand-/Prop-Sichtblockierung, Schaden an der Testtafel, Physikimpulse,
HUD und Wiederaufnahme ohne versehentlichen Schuss. Lichtkonfiguration wird
auf Farb-Umgebungslicht, Forward+ und aktivierte Richtungsschatten geprüft.

## Manuelle Windows-Checkliste

1. **F5 / Bild:** Testszene startet direkt mit kleinem Fadenkreuz; Hilfetext und
   Beenden-Button erscheinen erst nach Esc. Fenstergröße ändern, Debugger bleibt
   fehlerfrei. Neutrale Beleuchtung, Lesbarkeit von Würfeln und Hindernissen sowie
   Richtungslicht-Schatten auf dem Boden prüfen. Im Godot-Debugger unter
   Monitore die tatsächlichen FPS beobachten und mit Auflösung/GPU dokumentieren;
   Headless-Laufzeit ist kein grafischer FPS-Nachweis.
2. **Bewegung:** WASD und diagonal laufen, Blick drehen, schnell stoppen; Shift
   erhöht das Tempo. Rampe hoch und herunter laufen, seitlich gegen die Wand gehen.
3. **Sprung:** Space hebt einmal ab, Landung ist stabil. Wiederholtes Drücken in
   der Luft erzeugt keinen weiteren Sprung; geduckt ist Springen gesperrt.
4. **Ducken:** Ctrl senkt Kamera und Kapsel, Bewegung wird langsamer. Unter die
   beschriftete niedrige Decke links gehen, Ctrl loslassen: kein Aufstehen durch
   die Decke. Beim Verlassen steht der Player automatisch auf; Shift übersteuert
   die Duckgeschwindigkeit nicht.
5. **Maus:** frei horizontal drehen, vertikaler Blick bleibt begrenzt, keine
   Glättung. Esc gibt Cursor frei und stoppt neue Steuerung; Linksklick fängt ihn.
   Alt-Tab gibt die Maus frei; nach Rückkehr bewusst klicken. Auf den Beenden-
   Button klicken darf die Maus nicht erneut fangen.
   Bei freier Maus E/Space unmittelbar vor dem Wiederaufnahme-Klick drücken:
   keine nachträgliche Interaktion und kein Sprung; frische Eingaben funktionieren.
6. **Interaktion:** Schalter ansehen und auf kurze Distanz herangehen. Hinweis
   erscheint, E wechselt Text und Farbe einmal pro Tastendruck. Aus der Ferne,
   mit freier Maus oder hinter der Wand ist keine Bedienung möglich.
7. **Physik:** Drei Würfel fallen und bleiben auf dem Boden, kollidieren mit
   Welt und Player. Beschuss bewegt und dreht sie entsprechend dem Trefferpunkt;
   ein Würfel oder die Wand blockiert Treffer auf dahinterliegende Ziele.
8. **Beenden:** Q testen; separat Esc und Beenden-Button sowie Fensterschließen.
9. **Waffe/ADS:** LMB feuert einen Schuss pro Klick, Halten erzeugt kein Dauerfeuer.
   RMB richtet die Platzhaltervisierung aus und reduziert FOV/Bewegungstempo;
   Mausblick bleibt direkt. Beim Sprinten/Ducken ADS und Schießen kombinieren.
   Kleine Rückstoßauslenkung und Rückstellung prüfen, auch beim Blick nach oben;
   Schüsse auf die Testtafel erhöhen deren Zähler und zeigen kurz einen Hitmarker.
10. **Nachladen/Fokus:** R mit teilweise vollem, leerem und vollem Magazin testen;
    wiederholtes R darf nicht neu starten, Schießen während Reload verbraucht
    nichts. Reserve wird erst am Ende übertragen. Esc oder Alt-Tab bricht Reload
    ohne Munitionstransfer ab. Wiederaufnahme-Klick und Halten dürfen keinen
    Schuss auslösen; erneutes Klicken feuert. Gehaltenes RMB muss nach Fokusverlust
    einmal losgelassen werden. Reserve leeren, keine negativen Werte oder Gratis-
    Munition. Der HUD bleibt kompakt und ohne dauerhaftes Hilfe-Overlay.

## Ergebnis des Qualitätsreviews (19.10.2026)

Verfügbar war Godot `4.7.2.stable.official.ed1daf0bf`, keine auffindbare 4.6.3.
Headless-Import und Start über 120 Frames: Exitcode 0, keine Skript-, Ressourcen-
oder Szenenfehler. FPS-Integrationstests: **40 bestanden, 0 fehlgeschlagen**;
Waffen-Integrationstests: **42 bestanden, 0 fehlgeschlagen** (insgesamt 82).
Die Umgebung meldet weiterhin `Failed to read the root certificate store`.
Test-Benutzerdaten werden innerhalb des Repository-Caches angelegt, wodurch
Schreibfehler für Editor-Einstellungen außerhalb des Repositorys entfallen.

Godot-4.6.3-Kompatibilität, grafische FPS-Spielszene, echtes Windows-Maus-
und Tastaturverhalten sowie das subjektive Bewegungs-/Waffengefühl wurden nicht
verifiziert. Dafür die obige manuelle Checkliste mit der Zielversion ausführen.

## Isolierter Arme-Importtest (19.10.2026)

`run_checks.ps1` führt zusätzlich Preview-Start und `arms_import_checks.gd` aus.
32 Arms-Prüfungen decken Skelett-/Skin-Verbindung, Gewichte, beide Texturen mit
Mipmaps, Originalmaßstab/Achskorrektur, sämtliche 18 Clips und Preview-Playback
ab. Zusammen mit den bestehenden 82 Gameplay-Prüfungen: **114 bestanden**.
Die Gameplay-Szenen, -Skripte und Input Map werden für den Preview nicht geändert.

Optionaler echter Grafiklauf (im Repository-Verzeichnis, ohne `--headless`):

```text
godot --path . --script res://tests/arms_import_checks.gd -- --capture
```

Erzeugt sechs PNGs und prüft GPU-Skinning unter `.godot/checks/arms_captures/`.
Getestet mit Godot 4.7.2 und Vulkan 1.4.351 / Forward+ auf NVIDIA RTX 5060 Ti:
44 Prüfungen im Capture-Modus erfolgreich, sechs Renderansichten erzeugt und
repräsentative Ansichten visuell inspiziert. Die bekannte Zertifikatsspeicher-
Meldung bleibt; keine weiteren Engine-Fehler im abschließenden Lauf.

Manuell: Preview mit F6 öffnen, Clips auswählen, Pause/Play/Restart/Repeat und
Timeline testen, beide Texturen und Ansichten vergleichen. Bei ausholenden
Posen die Übersicht verwenden. Das ist keine Bestätigung einer Integration
mit Waffen oder einer vollständigen manuellen Prüfung der Windows-Eingaben.
Importdetails: [Arme-Bericht](../assets/source/drillimpact_first_person_arms/README.md).

## Bewusst zurückgestellt

Weitere Modelle, Waffenanbindung der Arme, neue Rigs/Animationen, Sounds, Waffenwechsel, Inventar,
Gegner, größere Umgebungen und Retro-Effekte. Die Waffe nutzt austauschbare
Primitive und einfache Anker. Kein separater Viewmodel-Renderer oder aufwendiges
Wandnähe-Animationssystem; visuelles Clipping der Platzhalter direkt an einer
Wand ist derzeit möglich und gehört zur späteren Modell-/Animationsintegration.
