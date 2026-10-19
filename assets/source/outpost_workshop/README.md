# Kleine Werkstatt-Ergänzung

Selektiv aus den lokal heruntergeladenen Archiven übernommen, keine vollständigen Packs.
`source_manifest.json` enthält Archivpfade und SHA-256 der unveränderten Originale.

- **Hammer, Bottles, TrashCan**: Kkryy, *Street Furniture.zip*, FBX mit je einer PNG.
  Offizielle Quelle: https://kkryy.itch.io/streetfurniture — ausdrücklich CC0.
  Die Projektkopien behalten die Originaldateien; Materialien und Maße werden nur
  in `scenes/environments/outdoor_test.tscn` gesetzt. Kein Unity-/Blender-Plugin.
- **Mat_Stone_Gray_01**, **Mat_Wood_Brown_01**: Screaming Brain Studios,
  *SBS - Base Materials Pack 256x256.rar*, 256×256 PNG, CC0/Public Domain.
  Unveränderter Original-Lizenztext: `License.txt`.

Im Cargo: Hammer etwa 30 cm lang, Flaschengruppe 24 cm hoch, offener Abfallbehälter
72 cm hoch (inklusive Deckel). Explizite Texturzuweisung und Mipmaps; einfache
statische Behälterkollision. Keine neuen Interaktionen oder Animationen.
Werkbank, Regal, Leuchtengehäuse und sechs einfache Felsformen sind eigene,
projektinterne Godot-Geometrie. Felsen besitzen passende konvexe Kollisionen bei
unskalierten Physikkörpern. Werkbank/Regal verwenden die neue Holztextur.

Die bestehenden Industrial-Assets bleiben separat mit ihrer CC-BY-4.0-Attribution
unter `../environment_candidates/README.md`. Keine Caliber-Felsen, Shelter-
Rohdaten oder Innenraum-Sammelpacks mit ungeklärter Lizenz übernommen.
