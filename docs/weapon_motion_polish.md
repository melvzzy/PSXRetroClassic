# Waffenbewegung und Übergänge

Die vorhandene Trennung bleibt: TestFirearm besitzt Eingaben, Munition, Treffer,
Timer und Zustände. WeaponOnlyViewmodel setzt deren sichtbare Darstellung um.
Keine neue Zustandsmaschine, kein Animation-Framework und kein Autoload.

## Sichtbare Änderungen

- Sprint trägt die Waffe abgesenkt und diagonal, statt nur um wenige Zentimeter
  zu verschieben. TestWeaponProfile enthält `sprint_offset` und
  `sprint_rotation_degrees`; Makarov, VSS und die WW2-Waffen erhalten angepasste
  Werte. SR-3 wird beim Sprint etwas weiter von der Kamera gehalten, damit der
  hintere Modellteil nicht die Near Plane schneidet. Hip-/ADS-Kalibrierung und
  reale Modellgröße bleiben erhalten.
- Die Tragehaltung folgt tatsächlicher Bewegung oberhalb der Gehgeschwindigkeit.
  Beim Anlaufen blendet sie sanft ein, beim Blockieren an einer Wand aus.
  Seitwärtsbewegung ergänzt maximal wenige Millimeter Positionsnachlauf und
  etwa einen Viertelgrad Roll. Sprung/Fall und Landungsrückkehr wirken nur als
  kleine, geglättete vertikale Waffenbewegung, nicht auf die Kamera.
- ADS, Reload, Holster und Schussbereitschaft haben Vorrang. Ein kosmetischer
  180-ms-Haltewert wird ausschließlich bei tatsächlichen Schüssen erneuert;
  die Tragepose pumpt dadurch nicht mehr zwischen automatischen Schüssen.
  Es gibt keine zusätzliche Sprint-to-fire-Sperre: Treffer bleiben unmittelbar.
- Zeichnen während des Sprints bereitet bereits während der vorhandenen
  Ziehzeit die Tragepose vor. Die Waffe muss nicht erst in Hip-Ready ankommen
  und anschließend wieder abgesenkt werden. Die logische Ziehsperre bleibt.
- Holster senkt und kippt die Waffe so weit, dass auch lange Mündungen vor dem
  Ausblenden unter dem Bildrand liegen. Modellwechsel zeigt weiterhin genau
  ein aktives Modell; neue Modelle beginnen abgesenkt. Keine neue Wechselphase.
- Beim Wechsel aus ADS bleibt das momentane FOV für die bestehende Interpolation
  erhalten. Dadurch entfällt der sofortige Sprung zur Hip-Vergrößerung.
  Fokusverlust/Esc setzt die Kamera weiterhin unmittelbar zurück.
- Profilabhängiger `visual_kick` / `visual_recovery` trennt sichtbaren
  Verschluss-/Waffenkick vom Kamera-Rückstoß. Kompakte Waffen kehren schneller
  zurück, STG 44 etwas kräftiger/langsamer. Kamera-Recoilwerte unverändert.
- Der Placeholder-Mündungsanker folgt jetzt derselben Trage-/Holsterbewegung
  wie sein sichtbares Modell. Bei importierten Waffen folgt er weiterhin dem
  tatsächlichen Modellmarker.

Die vorhandene Reload-Geste bleibt am echten Reload-Fortschritt orientiert;
keine bewegten losgelösten Magazine erfunden. Idle bleibt ruhig. Walk Motion und
Motion Response liegen am Adapter; Tragepose und sichtbarer Kick in den acht
Profilen. Mausbewegung, Bewegungswerte, Kollision, Feuermodi, Kadenz, Munition,
Reload-Zeiten, Hitscan und physische Impulse wurden nicht verändert. Optionale
Drillimpact-Posen und deren Handbindungen bleiben erhalten; neue Carry-Posen
betreffen die normale weapon-only Darstellung. Kein Charakter, Audio oder Mapbau.

## Verifikation und Grenzen

Godot 4.6.3.stable.official.7d41c59c4, Forward+/Vulkan/RTX 5060 Ti.
Vollständige Regression: 747 Checks. WeaponMotion ergänzt 99 Fälle im echten
F5-Startup: alle acht Trageposen, Near Plane, Mündung, ADS-Bildmitte, Ready,
Holster/Draw, unmittelbare Schüsse, FOV-Rückweg, Burst-Haltezeit, unterbrochenes
Reload, blockierter Sprint, Placeholder und Draw-zu-Sprint.

Grafik: WeaponMotion 118 Checks / 19 Captures, erhaltene Makarov-Arme 36/8,
Outdoor 49/5, insgesamt 203/32. Native Ansichten kontrolliert. Logs enthalten
nur die bekannte Windows-Zertifikatsspeicher-Meldung, keine Projektfehler.
Bilder `.godot/checks/weapon_motion/`, insbesondere `sprint_0..7.png`,
`ads_0..7.png`, `burst_ready.png`, `draw_into_sprint.png`, `reload_from_sprint.png`.
Log `.godot/checks/motion-polish-final-suite.txt`; zusätzliche Grafiklogs
`motion-final-*-render.log` samt Fehlerlogs.

Kein vollständiger manueller Spielgefühl-/FPS-Benchmark. Einfache Quellmodelle,
bestehendes Waffen-/Wand-Clipping und fehlende detaillierte Reload-Clips bleiben.

F5: alle acht Slots prüfen, mit Shift anlaufen/stoppen und gegen eine Wand laufen;
Sprint direkt mit RMB/LMB/R/X/1–8 unterbrechen. Laufend zielen, automatische
Salven und Einzelschüsse, Nachladen abbrechen und Munition nach Rückwechsel
kontrollieren. Springen/landen/ducken und Esc/Alt-Tab/Recapture prüfen. Optional
Makarov-Arme und Placeholder separat starten. Stärke der Tragewinkel subjektiv
bewerten; Parameter vor weiterer Mechanik anhand dieses Tests feinjustieren.
