# Asset-Konventionen

Aktuell keine externen Assets. Diese Regeln gelten für spätere, ausdrücklich
beauftragte Importe; Ordner erst mit den ersten tatsächlichen Dateien anlegen.
Ziel sind glaubwürdige, leicht raue PS1/PS2-Umgebungen mit einfacher Geometrie,
erkennbaren niedrig aufgelösten Texturen und zurückhaltender moderner Beleuchtung.

## Maßstab und Ausrichtung

- 1 Godot-Einheit = 1 Meter; +Y zeigt nach oben. Gameplay blickt entlang -Z,
  +X ist rechts. Modelle anhand ihrer tatsächlichen Ausrichtung prüfen und eine
  nötige Drehung/Skalierung unter dem Modell-Anker vornehmen, nicht am Player.
- Der Player-Ursprung liegt am Fuß: stehende Kapsel 1,8 m hoch, Radius 0,3 m,
  Augenhöhe 1,65 m; geduckt 1,1 m / 0,95 m. Das sind die Kollisions-/Kameramaße,
  keine Vorgabe, ein späteres Charaktermodell zu verzerren. Humanoide zunächst
  ungefähr 1,7–1,9 m groß prüfen. Controller und Physikkörper nicht skalieren.
- Waffen zunächst in plausibler Originalgröße importieren. Viewmodel-Lage und
  Visierausrichtung über die vorhandenen Hip-/ADS-Werte und `ModelMount` anpassen.
  Eine Laufachse entlang lokal -Z vereinfacht die Ausrichtung der Mündungsmarker.

## Quellen und wiederverwendbare Szenen

- GLB oder glTF samt externen Texturen/Binärdaten unter `assets/source/<pack>/`
  ablegen; Herkunft und Originalbezeichnungen dort nachvollziehbar halten.
  Bestehendes `assets/audio/` ist für Audio vorgesehen.
- Wiederverwendbare `.tscn`-Szenen unter `scenes/` instanziieren die importierte
  Szene als Visual-Kind. Kollision, Skripte und Interaktionskomponenten gehören
  in diese Gameplay-Hülle. Keine Änderungen an generierten `.godot/`-Dateien;
  Godot-Import-Sidecars und `.uid`-Dateien erhalten.
- Gebäude-/Modulursprünge an einer nachvollziehbaren Bodenkante setzen und
  Anschlüsse auf ein Meter-Raster ausrichten, sofern das tatsächliche Pack dazu
  passt. Keine Raster-/Sockel-Frameworks und keine leeren Figuren-Rigs anlegen.

## Kollision und bestehende Verträge

- Unbewegliche Gebäude: `StaticBody3D` mit einfachen Kollisionsformen; konkave
  Dreiecksformen nur für statische Geometrie, wenn für Durchgänge nötig.
- Bewegliche Props: `RigidBody3D` mit Primitiven oder vereinfachten konvexen
  Formen, Masse in kg passend zur Größe; keine konkaven dynamischen Meshes.
- Layer 1 = Welt (Bitwert 1), 2 = Physikprops (2), 3 = Player (4). Bestehende
  Strahlen/Player treffen Welt und Props (Maske 3); Props kollidieren mit allen
  drei (Maske 7). Rein visuelle Waffen-/Charakterteile erhalten keine Kollision.
- Bedienbare Collider erhalten direkt ein Kind `InteractionTarget`; dessen
  Signal `interacted(actor)` mit der lokalen Funktion verbinden. Zählbare
  Trefferziele implementieren `receive_hit(damage: float)`. Nicht bedienbare
  Collider blockieren Strahlen weiterhin; keine zweite Kollision nur für Visuals.

## Waffe und spätere Animationen

- Nur `test_firearm.tscn/Visuals/ModelMount/Placeholder` durch eine Modellinstanz
  ersetzen. Root, Actor-/Camera-Referenzen und `Visuals` erhalten; die Waffenlogik
  besitzt die Position/Rotation von `Visuals` sowie den Kamera-Rückstoß.
- `Visuals/Muzzle` an die neue Mündung verschieben, `Visuals/AudioMount` für
  spätere Audioquellen verwenden. Hitscan bleibt kamerabasiert und unabhängig
  vom sichtbaren Lauf. Die kleine vorhandene `Flash` ist austauschbares Feedback.
- Bewegliche Waffenteile/Animationen erst mit dem echten Modell ergänzen und
  auf dessen Kindknoten unter `ModelMount` begrenzen. Animationsspuren dürfen
  Kamera, Kollision und die von Gameplay gesteuerten Root-/Visuals-Transforms
  nicht überschreiben. `CharacterVisuals` bleibt der Anker für spätere Figuren.

## Texturen, Materialien und Licht

- GLB/glTF zunächst mit gemeinsam genutzten importierten Materialien instanziieren.
  Nur tatsächlich anzupassende Materialien einmal extern als `.tres` speichern
  und beim Reimport wiederverwenden; nicht jede Instanz unabhängig duplizieren.
  Absichtlich individuelle Farbänderungen wie beim Testschalter brauchen dagegen
  eine lokale Materialkopie. Nach einem Reimport Materialzuordnungen prüfen.
- Für Welttexturen zunächst Mipmaps erzeugen. Für grobe Retro-Texturen am 3D-
  Material `Nearest with Mipmaps` prüfen; bei stark flimmernden schrägen Flächen
  lineare/anisotropische Filterung gezielt vergleichen. Filterung ist eine 3D-
  Materialoption, Mipmap-Erzeugung eine Texturimportoption. Keine globale
  Abschaltung von Mipmaps. Atlasränder/UV-Padding beim echten Pack kontrollieren.
- `StandardMaterial3D` mit Albedo und plausibler Rauheit ist der Ausgangspunkt
  für Forward+. Metall-, Normal- und Alphakanäle nur nutzen, wenn die Vorlage
  sie sinnvoll mitbringt. Undurchsichtige Materialien bevorzugen; keine
  ungewollt leuchtenden/unbeleuchteten Weltmaterialien oder neuen Retro-Shader.
- Das vorhandene Richtungslicht mit Schatten und farbbasierte Umgebungslicht
  zunächst beibehalten. Nach dem Import Albedo/Größe prüfen, bevor Belichtung
  oder Lichtenergie verändert werden. Importierte Kameras/Lichter nicht
  ungeprüft aktivieren; keine packweise eigene Belichtung oder Effektstapel.

Godot-4.6-Referenz für [Kollision und Materialimport](https://docs.godotengine.org/en/4.6/tutorials/assets_pipeline/importing_3d_scenes/advanced_import_settings.html)
und [Texturimport/Mipmaps](https://docs.godotengine.org/en/4.6/tutorials/assets_pipeline/importing_images.html).
Texeldichte, endgültige Waffenproportionen, Animationszuordnung und Kompression
erst anhand der tatsächlichen Packs festlegen; noch keine Importautomatisierung.
