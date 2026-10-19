# PSX First Person Arms — isolierter Importtest

Quelle: **Drillimpact**, [Asset-Seite](https://drillimpact.itch.io/psx-first-person-arms-free),
Downloadseite Version 1.1.0, geprüft am 19.10.2026.
[Lizenznachweis](LICENSE.md): CC0 gemäß Autorenseite, keine Lizenzdatei im ZIP.
Die drei Originaldateien sind unverändert; [Prüfsummen](source_manifest.json).

## Übernommener Inhalt

- `arms_rig.glb`: glTF 2.0, ein Mesh, ein Skin, 52 Gelenke, 18 gebackene Clips.
  758 Vertex-Datensätze, 1.176 Dreiecke, eine Materialfläche; UVs, Normalen,
  vier normalisierte Skin-Gewichte je Vertex und eingebettete Basistexur.
  Der GLB-Sidecar belässt diese Textur eingebettet (`Embed as Uncompressed`),
  damit Godot keine zusätzliche PNG-Kopie neben den Originaltexturen erzeugt.
- `arms_01.png` / `arms_gloves_01.png`: beide 512×512 RGBA; nackte Hände und
  schwarze fingerlose Handschuhe. Original-PNGs bleiben erhalten. Die Godot-
  Sidecars erzeugen Mipmaps und verwenden verlustfreien Import. Nur die Vorschau
  setzt auf einer lokalen Materialkopie `Nearest with Mipmaps` und Texturwechsel.
- Nicht übernommen: FBX-/Blender-Duplikate, `arms_uv.png` sowie sämtliche Dateien
  unter `Old Versions/`. Die 2024-GLB enthält 50 Gelenke, 11 andere Clips und eine
  256×256-Textur. Für den aktuellen Preview ist nur die neue GLB erforderlich;
  das Originalarchiv inklusive `.blend` bleibt unverändert im Downloadordner.

## Vorschau öffnen

`scenes/previews/arms_preview.tscn` im Godot-Editor öffnen und **F6** drücken.
**F5** startet weiterhin das bestehende FPS-Projekt, nicht diese Vorschau.
Alternativ: `godot --path . res://scenes/previews/arms_preview.tscn`.

Clip wählen, Play/Pause, Restart und Repeat verwenden; der Slider spult den
aktuellen Clip. Beide Texturen sowie First-Person-/Übersichtsansicht sind
umschaltbar. Esc oder Close beendet die Vorschau. Keine Mausaufnahme und kein
FPS-/Waffenskript; nur der importierte AnimationPlayer wird bedient.
Die Bodenplatte ist 2×2 Meter groß und dient ausschließlich als Maßstab.

## Befund: Maßstab, Achsen und Rig

- Der Import besitzt Metermaßstab und benötigt keine Skalierung. Die Restpose
  hat eine X-Spannweite von 1,67744 m; ihre Vertex-Y-Werte liegen bei 1,16980 bis
  1,65769 m. Das ist die Arm-/Restpose, keine vollständige Charakterhöhe.
- Der exportierte `camera`-Bone liegt in der globalen Restpose bei Y=1,743155 m.
  Er ist eine Rig-Referenz, keine importierte aktive Godot-Kamera. Die unabhängige
  Preview-Kamera nutzt diesen Referenzpunkt, FOV 80° und Near=0,03 m.
- Die animierten Arme zeigen im Quellmodell nach **+Z**. Der Preview-Knoten
  `Orientation` dreht ausschließlich die Modellinstanz um **180° um Y**, sodass
  Godots −Z-Blickrichtung passt. Quell-GLB, Skelett und Clips bleiben unverändert.
- Explizite Skin-/Skeleton-Verbindung und alle 52 Bindings sind geprüft; alle
  Clip-Tracks finden ihre Ziele. Die Posen bleiben endlich und die bewegten
  Clips verändern Bones. `rest` ist lediglich eine etwa 0,067 s lange Ruhepose.
- GLB liefert gebackene Bone-Tracks, kein ausführbares Blender-Constraint-/IK-
  System. Das Vorhandensein von `handIK`-/`elbowIK`-Bones ersetzt keine IK-Lösung.

## Verfügbare Godot-Clips

| Godot-Name | Länge (s) |
| --- | ---: |
| finger_gun_broken | 2,000 |
| finger_gun_fire | 0,500 |
| finger_gun_fix | 1,333 |
| finger_gun_idle | 2,000 |
| grab_L / grab_R | je 0,733 |
| guard_draw | 0,633 |
| guard_idle | 2,167 |
| jab_L / jab_R | je 1,000 |
| knife_draw | 0,433 |
| knife_hit_01 | 0,700 |
| knife_hit_02 | 0,733 |
| knife_idle | 1,667 |
| push_L / push_R | je 0,800 |
| relax | 2,000 |
| rest | 0,067 |

Godot ersetzt Punkte in Clipnamen durch Unterstriche, z. B. `jab.R` → `jab_R`.
Die Bone-Namen mit `.L`/`.R` bleiben erhalten; Animationen über die tatsächlich
importierten Namen auswählen. Die Vorschau listet sie automatisch auf und
wiederholt Clips optional, ohne die Loop-Metadaten der Quelle zu verändern.

## Vor einer Waffenintegration noch erforderlich

- Waffen-spezifische Griff-, ADS-, Feuer- und Nachladeposen erstellen/zuordnen.
  `finger_gun_fire` ist eine Fingerpistole, kein fertiger Feuerclip für unsere
  Waffe; ein Magazin-Nachladeclip ist nicht enthalten. Auch `knife_*` enthält
  ausschließlich Arme, kein Messer-Modell.
- Den Quell-Kameraursprung bei einer späteren kamera-lokalen Arms-Instanz
  berücksichtigen: Ausgangspunkt wäre eine reine Visual-Hülle mit Y-Offset
  −1,743155 m und Y-Drehung 180°, nicht das unveränderte Modell unter die schon
  versetzte Waffen-Hülle hängen. Das muss mit echten Waffenmaßen abgestimmt werden.
- Arms-Animationen dürfen bestehende Kamera, Recoil-/ADS-Transforms und
  Kollisionskapsel nicht überschreiben. Griffpunkte, Skinning an gekrümmten
  Handgelenken/Fingern, Armabschlüsse und Near-Clipping mit dem echten Modell prüfen.
- Einige weit ausholende/abgesenkte Posen (z. B. ein Teil von `knife_hit_01`)
  verlassen bei festem FOV 80° den First-Person-Bildausschnitt. Sie sind über
  die Übersicht prüfbar; Framing/Posen später pro Waffenhaltung abstimmen,
  nicht jetzt das Gameplay-FOV oder die Quellanimationen verändern.

## Verifikation am 19.10.2026

Godot **4.7.2.stable.official.ed1daf0bf**; keine 4.6.3 auffindbar.
Headless-Import und begrenzter Preview-Start erfolgreich. 32 Arms-Prüfungen
(Skin, Texturen/Mipmaps, Skala/Achsen, alle Clips, Playback und Preview-Buttons).
Bestehende 40 FPS- und 42 Waffenprüfungen bleiben erfolgreich.

Zusätzlich echter Windows-Renderlauf: **Vulkan 1.4.351 / Forward+ / NVIDIA
GeForce RTX 5060 Ti**. Sechs gerenderte Ansichten und GPU-gebackene Skin-Posen
wurden erzeugt (44 Prüfungen im Capture-Modus); First-Person mit beiden Texturen,
Stoß-/Fingerpistolenpose und Übersicht visuell inspiziert. Keine fehlenden
Texturen oder offensichtlich explodierten Meshes in den geprüften Ansichten.
Das ist keine vollständige manuelle Prüfung aller Zwischenposen oder UI-Eingaben.

Die bekannte Umgebungsfehlermeldung `Failed to read the root certificate store`
tritt weiterhin auf. Keine Skript-, Ressourcen-, Animations- oder Renderfehler
im abschließenden Armstest. Godot 4.6.3 ist nicht verifiziert. Die spätere
provisorische Makarov-Anbindung wird separat im [Waffenbericht](../weapon_candidates/README.md)
beschrieben; sie ändert diese Quelldateien und die isolierte Vorschau nicht.
Captures/Logs liegen lokal ignoriert unter `.godot/checks/arms_captures/` bzw.
`.godot/checks/`; ausführbare Prüfungen: `tests/arms_import_checks.gd`.
