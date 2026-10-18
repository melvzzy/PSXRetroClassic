# PSXRetroClassic

Eigenständiges Godot-**4.6.3 Standard**-Projekt (GDScript, Forward+) für einen
zukünftigen Retro-Sandbox-Shooter. Aktuell: kleine spielbare FPS-Grundlage mit
einer halbautomatischen Testwaffe, ohne Inventar, Gegner, Fremdassets oder Plugins.

## Öffnen und starten

Im Godot-Projektmanager `project.godot` importieren und **F5** drücken.
`scenes/startup.tscn` instanziiert direkt die kleine `fps_test.tscn`.
Das veränderbare Fenster startet mit 1280 × 720 und VSync. Forward+ benötigt
passende Grafiktreiber. Das Projekt enthält alle benötigten Ressourcen.

## Bedienung

- WASD: Bewegung relativ zur Blickrichtung, Shift: Sprint.
- Space: Sprung, Ctrl halten: Ducken. Unter einer niedrigen Decke bleibt der
  Player geduckt, bis genügend Platz zum Aufstehen vorhanden ist.
- Maus: direkte Blicksteuerung. Esc oder Fokusverlust gibt sie frei und sperrt
  Gameplay-Eingaben; Linksklick außerhalb des Beenden-Buttons fängt sie erneut.
- E: Schalter innerhalb von 2,5 Metern bedienen; Text und Farbe zeigen den Zustand.
- Linke Maustaste: einzelner präziser Schuss; rechte Maustaste halten: ADS.
  R: Nachladen. Startmunition: 12 im Magazin, 48 in Reserve, keine automatische
  Nachladung. Nachladen blockiert Schüsse und beendet ADS; Fokusverlust/Esc
  bricht es ohne Munitionsübertragung ab. Ein Wiederaufnahme-Klick feuert nie.
- Q, Fenster schließen oder nach Esc auf **Beenden** klicken: Spiel verlassen.

Während des Spiels bleiben Fadenkreuz, kompakte Munitionszahl und kurze
Interaktions-/Waffenhinweise sichtbar. Bestätigte Treffer zeigen kurz ein kleines
graues Kreuz; Hilfetext und Beenden-Button erscheinen nach Esc.

Die Testfläche enthält Boden, Wand, Rampe, einen niedrigen Duckbereich und drei
fallende Physikwürfel sowie eine kleine Treffertafel vor der vorhandenen Wand.
Schüsse geben Physikwürfeln einen Impuls; es gibt kein Greifen oder Tragen.
Am Rand kann man herunterfallen; zum erneuten Testen das Projekt neu starten.
Nach aufgebrauchter Munition ebenfalls neu starten.

## Struktur und Erweiterung

- `scenes/player.tscn`: wiederverwendbarer CharacterBody3D mit Kamera und Interactor.
  `CharacterVisuals` am Player-Fuß und `Head/Camera3D/ViewmodelMount` sind klar
  benannte Modell-Anker, ohne Rig oder Ladesystem.
- `scenes/test_firearm.tscn`: einzelne konfigurierte Waffe; unter
  `Visuals/ModelMount/Placeholder` liegen austauschbare Primitive. `Visuals/Muzzle`
  und `Visuals/AudioMount` markieren spätere Effekt- und Soundpositionen.
- `scenes/fps_test.tscn`: ausschließlich kleine Funktions-Testumgebung samt HUD.
- `scripts/`: kleine, getrennte Controller-, Interaktions- und Testszene-Skripte.
- `assets/`, `assets/audio/`: Platz für zukünftige eigene Assets.
- `tests/`: Integrationstests, Windows-Prüfskript und manuelle Checkliste.

Bewegungswerte, Empfindlichkeit und FOV am Player im Inspector konfigurieren;
Magazin, Reserve, Feuerrate, Nachladezeit, ADS und Rückstoß an der Testwaffe.
ADS reduziert Bewegungstempo und übersteuert Sprint. Die Maus bleibt direkt;
nur ADS-Darstellung und Rückstoßrückstellung verwenden kurze Übergänge.
Bewegung und Strahlenabfragen laufen im Physiktakt, Mausblick direkt bei Eingabe.
Details zum Interaktionsvertrag und zu Kollisionslayern: [scripts/README.md](scripts/README.md).
Es gibt keine Autoloads oder generischen Manager. Weitere Systeme nur nach Auftrag ergänzen.

## Prüfen

```powershell
./tests/run_checks.ps1 -Godot 'C:\Pfad\Godot_v4.6.3-stable_win64_console.exe'
```

Das Skript prüft Version, Headless-Import, Start über 120 Frames und die
FPS- und Waffen-Integrationstests; jeder Prozess hat ein Zeitlimit von 60 Sekunden.
Prüfprotokolle und Test-Benutzerdaten liegen ignoriert unter `.godot/checks/`.
Ergebnisse und manuelle Windows-Checkliste: [tests/README.md](tests/README.md).

Die technische Integration ist headless geprüft. Zielversion 4.6.3, grafische
Windows-Ausgabe und Spielgefühl müssen noch manuell geprüft werden; lokal stand
nur Godot 4.7.2 zur Verfügung. Modelle, Sounds, Animationen und weitere Spielsysteme
bleiben bewusst zurückgestellt.
