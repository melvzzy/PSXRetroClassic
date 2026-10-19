# Vier selektive Industrial-Auszüge

Abgeleitet von godgoldfear, **PSX Industrial Environment Asset Pack**, CC BY 4.0.
Quelle: https://godgoldfear.itch.io/psx-industrial-environment-asset-pack
Lizenz: https://creativecommons.org/licenses/by/4.0/

Godot 4.7.2 GLTFDocument-Export von Cargo_1_open, Generator, Box_wood und Barrel_1.
Die GLBs enthalten jeweils nur das gewählte Objekt mit seinem Material/Albedo.
Exportbasis und physischer Maßstab blieben erhalten, Aufstellungsversatz wurde
entfernt und der Ursprung auf Boden/Mitte gesetzt. Cargo_1_open erhielt seine
Originaltextur Cargo_1.png explizit, da die Sammel-FBX-Zuordnung leer importierte.
Keine erfundenen Türen, Kollisionen, Animationen oder begehbaren Räume.

Original-FBX und verwendete PNGs bleiben unter
`assets/source/environment_candidates/industrial/` unverändert erhalten;
`.gdignore` schließt die monolithische Referenz vom automatischen Import aus.
Die Preview lädt ausschließlich diese vier kleinen GLBs. Reproduktion: Original
in separater Importprobe öffnen, genanntes Mesh mit globaler Basis duplizieren,
Bounding-Box-Boden/Mittelpunkt abziehen, zugeordnetes Material übernehmen und
jeweils über GLTFDocument als GLB exportieren. Details und Originalhashes im
Quellen-README/Manifest. Zusätzliche PNGs wurden von Godot aus den GLBs extrahiert.

Bei Weitergabe Credit, Quelle, Lizenz und diese Änderungsangabe beibehalten.
