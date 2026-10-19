# Waffenprüfung und erste Makarov-Integration

Aktueller Stand: Acht spielbare Waffen mit Wechsel über 1–8; M4A4 und alle drei
WW2-Reserven sind inzwischen gezielt importiert. Aktuelle Auswahl, Quellen,
Grenzen und Tests: [Waffen-Roster](../../../docs/weapon_roster.md).
Die folgende Erstprüfung dokumentiert den früheren Importumfang.

Stand: 19.10.2026. Originale/Archive: `source_manifest.json`,
Lizenzzuordnung: [LICENSES.md](LICENSES.md), maschinenlesbare Sichtung:
[review_inventory.json](review_inventory.json).

## Prüfumfang und Auswahl

Alle 66 ZIP-/RAR-Verzeichnisse des Downloadordners wurden gelesen, einschließlich
der verschachtelten Waffen-RARs im PSX Starter Kit. Die nachfolgende Tabelle
fasst erkennbare Waffenquellen und relevante Sammelpakete zusammen. FBX-Geometrie,
Objektnamen, Materialien/PNG-Verweise, Skin-Deformer und Animationskurven wurden
ausgelesen; GLB und relevante OBJ-Exporte zusätzlich geprüft. Native `.blend`-
Constraints/ungebackene Actions wurden nicht in Blender ausgewertet. Godot-
Import und Renderprüfung erfolgten gezielt nur für die fünf ausgewählten Modelle.

| Archiv/Paket | Befund und Entscheidung |
| --- | --- |
| **Makarov.zip** | **Ausgewählt, spielbar.** 10 getrennte Teile inkl. Schlitten, Hahn, Abzug und zwei alternativen Magazinen; passende Textur. Kein Skin, keine exportierten Clips. Gute erste Pistole. |
| **PackVs-As-Sr-3-Pack.rar** | **Alle drei ausgewählt und vor F5 einzeln spielbar:** AS Val, VSS, SR-3. 8/8/9 Teile, Magazine/Verschlüsse/Schäfte separat. Leere `CorpsAction`-Exporte, keine Feuer-/Reload-Clips. Einheitliche Qualität und Materialien; kein künstliches Limit pro Paket. |
| **Izh-54.zip** | **Ausgewählt als Preview-Kandidat mit offener Lizenzzuordnung.** 5 Teile inkl. Lauf, Verschluss, Abzug und loser Patrone. Kein Skin/Clip. Gute Flintenabdeckung; nicht für Veröffentlichung freigegeben. |
| M4A4.rar | Technisch brauchbare Reserve: 10 Teile. Drei Action-Namen, aber keine nichtkonstanten Kurven. Für diesen Import zurückgestellt, weil das vollständig behaltene Val/VSS/SR-3-Paket die Langwaffen bereits abdeckt. Nicht wegen eines Paketlimits ausgeschlossen. |
| M1 Garand.zip | 7 getrennte Teile, kein Skin/Clip. Mehrere alte/abweichende Texturpfade im FBX, zwei PNGs; Clip-Texturbezeichnung passt nicht direkt zu einer exportierten Referenz. Zusätzliche Remaps und eigene Hand-/Clip-Bewegungen nötig; zurückgestellt. Lizenz im ZIP fehlt. |
| PSX firearms basic kit.zip — CodeCola | Pistol, AK, Assault Rifle, MP, Revolver, Shotgun und Rauchgranate vollständig strukturell gesichtet. Je ein zusammengefügtes Mesh; keine beweglichen Verschlüsse/Magazine. Sechs Action-Namen im Assault-Rifle-Export enthalten keine bewegten Kurven. Solide statische Low-cost-Reserve mit 128er Texturen, für diese bewegliche Pistolenintegration weniger geeignet. Autor erlaubt Projektnutzung mit Credit und ohne Asset-Weiterverkauf. |
| PSX German Weapons from WW 2 mini-Asset Pack.zip — PUNDEL | **Alle drei als brauchbare Reserve bewertet:** EMP, MP40, STG44. FBX und GLB, 4/6/4 Teile, je eine eingebettete Textur, keine Skins/Clips. README enthält CC0-Deklaration. Gute spätere Alternative; jetzt kein zusätzliches WW2-Set importiert. |
| PSx Assets Ver_0.6.rar — Dysfunctional_Dev | Verschachtelte Glock-17-, Deagle-, Flintlock- und FlashlightGun-Archive geprüft. Glock hat 3 Teile/9 Action-Namen, aber nur konstante Kurven; Deagle 2 Teile ohne Clips; Flintlock ein Mesh und konstante Actions. Pistolenreserven, weniger differenzierte Mechanik als Makarov; Flintlock/Melee nicht aktuelles Ziel. FlashlightGun ist ein Zubehörteil. Quellenlizenz erlaubt Spielprojekte mit Einschränkungen, nicht CC0. |
| psxAssets.zip | Statische Shotgun, Ammo- und Ammo-Box-Modelle gefunden. Shotgun ein Mesh ohne Clip/Skin. Lizenzdatei: CC BY 4.0, Autorzuordnung im Archiv nicht ausreichend geklärt. Gegenüber getrennter Izh-Geometrie zurückgestellt. |
| Survival.rar | Zwei Jagdgewehr-Objekte und Bullet in einer 44-Mesh-Sammelszene; keine Actions/Skins, Textur vorhanden, Lizenz fehlt. Selektive Herauslösung/Neuverpackung nötig; für diesen ersten Import nicht gewählt. |
| Armstest.rar | Alternative Arm-Rig-Exporte, keine mitgelieferten Actions. Kein Grund, das funktionierende Drillimpact-Rig zu ersetzen; nicht importiert. |
| psx-first-person-arms-free-game-assets.zip | Vorhandenes Drillimpact-Rig erneut als Integrationsbasis verwendet; 52 Gelenke, 18 Clips. Quellen unverändert. Kein spezieller Pistolen-Reload-/ADS-Clip vorhanden. |
| Free_Character.zip | `thugWeapon.obj` ist laut OBJ-Objektname ein Switchblade, kein Gewehr. Archivlizenz CC0/Katcho. Keine Charakter-/Melee-Assets importiert. |
| FREE APOCA.zip | GLB-/FBX-Objektliste enthält 11 Umgebungsprops, keine Feuerwaffe. Nicht importiert. |
| miscmodelsAll.rar / Models pack psx - new.rar | Kombinierte FBX-Szenen strukturell gelesen; keine erkennbaren Waffenobjekte in der Namensliste. Kein automatischer Sammelimport. |
| Classic 64 Asset Pack 0.6 / Exploration objects | Verzeichnisse bzw. Exportnamen zeigen Umweltobjekte/Untersuchungsgeräte, keine passenden Feuerwaffen. Nicht als Waffenpakete importiert. |

Webquellen: [Makarov](https://artemoq.itch.io/pistol-makarov-ps1psx-low-poly-retro),
[Dreierpaket](https://artemoq.itch.io/vs-vintarez-as-val-vihr-sr-3-ps1psx-low-poly),
[M4A4](https://artemoq.itch.io/m4a4),
[CodeCola](https://codecola.itch.io/psx-retro-style-gun-kit),
[PSX Starter Kit](https://dysfunctional-games.itch.io/psx-starter-kit).
Aus einem Action-Namen wurde ausdrücklich keine Fähigkeit zum Feuern/Nachladen abgeleitet.

## Import und Preview

Die zehn ausgewählten Originaldateien bleiben bytegleich. FBX wird nativ mit
Godots ufbx-Importer geladen, ohne Blender/Plugin. Die Import-Sidecars sind
versioniert; PNGs nutzen verlustfreie Daten und Mipmaps. Materialzuordnungen
werden im kleinen `WeaponAsset`-Visual-Wrapper gesetzt: pro Modell ein gemeinsam
genutztes, neutrales StandardMaterial3D mit dem jeweiligen Original-PNG und
Nearest-with-Mipmaps. Das behebt insbesondere die fehlenden Texturverbindungen
der drei Langwaffen, ohne das Original-FBX oder UVs umzuschreiben.

| Kandidat | PNG | Visual-Skalierung des importierten FBX | sichtbare Länge |
| --- | --- | ---: | ---: |
| Makarov | 524×524 | 0,0342828 | 0,168 m |
| AS Val | 649×583 | 0,06162 | 0,875 m |
| VSS | 900×583 | 0,06314 | 0,894 m |
| SR-3 | 649×583 | 0,06595 | 0,640 m ohne optionalen Schalldämpfer |
| Izh-54 | 512×512 | 0,20488 | 1,100 m |

Die importierten Waffen zeigen bereits nach −Z; die Arme benötigen weiterhin
ihre Y-Drehung um 180°. Nur die Visual-Knoten werden skaliert, keine Kollision
oder Spiellogik. Es wurden keine Weapon-Rigs erfunden. Die drei Langwaffen-
Actions kommen nach Entfernen konstanter Tracks als 0-Track-/0,001-s-Clips an.

`scenes/previews/weapon_asset_preview.tscn` öffnen, **F6**: fünf Modelle auswählen,
Kameradistanz/Drehung einstellen, Einzelteile verschieben und die Drillimpact-
Arme als Metermaßstab ein-/ausblenden. Die Teileverschiebung ist eine Inspektion,
keine behauptete Nachladeanimation. Optionale/alternative Teile können dort
gezielt betrachtet werden. Leere Clip-Exporte sind sichtbar gekennzeichnet,
Play bleibt deaktiviert. Kein Waffenwechsel innerhalb des eigentlichen Spiels.

## Tatsächlich im Spiel

**F5** startet dieselbe FPS-Testszene mit der Makarov und Drillimpact-Armen.
Die bestehende Waffenlogik in `scripts/test_firearm.gd` besitzt
weiterhin Schussrate, Hitscan, Impulse, Munition, Reload, ADS und Rückstoß.
Die Werte 12/48 bleiben absichtlich die bestehende Testkonfiguration und sind
keine Aussage über eine originalgetreue PM-Magazinkapazität.

`MakarovViewmodel` unter `Visuals/ModelMount` ist ausschließlich Präsentation:

- `finger_gun_idle` liefert nur die Grundreferenz für den rechten Arm. Alle
  30 Fingergelenke und die linke Stützhand werden auf die Makarov kalibriert;
  kein Fingerpistolen-Feuer wird als Waffenanimation abgespielt.
- Die Pistole folgt `hand.R` über `Skeleton3D.skeleton_updated` mit konstantem
  handlokalem Grifftransform. Die Visier-
  referenz liegt in ADS auf der Kameramitte; Lauf und Kamera zeigen parallel −Z.
  Die Quell-Armkamera-Höhe bleibt berücksichtigt, keine Kamerasteuerung aus dem Rig.
- Das vorhandene `fired`-Signal bewegt Schlitten, Sight und Extractor gemeinsam
  und zieht den Zeigefinger kurz an. Der autoritative Reload-Fortschritt steuert
  Greifen, Herausziehen, Wiedereinsetzen und Rückkehr der linken Hand. Während
  des Herausziehens ist das vorhandene Magazin an die linke Hand gebunden.
  Keine zweite Munition, keine erfundene Tasche oder mitgelieferte Reload-Clips.
- Leeres/volles Magazin sind alternative Meshes und werden nicht gleichzeitig
  angezeigt. Fokus-/Mausfreigabe setzt temporäre Teilebewegungen zurück. Der
  Mündungsmarker wurde an die Modellmündung versetzt; Hitscan bleibt kamerabasiert.
- Fallback: vor dem Start am `MakarovViewmodel` im Inspector `use_imported_visuals` ausschalten.
  Dann erscheinen die unveränderten Primitive und der ursprüngliche Mündungsmarker.
  Kein Inventar, keine zusätzliche Eingabe und keine zweite Schussinstanz.

**Nur Preview:** Izh-54. AS Val, VSS und SR-3 sind inzwischen ohne Arme einzeln
spielbar; sie nutzen die gemeinsame Waffenlogik statt eigener Controller.

## Offene Punkte und nächste sinnvolle Verfeinerungen

Die Zweihandhaltung und alle Fingerketten sind jetzt Makarov-spezifisch,
mit lokal authorierten Halte-/Greif-/Ziehposen. Die grobe Skin-Geometrie bleibt
unverändert: extreme Nahansichten können Finger-/Hand-Durchdringungen und
kantige Gelenke zeigen. Reload ist eine sichtbare Teilsequenz mit demselben
Magazin; eine vollständige Magazinentnahme/-ersetzung aus einer Tasche und
der korrekte PM-Magazinhalter sind nicht umgesetzt. Source-Dateien bleiben
unverändert. Details: `docs/first_person_arms_polish.md`.

Kein Geräuschpaket wurde importiert, kein IK-/Retargeting-/Animationsframework
gebaut. Near-/Wand-Clipping und endgültiges FOV-Framing bleiben Modellarbeit.
Izh-Lizenz vor Veröffentlichung klären. Bei den übrigen Quellen keine CC0-
Freigabe aus bloßem kostenlosem Download ableiten.

## Verifikation

Godot **4.7.2.stable.official.ed1daf0bf**, keine auffindbare 4.6.3.
Import und begrenzte Starts für Spiel sowie Preview. Bestehende Regressionen
prüfen Bewegung, Fokus, Schusskadenz, Hitscan, Impulse, ADS und Reload weiterhin;
zusätzlich gezielte Modell-/Textur-/Maßstabs-/Mündungs-/Fallback-Prüfungen.
Ergebnisse und manuelle Checkliste: `tests/README.md`.

Windows-Grafiklauf: Vulkan 1.4.351 / Forward+ / RTX 5060 Ti. Acht native Captures
(fünf Kandidaten und spielbare Hip-/ADS-/Reload-Ansichten) wurden erzeugt und
visuell geprüft. Das ist eine programmatisch gesteuerte Renderprüfung, kein
vollständiger manueller Spieltest. Die bekannte Zertifikatsspeicher-Meldung der
Umgebung bleibt; alle anderen abschließenden Logs müssen frei von Engine-Fehlern sein.


Foundation-Polish: X steuert jetzt eine kurze, zustandsgebundene Absenk-/Zieh-
bewegung. Die Arme interpolieren zwischen der erhaltenen Haltepose und einem
Sample der vorhandenen `relax`-Pose; die Pistole wird beim Absenken verborgen.
Handbindung und markerbasierte ADS bleiben erhalten. Das ersetzt keine eigens
mitgelieferte Holster-/Reload-Animation. Aktuell wurden lokale Zweihand- und
Teil-Reload-Posen authoriert; Details stehen in `docs/first_person_arms_polish.md`.
Waffenlogik bleibt alleiniger Zustandsbesitzer.


## Aktueller Vier-Waffen-Testmodus

Makarov, AS Val, VSS und SR-3 sind jetzt einzeln vor F5 am Startup-Root wählbar.
Alle vier nutzen dieselbe Gunplay-Instanz. Standard ist ohne Arme, mit eigenen
Hip-/ADS-Profilen und tatsächlichen Korn-/Mündungsmarkern. Magazine bleiben ohne
Hände eingesetzt. VSS-Scope ist nur im spielbaren offenen-Visierungs-Modus
verborgen und bleibt im Original/Preview erhalten. Nur Izh-54 ist weiterhin
reiner Preview-Kandidat. Show Arms stellt den vorherigen Makarov-Aufbau wieder
her. Der oben beschriebene Arm-/Teil-Reload gilt ausschließlich für diese Option.
Details: `docs/four_weapon_setup.md`.
