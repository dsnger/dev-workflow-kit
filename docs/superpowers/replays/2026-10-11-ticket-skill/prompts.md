# Prompts (verbatim, written before the runs)

Each prompt is the whole `claude -p` input of one run. None quotes an expected answer. The
baseline prompts are the same text with `/dev-workflow:intake` in place of `/dev-workflow:ticket`
(spec §3, "Baseline"). `L` has no baseline (not one of AC-11's three cases).

## K1 — bug with evidence

```text
/dev-workflow:ticket A customer got a download link to a broken export. Worker log on version 1.4.2: `2026-10-08T09:14:03Z worker job=8812 status=failed rows_written=4100/9800 published=true url=https://exports.example.eu/8812.xlsx`. The job failed half way, but the file was published and the link in the customer's e-mail works. First seen in 1.4.2; 1.4.1 did not do this.
```

## K2 — improvement inside a commitment

```text
/dev-workflow:ticket Large exports are slow. Job 9120 (212,000 rows) took 41 minutes from queue to e-mail, measured from the worker log: `2026-10-09T10:02:11Z worker job=9120 status=queued` and `2026-10-09T10:43:30Z notify job=9120 kind=email`. Customers with big accounts wait a long time; it would be good to make big exports faster.
```

## K3 — a "bug" that changes a commitment

```text
/dev-workflow:ticket Bug: the export comes out as XLSX, but our customers want CSV. Please fix the export so it produces a CSV file instead.
```

## L — list

```text
/dev-workflow:ticket list
```
