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
godot --headless --path . res://scenes/previews/weapon_asset_preview.tscn --quit-after 120
godot --headless --path . --script res://tests/weapon_asset_checks.gd
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
   RMB richtet die Makarov-Visierung aus und reduziert FOV/Bewegungstempo;
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

## Früherer Qualitätsreview vor Waffenmodellintegration (19.10.2026)

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

## Früherer isolierter Arme-Importtest (19.10.2026)

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

Weitere In-game-Waffen, modellbezogene Hand-/Nachladeclips, neue Rigs, Sounds,
Waffenwechsel, Inventar, Gegner, größere Umgebungen und Retro-Effekte. Kein
separater Viewmodel-Renderer oder aufwendiges Wandnähe-Animationssystem;
visuelles Clipping direkt an einer Wand ist derzeit möglich.

## Aktuelle Waffenmodellintegration (19.10.2026)

Godot **4.7.2.stable.official.ed1daf0bf**: Headless-Import und begrenzte Starts
für Spiel, Arme- und Waffen-Preview erfolgreich. **151 Prüfungen bestanden**:
40 FPS, 43 Gunplay, 32 Arme und 36 Waffenmodelle. Die bekannte Zertifikatsspeicher-
Meldung bleibt; keine Skript-, Ressourcen-, Animations- oder Szenenfehler in den
abschließenden Logs. Godot 4.6.3 wurde nicht getestet.

Die neuen Prüfungen testen alle fünf Visual-Wrapper, Textur-/Mipmap-Zuordnungen,
Metermaßstab, einzelne Teile, fehlende/konstante Quellclips, stabile Armhaltung,
zentrierte ADS-Visierreferenz, Lauf-/Kameraachse, genau eine Schuss-/Schlittenaktion,
temporäre Magazinbewegung, Fokusabbruch, alternative leere Magazine und Fallback.
Die bestehenden Hitscan-/Impuls-/Ammo-/Reload-Regressionsprüfungen bleiben aktiv.

Optionaler Grafiklauf:

```text
godot --path . --script res://tests/weapon_asset_checks.gd -- --capture
```

**44 Prüfungen bestanden** im Windows-Grafiklauf mit Vulkan 1.4.351 / Forward+
auf RTX 5060 Ti; acht native Ansichten (fünf Modelle, Hip/ADS/Reload im Spiel)
unter `.godot/checks/weapon_captures/` erzeugt und visuell betrachtet. Das ist
programmatische Renderprüfung, kein vollständiger manueller Gameplay-Durchlauf.

Manuell zusätzlich: F5 starten, Griff/Finger in Hip/ADS prüfen, beim Laufen und
Ducken feuern, leeres/partielles Nachladen sowie Esc/Alt-Tab testen. Magazin und
Schlitten dürfen nicht doppelt erscheinen; Hand-/Magazin-Durchdringungen bewusst
beurteilen. Treffer auf Tafel/Props mit Visier vergleichen. Fallback vor Start
am MakarovViewmodel einschalten und separat prüfen. F6-Waffen-Preview: alle fünf
Modelle/Teile, Drehung, Distanz und Arms-Referenz prüfen. Tatsächliche FPS und
Spielgefühl bleiben manuell zu bewerten. Details: [Waffenbericht](../assets/source/weapon_candidates/README.md).


## Fokussierte Handbindung-/ADS-Reparatur (19.10.2026)

Vor Änderungen: 151 Checks bestanden. Nach der Reparatur: 173 Checks
(40 FPS, 43 Gunplay, 32 Arme, 58 Waffenmodelle). Alle 18 Arm-Clips werden an
je drei Zeitpunkten auf konstanten handlokalen Griff, gültige Orientierung und
passende Mündung geprüft. Wiederherstellen der Haltepose darf keine Drift
hinterlassen. Eine absichtlich verschobene/gedrehte SightLine muss weiterhin
zentriert werden; danach muss die Hip-Position zurückkehren. Vorhandene
Schuss-/Reload-/Fokus-/Fallback-Checks bleiben aktiv.

Godot 4.7.2.stable.official.ed1daf0bf; 4.6.3 nicht verfügbar/verifiziert.
Headless-Import und begrenzte Starts erfolgreich. Grafiklauf: 66 Checks,
Forward+/Vulkan/RTX 5060 Ti; Hip- und ADS-Captures visuell geprüft, kein manueller
Gameplay-Durchlauf. Bekannte Zertifikatsspeicher-Meldung der Umgebung bleibt.

F5 manuell: Laufen/Ducken/Springen; Hip/ADS mehrfach wechseln; beim Zielen
schießen; partiell/leer nachladen; Esc/Alt-Tab und erneute Mausaufnahme;
Treffer auf Tafel/Props vergleichen; Griff/Finger und Wand-Clipping ansehen.
Fallback vor Start deaktivieren und Schießen/ADS/Reload separat prüfen.
Die Quellclips sind technische Bindungsproben, keine neu integrierten
Pistolenanimationen; vorläufige Finger-/Reload-Durchdringungen bleiben möglich.


## Aktueller Foundation-Polish

Ausgangsbasis: 173 Checks. Zusätzlich `foundation_polish_checks.gd` mit 32
gezielten Checks: X/Holster/Draw, wiederholte Eingaben, Reload-Abbruch ohne
Ammo-Transfer, gehaltene Maustasten, Puffergrenzen und -abbruch, Fallback,
ADS nach Posewechsel, Kameraübergänge, HUD, entfernte Q-Bindung und 4× MSAA.
Der bestehende Crouch-Check erwartet jetzt sofortige Kapseländerung bei
interpolierender Augenhöhe. Gesamtsuite: 205 Checks (40+43+32+58+32).

Godot 4.7.2.stable.official.ed1daf0bf; 4.6.3 weiterhin nicht installiert/getestet.
Import und begrenzte Starts werden vom bestehenden Runner erfasst. Grafikcheck:
`godot --path . --script res://tests/foundation_polish_checks.gd -- --capture`
mit vier Ansichten (Ready, ADS, Übergang, Holstered) und 36 Checks; Forward+,
Vulkan, RTX 5060 Ti. Renderprüfung ersetzt keinen manuellen Windows-Spieltest
oder verlässlichen FPS-Benchmark. Bekannte Windows-Zertifikatsmeldung bleibt.

F5: WASD/Sprint/Jump, Ctrl langsam/schnell unter niedriger Decke, mehrfach X,
X während Reload/ADS, gedrückte LMB/RMB beim Ziehen, einzelne/rasche Schüsse,
Reload partiell/leer, Props/Tafel treffen, E weggesteckt, Esc/Alt-Tab/Recapture,
HUD und Q ohne Wirkung, Beenden-Button. Fingerkontakt, Holster-Übergang und
Wand-Clipping visuell bewerten; FPS im Godot-Monitor separat messen.


## Aktueller Arm-/Waffenpolish und Umgebungssichtung

Ausgangsbasis 205 Checks; aktuell **235 Checks bestanden**: 40 FPS, 43 Gunplay,
32 Arme, 60 Waffenmodelle, 32 Foundation-Polish, 28 neue Arm-/Waffenprüfungen.
Die vorhandenen Magazin-Checks unterscheiden jetzt Greifen, Herausziehen und
sanfte visuelle Rückkehr nach sofortigem logischem Reload-Abbruch.

Godot 4.7.2.stable.official.ed1daf0bf. Headless-Import, begrenzte Starts und
Previews bestanden; 4.6.3 nicht verifiziert. Die bekannte Zertifikatsspeicher-
Meldung bleibt. Grafiklauf: 36 Checks mit acht geprüften nativen Captures
(Idle, Detail, ADS, Feuer, Reload-Greifen/-Ziehen/-Einsetzen, Holstered),
Forward+/Vulkan/RTX 5060 Ti. Kein vollständiger manueller Windows-Spieltest.

Details, Einschränkungen und F5-Checkliste:
[Arm-/Waffenbericht](../docs/first_person_arms_polish.md).
42 Umgebungs-/Texturarchive gesichtet, 43 Modellstichproben dokumentiert;
keine Umgebung importiert: [Umgebungsbericht](../docs/environment_asset_review.md).


## Aktueller Weapon-only-/Vier-Waffen-Modus

Standard F5 zeigt ausschließlich das vorab ausgewählte Modell. Die bisherigen
Arm-Regressionsfixtures setzen nun ausdrücklich `show_arms = true`; ihre
Prüfungen bleiben erhalten. Die allgemeine Gunplay-Suite läuft gegen den neuen
Standardmodus, einschließlich alternativer leeren Makarov-Magazinmeshes.

Vor Änderungen: 235 Checks. Abschließend bestehende 235 plus **87 neue
Vier-Waffen-Checks = 322 bestanden**. Die neue Suite prüft Auswahl/Profile,
Texturen, deaktivierte Arme, Unabhängigkeit von Armtransforms, Nahgrenze,
ADS-Marker und tatsächliches Korn, Mündung, echte Zieltreffer vor Recoil,
Einzelschuss/Halten, Reload/Munitionssumme, Holster/Draw, Fokus und Fallback.
Headless-Import, begrenzter Spielstart und beide Vorschauen erfolgreich.

Godot **4.7.2.stable.official.ed1daf0bf**, keine 4.6.3-Verifikation. Grafiklauf:
`godot --path . --script res://tests/four_weapon_checks.gd -- --capture`
mit **107 Checks / 20 Aufnahmen** (vier Modelle × Hip/ADS/Feuer/Reload/Holstered).
Forward+/Vulkan/RTX 5060 Ti; repräsentative Hip-/ADS-Ansichten einzeln und alle
Zustände als Kontaktübersicht visuell geprüft. Die wiederherstellbaren Makarov-
Arme wurden zusätzlich über den bisherigen Grafiktest geprüft: 36 Checks /
8 Aufnahmen, inklusive visuell kontrollierter wiederhergestellter Haltepose. Bekannte Windows-
Zertifikatsmeldung bleibt; keine anderen abschließenden Engine-Diagnosen.
Keine Behauptung eines vollständigen manuellen Windows-Spieltests oder FPS-Tests.

Auswahl, Werte, Grenzen und F5-Checkliste:
[Vier-Waffen-Setup](../docs/four_weapon_setup.md).


## Aktueller Acht-Waffen-Modus und Wechsel

Vor der Erweiterung wurden die vorhandenen 322 Checks ausgeführt. Vier ältere
Makarov-Fixtures setzen nun ausdrücklich `test_weapon = 0`, damit die gespeicherte
AS-Val-Startauswahl ihre pistolenbezogenen Erwartungen nicht verfälscht.
Abschließend **442 Checks bestanden**: bisherige 322 plus 120 Roster-Prüfungen.
Headless-Import, begrenzter Start und beide bestehenden Previews erfolgreich.
Der Runner enthält jetzt auch `tests/weapon_roster_checks.gd`.

Zusätzlich tatsächlicher Windows-Grafiklauf mit **137 Checks und 17 Captures**:
Hip/ADS aller acht Waffen und zurückgeschaltete Makarov-Arme. Alle acht Hip-/
ADS-Paare und die Armansicht visuell geprüft. Forward+/Vulkan/RTX 5060 Ti;
Godot **4.7.2.stable.official.ed1daf0bf**, keine 4.6.3-Verifikation.
Nur die bekannte Windows-Zertifikatsspeicher-Meldung in den abschließenden Logs;
keine weiteren Script-/Ressourcen-/Szenenfehler oder Warnungen.

Die Tests verwenden echte Nummern-/Mausereignisse, prüfen alle Profile samt
Texturen, physischen Maßen, Hip-/ADS-Nahgrenze, Markerausrichtung, tatsächlichen
Zieltreffern, Schuss und Reload-/Holster-Abbruch. Sie prüfen Munition nach einer
Runde durch alle Slots, Reload-Abschluss mit Munitionserhalt, schnelle Wechsel
bei gehaltenen Maustasten, Cooldown-Erhalt, Ziehsperre, Fokus, HUD-Namen sowie
Arme und Placeholder (auch nach Start mit einer anderen Waffe).

Aufnahmen: `.godot/checks/roster/`; Übersicht `hip_overview.png` und
`ads_overview.png`. Diese Dateien sind absichtlich nicht versioniert.
Das ist eine gesteuerte Renderprüfung, kein vollständiger manueller Windows-
Spieltest oder FPS-Benchmark. Manuelle F5-Checkliste und Quellen:
[Acht-Waffen-Setup](../docs/weapon_roster.md).


## Isolierte Umgebungsvorschau

Aktueller Durchlauf: **481 Checks bestanden** (vorhandene 442 + 39 neue
Umgebungsprüfungen), alle mit Godot **4.7.2.stable.official.ed1daf0bf**.
Headless-Import, begrenzter Startup, bestehende Arme-/Waffenpreviews und neuer
Environment-Preview-Start bestanden. Startup/FPS-Testszene, Projektsettings,
alle Waffen und Gameplay-Skripte wurden für diese Aufgabe nicht verändert.

Zusätzlicher Windows-Grafiklauf: **46 Checks / 7 Aufnahmen**, Forward+ / Vulkan /
RTX 5060 Ti. Fünf Gruppenansichten und zwei Gebäudeansichten auf 1,65-m-Augenhöhe
visuell geprüft. Texturen, Alpha/Schatten, Herkunftsmaßstab, offene Cargo-Enden
und geschlossenes Hallentor wurden anhand der Renderbilder bewertet. Nur die
bekannte Windows-Zertifikatsspeicher-Meldung in den abschließenden Engine-Logs.
**Godot 4.6.3 nicht getestet**, kein vollständiger manueller F6-Spieltest oder
FPS-Benchmark behauptet.

Reproduzieren:
`Godot.exe --path . --script res://tests/environment_preview_checks.gd -- --capture`
Bilder: `.godot/checks/environment/group_0.png` bis `group_4.png`, zusätzlich
`eye_0.png` (offener Cargo-Durchgang) / `eye_1.png` (Hallentor außen).

F6 manuell: `scenes/previews/environment_preview.tscn` öffnen, 0–4 drücken,
rechte Maustaste ziehen, Mausrad zoomen. Rückseiten von Laub, Schatten, nahe
Texturen, Augenhöhenmaß und Modellunterseiten prüfen. F5 muss unverändert den
bisherigen Waffentest starten. Die Vorschau hat absichtlich keine begehbaren
Kollisionen, Türen oder Gameplay-Logik. Auswahl, Lizenzgrenzen und Bereichsplan:
[Umgebungsvorschau](../docs/environment_preview.md).
