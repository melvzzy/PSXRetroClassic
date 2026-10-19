# PSXRetroClassic

Eigenständiges Godot-**4.6.3 Standard**-Projekt (GDScript, Forward+) für einen
zukünftigen Retro-Sandbox-Shooter. Aktuell: kleine spielbare FPS-Grundlage mit
einer halbautomatischen Makarov-Testwaffe und Drillimpact-Armen, ohne Inventar,
Gegner oder Plugins. Separate Arme- und Waffen-Vorschauen dienen der Asset-Prüfung.

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
  `Visuals/ModelMount` liegt die Makarov-Präsentation mit Armen. Die ursprünglichen
  Primitive unter `Placeholder` bleiben als Fallback erhalten; vor dem Start
  `use_imported_visuals` am `MakarovViewmodel` ausschalten. Die Schusslogik bleibt dieselbe.
- `scenes/weapons/`: fünf Visual-Wrapper und der Makarov-Viewmodel-Adapter.
  Die anderen vier Kandidaten sind nur in der Asset-Vorschau montiert.
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
Maßstab, Modell-Anker, Kollisionshüllen, Material-/Texturimport und Trennung von
Originaldateien und Gameplay-Szenen: [assets/README.md](assets/README.md).
Es gibt keine Autoloads oder generischen Manager. Weitere Systeme nur nach Auftrag ergänzen.

## Prüfen

Arme-Vorschau: `scenes/previews/arms_preview.tscn` öffnen und **F6** drücken.
Clips, Timeline, Texturvarianten und Ansicht sind umschaltbar. Details zu Quelle,
Lizenz, Achsen und offenen Anpassungen: [Importbericht](assets/source/drillimpact_first_person_arms/README.md).
**F5** startet unverändert die FPS-Testszene.

Waffen-Auswahl zur Inspektion: `scenes/previews/weapon_asset_preview.tscn` mit
**F6** starten. Modell, einzelne Teile, Drehung, Distanz und Arm-Maßstabsreferenz
sind einstellbar; das ist kein Waffenwechsel im Spiel. Vollständige Auswahl,
Lizenzen und Einschränkungen: [Waffenbericht](assets/source/weapon_candidates/README.md).

```powershell
./tests/run_checks.ps1 -Godot 'C:\Pfad\Godot_v4.6.3-stable_win64_console.exe'
```

Das Skript prüft Version, Headless-Import, Start über 120 Frames und die
FPS-, Waffen-, Arme- und Waffenmodelltests sowie begrenzte Preview-Starts;
jeder Prozess hat ein Zeitlimit von 60 Sekunden.
Prüfprotokolle und Test-Benutzerdaten liegen ignoriert unter `.godot/checks/`.
Ergebnisse und manuelle Windows-Checkliste: [tests/README.md](tests/README.md).

Die technische Integration ist headless und anhand programmatischer Windows-
Render-Captures geprüft. Zielversion 4.6.3, vollständige manuelle Bedienung und
Spielgefühl sind noch offen; lokal stand nur Godot 4.7.2 zur Verfügung.
Waffen-spezifische Hand-/Nachladeanimationen, Sounds und weitere Spielsysteme
bleiben bewusst zurückgestellt.


### Foundation-Polish

X senkt/zieht die Waffe in etwa 0,22 s. Währenddessen und weggesteckt sind
Feuer, ADS und Reload gesperrt; Holstern bricht Nachladen ohne Munitionstransfer
ab. Gehaltene Maustasten aktivieren nach dem Ziehen keine Aktion. Die Arme
blenden zwischen vorhandener Halte- und entspannter Quellpose; keine neue
animierte Holster-/Reload-Sequenz wird behauptet.

Ducken/Aufstehen interpoliert nur die Kamerahöhe; Kapsel und Standfreigabe bleiben
physikalisch sofort wirksam. Mausblick und Bewegung werden nicht geglättet.
Forward+ verwendet 4× MSAA, im ADS entfällt das zusätzliche Fadenkreuz.
Der konfigurierbare 60-ms-Schusspuffer gilt nur am Ende des Cooldowns und nur
solange die Taste gehalten wird. Loslassen, Fokusverlust, Holstern oder Reload
löschen ihn; zu frühe Klicks werden nicht nachträglich ausgeführt. Q beendet
nicht mehr das Spiel.
