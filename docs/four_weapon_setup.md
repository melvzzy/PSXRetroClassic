# Vier einzeln testbare Waffen, standardmäßig ohne Arme

## F5-Auswahl

`scenes/startup.tscn` öffnen, Root **Startup** auswählen und im Inspector:

- **Test Weapon**: Makarov, AS Val, VSS oder SR-3 wählen; Szene speichern, F5.
- **Show Arms**: standardmäßig aus. Stellt für **Makarov** die vorherige
  Zweihand-/Finger-/Reload-Darstellung wieder her. Für Langwaffen existieren
  keine passenden Armposen; dort bleiben die Arme aus, auch wenn die Option an ist.
- **Use Imported Visuals**: ausschalten für den ursprünglichen Placeholder.

Kein Wechsel während des Spiels, kein Inventar. Die Profile unter
`scenes/weapons/profiles/` enthalten nur Modell-/Testwerte. Eine gemeinsame
`TestFirearm`-Instanz verarbeitet weiterhin Eingaben, Hitscan, Munition, Reload,
ADS, Rückstoß, Holster-Zustände und Physikimpulse.

| Profil | Magazin / Reserve | Mindestabstand Schuss | Reload | Hip-Recoil | ADS-FOV |
| --- | ---: | ---: | ---: | ---: | ---: |
| Makarov | 12 / 48 | 0,18 s | 1,35 s | 1,2° | 60° |
| AS Val | 20 / 80 | 0,12 s | 2,10 s | 0,85° | 60° |
| VSS | 10 / 40 | 0,22 s | 2,40 s | 1,0° | 55° |
| SR-3 | 20 / 80 | 0,11 s | 1,90 s | 0,95° | 60° |

Alle vier feuern **halbautomatisch**, auch die normalerweise automatischen
Vorbilder. Halten macht kein Dauerfeuer. Dies sind vorläufige Testwerte,
keine Waffensimulation. Makarov behält bewusst die bisherige 12/48-Konfiguration;
das ist keine Aussage über die Kapazität des dargestellten Originalmagazins.

## Darstellung

Die Modelle behalten ihre normalisierten Originalmaße: Makarov ca. 0,168 m,
AS Val 0,875 m, VSS 0,894 m, SR-3 0,640 m ohne optionalen Schalldämpfer.
Quell-FBX/PNG bleiben unverändert; Texturen und neutrale Materialien werden
über die vorhandenen Visual-Wrapper verwendet. Hip-Abstand und -Höhe sind
pro Profil eingestellt, sodass auch die hinteren Schäfte vor der Kamera-Nahgrenze
bleiben. Keine Kamera-/Movement-Änderung, Forward+ und 4× MSAA bleiben erhalten.

Alle vier Wrapper besitzen Muzzle und SightLine. Langwaffen-Sichtlinien wurden
aus tatsächlich gelesenen Kornvertices kalibriert (AS Val y≈0,04091 m,
VSS ≈0,04192 m, SR-3 ≈0,05697 m). Die gemeinsame Darstellung zentriert den
Marker im ADS, statt eine Handpose vorauszusetzen. Mündungen wurden an den
vorderen Laufquerschnitten geprüft. Hitscan bleibt kamerabasiert: Kamerastrahl
und Modellvorwärtsrichtung stimmen überein; die außermittige Hip-Mündung ist
kein zweiter ballistischer Strahl.

VSS verwendet vorerst **offene Visierung**: Das vorhandene Scope-Mesh wird nur
in dieser spielbaren Darstellung ausgeblendet. Es bleibt im Original und in
der F6-Modellvorschau erhalten. Keine erfundene Scope-Linse, kein Retikel oder
zusätzlicher Optikrenderer. Die sehr einfache hintere Visiergeometrie der
Langwaffen ist keine detaillierte mechanische Kimme.

Schussimpuls bewegt bei Makarov Schlitten/Visier/Auszieher, bei den drei
Langwaffen den separaten Auszieher geringfügig. Der gemeinsame Rückstoß wirkt
weiter auf die Waffendarstellung. Keine mitgelieferten Feuer-/Reload-Clips werden
behauptet: Die Langwaffen besitzen nur leere/konstante Quell-Actions.

Ohne Hände bleiben Magazine eingesetzt. Die Waffe neigt sich beim Reload als
Ganzes; der vorhandene Reload-Roll wird jetzt kurz interpoliert, um den bisherigen
sichtbaren Sprung beim Start/Ende zu entfernen. Die Munition wird weiterhin nur
am Ende des ursprünglichen Timers übertragen. Holstern senkt das Modell ab und
blendet es erst am Ende aus; gezogen wird derselbe Zustand, ohne gehaltene
Maustasten als neue Schüsse/ADS zu behandeln.

## Erhaltung der Arme und Grenzen

Der Makarov-Adapter, alle Bone-/Fingerposen, Teilebindungen, Original-GLB und
Animationen bleiben erhalten. Im Standardmodus ist dessen kompletter Teilbaum
unsichtbar und im Prozessmodus Disabled; der AnimationPlayer ist zusätzlich
inaktiv. Die sichtbare Waffe ist eine eigene Visual-Instanz und folgt keinem Bone.
Die Arm-Regressionsszenen aktivieren Show Arms ausdrücklich und prüfen weiterhin
den bisherigen Griff, ADS, Teil-Reload und Holster-Zyklus.

Das ausgeblendete Rig wird aus der Szene weiterhin geladen; dies ist keine
Speicher-/Streaming-Optimierung. Nur Makarov hat passende Armposen. Kein
realistischer Magazinwechsel, keine Sounds, kein Vollautomatikmodus und keine
vollständige Optik. Große Schäfte und einfache Texturatlanten bleiben als
Eigenschaft der Originalmodelle sichtbar. Wand-Clipping wird nicht durch ein
neues System kaschiert.

## Verifikation / manuell

Godot **4.7.2.stable.official.ed1daf0bf**, Windows, Forward+/Vulkan/RTX 5060 Ti.
**4.6.3 weiterhin nicht getestet.** Import, begrenzte Starts und die vorhandenen
235 Regressionen bestanden; zusätzlich 87 Vier-Waffen-Checks (zusammen 322).
Der Grafiklauf besteht mit 107 Checks und 20 Aufnahmen. Zusätzlich besteht
der wiederhergestellte Makarov-Armaufbau mit 36 Grafikchecks und acht Aufnahmen;
die Haltepose wurde auch visuell kontrolliert. Der Grafiktest erzeugt je Modell
Hip-, ADS-, Schuss-, Reload- und Holstered-Bilder unter
`.godot/checks/four_weapons/`. Alle Modi wurden gerendert; insbesondere die
Hip-/ADS-Ansichten werden auf tatsächliche Geometrie statt nur Marker geprüft.
Die zusätzliche Geometrieprüfung kontrolliert die echte Kornlinie und Nahgrenze.
Inaktive Arme dürfen die sichtbare Waffe auch nach Transformänderungen nicht bewegen.
Ein physischer Klick muss sowohl Munition verbrauchen als auch die Testtafel treffen.
Dies ist automatisierte und programmatisch gerenderte Prüfung, kein vollständiger
manueller Windows-Spieltest und keine FPS-Messung. Die bekannte Meldung zum
Windows-Zertifikatsspeicher bleibt als Umgebungsproblem separat dokumentiert.

F5 manuell für jedes Profil: Hip/ADS beim Umsehen/Laufen/Ducken; einzelne/rasche
Klicks und gehaltene LMB; R partiell/leer; X während ADS/Reload und mehrfach
ziehen/wegstecken; Esc/Alt-Tab/Recapture; Treffer auf Tafel/Props und E.
Dann Makarov mit Show Arms und anschließend den Placeholder-Fallback testen.
Nähe zu Wänden, Schaft-Framing, Ziellinie und echte FPS beurteilen.

Nächster Schritt: ein Profil beim manuellen F5-Test als Referenz für Handling
und endgültiges Framing festlegen; danach gezielt passende Waffen-/Reload-Clips
oder eine echte VSS-Optik ergänzen, ohne schon ein Inventar zu bauen.
