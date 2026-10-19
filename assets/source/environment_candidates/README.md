# Quellen der isolierten Umgebungsvorschau

Importiert am 19.10.2026, nur zur Asset-Prüfung. Keine Startup-/Gameplay-Anbindung.
`source_manifest.json` nennt Archiv und Eintrag sowie SHA-256 von Archiv und jeder
unveränderten Quelldatei. 24 Originaldateien aus vier Archiven, ca. 1,7 MB.
Godot extrahiert zusätzlich eingebettete GLB-Texturen; diese PNGs und `.import`-
Sidecars sind notwendige Importdaten und bleiben versioniert. Keine Blend-Dateien,
Unity-Projekte, Pack-Demoszenen oder Shader übernommen.

## Urban — valsekamerplant — CC0

Quelle: https://valsekamerplant.itch.io/psx-style-urban-stacked-pack
Autorenseite erneut am 19.10.2026 gelesen: Modelle CC0, Texturen aus CC0-Quellen
oder eigenen Fotos. Drei originale GLBs: Hangar1 und zwei Road-type-1-Module.
Originale Export-Aufstellungsversätze werden ausschließlich im Preview-Wrapper
zentriert und geerdet. Straßen einheitlich 0,5 skaliert: 8×8 m statt 16×16 m.
Freiwilliger Credit: „PSX style urban stacked pack — valsekamerplant“.

## Industrial — godgoldfear — CC BY 4.0

Quelle: https://godgoldfear.itch.io/psx-industrial-environment-asset-pack
Lizenz: https://creativecommons.org/licenses/by/4.0/
Credit: „PSX Industrial Environment Asset Pack — godgoldfear, CC BY 4.0“.
Änderungen: Vier Objekte aus der Sammelszene selektiv nach GLB exportiert,
Meter-/Achsenbasis übernommen, Boden und Mittelpunkt normalisiert; offene
Cargo-Materialzuordnung mit originalem Cargo_1.png ergänzt. Keine Geometrie-
Umgestaltung. Verwendung dieser Auszüge erfordert weiter Credit, Quellen-/
Lizenzlink und Änderungsangabe; diese Datei mit den Assets weitergeben.

Das unveränderte ursprüngliche FBX und die fünf zur Sichtung kopierten Albedos
stehen unter `industrial/`. `.gdignore` verhindert den automatischen Import
dieser Sammelszene: Sie enthält sämtliche Pack-Objekte und verweist zusätzlich
auf nicht ausgewählte Texturen. **Keine Vorschau-Ressource lädt dieses FBX.**
Vier eigenständige Auszüge liegen unter `assets/environment/industrial/`.
Normalmaps und die übrigen Albedos wurden nicht übernommen.

## Retro PSX Nature Pack — Elegant Crow

Quelle: https://elegantcrow.itch.io/retro-psx-nature-pack
Die Autorenseite erklärt die **Modelle** zu CC0 und nennt AmbientCG für Texturen
sowie Pixabay für Bilder. Daher keine pauschale CC0-Erklärung für sämtliche
Bildquellen: deren Herkunft wird getrennt bewahrt. Die Originaldatei
`nature/READ ME.txt` enthält den Autor und seine Kontakt-/Supportlinks.
Freiwilliger Credit: „Retro PSX Nature Pack — Elegant Crow; texture/image sources:
AmbientCG / Pixabay“. Individuelle Ursprungsbild-IDs sind im Download nicht
angegeben; vor einer separaten Weitergabe als Texturbibliothek klären.

Nur Baum 01/05, Busch 01, Gras 01 und vier zugehörige Sommertexturen. GLBs
enthalten keine Materialien: Zuweisung im Preview, Alpha-Scissor 0,45,
beidseitig, rau, Nearest with Mipmaps; Originale/UVs unverändert.

## Street Furniture — Kkryy — CC0

Quelle: https://kkryy.itch.io/streetfurniture
Autorenseite nennt ausdrücklich CC0 1.0 Universal und Street Furniture.zip.
Je FBX + PNG für Barrel, Box, Conditioner. Keine Blend-Dateien.
Preview-Materialzuordnung repariert; gleichförmige Skalierung auf Fass 0,9 m,
Kiste 0,8 m und Klimagerät 0,7 m Höhe. Freiwilliger Credit: „Retro Psx Street
Furniture — Kkryy“.

## Bewusst nicht kopiert

Caliber Creations Rock Packs 1/2: lokale Licence.txt erlaubt Spielprojekte und
interne Teamnutzung, untersagt öffentlich zugängliche wiederverwendbare Rohdaten.
CursedLake Shelter: Autor erlaubt Projekte/Änderungen, untersagt Asset-
Weiterverteilung: https://cursedlake.itch.io/ps1-psx-post-apocaliptic-shelter
Diese Pakete sind nicht technisch unbrauchbar; sie sind keine frei verteilbare
Rohdatenbasis für dieses Repository. Retro Tree Pack: im lokalen ZIP keine
Lizenzdatei; aktuelle abweichende Lizenz gegenüber älterer CC0-Ankündigung nicht
belastbar dem Archiv zugeordnet. Rocks/Rocas, Buildings/Cabañas, Forest Model
Pack und FREE APOCA bleiben ohne geklärte Quellen-/Nutzungszuordnung zurückgestellt.

Technik, Grenzen und erster Bereichsvorschlag: `docs/environment_preview.md`.
