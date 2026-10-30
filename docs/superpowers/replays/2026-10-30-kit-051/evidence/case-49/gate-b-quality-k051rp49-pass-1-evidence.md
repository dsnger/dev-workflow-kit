# Gate B quality — k051rp49 pass 1

Range: 62ebb90992ec5dda61349371cb47ee90e55efea2..00faea5e081f8aefd37609f4e21df0b6877fc896.
HEAD matched the requested head; tracked working-tree content was unchanged. Branch: quality. Mode: strict.

Read the range's implementation, tests, story, spec, plan, AGENTS.md, local gate-review skill, and related parser/measurement callers. Initial hypotheses: incomplete refreshes could discard evidence; cached observations could become falsely fresh; projection could retain session text; raw working-tree comparisons could disagree with git normalization. The implementation claims were treated as claims, not evidence of correctness.

Graph freshness for this head was not established; used direct HEAD searches and source inspection. No repository was indexed. No refresh command is recorded in this head's todos.md section Tooling revalidation; the optional integration is a backlog item.

## Tests and observations

All execution below used .agents/skills/gate-b-review/scripts/run-tests.sh with this explicit head and its isolated tracked-file copy. No full battery was run.

TESTS: sh scripts/run-analytics.test.sh | exit 0 | 47s | 31 passed, 0 failed
TESTS: sh scripts/status-view.test.sh (first attempt) | runner reported exit 1 | 99s | output unavailable: concurrent runner cleanup removed the temporary out file; this is not usable evidence of a product test failure. Repeated alone below.
TESTS: python3 -B -c <targeted probes below using status-view.test.sh fixture helpers> | exit 0 | 5s | reproduced both reported defects
TESTS: sh scripts/status-view.test.sh (isolated repeat) | exit 0 | 242s | 123 passed, 0 failed, including five mutation controls
TESTS: git diff --check 62ebb90992ec5dda61349371cb47ee90e55efea2..00faea5e081f8aefd37609f4e21df0b6877fc896 | exit 0 | no whitespace errors

The runner reported no checkout-changed error. The initial suite failure coincided with another runner's stale-copy cleanup and missing output, so it was resolved as an execution-infrastructure problem by the isolated successful repeat, not classified as a production defect.

### Reproduction evidence

1. A fixture transcript initially contained toolu_P1 and a valid result identifying cycle pppppppp12. The first page showed Effort [ok], cycle pppppppp12, one call and one attempted slot. Replacing only that result's content field with integer 7 and refreshing produced Effort [ok], calls without a cycle: calls 1, passes -. The previous cycle attribution was gone. The read_transcript validation checks a gate use's input shape, but neither it nor uses_from_lines checks the result content shape; project_use then commits an empty projection. sec_open consumes sec_effort's no_record list, so the corresponding open-cycle observation is also lost. Existing p7/p8 tests cover malformed use IDs and inputs, not result content.

2. In a clean fixture, committed .gitattributes containing *.txt text=auto and crlf.txt with bytes a\r\nb\r\n. Ran with --base equal to the resulting HEAD immediately after commit. Current work: uncommitted paths: 0. Artifact growth: crlf.txt modified, 4 → 6 (+2), group files changed 1. worktree_state trusts matching index size/mtime before checking attributes; sec_growth uses raw hashes and only consults that dirty result for its uncertainty label. Existing normalized-file tests explicitly change mtime, bypassing the missing case.

Executed probe body (passed as one Python -c argument through the runner; fixtures existed only in its disposable copy):

```python
import os,sys
src=open("scripts/status-view.test.sh").read().split("<<'PY'\n",1)[1].split("# ---- repository A:",1)[0]
sys.argv=["driver",os.path.join(os.environ["TMPDIR"],"probe"),os.path.abspath("scripts/status-view.py")]
exec(compile(src,"fixture-helpers","exec"))
rmhome()
R=mkrepo("probe")
put(R,".gitattributes","*.txt text=auto\n")
put(R,"crlf.txt","a\r\nb\r\n")
base=commit(R,"normalized")
run(R,"--base",base)
print("NORMALIZED_WORK",section_of(text(R),"Current work"))
print("NORMALIZED_GROWTH",section_of(text(R),"Artifact growth"))
tr=transcript("probe.jsonl",use("toolu_P1",T(2),R,S1)+result("toolu_P1",T(1.9),S1,"gate-a-spec | pass 1 | 0 findings | .context/codex-reviews/gate-a-spec-pppppppp12-pass-1.md"))
run(R)
print("BEFORE_RESULT",section_of(text(R),"Effort"))
data=open(tr).read()
objects=[json.loads(l) for l in data.splitlines()]
objects[1]["message"]["content"][0]["content"]=7
open(tr,"w").write("".join(line(o) for o in objects))
run(R)
print("AFTER_RESULT",section_of(text(R),"Effort"))

```

## Quality assessment

Strengths: the run-analytics extraction preserves its existing scanner behavior and suite; directory-descriptor output containment, exclusive locking, atomic replacement, bounded field projection, source-specific retention and explicit unknown/stale states are substantial. The status suite exercises real fixture repositories and logs, with mutation controls for unknown values, installed-version ambiguity, cache reuse, model projection and false load mentions.

Ready to merge: With fixes. No blocker was found; the malformed-result path loses previously observed evidence under a fresh status, and normalized-file reporting needs the smaller correction above. Passing suites do not cover these two reproduced inputs. This review did not repeat the full quality battery, browser age demonstration, or historical real-work demonstration.

## Callers and dependents

The entries below record local reference searches, with dynamic dispatch and external scanner callers noted explicitly. Generic names have incidental text hits; their actual control flow was checked by reading the implementation and driver. The new status report is called by its __main__ entry and the fixture driver; sections are dispatched from collect at line 1344. The test driver exercises report behavior via run → SV.main.

CALLERS: scripts/status-view.py load — scripts/status-view.py:45,46,1275,1287
CALLERS: scripts/status-view.py Discarded — scripts/status-view.py:1350,1368,1417
CALLERS: scripts/status-view.py Unclaimed — scripts/status-view.py:610,649
CALLERS: scripts/status-view.py Refused — scripts/status-view.py:135,136,137,144,147,151,162,1465,1484
CALLERS: scripts/status-view.py now_utc — scripts/status-view.py:1309,1369,1381,1487
CALLERS: scripts/status-view.py fmt — scripts/status-view.py:761,830,840,879,905,909,921,926,973,986,1012,1020,1047,1075,1160,1167,1182,1195,1210,1257,1354,1402,1423,1487
CALLERS: scripts/status-view.py esc — scripts/status-view.py:798,825,828,830,833,847,848,851,854,861,882,884,887,888,892,916,918,921,924,926,929,939,946,951,952,1012,1035,1038,1043,1047,1137,1139,1141,1156,1184,1195,1199,1229,1232,1253,1267,1276,1284,1292,1296,1397,1398,1400,1402,1403,1407
CALLERS: scripts/status-view.py git — scripts/status-view.py:8,11,97,98,99,116,118,194,198,201,203,210,212,219,294,296,307,309,315,340,352,365,369,371,387,412,424,440,832,1011,1104,1201,1248,1329,1439,1441,1444,1445,1447,1449
CALLERS: scripts/status-view.py read_regular — scripts/status-view.py:345,390,444,504,681,1071,1179,1211
CALLERS: scripts/status-view.py git_text — scripts/status-view.py:302,315,357,385,401,1062,1094,1313,1314,1315,1327,1334
CALLERS: scripts/status-view.py open_dir — scripts/status-view.py:1458
CALLERS: scripts/status-view.py take_lock — scripts/status-view.py:1461
CALLERS: scripts/status-view.py check_target — scripts/status-view.py:166,177,1460,1463
CALLERS: scripts/status-view.py write_atomic — scripts/status-view.py:1425,1426,1493
CALLERS: scripts/status-view.py read_cache — scripts/status-view.py:1464
CALLERS: scripts/status-view.py resolve_baseline — scripts/status-view.py:1467
CALLERS: scripts/status-view.py head_state — scripts/status-view.py:1304,1376,1469
CALLERS: scripts/status-view.py records_in_range — scripts/status-view.py:268
CALLERS: scripts/status-view.py lm_log_args — scripts/status-view.py:219
CALLERS: scripts/status-view.py cycle_state — scripts/status-view.py:271
CALLERS: scripts/status-view.py cycles — scripts/status-view.py:779,862,871,889,902,939,941,944,949,1039,1320,1338
CALLERS: scripts/status-view.py worktree_state — scripts/status-view.py:366,375,430,1127,1316
CALLERS: scripts/status-view.py changed_paths — scripts/status-view.py:1321
CALLERS: scripts/status-view.py committed_paths — scripts/status-view.py:1322
CALLERS: scripts/status-view.py commit_time — scripts/status-view.py:877
CALLERS: scripts/status-view.py story_header — scripts/status-view.py:1331
CALLERS: scripts/status-view.py last_commit — scripts/status-view.py:439,1022,1289
CALLERS: scripts/status-view.py dirty — scripts/status-view.py:435,906,1290
CALLERS: scripts/status-view.py revision — scripts/status-view.py:1018,1024
CALLERS: scripts/status-view.py read_text — scripts/status-view.py:998,1024,1258
CALLERS: scripts/status-view.py newest_handover — scripts/status-view.py:996
CALLERS: scripts/status-view.py md_sections — scripts/status-view.py:896,1008,1032
CALLERS: scripts/status-view.py valid_path — scripts/status-view.py:483,525
CALLERS: scripts/status-view.py project_use — scripts/status-view.py:540
CALLERS: scripts/status-view.py read_transcript — scripts/status-view.py:658
CALLERS: scripts/status-view.py load_events — scripts/status-view.py:521
CALLERS: scripts/status-view.py project_codex — scripts/status-view.py:688
CALLERS: scripts/status-view.py refresh_files — scripts/status-view.py:657,670
CALLERS: scripts/status-view.py read_codex_sid — scripts/status-view.py:671
CALLERS: scripts/status-view.py collect_effort — scripts/status-view.py:778
CALLERS: scripts/status-view.py section — scripts/status-view.py:16,839,840,920,933,953,956,957,961,971,972,976,978,989,993,999,1049,1050,1161,1297,1355,1389,1405,1406
CALLERS: scripts/status-view.py ul — scripts/status-view.py:774,831,930,931,932,953,1050,1201,1287,1296
CALLERS: scripts/status-view.py sec_effort — dynamic dispatch from collect at scripts/status-view.py:1344
CALLERS: scripts/status-view.py sec_work — dynamic dispatch from collect at scripts/status-view.py:1344
CALLERS: scripts/status-view.py sec_progress — dynamic dispatch from collect at scripts/status-view.py:1344
CALLERS: scripts/status-view.py observed — scripts/status-view.py:798,809,830,926,1007,1030,1042,1046,1047,1184,1190,1192,1199,1242,1245,1265,1275,1281,1291,1396
CALLERS: scripts/status-view.py parse_iso — scripts/status-view.py:877,959
CALLERS: scripts/status-view.py asof — scripts/status-view.py:769,770,1050,1297,1407
CALLERS: scripts/status-view.py source — scripts/status-view.py:77,841,881,977,985,999,1012,1025,1035,1049,1084,1158,1243,1264,1352
CALLERS: scripts/status-view.py handover — scripts/status-view.py:8,450,893,920,994,999,1004,1011,1158,1159,1169,1182
CALLERS: scripts/status-view.py sec_open — dynamic dispatch from collect at scripts/status-view.py:1344
CALLERS: scripts/status-view.py blob_lines — scripts/status-view.py:1074,1106,1186
CALLERS: scripts/status-view.py sec_growth — dynamic dispatch from collect at scripts/status-view.py:1344
CALLERS: scripts/status-view.py handover_growth — scripts/status-view.py:1158
CALLERS: scripts/status-view.py installed_source — scripts/status-view.py:1243
CALLERS: scripts/status-view.py sec_version — dynamic dispatch from collect at scripts/status-view.py:1344
CALLERS: scripts/status-view.py collect — scripts/status-view.py:1415
CALLERS: scripts/status-view.py name_moved — scripts/status-view.py:1367
CALLERS: scripts/status-view.py render — scripts/status-view.py:1426,1493
CALLERS: scripts/status-view.py run_once — scripts/status-view.py:1483
CALLERS: scripts/status-view.py main — scripts/status-view.py:15,198,200,201,204,205,206,1513; scripts/status-view.test.sh:156 calls SV.main through the run fixture
CALLERS: scripts/status-view.py watch_loop — scripts/status-view.py:1471
CALLERS: scripts/status-view.py fail — scripts/status-view.py:16,1340,1343,1438,1444,1447,1451,1455,1466,1485,1489
CALLERS: scripts/status-view.py is_member — scripts/status-view.py:723,748
CALLERS: scripts/status-view.py read — scripts/status-view.py:17,76,77,110,184,217,221,503,585,625,656,669,682,701,756,757,841,977,999,1049,1050,1119,1124,1133,1159,1206,1215,1244,1451
CALLERS: scripts/status-view.py measure — scripts/status-view.py:1083,1084
CALLERS: scripts/status-view.py ln — scripts/status-view.py:1156
CALLERS: scripts/status-view.py sizes — scripts/status-view.py:1156,1160
CALLERS: scripts/status-view.py read_wt — scripts/status-view.py:1264
CALLERS: scripts/status-view.py read_artifact — scripts/status-view.py:1025
CALLERS: scripts/status-view.py HERE — scripts/status-view.py:35,39,47
CALLERS: scripts/status-view.py ra — scripts/status-view.py:45,47,481,484,486,488,491,496,523,527,533,536,539,540,546,574,577,579,580,588,645,648,688,708,717,725,731,735,737,739,742,785,787,802,814,820,821,822,826,828,834,959,1468,1505
CALLERS: scripts/status-view.py lu — scripts/status-view.py:46,99,258
CALLERS: scripts/status-view.py lm — scripts/status-view.py:47,232,234,241,279
CALLERS: scripts/status-view.py PLUGIN — scripts/status-view.py:49,1221
CALLERS: scripts/status-view.py RULE_FILES — scripts/status-view.py:50,1288
CALLERS: scripts/status-view.py MANIFEST — scripts/status-view.py:51,1248,1255,1258
CALLERS: scripts/status-view.py WINDOW_HOURS — scripts/status-view.py:52,783
CALLERS: scripts/status-view.py SECTIONS — scripts/status-view.py:53,1404
CALLERS: scripts/status-view.py TITLES — scripts/status-view.py:54,1407
CALLERS: scripts/status-view.py RE_LOAD — scripts/status-view.py:56,565
CALLERS: scripts/status-view.py RE_OPEN_HEAD — scripts/status-view.py:57,1008
CALLERS: scripts/status-view.py REVIEW_TYPES — scripts/status-view.py:58,482
CALLERS: scripts/status-view.py GROUPS — scripts/status-view.py:59,1108,1113,1143
CALLERS: scripts/status-view.py PHASES — scripts/status-view.py:67,880
CALLERS: scripts/status-view.py CYCLE_PHASE — scripts/status-view.py:68,872,873
CALLERS: scripts/status-view.py RE_INDEX — scripts/status-view.py:290,311
CALLERS: scripts/run-analytics.py scan_transcripts — scripts/run-analytics.py:659; scripts/live-effort.py:75
CALLERS: scripts/run-analytics.py transcript_uses — scripts/run-analytics.py:190
CALLERS: scripts/run-analytics.py uses_from_lines — scripts/run-analytics.py:199; scripts/status-view.py:536
CALLERS: scripts/run-analytics.py scan_codex — scripts/run-analytics.py:664; scripts/live-effort.py:80
CALLERS: scripts/run-analytics.py codex_fact — scripts/run-analytics.py:261
CALLERS: scripts/run-analytics.py fact_from_lines — scripts/run-analytics.py:269; scripts/status-view.py:688
CALLERS: scripts/status-view.test.sh git — scripts/status-view.test.sh:45,57,58,59,65,78,210,213,214,216,220,250,251,260,262,264,305,482,484,489,490,491,495,500,503,504,505,557,669,670,694,697,701,706,712,719,725,727,734,737,742,743,747,758,766,776,779,780,786,788,812,814,834,835,836,837,838,839,841,842,849,856,859,864,865,874,877 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh put — scripts/status-view.test.sh:69,70,71,72,73,74,75,76,204,206,211,223,224,226,227,229,230,231,311,432,487,541,558,567,569,614,620,623,628,664,682,699,702,708,713,720,721,726,732,738,759,800,824,840,857,860,862,866,875,878 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh commit — scripts/status-view.test.sh:58,77,205,207,210,212,213,214,216,220,228,274,314,482,486,488,493,495,504,542,568,665,670,674,700,733,736,742,746,747,762,770,774,780,812,838,842,858,861,865,876 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh mkrepo — scripts/status-view.test.sh:203,515,520,529,540,545,566,731,817,831,848,855 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh line — scripts/status-view.test.sh:89,95,101,107,115,116,117,273,347,348,352,378,384,392,418,422,572,584,594,607,662 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh use — scripts/status-view.test.sh:233,234,235,326,334,546,548,571 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh result — scripts/status-view.test.sh:233,235,270,321,324,326,547,549,554,571 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh skill — scripts/status-view.test.sh:102,108,234,237,238,350 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh mention — scripts/status-view.test.sh:234,295 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh codex_log — scripts/status-view.test.sh:236,330,379,573 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh transcript — scripts/status-view.test.sh:232,237,238,324,326,334,417,418,425,546,571 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh installed — scripts/status-view.test.sh:202,297,298,409,411,416,439,441,443,444,565 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh rec — scripts/status-view.test.sh:202,441,444,565 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh load — scripts/status-view.test.sh:149,637 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh run — scripts/status-view.test.sh:45,66,263,266,312,318,322,327,331,335,339,345,351,357,362,369,374,375,380,385,393,397,407,414,423,433,436,442,451,459,470,483,490,495,506,518,526,532,543,550,559,586,597,605,616,625,635,645,655,661,667,671,684,695,698,704,715,723,730,734,740,744,753,764,767,772,784,791,796,801,808,813,819,826,833,843,850,863,867,879,887,900,902,909,910 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh page — scripts/status-view.test.sh:4,169,282,301,302,308,395,448,453,462,472,494,496,528,534 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh text — scripts/status-view.test.sh:49,53,97,102,108,122,126,265,313,319,323,328,332,336,340,346,352,358,363,367,370,376,381,386,392,394,398,408,415,424,432,434,437,443,460,471,485,492,507,544,551,560,587,598,606,617,618,626,636,646,656,662,668,672,675,676,685,686,745,759,765,768,773,785,792,803,804,810,815,820,827,844,868,880,900 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh fmt_mtime — scripts/status-view.test.sh:411 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh section_of — scripts/status-view.test.sh:267,271,278,283,291,294,313,319,323,328,332,336,347,348,370,378,381,387,409,415,425,434,492,544,554,556,574,617,627,637,647,657,668,672,685,745,765,768,773,785,792,803,815,820,827,868,880 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh check — scripts/status-view.test.sh:45,266,268,269,270,272,273,274,275,276,277,279,280,281,282,286,287,288,289,290,292,293,295,296,297,299,301,303,305,306,307,308,314,319,324,325,329,333,337,340,347,348,352,358,364,378,387,394,399,409,411,416,425,434,437,443,453,461,462,472,473,485,493,496,508,509,519,527,533,535,544,552,553,554,555,556,560,588,599,607,618,627,637,647,657,658,662,668,673,674,676,686,696,705,716,724,729,734,741,746,755,765,769,774,785,794,804,810,815,821,827,833,844,851,868,881 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh wanted — scripts/status-view.test.sh:317,368,431,440,447,456,476,499,512,538,563,830,847,854,871 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh rmhome — scripts/status-view.test.sh:201,539,564 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh repo_snapshot — scripts/status-view.test.sh:261,303 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh spoil — scripts/status-view.test.sh:407 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh spoil_t — scripts/status-view.test.sh:423 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh boom — scripts/status-view.test.sh:468 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh move — scripts/status-view.test.sh:483 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh advance — scripts/status-view.test.sh:506 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh step — scripts/status-view.test.sh:579 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh wrong_shape — scripts/status-view.test.sh:585 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh complete_then_partial — scripts/status-view.test.sh:596 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh malformed_then_partial — scripts/status-view.test.sh:604 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh handover_gone_story_new — scripts/status-view.test.sh:615 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh corrupt_manifest — scripts/status-view.test.sh:624 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh bad_attachment — scripts/status-view.test.sh:634 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh bad_input — scripts/status-view.test.sh:642 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh bad_tool_id — scripts/status-view.test.sh:652 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh lock_one — scripts/status-view.test.sh:683 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh add_driver — scripts/status-view.test.sh:715 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh add_driver_mid — scripts/status-view.test.sh:723 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh lock_dir — scripts/status-view.test.sh:801 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh lock_file — scripts/status-view.test.sh:808 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh pass — scripts/status-view.test.sh:18,233,235,292,321,326,355,547,549,562,571,891,896,911 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh fail — scripts/status-view.test.sh:5,19,457,458,892,896,899,913 (test fixture/driver only)
CALLERS: scripts/status-view.test.sh mutant — scripts/status-view.test.sh:898,900,906,911,913,916,917,918,919,920 (test fixture/driver only)
CALLERS: scripts/status-view.py path and CLI — README.md:194; AGENTS.md:52,83,301; scripts/status-view.test.sh:70,149,156; spec sections 0–9 and plan Tasks 1–7.
CALLERS: scripts/status-view.test.sh path — .github/workflows/ci.yml:93,124; AGENTS.md:53,283,285; plan Task 7 and spec section 9.
CALLERS: .context/status/index.html, cache.json, .lock — main containment checks, run_once publication, watch_loop failure rendering, read_cache, take_lock; fixture page/cache and containment assertions. No reader of the telemetry store was introduced.
CALLERS: status-view test case names c1–c18, p3–p8, w1–w2, h1, s1, g1 — driver check/wanted filtering and mutant selectors at scripts/status-view.test.sh:916-920.
CALLERS: story AC-1–AC-12 and Story header — cited by the new spec and plan; references retained, no criterion renumbering or heading removal.
CALLERS: new spec section headings — plan task descriptions and status-view.py:5,97,367,794; suite header and source assertions.
CALLERS: new plan Task headings — internal prerequisite ordering and test references; no existing heading renamed or removed.
CALLERS: report counts and command rows in AGENTS.md and CI — README.md:163 and CI lint/test steps updated consistently; no plugin path changed, so invariant 12 does not require a plugin version bump. Manifest read at HEAD: version 0.18.0, metadata only.
CALLERS: todos.md optional codebase-memory and security-concept entries — local backlog ordering and existing process-monitoring owner; no executable consumer, no new status mechanism.
