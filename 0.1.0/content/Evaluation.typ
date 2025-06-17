#import "@preview/abbr:0.2.3"

= Evaluation
== JV Template Generation Evaluation

When evaluating the robustness of a CSV type inference system that incorporates both column name
 and content heuristics,
a number of non-trivial edge cases must be considered to ensure consistent parsing behavior
 across real-world datasets.

=== Test Architecture Overview

Before diving into edge cases, it helps to understand the overall test harness
that drives template generation at scale.
In our HPC setup, 10 000 CSV files reside under `CSVFiles/`, are fed one by one into the Jayvee generator,
then each resulting `.jv` is executed to produce a SQLite sink.
The following diagram in @test_architecture_tempgen illustrates the flow:
#figure(
image("./Test_Architecture_TempGen.png", width: 120%),
caption: [Test Architecture for Jayvee Template Generation],
) <test_architecture_tempgen>


In this architecture, the SLURM job script first bootstraps the HPC environment—loading necessary modules,
activating the Conda environment, exporting all required paths
(including `CSVFiles/`, `JvFiles/`, `SQLiteFiles/`, `JsonFiles/`, and log file locations),
and creating directories. It then invokes the Python test harness, which scans the input folder,
calls the JV Generator CLI to infer schema and emit `.jv` templates,
and immediately runs the JV Executor on each template to produce `.sqlite` sinks.
Throughout this process, errors and execution metrics are aggregated into central
log files for later inspection.

=== Edge Cases in CSV Schema Inference

When evaluating the Jayvee template generation system, we encountered several edge cases
Whitespace and encoding anomalies frequently interfere with column name detection.
A robust system must remove leading and trailing whitespace and handle invisible characters
such as the byte order mark (BOM) before applying Regular Expression matching.
Columns with duplicate or missing headers should be resolved automatically by assigning fallback
identifiers (for example, `column_1`, `column_2`, and so on) to ensure that every field remains addressable.
Special characters and multilingual content introduce further challenges:
matching patterns in names like “résumé” or “order\#id” requires Unicode‑aware expressions
and normalization to a standard form (such as NFKC) so that semantically equivalent strings compare correctly.
In cases where a header suggests a numeric type—such as fields ending in `_id`—the system
applies a tiered fallback strategy, defaulting to integer only if all values are strictly numeric,
and otherwise inferring text to avoid errors from hybrid or malformed inputs.

Date fields often exhibit mixed formats even when the header indicates a date
(for example, containing `_date`). Content‑based validation must support flexible formats
(including `YYYY‑MM‑DD`, `MM/DD/YYYY`, and written forms like `June 4 2021`)
and either coerce values or flag rows that fail parsing. Numeric strings with leading zeros,
such as ZIP codes or identifiers, must not be misinterpreted as numbers;
when the column name suggests an identity field, the presence of leading zeros triggers a forced string type.
 Handling missing or special “null” values—such as `null`, `N/A`,
 or empty strings—requires semantic understanding: depending on context,
 these may be dropped, cast to `None`, or retained as literal strings.

Proper delimiter handling is also essential. Rather than simply splitting on commas,
the system adheres to RFC 4180 (or a specified CSV dialect),
especially for fields that include delimiters inside quoted text.
Column name normalization—such as replacing hyphens with underscores—improves pattern‑matching
reliability for downstream consumers.
Boolean inference must recognize a variety of representations (`1`/`0`, `true`/`false`, `YES`/`NO`)
and normalize them into a single Boolean type, assuming no conflicting values exist.

All of these edge‑case scenarios were incorporated into our evaluation process,
verifying how both baseline heuristics and LLM‑assisted inference generalize to structurally
inconsistent or malformed CSV data.
The results confirm that successful schema inference depends not only on accurate
model predictions but also on robust preprocessing, normalization,
and error‑handling logic embedded throughout the parsing stack.

== LLM Schema Inference Evaluation

=== Test Architecture Overview

The evaluation of Jayvee's LLM-powered CSV header detection was grounded
in a synthetically generated benchmark designed to emulate the inconsistencies, ambiguities,
and pre-processing hurdles of real-world CSV data.
Central to this process was the use of ChatGPT to generate a large and diverse corpus of 10,000 CSV files,
each paired with an explicit ground truth annotation identifying the correct header row.
These ground truth indices were embedded in JSON format and stored alongside their corresponding CSVs,
enabling precise and automated comparison between model predictions and intended schema boundaries.

The CSV files were deliberately infused with heterogeneous pre-header content to simulate common
real-world obfuscations. These included comments, legal disclaimers, metadata blocks, dates,
units of measurement, multi-language headers, and other non-structural information
that precedes the actual schema-defining row.
This design choice introduced semantic ambiguity and structural irregularity into the dataset,
challenging the models not simply to detect positional patterns but
to exhibit genuine contextual understanding and schema discrimination.
Each file thus acted as a stress test for both LLM-based parsing and prompt sensitivity.

The evaluation pipeline was executed in a high-performance compute (HPC) environment
using SLURM to coordinate resource allocation and batch inference.
The pipeline initializes by setting up the compute context: loading required modules,
activating the Conda environment, and preparing directory structures for input CSVs,
generated prompts, output predictions, logs, and results.
Once initialized, a Python-based test harness iterates through all files in the LLMInf/CSVFiles/ directory,
pairs each CSV with its associated JSON label from LLMInf/Labels/,
and formats a prompt tailored to the model under test.

Inference is performed either via local engines (such as vLLM or HuggingFace Transformers)
or through remote APIs compatible with OpenAI’s specification, depending on the model configuration.
Once a prediction is received, the harness parses the result, extracts the proposed header row index,
and compares it to the reference label.
Accuracy statistics are continuously updated across the 10,000-file corpus,
and all mismatches are logged for subsequent analysis, including token-level audit trails and
full prompt histories to support reproducibility and debugging.

The following diagram in @test_architecture_llminf provides a structural overview of this evaluation loop:
#figure(
image("./LLMInf_Test_Architecture.png", width: 120%),
caption: [Test Architecture for LLM-based CSV Header Detection],
) <test_architecture_llminf>

The testbed's design ensures that models are not only exposed to well-behaved files,
but are rigorously evaluated under edge conditions that reflect practical deployment environments.
The interplay of synthetic control (via ChatGPT), adversarial formatting (via pre-header noise),
and automated ground truth comparison (via JSON indices) yields a robust
and scalable platform for measuring the limits and strengths of LLM-based schema inference.

=== Evaluation Summary

Using the test architecture described above, multiple large language models were evaluated
on their ability to correctly identify header rows within the 10,000 noisy CSV files.
Accuracy was defined as the proportion of model predictions that exactly matched the annotated ground truth.
Results varied widely across model families, with top-tier instruction-tuned models
such as Deepseek-R1 achieving a high of 84.7% accuracy,
correctly locating the header row in 8,470 of the test files.
Less capable models—especially those without domain tuning—struggled to interpret pre-header noise
and often defaulted to selecting the first or second row, resulting in accuracies as low as 62%.

A comparative assessment revealed that larger models consistently exhibited stronger contextual
reasoning, especially when encountering extended metadata blocks or commentary preceding the actual schema.
Their ability to recognize subtle lexical cues and structural intent allowed for more precise row selection.
In contrast, smaller or instruction-naïve models frequently misinterpreted
comment rows or misaligned multi-row headers, pointing to a lack
of robustness in ambiguous or cluttered scenarios.

Error analysis surfaced several recurring failure modes.
Files with inconsistent delimiters, embedded comments, or hybrid numeric-text columns
often triggered incorrect inferences.
Some models failed entirely to distinguish between a header and a descriptive unit row.
In other cases, models overfitted to superficial patterns,
misclassifying rows with frequent capital letters or delimiter density as the schema row despite
lacking columnar semantics.

These findings suggest that while language models can significantly streamline schema discovery,
especially when well-prompted and instruction-tuned,
their reliability diminishes in the face of unstructured input.
This underscores the importance of hybrid approaches that blend LLM predictions
with traditional heuristics or rule-based prefilters.
Additionally, fine-tuning on domain-specific CSV structures and systematic prompt optimization
may offer further gains in detection fidelity.