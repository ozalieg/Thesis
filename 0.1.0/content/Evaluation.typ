#import "@preview/abbr:0.2.3"

= Evaluation
== JV Template Generation Evaluation


When evaluating the robustness of a CSV type inference system that incorporates both column name and content heuristics,
a number of non-trivial edge cases must be considered to ensure consistent parsing behavior across real-world datasets.

Whitespace and encoding anomalies frequently interfere with column name detection.
A robust system must remove leading and trailing whitespace and handle invisible characters
such as the byte order mark (BOM) prior to applying #abbr.add("RegEx", "Regular Expressions") #abbr.a[RegEx] matching.
Columns with duplicate or missing headers should be automatically resolved by assigning fallback identifiers
such as `column_1`, `column_2`, etc., to ensure that every field is addressable.

Special characters and multilingual content present additional complications.
Matching patterns in names like “résumé” or “order\#id” requires Unicode-aware #abbr.a[RegEx]
and often normalization using forms such as NFKC to compare semantically equivalent strings.
Ambiguities in naming patterns—such as fields ending in `_id`—may misleadingly suggest an integer type.
In such cases, a tiered fallback strategy should apply: default to integer only if the content is strictly numeric,
otherwise infer as string to prevent errors from hybrid or malformed inputs.

Columns where values exhibit mixed formats are particularly common in date fields.
Even if the header indicates a date (e.g., contains “\_date”),
content-based validation must confirm consistent parsing across rows.
A content parser should support flexible date formats (e.g., `YYYY-MM-DD`, `MM/DD/YYYY`, `June 4 2021`)
and either coerce or flag rows that fail validation.
Similarly, numeric strings with leading zeros, such as zip codes or identifiers,
must not be misinterpreted as numbers. If the column name suggests identity (e.g., ends with `_id`),
the presence of leading zeros should trigger a forced cast to string.

Handling missing or special “null” values—such as `null`, `N/A`,
or empty strings—requires semantic understanding of their intent.
Depending on the context, they may be dropped, cast to `None`, or retained as string representations.
Proper delimiter handling is also essential. Rather than naively splitting on commas,
systems must adhere to #abbr.add("RFC", "Request For Comments") #abbr.a[RFC] 4180 or another specified CSV dialect,
especially for fields that contain delimiters inside quoted strings.

Column name normalization is recommended to improve pattern matching reliability.
This may involve replacing hyphens (`-`) with underscores (`_`) to align with standard naming conventions in downstream systems.
Boolean inference should also account for a wide variety of lexical representations, including `1/0`, `true/false`,
and `YES/NO`, and normalize them into a unified Boolean type, assuming no conflicting values are found.

All of these cases were part of the evaluation process to verify how well both the baseline heuristics
and the #abbr.add("LLM", "Large Language Model") #abbr.pla[LLM]-assisted inference generalize
to structurally inconsistent or malformed CSV data.
The edge-case evaluation confirms that successful schema inference requires more than just
accurate model predictions—it must also include robust pre-processing, normalization, and error handling logic built into
the parsing stack.

