# Decision evidence, part 2 — sanitized excerpt

Source: the sparring assessment `20261003-104113-loop-usefulness-warning-assessment.md`
(German, local and untracked), on which Daniel decided the part-2 narrowing on 2026-10-03.
Quoted verbatim where kept; what was removed and why is listed in `../README.md`.

Meine Empfehlung ist Option 1 als begrenzte erste Stufe. Die vollständige Nutzenbewertung bleibt ausdrücklich offen. Option 2 allein wegen der Farbe Grün zu bauen, wäre kein ausreichender Grund für den Mehraufwand.

## Belege (excerpt)

- docs/superpowers/specs/2026-10-02-loop-usefulness-design.md §2 schließt Findings- und Dispositions-Dateien als Eingaben aus.
- §3 erklärt Wahrheit der Befunde und tatsächlich geprüften Umfang als unbekannt.
- §5, insbesondere Zeile 111, vergibt trotzdem pauschal Grün unterhalb der Warnschwellen. Der Widerspruch ist damit im Text nachvollziehbar.
- docs/superpowers/stories/2026-10-02-review-loop-usefulness-assessment-story.md fordert eine erklärte Ampel und die Kalibrierung gegen Vision und Feldberichte.
- docs/superpowers/specs/2026-08-30-dark-factory-vision.md §4 verlangt bestätigte unterschiedliche Befunde, Reparaturwirkungen, Aufwand und Abdeckung; fehlende Beweise dürfen nicht grün werden.

## Einordnung (excerpt)

Option 1 bietet einen begrenzten Nutzen: ungewöhnlich lange oder wieder ansteigende Review-Verläufe sichtbar machen. Sie beantwortet nicht, ob die Schleife ihren Aufwand wert war. Diese Einschränkung muss im Produktversprechen und im verbleibenden Arbeitsumfang stehen, nicht nur in einer Fußnote.

## Bedingungen für Option 1

1. **Warnung und Nutzen getrennt darstellen.** Gelb/Rot heißen Anlass zur menschlichen Neubewertung, nicht bewiesene Verschwendung oder schlechte Reviewqualität. Ohne ausgelöstes Signal: „Keine Warnschwelle in den verfügbaren Daten erreicht; Nutzen unbekannt.“ Bei unzureichenden Daten ausdrücklich „Warnstatus nicht vollständig bestimmbar“. Fehlende Vergleiche sind keine Nullwerte. Ein bereits belegtes Warnsignal bleibt trotz anderer fehlender Daten sichtbar.
2. **Kalibrierung bleibt erforderlich.** Historische und Feldberichtsfälle mit erwarteter Empfehlung und Grenzen durchgehen. Fälle, die gleiche Zahlen, aber verschiedene Produktwirkung haben, zeigen eine Grenze des Warnlichts. Diese Grenze darf sichtbar bleiben; sie zählt nicht als bestandene Unterscheidung. „Provisorisch“ ersetzt die Prüfung nicht. Warnungen müssen erklären, warum Neubewertung empfohlen wird; sie lösen keine automatische Fortsetzung, Reparatur oder Freigabe aus.
3. **Keine Wirkungsbehauptung aus Dateipfaden.** Ein ausführbarer Plan unter docs/ ist nicht allein deshalb nicht-operativ. Fehlt belastbare Wirkungsevidenz, bleibt die Produktdistanz unbekannt. Zahlenbasierte Warnungen dürfen trotzdem möglich sein, mit offengelegter begrenzter Aussage.
4. **Umfang bewusst ändern.** Nach Daniels Entscheidung Story-Ziel, Akzeptanzkriterien und Spec konsistent auf das Warnlicht begrenzen, datiert und mit Zuordnung der bisherigen Anforderungen: beibehalten, eingeschränkt oder vertagt. Die vollständige Nutzenbewertung in Epic/todos bleibt offen. Eine Notiz allein erfüllt die ursprünglichen Anforderungen nicht. Bestehende Gates und Stopps gelten weiter.

Preis: Teil 2 liefert zunächst ein Warninstrument, keinen Nachweis für lohnende Reviews und keine Grundlage für mehr Autonomie. Wenn Daniel jetzt bereits eine Entscheidungshilfe „War diese Schleife ihren Aufwand wert?“ benötigt, genügt Option 1 nicht; dann muss die Evidenzarbeit aus Option 2 gezielt geplant werden, ohne Grün zu versprechen.
