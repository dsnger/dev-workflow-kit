1 | fixed | newlines are flattened with tr before sed, so the boundary holds across lines; section 47 multiline case
2 | fixed | the sed output is captured and a failed sed returns not resumed (counts); section 47 sed shim case
