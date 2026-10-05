# Decision evidence, part 1 — sanitized excerpt

Source: the sparring assessment `20261002-132344-telemetry-t1-scope-triage-assessment.md`
(German, local and untracked), on which Daniel decided the part-1 narrowing on 2026-10-02.
Quoted verbatim where kept; what was removed and why is listed in `../README.md`.

## Empfehlung

Eine modifizierte Option 1 wählen: bestätigte Story-Zuordnung vereinfachen, aber Messdaten offener und abgebrochener Versuche nicht wegen eines fehlenden Abschlusscommits verwerfen. Option 1 in der angebotenen Form verschlechtert den Messzweck; unbegrenztes Weiterreparieren bei unverändertem Anspruch ist ebenfalls keine sinnvolle Vorgabe.

Die entscheidende Trennung lautet: Repo-Zugehörigkeit bestimmt, welche Daten der lokale Collector aufnehmen darf. Story-Zuordnung bestimmt, unter welcher Story bereits aufgenommene Daten ausgewertet werden. Ein fehlender Story-Nachweis ist kein Beweis, dass kein messenswerter Aufruf stattgefunden hat.

## Einordnung (excerpt)

**Der Aufwand abgebrochener Versuche gehört zur Fragestellung.** Wenn nur historisch nachgewiesene abgeschlossene Zyklen in den Speicher gelangen, werden nie abgeschlossene Versuche systematisch ausgeschlossen. Das ist eine Verzerrung zugunsten abgeschlossener Arbeit, keine neutrale Vereinfachung. Tokens und Laufzeit können schon verbraucht worden sein, auch wenn ein Zyklus nie endet. Die bestehende Story will gerade Aufwand zusammen mit Messlücken zeigen. Geld/Credits sind inzwischen ausdrücklich ausgeschlossen; hier geht es um Aufwand in Tokens und Zeit.

**Unattributed und nicht gespeichert sind verschiedene Ergebnisse.** Der Vorschlag verspricht „alles andere nicht zugeordnet, mit Grund“, sagt aber zugleich, nie abgeschlossene Zyklen würden nicht gespeichert. Ohne gespeicherten Datensatz bleibt nach dem Löschen der Rohquelle auch kein dauerhaft auswertbarer unzugeordneter Aufwand übrig. Die Entscheidung muss diesen Unterschied offen benennen.

## Konkrete Begrenzung, die ich empfehlen würde

1. **Story-Zuordnung v1 nur über eindeutige Abschluss-Provenienz.** Die Pflicht „wo immer bestimmbar“ entsprechend begrenzen. Freie Story-Erwähnungen und nachträgliches Erraten über aktuelle Artifact-Header entfallen. Konflikte oder fehlender Abschlussnachweis bleiben sichtbar unzugeordnet. Ein Commit-Eintrag belegt dabei aufgezeichnete Provenienz, nicht unabhängig deren Wahrheit.
2. **Repo-Aufnahme bleibt davon getrennt.** Eindeutig diesem Klon zugehörige Tool-Aufrufe werden auch ohne Abschlusscommit gespeichert. Dafür einen engen, überprüfbaren Repo-Kontext verwenden; der vorhandene common-directory-Ansatz ist als Ausgangspunkt ausreichend konkret, sein gemeldeter Einfluss durch geerbtes GIT_DIR muss behandelt werden. Kein beliebiges Fremdprojekt importieren, um Vollständigkeit zu behaupten. Nicht mehr belegbare Repo-Zugehörigkeit, etwa bei entfernten Worktrees ohne andere Evidenz, darf ausdrücklich außerhalb der v1-Abdeckung bleiben und wird als Einschränkung benannt. Ein passender History-Nonce allein wird nicht stillschweigend zum Beweis lokaler Ausführung.
3. **Messwerte bleiben ohne Story nutzbar.** Für aufgenommene Aufrufe ohne bestätigte Story Anzahl, bekannte Token-/Zeitbeiträge und fehlende Beiträge ausweisen. Keine erfolgreiche Gate-Prüfung oder bestätigte Gate-Absicht allein aus dem Toolnamen ableiten. Story-Summen heißen zugeordneter Aufwand, nicht vollständiger Gesamtaufwand dieser Story.
4. *(removed: spec-level repair advice, see README)*
5. **Scope-Änderung bewusst dokumentieren.** Bei einer von Daniel bestätigten Änderung jedes alte Kriterium als beibehalten, ersetzt oder bewusst eingeschränkt ausweisen und auch Desired outcome/umgebende Zusagen anpassen. Die geänderte Menge kostet nach §5 einen weiteren Pass; weder die menschliche Scope-Entscheidung noch dieser Rat schließen das Gate. Bestehende Stopps und Abschlussregeln bleiben in Kraft. Minor/Nit-Funde nicht als „billig“ zum pauschalen Zusatzauftrag machen; ihre eigene Severity rechtfertigt keine Reparaturrunde.

Der Preis dieser Variante: Vor Abschluss können Story-Reports unvollständig sein. Der Gesamtüberblick über eindeutig lokale, beobachtete Aufrufe behält jedoch auch fehlgeschlagene Arbeit. Historische Aufrufe mit nicht mehr belegbarer Repo-Zugehörigkeit bleiben eine offen ausgewiesene Abdeckungslücke. Damit fällt das komplexe Rekonstruieren jeder möglichen Story-Verbindung weg, ohne den Messzweck auf erfolgreich abgeschlossene Arbeit zu reduzieren.

Wenn Daniel tatsächlich nur eine Auswertung abgeschlossener Zyklen will, ist die ursprüngliche Option 1 als bewusst anderes Produkt möglich. Dann müssen Titel, Nutzenversprechen und spätere Aussagen zur gesamten Workflow-Effizienz entsprechend eingeschränkt werden. Für das erklärte Ziel der Aufwandsmessung empfehle ich das nicht.
