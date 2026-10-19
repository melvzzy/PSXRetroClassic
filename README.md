# PSXRetroClassic

Aktuell verifiziert: **Godot 4.6.3.stable.official.7d41c59c4**, vollständiger
Neuimport und grafische Windows-Prüfungen erfolgreich; aktuell 648 Regressionstests
mit beiden lokalen Charakterkandidaten bestanden.
Details und Grenzen: [Kompatibilitätsnachweis](tests/README.md).

Eigenständiges Godot-**4.6.3 Standard**-Projekt (GDScript, Forward+) für einen
zukünftigen Retro-Sandbox-Shooter. Aktuell: kleine spielbare FPS-Grundlage mit
acht im Spiel auswählbaren Testwaffen mit profilabhängigem Einzel-/Dauerfeuer, standardmäßig ohne
Arme, ohne Inventar,
Gegner oder Plugins. Separate Arme- und Waffen-Vorschauen dienen der Asset-Prüfung.

## Öffnen und starten

Im Godot-Projektmanager `project.godot` importieren und **F5** drücken.
`scenes/startup.tscn` startet direkt den kompakten Außenhof in
`scenes/environments/outdoor_test.tscn`: Halle, durchquerbarer Cargo, Straße,
Vegetation, Generator-Schalter, Schießtafel und drei Physikprops.
Die bisherige Testfläche bleibt unter `scenes/fps_test_fallback.tscn` per **F6**
verfügbar; `fps_test.tscn` bleibt ebenfalls unverändert.
Am Root **Startup** im Inspector **Test Weapon** wählen (Makarov / AS Val / VSS /
SR-3 / M4A4 / EMP / MP40 / STG 44), speichern und F5 starten. **Show Arms** stellt nur für Makarov den
bisherigen Armaufbau wieder her; **Use Imported Visuals** schaltet den Fallback.
Details: [Waffen-Roster und Wechsel](docs/weapon_roster.md),
[aktuelles FPS-/Gunplay-Tuning](docs/fps_core_upgrade.md).
Das veränderbare Fenster startet mit 1280 × 720 und VSync. Forward+ benötigt
passende Grafiktreiber. Das Projekt enthält alle benötigten Ressourcen.

## Bedienung

- WASD: Bewegung relativ zur Blickrichtung, Shift: Sprint.
- Space: Sprung, Ctrl halten: Ducken. Unter einer niedrigen Decke bleibt der
  Player geduckt, bis genügend Platz zum Aufstehen vorhanden ist.
- Maus: direkte Blicksteuerung. Esc oder Fokusverlust gibt sie frei und sperrt
  Gameplay-Eingaben; Linksklick außerhalb des Beenden-Buttons fängt sie erneut.
- E: Schalter innerhalb von 2,5 Metern bedienen; Text und Farbe zeigen den Zustand.
- Linke Maustaste: Makarov/VSS Einzelfeuer; AS Val, SR-3, M4A4, EMP, MP40 und
  STG 44 feuern beim Halten automatisch. Rechte Maustaste halten: ADS.
  R: Nachladen. Startmunition je Profil (Makarov weiterhin 12/48), keine automatische
  Nachladung. Nachladen blockiert Schüsse und beendet ADS; Fokusverlust/Esc
  bricht es ohne Munitionsübertragung ab. Ein Wiederaufnahme-Klick feuert nie. Nach Reload, Wechsel oder Ziehen braucht
  Dauerfeuer einen neuen bewussten Tastendruck.
- 1–8: Makarov, AS Val, VSS, SR-3, M4A4, EMP, MP40, STG 44 wählen.
  Magazin/Reserve bleiben je Waffe erhalten. Wechsel bricht Reload/ADS ab und
  zieht die neue Waffe; gehaltene Maustasten lösen dabei keinen Schuss aus.
- X: Waffe wegstecken/ziehen; Q beendet nichts.
- Fenster schließen oder nach Esc auf **Beenden** klicken: Spiel verlassen.

Während des Spiels bleiben Fadenkreuz, Waffenname, kompakte Munitionszahl und kurze
Interaktions-/Waffenhinweise sichtbar. Bestätigte Treffer zeigen kurz ein kleines
graues Kreuz; Hilfetext und Beenden-Button erscheinen nach Esc.

Die erhaltene Fallback-Testfläche enthält Boden, Wand, Rampe, einen niedrigen Duckbereich und drei
fallende Physikwürfel sowie eine kleine Treffertafel vor der vorhandenen Wand.
Schüsse geben Physikwürfeln einen Impuls; es gibt kein Greifen oder Tragen.
Am Rand kann man herunterfallen; zum erneuten Testen das Projekt neu starten.
Nach aufgebrauchter Munition ebenfalls neu starten.

## Struktur und Erweiterung

- `scenes/player.tscn`: wiederverwendbarer CharacterBody3D mit Kamera und Interactor.
  `CharacterVisuals` am Player-Fuß und `Head/Camera3D/ViewmodelMount` sind klar
  benannte Modell-Anker, ohne Rig oder Ladesystem.
- `scenes/test_firearm.tscn`: gemeinsame Waffenlogik; `WeaponOnlyViewmodel` zeigt
  das ausgewählte Modell. Der erhaltene Makarov-Arm-Adapter ist standardmäßig
  unsichtbar und im Prozessmodus Disabled. `Placeholder` bleibt als Fallback.
- `scenes/weapons/`: neun Visual-Wrapper, Makarov-Arm-Adapter und acht kleine
  Testprofile. Nur Izh-54 bleibt ausschließlich Vorschau-Kandidat.
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
blenden zwischen Makarov-spezifischer Zweihandhaltung und entspannter Quellpose.
Reload greift/zieht/setzt das vorhandene Magazin ein; dies ist eine lokale
Teilsequenz ohne Ersatzmagazin oder mitgelieferten vollständigen Reload-Clip.

Ducken/Aufstehen interpoliert nur die Kamerahöhe; Kapsel und Standfreigabe bleiben
physikalisch sofort wirksam. Mausblick und Bewegung werden nicht geglättet.
Forward+ verwendet 4× MSAA, im ADS entfällt das zusätzliche Fadenkreuz.
Der konfigurierbare 60-ms-Schusspuffer gilt nur am Ende des Cooldowns und nur
solange die Taste gehalten wird. Loslassen, Fokusverlust, Holstern oder Reload
löschen ihn; zu frühe Klicks werden nicht nachträglich ausgeführt. Q beendet
nicht mehr das Spiel.


### Aktuelle Hände und Umgebungssichtung

Bei aktiviertem **Show Arms** verwendet die Makarov beide Hände mit angepassten
30 Fingergelenken. ADS behält
den Zweihandgriff; Schuss/Erholung, Magazin-Handbindung und Holster-Übergänge
laufen in F5 über die bestehenden Waffenereignisse/-zeiten. Die kleinen
Bewegungsimpulse betreffen nur das Viewmodel, nicht die Kamera.
Details und Grenzen: [Arm-/Waffenpolish](docs/first_person_arms_polish.md).
Die [Umgebungsauswahl](docs/environment_asset_review.md) bewertet 42 lokale
Archive; es wurde keine Umgebung importiert oder Karte gebaut.


## Isolierte Umgebungsvorschau

`scenes/previews/environment_preview.tscn` öffnen, **F6**: 14 ausgewählte Gebäude-,
Straßen-, Natur- und Prop-Modelle, getrennt von Startup und FPS-Testfläche.
0–4 wählen Gruppen, rechte Maustaste dreht die Kamera, Mausrad zoomt.
[Auswahl, Quellen, Einschränkungen und erster Bereichsplan](docs/environment_preview.md).


## Spielbarer Außenhof

F5 führt direkt in den etwa 40×40-m-Hof. Die vorhandenen 14 Asset-Typen werden
mit festen Kollisionen, wenigen Baum-/Buschwiederholungen und drei beweglichen
Kisten/Fässern genutzt. Halle bleibt geschlossen; Cargo kann durchlaufen werden.
Generator-Schalter: E; Schießtafel am nördlichen Kugelfang. Alle bisherigen
Waffen-/Maus-/Bewegungsbefehle bleiben gleich. Licht: einfacher Himmel,
Umgebungslicht und Richtungsschatten, Forward+ und 4× MSAA unverändert.
Details, Grenzen und Checks: [Außenhof](docs/playable_outdoor.md).


Der Hof besitzt jetzt einen kleinen östlichen Wartungsrundweg mit zwei Zugängen,
flacher Böschung bis 1,2 m, dichterem Randgrün und sichtbarer Zaunbegrenzung.
Texturierte Erd-/Betonflächen, Wegweiser und Materiallager ordnen den Bereich.
F5 bleibt der direkte Einstieg; Steuerung und Waffen unverändert.


Isolierter Ganzkörpervergleich: `scenes/previews/character_comparison.tscn`
öffnen und F6. Auswahl/Lizenzgrenzen: [Charakterreview](docs/character_asset_review.md).
F5 und der bestehende FPS-Spieler bleiben unverändert.
