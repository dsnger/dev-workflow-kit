# AGENTS.md — exporter

A small service that lets customers export their account data as spreadsheet files.
A web UI queues export jobs; one worker processes the queue in order.

## Architecture

- `web/` — the UI and the HTTP API.
- `worker/` — the single export worker; processes one job at a time, in queue order.
- `notify/` — in-app notices and e-mail.

## Key invariants

### Exports

1. **A customer never receives a partial file.** A file is published to the customer only after the worker has written it completely; a failed job publishes nothing.
2. **The queue is strictly ordered.** Jobs run in the order they were queued; no job skips ahead.

### Permissions and data

3. **Only admins change roles or permissions.** Every permission check goes through `requireRole()`; no handler checks roles inline.
4. **Personal data stays in the EU region.** Export files are stored only in the EU bucket.
5. **Every grant and revoke of a permission is audit-logged** with actor and timestamp.

## Commands

| Role | Command |
|---|---|
| quality | `make check` |
