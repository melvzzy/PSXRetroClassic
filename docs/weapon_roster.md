# Acht Waffen, ein Firearm

Startup bleibt dieselbe kleine Testszene. Im Inspector am Startup-Root bestimmt
**Test Weapon** die Startwaffe; die gespeicherte AS-Val-Auswahl bleibt erhalten.
**1–8** wechseln im Spiel direkt, ohne Inventar oder Mausradbelegung.

| Taste | Waffe | Magazin / Reserve | Schussabstand | Reload |
| --- | --- | --- | --- | --- |
| 1 | Makarov | 12 / 48 | 0,18 s | 1,35 s |
| 2 | AS Val | 20 / 80 | 0,12 s | 2,1 s |
| 3 | VSS | 10 / 40 | 0,22 s | 2,4 s |
| 4 | SR-3 | 20 / 80 | 0,11 s | 1,9 s |
| 5 | M4A4 | 30 / 90 | 0,12 s | 2,2 s |
| 6 | EMP | 32 / 96 | 0,14 s | 2,4 s |
| 7 | MP40 | 32 / 96 | 0,14 s | 2,4 s |
| 8 | STG 44 | 30 / 90 | 0,14 s | 2,5 s |

Alle schießen bewusst halbautomatisch. Werte sind konfigurierbare Testprofile,
keine Simulation der historischen Vorbilder. Die bestehenden Profile sind die
Wahrheitsquelle für Werte; Gameplay bleibt ausschließlich in `TestFirearm`.

## Wechsel und Sicherheit

Ein Firearm und ein aktives Modell; Magazine, Reserven und Rest-Cooldowns werden
pro Profil behalten. Nummerneingaben werden im nächsten Physiktakt verarbeitet;
bei mehreren Anfragen gewinnt die letzte. Derselbe Slot ist ein No-op. Reload
wird ohne Transfer abgebrochen, ADS/Schusspuffer/Rückstoß werden zurückgesetzt,
danach läuft die bestehende kurze Ziehphase. Gehaltenes Feuer/ADS wird erst nach
Loslassen wieder scharf. Fokusverlust/Esc löscht auch ausstehende Wechsel.
Waffenname und Munition stehen kompakt im bestehenden HUD.

**Show Arms** bleibt standardmäßig aus. Eingeschaltet gilt die erhaltene
Drillimpact-Integration nur für Makarov; andere Slots deaktivieren sie, Rückkehr
zu Slot 1 stellt sie wieder her. **Use Imported Visuals** aktiviert/deaktiviert
weiterhin den primitiven Fallback. Keine neuen Armposen oder Animationen.

## Modelle und Darstellung

M4A4 aus `M4A4.rar` (artemoq): unverändertes FBX + PNG, zehn Einzelteile,
Import ohne Blender. Die drei benannten Actions enthalten keine brauchbaren
bewegten Clips. Einmalige Einheitenkalibrierung im Wrapper: 0,205, Länge ca.
0,81 m. Kleine Verschlussbewegung nutzt das echte Schusssignal.

EMP, MP40 und STG 44 aus PUNDELs WW2-Mini-Paket: drei originale GLBs mit
Original-README (CC0). Eingebettete Materialien/Texturen bleiben erhalten;
Filter/Glanz werden nur lokal vereinheitlicht. Godot extrahiert beim Import
drei PNGs aus den GLBs; diese und ihre Import-Sidecars bleiben im Projekt. Originaleinheit Meter; MP40 und
STG 44 benötigen 180° um Y für −Z vorwärts. Separate Verschlüsse/Magazine,
keine Skins und keine importierten Feuer-/Reload-Clips. EMP besitzt konstruktiv
ein seitliches Magazin. Kein Asset-Sammelimport.

Quellen, Erlaubnisse und Hashes:
[LICENSES](../assets/source/weapon_candidates/LICENSES.md),
[Originalmanifest](../assets/source/weapon_candidates/roster_source_manifest.json).
Izh-54 bleibt wegen ungeklärter Erlaubnis nur der bereits vorhandene Preview-
Kandidat. M1 Garand bleibt wegen ungeklärter Lizenz und zusätzlicher
Texturzuordnung zurückgestellt. Andere zuvor bewertete Pakete wurden nicht
zusätzlich importiert.

Alle acht Hip-Profile liegen näher an der Kamera, leicht eingedreht und mit
sichtbarerem Gehäuse. Die bestehenden Modellmaßstäbe bleiben erhalten. ADS wird
aus `SightLine` berechnet; M4 trägt eine kleine Visierneigung passend zur
Korn-/Tragegriffgeometrie. Die Mündung folgt ihrem Marker; Treffer bleiben
kamerabasierter Hitscan. VSS behält seine offene Visierung und den verborgenen
Scope im Spiel. Forward+, 4× MSAA, Beleuchtung und Bewegung bleiben unverändert.

Reload ist die bestehende zurückhaltende Bewegung des gesamten Modells;
Magazine bleiben ohne Hände eingesetzt. Es werden keine fehlenden Quellanimationen
vorgegeben. Grobe Visiergeometrie, Wand-Clipping und endgültiger Klang bleiben
spätere Detailarbeit, kein Anspruch auf ballistische Lauf-/Visierparallaxe.

## Prüfen

Abschluss: 442 automatisierte Checks bestanden, plus Grafiklauf mit 137 Checks
und 17 Aufnahmen. Getestet: Godot 4.7.2.stable.official.ed1daf0bf,
Forward+/Vulkan/RTX 5060 Ti. Abschließende Logs enthalten ausschließlich die
bekannte Windows-Zertifikatsspeicher-Meldung; keine weiteren Engine-Diagnosen.

`tests/run_checks.ps1 -Godot <Godot.exe>` prüft Import, begrenzten Spiel-/Preview-
Start und alle Regressionen einschließlich `weapon_roster_checks.gd`.
Renderlauf: `Godot.exe --path . --script res://tests/weapon_roster_checks.gd -- --capture`.
Native Bilder stehen im ignorierten `.godot/checks/roster/` (Hip/ADS aller Slots,
zusätzlich wiederhergestellte Makarov-Arme). Renderprüfung ist kein manueller
Windows-Spieltest oder FPS-Benchmark. Godot 4.6.3 bleibt bis zu einem tatsächlichen
Lauf mit dieser Version unbestätigt.

F5 manuell: 1–8 auswählen, Hip/ADS/nahe Wände ansehen; pro Slot einzeln/rasch/mit
gehaltener LMB schießen und Tafel/Props treffen; R vollständig sowie während
Reload/ADS/X wechseln, zu altem Slot mit korrekter Munition zurückkehren.
Mehrere Nummern rasch drücken, LMB/RMB dabei halten, Esc/Alt-Tab und Recapture
prüfen. WASD/Sprint/Jump/Crouch/E bleiben bedienbar. Show Arms + Slot 1 sowie
Use Imported Visuals=false separat starten. Tatsächliche FPS im Monitor messen.

Sinnvollster nächster Schritt: dieses Framing im manuellen Spieltest bestätigen,
dann passende einzelne Schuss-/Reload-Geräusche ergänzen; keine weiteren Waffen
oder Systeme vor diesem Feedback.
