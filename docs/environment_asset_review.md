# Umgebungssichtung: kleiner Außenposten

Stand 19.10.2026. **Keine Umgebungsassets ins Spiel importiert, keine Karte gebaut.**
42 relevante Archive mit 43 konkreten Modellstichproben anhand ihrer Dateilisten geprüft; konkrete FBX-/GLB-/OBJ-/
Collada-Stichproben strukturell gelesen, Texturen geöffnet und verglichen.
[Technische Stichproben](environment_asset_audit.json) enthalten Dateinamen,
Hashes, Geometrie, Materialien und vorhandene Lizenztexte. Exportdateien sind
keine Zählung einzigartiger Assets: GLB/FBX und Auflösungsvarianten doppeln sich.
Native Blender-Dateien wurden nicht in Blender geöffnet; für die Umgebung gab
es keinen Godot-Import-/Renderdurchlauf. Bounds sind rohe Exportkoordinaten,
kein Nachweis fertiger Godot-Metermaße oder begehbarer Innenräume.

## Empfohlene kleine Auswahl

| Aufgabe | Tatsächlich vorhandene Kandidaten | Import-/Stilbefund und Lizenz |
| --- | --- | --- |
| Hauptstruktur und Nutzobjekte | **Industrial_exterior_v1.zip**, intern `Industrial_exterior_v2/Models/IndustrialHorror_PS_like.fbx`: Building_1…13, Cargo_1_open/close, Box_wood, Barrel_1…3, Rohre und Straßen-/Bodenmodule | Zusammengefügte Export-Szene mit getrennten Objekten, externe 512er Albedo-/Normaltexturen. Grau/braun, gut zur Makarov passend. FBX-Units, einzelne Pivots und Texturpfade im künftigen Import prüfen. Nur wenige Objekte herauslösen. Autor godgoldfear, **CC BY 4.0**, Credit/Änderungsangabe einplanen. |
| Alternative bewohnte Hauptstruktur | **Post-apocaliptic Shelter_Base.rar**: RustyTruck, Trailer, Roof, WoodenBox, Generator, ElectricalPanel, Barrel, Fence | GLB mit 40 Meshes, 8.563 Dreiecken; passende Texturatlanten. Eine zusammenhängende, charaktervolle Shelter-Gruppe statt wahlloser Props. FakeLight-Material ist BLEND: für neutrale Beleuchtung prüfen/deaktivieren. Innenraumzugang und Kollision noch nicht getestet. CursedLake erlaubt Projektnutzung und Änderungen, untersagt Asset-Weiterverteilung; Downloadname auf Autorenseite weicht leicht ab. |
| Straße, Pfadbegrenzung, kleine Architektur | **URBAN.zip**: modulare Building Parts, Roads/Road type 1, Fences, Müll-/Lüftungs-/Rohrmodule | GLB-Stichproben haben zugewiesene Materialien; manche Wandteile sind nur Flächen und brauchen bewusst gesetzte Kollisionskörper. Nicht die gesamte Stadtbibliothek laden. Dateistruktur und Teile entsprechen dem Urban Stacked Pack von valsekamerplant, Autorenseite **CC0**. Für den ersten Bereich 2–3 Straßenstücke plus wenige passende Module. |
| Bäume, Gras, wilde Büsche | **retro_nature_pack.zip**: acht Baum-, acht Busch- und zwölf Grasgrundformen mit Jahreszeiten-Texturen | GLB und FBX, 128er RGBA-Texturen. Geprüfter bush01-GLB: 160 Dreiecke, rund 0,7×1×0,7 lokale Einheiten, **keine Materialliste**. Texturen daher ausdrücklich zuweisen; Alpha-Scissor/Depth-Prepass, beidseitige Blätter und Schatten prüfen. Elegant Crow nennt Modelle CC0; Texturen AmbientCG, Bilder Pixabay separat dokumentiert. Eine Jahreszeit wählen. |
| Zusätzliche Baum-Silhouetten | **Retro Tree Pack v1.0.zip**: Low Res/GLB dead_tree_rt_1, small_tree_rt_1, tree_rt_* | GLB mit eingebetteten Bildern; toter Baum als Stichprobe 125 Dreiecke. Blätter MASK, beidseitig, sinnvolle günstige Silhouetten. Source-Node-Rotation beachten: rohe Z-Ausdehnung ist nicht automatisch Godot-Höhe. Pizza Doggy: aktuelle Seite bietet eigene Lizenz-PDF; ältere eigene Ankündigung nennt CC0. **Vor Import aktuelle Lizenzfassung sichern/Version zuordnen**, nicht stillschweigend CC0 annehmen. |
| Bodenrand, Felsen | **PSX_Large_Terrain_Rock_Pack.zip** und **…_2.zip** | Konkrete 2-m-FBX-Stichproben: 782 bzw. 1.458 Polygone laut Export, grobe Naturformen; Atlasvarianten bis 2K/4K/8K sind für den kleinen Bereich unnötig groß. Kleinere Atlasvariante testen, keine neue Terraintechnik nötig. Caliber Creations erlaubt Spielnutzung/Änderung/kompilierte Builds; untersagt öffentlich wiederverwendbare Rohdateien. Nicht ungeprüft in öffentliches Source-Repo übernehmen. |
| Praktische kleine Props | **Street Furniture.zip**: Barrel, Box, GarbageBag, Conditioner, Bottles, Flashlight usw. | 13 getrennte FBX/Blender-Objekte, meist 256er Texturen. Fass-Stichprobe 347 Vertices/319 Polygone; Maßstab nach Import am Player prüfen. Kkryy, Autorenseite **CC0**. Fass/Kiste/Müllsack reichen zunächst. |
| Begrenzung/Hecken | **all_fences.zip**, **All bushes.zip** | GLB/FBX; 4×2-m-Mauer-Stichprobe 44 Dreiecke, Heckenende 24 Dreiecke. Hecken nutzen BLEND und brauchen für saubere Schatten ggf. Alpha-Scissor. valsekamerplant bestätigt **CC0**. Hecken sind gepflegte Formteile, kein Ersatz für wilde Büsche. |

Offizielle Quellen: [Industrial](https://godgoldfear.itch.io/psx-industrial-environment-asset-pack),
[Shelter](https://cursedlake.itch.io/ps1-psx-post-apocaliptic-shelter),
[Urban](https://valsekamerplant.itch.io/psx-style-urban-stacked-pack),
[Natur](https://elegantcrow.itch.io/retro-psx-nature-pack),
[Retro Tree](https://pizzadoggy.itch.io/retro-tree-pack),
[ältere Tree-Ankündigung](https://itch.io/t/5198353/-retro-tree-pack-cc0-),
[Street Furniture](https://kkryy.itch.io/streetfurniture),
[Zäune](https://valsekamerplant.itch.io/psx-style-walls-fences),
[Hecken](https://valsekamerplant.itch.io/psx-style-hedges).
Rock-EULA liegt in beiden lokalen ZIPs als `Licence.txt` vor.

## Weitere gesichtete Pakete / Zurückstellung

| Archiv | Befund / Entscheidung |
| --- | --- |
| Buildings.rar | GLB: zehn Gebäudefassaden, 2.470 Dreiecke, viele Materialslots/kleine nicht quadratische Texturen. Eher Hintergrundbebauung; Innenräume und lokale Lizenz ungeklärt. |
| Builduings.rar | `Edificios.dae`, 17 Geometrien, Z_UP, meter=1, teils große Fassadenfotos. Gegenüber modularen GLBs mehr Material-/Achsenarbeit; Lizenz fehlt. |
| Cabañas.rar | Collada, 31 Geometrien, Z_UP und **meter=0.3**. Hütte prinzipiell passend, aber Einheit, Zeichencodierung und Lizenz müssen geklärt werden. |
| Forest Model Pack.zip | BlueberryBush/Pine_1/Fern-FBX tatsächlich gelesen; niedrige Geometrie, 256er Pflanzenatlanten, getrennte FBX-Unterordner. Gute optische Reserve für Wald, aber lokale Lizenz fehlt; nicht zusätzlich mit allen anderen Baumstilen mischen. |
| FREE APOCA.zip | GLB mit elf Props/1.714 Dreiecken: Radio, Schlafsack, Metallschrank, Reifen, Flaschen usw. Praktisch fürs Shelter; Lizenz im Archiv nicht belegt, deshalb Reserve. |
| Maquinas.rar | Collada mit zwölf Geometrien; industrielle Maschinenreserve. Z_UP, Materialpfade und Lizenz ungeklärt. |
| Objects_Interior(Village)_Demo.rar | Sammel-FBX mit House_Demo-Objekten; Inneneinrichtung statt Außenbereich. Zurückgestellt, Lizenz nicht im Archiv. |
| PSX modular house interior pack.zip | GLB archBrick-Stichprobe: 36 Dreiecke, zugewiesenes Mauer-Material; modulare Innenraumwände. Nützlich später, kein fertiges Außen-Shelter, Lizenzzuordnung offen. |
| psxAssets.zip | Road-/Bus-OBJ vorhanden, aber Material- und Autoren-Zuordnung weniger eindeutig als Urban/Industrial. Keine zweite Straßenbibliothek nötig. |
| PSX_The_Island_Pack.zip | Ground_0-FBX: 1.515 Vertices/3.026 Polygone; Farn und Küstenpflanzen geprüft. Größere Bodenmodule/Atlanten und Küstenästhetik passen weniger zum ersten kleinen Wald-Außenposten. EULA erlaubt Projekte, verbietet rohe Weitergabe und generatives Modelltraining. Nicht gewählt. |
| Rocas.rar / rocks.rar | Acht Collada-Felsen bzw. fünf getrennte FBX-Felsobjekte, einfache 128/256er Texturen. Technisch kleine Reserve, keine lokale Lizenz; Rock-Pack besser dokumentiert. |
| Sewer.rar | Collada mit 118 Geometrien: Rohre, Türen, Müll, Kanalmodule. Für späteren Innen-/Untergrundbereich, nicht den ersten Außenposten; Lizenz ungeklärt. |
| Survival.rar | 44 Collada-Geometrien inklusive Shelter_tent, Lagerfeuer, Behälter und vielen Gameplay-Objekten. Keine neuen Survival-Systeme daraus ableiten; selektive Props erst nach Lizenzklärung. |
| Vegetation.zip | Dateiname irreführend: Sammel-FBX enthält Archivschränke, Bücher, Dokumente, Geschirr, Holz usw. Nicht als verifizierte Baum-/Buschbibliothek behandeln; Lizenz fehlt. |
| DEMO_LoomingLandmarks-V1.2.zip | Windrad-GLB mit zwei Meshes/1.120 Dreiecken, 1024er Bake, BLEND-Material; Readme enthält Kontakt, keine klare Lizenz. Als Fernlandmarke später, für kleinen Startbereich unnötig. |
| - Classic 64 Asset Pack 0.6.zip | Überwiegend native `.blend`-Dateien und Materialien; keine direkten FBX/GLB-Modelle im gelesenen Exportinventar. Ohne Blender nicht modellseitig verifiziert, Stil außerdem bunter. |
| Chairs&Tables_PSX_Asset_Pack.zip | Native `.blend`/`.blend1` plus 64er Holztexturen; kein direkter getesteter Modell-Export. Einrichtung später, keine jetzt notwendige Blender-Abhängigkeit. |

## Ergänzende Textur- und Sammelpakete

| Archiv | Befund / Entscheidung |
| --- | --- |
| skyscraper_pack.zip | 18 FBX-Hochhäuser, building_01.1 als konkrete Stichprobe; 256er Fassaden. Für Stadtsilhouette später, nicht den kleinen Waldposten; lokale Lizenz fehlt. |
| Exploration objects.rar | Acht FBX-Geräte, EMF_Detector konkret gelesen, 512er RGBA-/Emissionskarten. Andere Spielrichtung und zusätzliche Interaktionsarbeit; jetzt nicht nötig, Lizenz offen. |
| miscmodelsAll.rar | Sammel-FBX mit Lampen, Büchern, Magazinen, Radio/TV usw.; Stichprobe strukturell gelesen. Praktische Innenraumreserve, aber Herauslösen/Quellenklärung nötig. |
| Models pack psx - new.rar | Sammel-FBX mit vielen generischen Cube-Namen, 256er Asphalt-/Fahrzeugtexturen. Schlechtere gezielte Wiederverwendung als Urban; Lizenz nicht enthalten. |
| Comida low poly.rar / Pesca.rar | Collada-Sammlungen mit Lebensmitteln bzw. Angel-/Holzobjekten; Geometrien tatsächlich gelesen, 256er Texturen. Nur spätere Dekoration, keine Survival-/Angelmechanik. Keine lokale Lizenz. |
| PSX-Ocean-Surface.zip | Godot-Shaderprojekt und 2048er Wassertextur, kein benötigtes Außenpostenmodell. Nicht importieren: Wasser-/Shadersystem außerhalb dieses Auftrags, Readme allein keine Lizenzfreigabe. |
| PSX_Sky_Sampler_v1-sky2test.zip | 256er Cubemaps sowie Beispiel-GLB mit Road/Verge/Pole/Wire/FencePost. Lokale Lizenz erlaubt persönliche/kommerzielle Nutzung/Änderung, verbietet Asset-Weitergabe. Spätere ruhige Tages-Skybox möglich; Demo-Level und Effekte nicht übernehmen. |
| PSX_Wood_Textures.zip | 128er Holztexturen, keine Modelle. Stilreserve, Lizenz im ZIP fehlt; jetzt bestehende Modelatlanten bevorzugen. |
| psx-textures-free-assets.zip | 128er Mauer-/Betontexturen, 16-Texturen-Demo plus Godot-Addon. Lokale Lizenz CC BY 4.0 / heyheythere. Falls später nötig nur PNGs, kein Textur-Addon übernehmen. |
| SBS - Base Materials Pack 256x256.rar / SBS - Tiny Texture Pack - 256x256.zip | Konkrete 256er Karton-/Ziegelbilder geprüft. Lokale CC0/Public-Domain-Lizenz. **Gute schlanke Ergänzung für eigenen Boden/Pfad**, falls vorhandene Modelatlanten nicht reichen. |
| SBS - Noise Texture Pack - 256x256.rar | 256er Risse/Noise, lokale CC0-Lizenz. Keine neuen Shader/Overlays daraus bauen; für diesen Bereich nicht nötig. |
| SBS - Seamless Sky Backgrounds - 512x512.rar | 512er RGBA-Himmelsbilder, lokale CC0-Lizenz. Als normale Himmelstextur später prüfbar, keine fertige atmosphärische Beleuchtung. |

## Vorschlag für den ersten Bereich

Ein **kleiner Wartungs-/Versorgungsposten am Waldrand**, ungefähr 25×30 m:
ein Industrial-Schuppen oder offener Cargo-Unterstand als Hauptform (alternativ
der Truck-Shelter, nicht beide als konkurrierende Hauptgebäude), eine kurze
schmale Zufahrt mit gebrochenem Straßenrand, ein umzäunter Arbeitshof, zwei
Fässer/eine Kiste, ein Stromkasten/Generator. Dahinter wenige ruhige Baumgruppen,
eine Busch-/Grasfamilie und 2–3 Felsen als Sichtbegrenzung. Naturboden anfangs
als kleines einfaches Mesh, keine Terrain-Generierung. Begrenzte Palette aus
verwittertem Holz, grauem Beton, stumpfem Metall und entsättigtem Grün.

Vor dem späteren Bau nur diese wenigen Assets in eine Maßstabs-/Materialprobe
importieren: begehbare Öffnungen, Kollisionen, echte Boden-/Baumhöhe, Texeldichte,
Alpha-Schatten und LOD-Bedarf testen. Keine Unity-Shader, Fake-Lichtkegel oder
Pack-Demoszenen übernehmen. Dieses Review ist eine Auswahlgrundlage, keine
Behauptung, dass alle Archive bereits fehlerfrei in Godot funktionieren.
