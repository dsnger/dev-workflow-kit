# Prompts (verbatim, as sent)

A1–G1 are the strand-C pilot's prompts, unchanged (`git show b348b9c:docs/superpowers/replays/2026-10-10-intake-skill-pilot/prompts.md`). H1–H3 and the `/compact` turn are new (plan Task 5). H runs as turn 1 = H1, turn 2 = `/compact`, turn 3 = H2, turn 4 = H3, one session.

## A1

````text
/dev-workflow:intake Rohe Idee (Sprachnotiz): Beim Export-Job brauchen wir eine Möglichkeit, dass Admins einen laufenden Export abbrechen können. Heute läuft ein gestarteter Export immer bis zum Ende durch, auch wenn er falsch konfiguriert war, und blockiert dann stundenlang die Queue. Wenn abgebrochen wird, soll der Export als "cancelled" im Verlauf stehen, beim Kunden darf keine halbe Datei landen, und der nächste Export in der Queue soll innerhalb einer Minute starten. Nur Admins dürfen abbrechen.
````

## A2

````text
Profile confirmed as proposed. For any clarifying question you asked: use your best reading of my input, and record anything still unclear under Open questions. Proceed.
````

## A3

````text
Approved as shown. Write and commit it.
````

## B1

````text
/dev-workflow:intake Amend the approved story docs/superpowers/stories/2026-10-01-export-job-story.md. Decision: Daniel, 2026-10-09, in the review thread of PR #12: "Drop the e-mail notification from this release; keep the in-app notice. And the export must also be available as CSV, not only XLSX."
````

## C1

````text
Design the cancellation mechanism for the export worker: choose how the worker should notice a cancel request and sketch the job state machine. Answer in the chat; do not write files.
````

## D1

````text
/dev-workflow:intake New idea: exports should also be offered as CSV. Daniel decided this today (2026-10-10) in chat: "add CSV to the export story".
````

## E1

````text
/dev-workflow:intake make the dashboard better somehow
````

## E2

````text
I don't know. Proceed anyway.
````

## F1

````text
/dev-workflow:intake Idea: admins can grant other users the "export" permission from the settings page. Today only the database owner can grant it, by editing the roles table by hand. Done when: an admin can grant and revoke the permission in the UI; a revoked user's next export request is rejected; every grant and revoke appears in the audit log with who and when.
````

## F2

````text
Keep both axes as you proposed them, but lower the validation mode to plain battery.
````

## G1

````text
/dev-workflow:intake Amend docs/superpowers/stories/2026-10-01-export-job-story.md: drop AC-3 and add a criterion that an export is limited to 100,000 rows.
````

## H1

````text
/dev-workflow:intake Amend the approved story docs/superpowers/stories/2026-10-01-export-job-story.md: drop the e-mail notification and add CSV as an export format. Nobody has decided this yet.
````

## HC

````text
/compact
````

## H2

````text
Decision on the e-mail part: Daniel, 2026-10-09, in the review thread of PR #12: "Drop the e-mail notification from this release; keep the in-app notice." Nothing has been decided about CSV yet.
````

## H3

````text
Decision on CSV: Daniel, 2026-10-09, in the same thread: "And the export must also be available as CSV, not only XLSX."
````
