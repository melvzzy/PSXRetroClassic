# Lokaler Charaktervergleich

Quellen: lokal heruntergeladene `Simple_Character_PSX.zip` und `male_casual.zip`
aus GameAssetsPSXRetroClassic. Originalarchive unverändert. Nur die für den
Godot-Vergleich benötigten Dateien extrahiert; Manifest mit Archivpfaden und
SHA-256: `source_manifest.json`. Keine neuen Downloads von Modell-/Anim-Dateien.

## Simple Character PSX — JashiPSX

https://jashi-psx.itch.io/simple-character-psx-asset

Custom Asset License im ZIP-README und auf der Herstellerseite: Nutzung und
Bearbeitung für eigene kommerzielle/nichtkommerzielle Projekte erlaubt, keine
Weitergabe der ursprünglichen oder bearbeiteten Rohdateien als Sammlung/Asset.
Credit optional, hier trotzdem JashiPSX genannt. **Keine CC0-Lizenz.**

Deshalb bleibt `simple_character_psx/original/` bewusst lokal und per `.gitignore`
ausgeschlossen. Hier liegen unverändertes GLB, `character_256.png` und README.txt.
Ein geklontes Repository zeigt stattdessen einen Hinweis; F5 und der Male-Vergleich
funktionieren weiter. Zum lokalen Wiederherstellen aus dem vorhandenen ZIP:

- `Simple_Character_PSX/model/glb/simple-character-psx.glb` nach
  `simple_character_psx/original/simple-character-psx.glb`.
- `Simple_Character_PSX/texture/character_256.png` und `README.txt` ebenfalls dorthin.
- Projektimport mit Godot 4.6.3 ausführen; Import-Sidecars bleiben lokal erhalten.

FBX wurde zusätzlich binär im ignorierten Auditbereich untersucht; GLB enthält
bereits das vollständige Rig. Keine FBX-/Blend-Duplikate im Assetordner importiert.
`.blend`/`.blend1` liegen weiter im Original-ZIP; kein Blender installiert, daher
keine nicht exportierten Blender-Actions behauptet oder neu exportiert.

## PSX Casual Male Character — Vinrax

https://vinrax.itch.io/psx-casual-male-character

Herstellerangabe: "feel free to use in your projects, just credit me".
Attribution: **PSX Casual Male Character — Vinrax**. Keine Lizenzdatei im ZIP;
diese Notiz bewahrt den online geprüften Nutzungs-/Credit-Nachweis. Nicht als
CC0 oder als separat weiterverkaufbares Modell deklarieren.

Unveränderte `male_casual.fbx` und `man_tex.png` liegen unter `male_casual/original/`.
Der ursprüngliche FBX enthält einen alten absoluten Texturpfad; die lokale PNG
wird in der Vorschau ausdrücklich zugewiesen. Keine externe Datei wird benötigt.

## Import- und Prüfgrenzen

Beide 256×256-Atlanten, lokale Materialkopien mit Nearest/Mipmaps und ruhiger
neutraler Beleuchtung. Gläsermaterial bei Simple bleibt separat transparent.
Beide nur im Preview visuell auf 1,80 m skaliert und nach -Z gedreht; Originale,
Skin-Bindings und Knochen unverändert. Skalierung nutzt tatsächlich geskinnte
Vertexpositionen, nicht die irreführende ungeskinnte Mesh-AABB.

Vorschau: `scenes/previews/character_comparison.tscn`, öffnen und F6.
F5, Controller, Waffen, Armsystem, Physik und Außenposten bleiben unverändert.
B bietet lediglich eine reversible lokale Fingergelenk-Probe, keinen fertigen
Griff und keinen importierten Clip. Ausführlicher Befund:
`docs/character_asset_review.md` im Projektroot.
