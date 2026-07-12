# dev-workflow-kit — Seed (extrahiert aus dem Quellprojekt, Stand 2026-07-10)

Unveränderte Kopien der Workflow-Artefakte. Quelle wird nicht mehr gebraucht —
dieses Archiv ist die vollständige Extraktionsbasis.

## source-files/ — was ist was

| Datei/Ordner | Rolle | Plugin-Ziel |
|---|---|---|
| skills/intake, skills/harden-finding | die zwei Projekt-Skills | Plugin (generalisieren! Taxonomie-Split bei harden-finding) |
| commands/process-pr-review.md | PR-Bot-Prozessor | Plugin (Bot-Namen konfigurierbar machen) |
| hooks/codex-gate.sh + .test.sh | Gate-Zähler/Mahner | Plugin (Hook-Registrierung via Plugin-Manifest) |
| claude-settings.json | zeigt, WIE der Hook verdrahtet ist | Referenz für Plugin-Hook-Registrierung |
| CLAUDE.md | Disziplinregeln §1–5 | /workflow-init-Template (Projekt-Datei) |
| prompt-standards.md | 10-Kriterien-Checkliste | Template + eigener Standard des Plugin-Repos |
| hardening-log.md | NUR als FORMAT-Referenz (sanitisiert: echte Findings entfernt) | Template: leeres Ledger mit Kopfzeile/Konvention |
| coding-workflow.md | neutrale Gesamt-Doku | Plugin-README-Grundlage |
| .gitattributes | Union-Merge fürs Ledger | Template-Zeile |
| pnpm-workspace.yaml | Supply-Chain-Policy (minimumReleaseAge) | Template |
| ci.yml | Quality-CI-Workflow | Template (Battery-Schritte stack-spezifisch markieren) |
| knip.json, .fallowrc.jsonc | Battery-Configs | NUR Beispiele — stack-spezifisch, kein Plugin-Inhalt |
| codex-config.toml, .mcp.json | Reviewer-Pin + MCP-Anbindung | Templates |
| eslint-rules/ | Custom-Regeln | NUR Beispiel (Convex-spezifisch) — dokumentieren, nicht generalisieren |

## Nicht enthalten (bewusst)
- AGENTS.md (Invarianten des Quellprojekts — pro Projekt neu; /workflow-init führt durch)
- Ledger-INHALTE, Baselines, todos-Inhalte (Projektzustand)
- Superpowers (externe Dependency, dokumentieren als Voraussetzung)
