# Scripts

Eigene GDScript-Dateien verwenden `snake_case.gd` und nach Möglichkeit Typangaben.

- `fps_controller.gd`: Bewegung, Kollisionshaltung und direkte Maussteuerung.
- `interactor.gd`: Kamera-RayCast mit kurzer Reichweite; verarbeitet E im Physiktakt.
- `interaction_target.gd`: kleiner Objektvertrag: direkter Collider-Kindknoten
  namens `InteractionTarget`, `prompt`, `enabled` und Signal `interacted(actor)`.
  Der erste Collider blockiert den Strahl, auch ohne Interaktionskomponente.
- `test_switch.gd`: ausschließlich sichtbares Schalterfeedback der Testszene.
- `test_scene.gd`: einfache HUD-Anbindung und Beenden, kein allgemeiner Manager.
- `test_firearm.gd`: eine halbautomatische Waffe mit Munition, abbrechbarem
  Nachladen, ADS, kamerabasiertem Hitscan, Rückstoß und Physikimpulsen.
- `test_target.gd`: nicht zerstörbare Testtafel mit Trefferzählung und kurzem
  neutralem Farbfeedback. `receive_hit(damage: float)` ist der kleine Treffervertrag;
  normale Weltgeometrie blockiert Schüsse, ohne als Ziel bestätigt zu werden.

Controller-Werte einschließlich Geschwindigkeit, Beschleunigung, Schwerkraft,
Mausempfindlichkeit und FOV sind im Inspector der Player-Szene einstellbar.
Die Kapsel steht mit ihrem Ursprung am Fuß; Player nicht skalieren oder kippen.
Kollisionslayer: 1 Welt, 2 Physikobjekte, 3 Player (Bitwerte 1, 2, 4).
Die Mausaufnahme steuert über ein Signal auch die Eingabefreigabe des Interactors.
Bei Esc oder Fokusverlust sind Bewegungs- und Interaktionseingaben gesperrt;
Schwerkraft, Kollisionen und Weltphysik laufen weiter.

Die Testwaffe benötigt die Inspector-Referenzen `actor` (FPSController) und
`camera` (Camera3D); `player.tscn` setzt diese. Kein Autoload, keine Registrierung.
Mauseingaben werden als kurze Schussanforderung erfasst; die Physikabfrage erfolgt
nach der Player-Bewegung im nächsten Physiktakt. Es gibt keine Streuung,
Schusspufferung oder automatische Nachladung. Schussrate und Reload sperren
unzulässige Anforderungen, ohne dabei Munition zu verbrauchen.

Rückstoß wirkt nur auf die lokale Kamera und den visuellen Waffen-Knoten,
nicht auf Kollisionskapsel oder Mausblickwinkel. Die Abfrage erfolgt vor dem
neuen Rückstoßimpuls und folgt vorhandener Rückstoßauslenkung. Die ADS-
Empfindlichkeit wird optional anhand des FOV skaliert. Bei Mausfreigabe werden
Schussanforderungen, ADS und Nachladen zurückgesetzt; gehaltene Maustasten müssen
vor einer erneuten Aktivierung losgelassen werden.

Modelle unter `Visuals/ModelMount/Placeholder` ersetzen; den `ModelMount`,
`Muzzle`, `AudioMount` und die Root-Logik erhalten. Muzzle und Sound-Anker sind
bewusst einfache Marker. Die primitiven Kimme-/Korn-Elemente sind nur ein
Platzhalter. Es existieren keine echten Sounds, Rigs oder Animationssysteme.
