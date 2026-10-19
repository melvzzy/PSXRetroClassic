# Umgebung: geprüfte Auswahl und isolierte Vorschau

Stand 19.10.2026. Diese Szene ist eine Asset-Ausstellung mit neutralem Boden,
Richtungslicht/Schatten und farbbasiertem Umgebungslicht. Keine Karte, keine
Spielerinstanz, keine Kollision, keine Interaktion oder Gameplay-Anbindung.
Startup, FPS-Testszene, Projektsettings und alle acht Waffen bleiben unverändert.

## Öffnen

`scenes/previews/environment_preview.tscn` öffnen und **F6** drücken.
**F5** startet weiterhin die bisherige FPS-Waffentestszene.
**0** Gesamtansicht, **1** Gebäude/Cargo, **2** Straße, **3** Natur, **4** Props.
Rechte Maustaste ziehen: um die gewählte Gruppe drehen; Mausrad: Abstand ändern.
Maus bleibt frei. Fenster schließen oder F8 im Editor beendet die Vorschau.
Die Szenenansicht zeigt alle Instanzen ebenfalls direkt, ohne einen Laufzeitloader.
Eine 1,8-m-Säule dient als Referenz.

## Tatsächlich importiert

| Gruppe | Auswahl / Quelle | Gemessene Darstellung in Godot |
| --- | --- | --- |
| Gebäude | Urban Hangar1 — valsekamerplant | ca. 11,57×8 m Grundfläche, 5,3 m hoch; geschlossene Außenhülle. Türen sind keine geprüften beweglichen Bauteile. |
| Unterstand | Industrial Cargo_1_open — godgoldfear | 8×3 m, 3 m hoch; beide Stirnseiten offen, Innenflächen vorhanden. Gut als überdachter Durchgang; für einen geschlossenen Unterschlupf fehlt eine Rückwand/Tür. |
| Straßen | Urban road_1_straight_no_sides / corner_no_sides | Beide ursprünglich 16×16 m; im Preview einheitlich 0,5 skaliert auf 8×8 m bei 8 cm Dicke. Breitere asphaltierte Zufahrt, kein schmaler Waldpfad. |
| Natur | Elegant Crow Baum 01/05, Busch 01, Gras 01 | Sommerfamilie; Bäume ca. 4,04/4,19 m hoch, Busch 1 m, Gras 0,5 m. Kleine Bäume, kein bereits fertiger hoher Wald. |
| Industrie | Generator, Box_wood, Barrel_1 — godgoldfear | Generator ca. 3,65×1,31 m, 1,75 m hoch; Holzkiste ca. 0,81 m; Fass ca. 0,95 m hoch. |
| Vergleichsprops | Street Furniture Barrel, Box, Conditioner — Kkryy | Gleichförmig auf 0,9 / 0,8 / 0,7 m Höhe kalibriert, keine verzerrten Achsen. |

14 Modelle aus vier Paketen, 24 unveränderte Quelldateien (ca. 1,7 MB).
Aktuell erneut **42 Archivverzeichnisse** inventarisiert:
[Inventar](environment_preview_inventory.json). Gemessene Wrappergrößen:
[Maße](environment_preview_dimensions.json). Die frühere Sichtung bleibt als
historische breitere Auswahl erhalten, ihre Empfehlungen wurden nicht automatisch
übernommen. Nicht sämtliche Modelle aus den 42 Archiven wurden neu importiert.

## Importkorrekturen und Befunde

Urban bringt vollständige Materialien/GLB-Texturen mit, aber die Objekte stehen
in ihren Exporten weit neben dem Ursprung. Die Wrapper zentrieren und erden sie.
Der Straßenmaßstab wurde nach dem ersten Render an Gebäude und Personenmaß
angepasst. Straßenkanten bleiben rechtwinklige Pack-Kacheln; ein glaubwürdiger
Übergang zu Naturboden fehlt noch.

Industrial liegt als eine große FBX-Sammelszene vor. Der erste selektive Import
zeigte dadurch fehlende Bildverweise auf **nicht ausgewählte** Objekte. Lösung:
vier vorhandene Objekte mit Godots GLTFDocument einzeln nach GLB exportiert,
inklusive ihrer Textur, mit korrigiertem Aufstellungsursprung. Beim offenen Cargo
war zusätzlich die ursprüngliche Materialzuordnung leer; das mitgelieferte
Cargo_1.png wurde explizit zugewiesen. Originale bleiben unverändert unter einer
`.gdignore`-Referenzablage. Regulärer Import und Vorschau laden diese Sammelszene
nicht; keine fehlenden übrigen Pack-Texturen nötig.

Natur-GLBs enthalten tatsächlich **keine Materialien**. Vier Sommeratlanten
wurden den Modellen zugewiesen, inklusive Stamm/Krone. Alpha-Scissor 0,45 und
beidseitige Blätter verhindern undurchsichtige Rechtecke und verschwundene
Rückseiten. Mipmaps sind für aktive Welttexturen aktiviert; keine globalen
Renderänderungen, künstlichen Retroeffekte oder Quelltextur-Umbauten.

Street-Furniture-Albedos werden im Wrapper ausdrücklich zugeordnet. Die rohe
Skalierung war zwischen Exporten ungleich; die Vorschau nutzt plausible Meter-
Maße. Industrial-Holzkiste und -Fass passen farblich am besten zum blauen Cargo/
Generator. Street-Kiste ist heller/gelblicher und bleibt vorerst Vergleich statt
bevorzugter Dekoration. Die Bäume sind kräftiger grün als Metall-/Betonassets;
für den späteren Bereich zunächst eine Saison und wenige Varianten behalten.

## Rechte und zurückgestellte Kandidaten

Vollständige Zuordnung, Änderungsangaben und Originalhashes:
[Quellen/Attribution](../assets/source/environment_candidates/README.md),
[Manifest](../assets/source/environment_candidates/source_manifest.json).
Urban und Street Furniture sind laut ihren Autorenseiten CC0. Industrial ist
**CC BY 4.0**, Credit/Quelle/Lizenz/Änderungen bleiben beizulegen. Elegant Crow
nennt Modelle CC0, Bildquellen AmbientCG/Pixabay getrennt; die Bilddaten werden
nicht pauschal zu CC0 erklärt. Die im ZIP fehlenden individuellen Ursprungsbild-
IDs bleiben eine Dokumentationsgrenze für eine separate Texturbibliothek.

- **Caliber Rock Packs 1/2:** Lizenztexte erneut gelesen. Projekte und interne
  Teams erlaubt, öffentliche wiederverwendbare Rohdateien untersagt. Nicht in
  die versionierte Auswahl übernommen; deshalb bewusst keine Naturfelsen im
  Showcase. Das ist eine Verteilungsgrenze, kein Nachweis technischer Untauglichkeit.
- **CursedLake Shelter:** Projekte erlaubt, Rohasset-Weitergabe untersagt.
  Für diese frei nachvollziehbare Auswahl nicht importiert; Cargo/Halle reichen
  als erste Strukturprobe.
- **Retro Tree Pack:** Keine lokale Lizenzdatei. Aktuelle Lizenzfassung lässt
  sich nicht sicher der älteren CC0-Ankündigung/des Downloads zuordnen; zusätzliche
  Baumfamilie jetzt unnötig.
- **Rocks/Rocas, Buildings/Builduings/Cabañas, Forest Model Pack, FREE APOCA:**
  lokale Rechte-/Quellenzuordnung weiterhin offen, deshalb kein Import.
- **Industrial Building_1:** Stichprobe ca. 12,9 m hoch und 22,6 m tief; für den
  kleinen ersten Posten zu groß. Kein zusätzlicher Gebäude-Auszug.
- **Island, Sky-Sampler, Sewer, Innenraum-/Blender-Sammlungen:** falscher Umfang,
  eingeschränkte Rohdatenweitergabe oder zusätzlicher Exportaufwand. Kein Grund,
  sie für diese kleine, bereits funktionierende Auswahl hinzuzuladen.

## Realistischer erster Bereich — nur Plan

Ein kleiner **Wartungshof am Rand einer überwachsenen Zufahrt**, etwa 35×40 m:

1. Beidseitig offener 8×3-m-Cargo als vorläufig überdachte Basis, eine Öffnung zu einem ca.
   10×12-m-Arbeitshof. Zwei Meter freien Zugang vor der Öffnung lassen. Für einen
   abgeschlossenen Hideout später eine passende Rückwand/Tür ergänzen.
2. Halle versetzt 5–7 m daneben/hinter dem Cargo als Werkstatt-Außenform, nicht
   schon als zugesagter begehbarer Innenraum. Generator 2–3 m seitlich mit
   Wartungsabstand, ein Fass und eine Industrial-Kiste reichen zur Maßstabsprobe.
3. Zwei bis drei 8-m-Straßenmodule als 16–24 m lange Zufahrt. Mit Asphaltmodulen
   zuerst eher ein kleiner Betriebshof als eine schmale Waldstraße; schmaler
   Schotterweg erfordert ein eigenes geeignetes Modul und Übergangsgeometrie.
4. Kleine Baumgruppen 3–5 m hinter dem Hof, Busch/Gras am Rand. Straße und
   Öffnung frei lassen, nicht jede Fläche mit dichtem Laub füllen.
5. Später außerhalb der ebenen Gebäudeflächen nur etwa 0,5–1,5 m Höhenunterschied
   über 10–20 m. Einfache handgeformte Bodenmeshes reichen zunächst; keine
   Terrain-/Prozeduraltechnik erforderlich.

**Noch nötig:** eindeutig weiterverteilbare Naturfelsen; passende Erde/Schotter-
und Bodenübergänge; höhere Bäume für einen echten Waldrand; geprüfte Tür-/Innenraum-
Geometrie, einfache Kollisionshüllen und tatsächlich begehbare Eingänge.
Licht-/Audio-/Interaktionsarbeit gehört in spätere Aufträge. Renderprüfung
beweist keinen fertigen, begehbaren oder performanten Außenbereich.

## Verifikation und nächster Schritt

`tests/run_checks.ps1 -Godot <Godot.exe>` umfasst zusätzlich begrenzten Start
und fokussierte Checks der isolierten Umgebungsvorschau.
Renderlauf: `Godot.exe --path . --script res://tests/environment_preview_checks.gd -- --capture`.
Bilder stehen unter `.godot/checks/environment/` und bleiben unversioniert.

Getesteter Engine-/GPU-Stand und endgültige Zähler stehen in `tests/README.md`.
Godot 4.6.3 wird nicht aus einem Lauf mit 4.7.2 abgeleitet. Geprüft werden echte
Material-/Texturreferenzen, Alpha-Einstellungen, Bodenlage, Metermaße, Gruppen,
Kamera und fehlende Gameplay-Kollision; Renderaufnahmen werden zusätzlich
visuell kontrolliert. Keine Behauptung eines vollständigen manuellen F6- oder
FPS-Benchmarks.

Nächster praktischer Schritt: F6-Auswahl gemeinsam auf Stil und Maßstab prüfen,
Cargo **oder** Halle als Hauptform festlegen und fehlende Fels-/Bodenrechte
klären. Erst danach einen kleinen separaten Blockout mit einfachen Kollisionen
beauftragen; die bisherige FPS-Testszene dabei weiterhin behalten.
