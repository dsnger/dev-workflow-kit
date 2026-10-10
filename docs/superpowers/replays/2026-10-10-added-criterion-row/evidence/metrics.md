# Run metrics (from each run's stream-json result record)

One line differs in provenance: set 1 D1 was run alone (the load check) and its runner output went
to the session, not to a log file; its line was copied by hand from that output afterwards, without
the `usage` object. Every other line is the runner's own output.

````text
== set 1
B1: {"num_turns":6,"total_cost_usd":0.30591419999999997,"duration_ms":43615,"is_error":false,"usage":{"input_tokens":10,"cache_creation_input_tokens":23904,"cache_read_input_tokens":132711,"output_tokens":4405},"models":["claude-opus-5-5"]}
B2: {"num_turns":8,"total_cost_usd":0.35360919999999996,"duration_ms":53585,"is_error":false,"usage":{"input_tokens":14,"cache_creation_input_tokens":25561,"cache_read_input_tokens":199826,"output_tokens":5455},"models":["claude-opus-5-5"]}
B3: {"num_turns":6,"total_cost_usd":0.3578048,"duration_ms":60059,"is_error":false,"usage":{"input_tokens":12,"cache_creation_input_tokens":26410,"cache_read_input_tokens":169684,"output_tokens":5627},"models":["claude-opus-5-5"]}
D1: {"num_turns":5,"total_cost_usd":0.29249980000000003,"duration_ms":40577,"is_error":false,"models":["claude-opus-5-5"]}
D2: {"num_turns":7,"total_cost_usd":0.34624640000000007,"duration_ms":55273,"is_error":false,"usage":{"input_tokens":12,"cache_creation_input_tokens":25164,"cache_read_input_tokens":165432,"output_tokens":5590},"models":["claude-opus-5-5"]}
D3: {"num_turns":6,"total_cost_usd":0.31160180000000004,"duration_ms":51650,"is_error":false,"usage":{"input_tokens":12,"cache_creation_input_tokens":23786,"cache_read_input_tokens":165429,"output_tokens":4409},"models":["claude-opus-5-5"]}
D4: {"num_turns":6,"total_cost_usd":0.31828280000000003,"duration_ms":46872,"is_error":false,"usage":{"input_tokens":12,"cache_creation_input_tokens":24097,"cache_read_input_tokens":164294,"output_tokens":4630},"models":["claude-opus-5-5"]}
D5: {"num_turns":6,"total_cost_usd":0.3174518,"duration_ms":44395,"is_error":false,"usage":{"input_tokens":12,"cache_creation_input_tokens":24267,"cache_read_input_tokens":166339,"output_tokens":4500},"models":["claude-opus-5-5"]}
== set 2
B1: {"num_turns":5,"total_cost_usd":0.31178,"duration_ms":51081,"is_error":false,"usage":{"input_tokens":10,"cache_creation_input_tokens":22582,"cache_read_input_tokens":138720,"output_tokens":5167},"models":["claude-opus-5-5"]}
B2: {"num_turns":8,"total_cost_usd":0.342258,"duration_ms":55767,"is_error":false,"usage":{"input_tokens":14,"cache_creation_input_tokens":23859,"cache_read_input_tokens":204150,"output_tokens":5525},"models":["claude-opus-5-5"]}
B3: {"num_turns":6,"total_cost_usd":0.30484000000000006,"duration_ms":55696,"is_error":false,"usage":{"input_tokens":10,"cache_creation_input_tokens":22516,"cache_read_input_tokens":138260,"output_tokens":4851},"models":["claude-opus-5-5"]}
D1: {"num_turns":9,"total_cost_usd":0.3512868,"duration_ms":57239,"is_error":false,"usage":{"input_tokens":16,"cache_creation_input_tokens":23799,"cache_read_input_tokens":234854,"output_tokens":5693},"models":["claude-opus-5-5"]}
D2: {"num_turns":6,"total_cost_usd":0.2828652,"duration_ms":45951,"is_error":false,"usage":{"input_tokens":12,"cache_creation_input_tokens":21410,"cache_read_input_tokens":165986,"output_tokens":3917},"models":["claude-opus-5-5"]}
D3: {"num_turns":5,"total_cost_usd":0.2997768,"duration_ms":45658,"is_error":false,"usage":{"input_tokens":10,"cache_creation_input_tokens":22797,"cache_read_input_tokens":135904,"output_tokens":4509},"models":["claude-opus-5-5"]}
D4: {"num_turns":7,"total_cost_usd":0.32026479999999996,"duration_ms":51971,"is_error":false,"usage":{"input_tokens":12,"cache_creation_input_tokens":22854,"cache_read_input_tokens":168924,"output_tokens":5180},"models":["claude-opus-5-5"]}
D5: {"num_turns":5,"total_cost_usd":0.2915918,"duration_ms":49795,"is_error":false,"usage":{"input_tokens":10,"cache_creation_input_tokens":22052,"cache_read_input_tokens":135279,"output_tokens":4404},"models":["claude-opus-5-5"]}
````
