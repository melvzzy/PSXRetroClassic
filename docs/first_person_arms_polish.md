# Makarov / Drillimpact: sichtbare Anpassung

Stand 19.10.2026. Dieser erhaltene Aufbau wird inzwischen über **Show Arms**
für Makarov aktiviert; Standard F5 ist der [Weapon-only-Modus](four_weapon_setup.md).
Der Armaufbau verwendet unverändert die vorhandene
Waffenlogik, Kamerasteuerung und das ursprüngliche Rig/Material. Keine neuen
Modelle, keine Retargeting- oder Runtime-IK-Abhängigkeit.

## Was sich sichtbar geändert hat

- Die Waffenposition relativ zur rechten Hand wurde an den tatsächlichen Griff
  angepasst. Mittel-, Ring- und kleiner Finger liegen um dessen Vorderseite,
  der Zeigefinger am Abzugsbereich; der Daumen liegt seitlich unterhalb des
  Schlittens. Alle drei Gelenke jeder Fingerkette beider Hände erhalten lokale
  Posen, insgesamt 30 Fingergelenke, statt nur einer Daumenkorrektur.
- Die linke Schulter-/Arm-/Handkette bildet einen festen Stützgriff. Bei der
  einmaligen Pose-Kalibrierung werden die vorhandenen Segmentlängen benutzt;
  es gibt keinen laufenden Zielverfolger/IK-Solver. Die Pose wird danach wie
  jede andere native Skeleton3D-Pose interpoliert. Unveränderte Metermaße und
  Skin-Gewichte; die Pistole folgt weiterhin hand.R mit konstantem Grifftransform.
- ADS behält diesen Zweihandgriff. Die Ausrichtung wird weiterhin aus SightLine
  abgeleitet, ohne Kamera-/Hitscan-Richtung aus dem Rig zu steuern.
- Schuss bewegt beide Arme über den bestehenden Waffenrückstoß. Zeigefinger
  zieht kurz an; Schlitten, Visiermesh und Auszieher laufen gemeinsam zurück
  und erholen sich. Keine zusätzliche Schussinstanz oder geänderte Kadenz.
- Beim Reload löst sich die linke Hand, greift nach unten zum vorhandenen Magazin,
  zieht es herunter, setzt es wieder ein und kehrt zum Stützgriff zurück.
  Das gezogene Magazin ist über einen festen lokalen Grifftransform an hand.L
  gebunden. Volles/leeres Mesh bleiben alternative Varianten, keine Doppelung.
- Holstern/Draw blenden weiterhin kurz zur entspannten Quellpose bzw. zum
  angepassten Griff. Beide Hände bleiben weggesteckt sichtbar. Beim Laufen
  kommen höchstens wenige Millimeter Viewmodel-Bewegung hinzu, im ADS ausgeblendet;
  kein Headbob, zusätzliche Kamerabewegung oder geglätteter Mausblick.

## Timing und Grenzen

`TestFirearm.get_reload_progress()` ist nur ein lesender Zugriff auf den
bestehenden Timer. Die Darstellung erreicht das Magazin im ersten Sechstel,
zieht ungefähr zwischen 18–38 % heraus, setzt zwischen 60–80 % ein und kehrt
bis zum Abschluss zurück. Munition wird weiterhin ausschließlich bei erfolgreichem
Reload-Ende übertragen. Bei Abbruch ist die Spiellogik sofort abgebrochen,
während Hände/Magazin kurz und ohne neue Munition in die Ruheposition zurückkehren.

Das ist **eine stabile Teil-Nachladesequenz**, keine vollständig realistische
Makarov-Nachladung: kein zweites Magazin, keine Tasche, kein Bediengriff am
PM-Magazinhalter, kein modellierter Magazinwechsel in der linken Hand.
Finger-/Daumenflächen können sich in extremen Nahansichten noch berühren oder
schneiden; das niedrig aufgelöste Mesh und seine ursprünglichen Gewichte erlauben
keine perfekte Anatomie. Kleine Handgelenk-/Handflächenfalten und kantige
Fingerkuppen bleiben. Kein neuer Haut-/Material- oder Sound-Auftrag wurde ergänzt.
Wand-Clipping bleibt ebenfalls möglich. Die groben Armproportionen wurden nicht
heimlich skaliert, um eine einzelne Kameraansicht zu kaschieren.

## Verifikation und Bilder

Godot **4.7.2.stable.official.ed1daf0bf**, Windows, Forward+/Vulkan auf RTX 5060 Ti.
4.6.3 ist weiterhin nicht getestet. Ausgangssuite 205 Checks; aktueller Runner:
**235 Checks** (40 FPS + 43 Gunplay + 32 Arms + 60 Weapon Assets + 32 Foundation
+ 28 Arms/Weapon Polish). Import, begrenzter Spielstart und beide Previews
erfolgreich; bekannte Windows-Zertifikatsspeicher-Meldung bleibt, keine anderen
abschließenden Script-/Resource-/Scene-Diagnosen.

Die neue Prüfung vergleicht alle 30 Fingergelenke mit der Originalpose, prüft
Stützhandnähe, ADS-Zentrum, Teilekopplung, Hand-/Magazinbindung, tatsächliche
Schuss-/Reload-Zustände, Rückkehr nach Holstern/Draw/Abbruch, gültige Skeleton-
Transforms und stetige hierarchische Posepfade in festen Blend-Schritten.
Das allein beweist keine visuell perfekte Anatomie.

Grafiklauf mit `tests/arms_weapon_polish_checks.gd -- --capture`:
**36 Checks**, acht native Captures unter `.godot/checks/weapon_captures/`:
`hands_idle`, `hands_ads`, `hands_firing`, `hands_reload_reach`,
`hands_reload_withdraw`, `hands_reload_reseat`, `hands_holstered`,
`hands_grip_detail`. Alle wurden visuell geprüft. Die Detailansicht nutzt nur
im Test eine abweichende Kamera und zeigt auch die oben genannten Mesh-Grenzen.
Die übrigen Bilder stammen aus der tatsächlichen spielbaren Szene. Dies ist
programmatisch gesteuerte grafische Prüfung, kein vollständiger manueller
Windows-Spieltest und kein FPS-Benchmark.

F5 manuell: Hip-/ADS-Griff beim Umsehen, Laufen und Sprinten ansehen; Einzel- und
rasche Schüsse samt Rückkehr beobachten; partiell/leer nachladen und die linke
Hand beim Herausziehen/Wiedereinsetzen prüfen; Reload durch X und Esc/Alt-Tab
abbrechen; mehrfach X ziehen/wegstecken; gehaltene LMB/RMB dürfen beim Ziehen
nichts auslösen. E/Physikziele und den vor Start aktivierten Placeholder-Fallback
separat testen. Nah-/Wand-Clipping, Handflächenkontakt und echte FPS beurteilen.

Nächster sinnvoller Schritt: die jetzigen festen Kontaktpunkte als Referenz
für eine kleine, gezielt authorierte Makarov-Sequenz mit echter Magazinübergabe
und korrigierter Handflächen-/Finger-Skin-Geometrie verwenden. Erst danach
weitere Waffen oder größere Umgebungsarbeit anbinden.
