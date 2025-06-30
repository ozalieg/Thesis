#import "@preview/abbr:0.2.3"

= Evaluation

This chapter presents the testing frameworks and results for both the Jayvee template
generation and the #abbr.a[LLM] schema inference pipeline, demonstrating system behavior
at scale and under edge-case-specific constraints.

== JV Template Generation Evaluation

This section describes the high-performance test harness used to validate
and benchmark the Jayvee template generation script across 10,000 structurally consistent CSV files,
as well as a separate suite of edge-case scenarios designed to test robustness.

=== Test Architecture Overview

To ensure both correctness and scalability, an automated testing infrastructure
was deployed on an #abbr.a[HPC] system. The 10,000 CSV files under `CSVFiles/`
were processed one by one through the Jayvee generator to emit `.jv` templates,
which were then immediately executed to produce corresponding `.sqlite` sinks.

#figure(
image("./Evaluation_TempGen.png", width: 120%),
caption: [Test Architecture for Jayvee Template Generation],
) <test_architecture_tempgen>

A SLURM job script bootstrapped the environment by loading necessary modules,
activating the Conda environment, exporting required paths (`CSVFiles/`, `JvFiles/`, `SQLiteFiles/`, etc.),
and creating output directories. The Python test harness then scanned the input folder,
invoked the Jayvee CLI for schema inference, and ran the resulting `.jv` files via the Jayvee Executor.
All logs (stdout, stderr) and result artifacts were centrally aggregated for analysis.

=== Evaluation Results and Execution Validation

The evaluation of the template generator is centered not just on template creation, but on
the ability to execute each generated pipeline successfully.
This integrated validation ensures the templates are not only syntactically correct
but also functionally operational.

All 10,000 `.jv` templates were executed end-to-end, each invoking a full Jayvee pipeline:
extraction, interpretation, and final loading into a SQLite sink.
Execution logs were captured, and the presence of valid SQLite outputs was programmatically verified.

#figure(
image("./AggregatedResults_TempGen.png", width: 80%),
caption: [Evaluation Summary for Jayvee Template Generation],
) <eval_sum_tempgen>
Over the course of 10,000 test cases executed across 10 workers, the Jayvee template generation system demonstrated flawless performance. Every pipeline completed successfully, yielding a 100.00% execution success rate. There were no empty SQLite outputs and no runtime errors encountered at any stage. These outcomes confirm that each generated pipeline was not only syntactically valid but also semantically executable from end to end.

In terms of performance, the system achieved an average generation time of 0.889 seconds per file, culminating in a total generation time of approximately 8,892.893 seconds—just under 2.5 hours for the entire batch. Execution followed a similarly consistent pattern, with each pipeline completing in an average of 10.076 seconds, adding up to a total execution time of 100,764.951 seconds, or roughly 28 hours overall.


These results underscore the structural soundness and semantic robustness of the Jayvee schema inference process. Despite the fact that the test corpus did not contain highly malformed or noisy CSVs, it did represent a wide range of structurally varied but valid real-world formats. The system's ability to synthesize executable pipelines from such diverse inputs, without manual intervention or post-processing, confirms its production-readiness.

Execution success in this context functioned not merely as a metric, but as a critical quality assurance mechanism. Any structural misalignment—be it malformed headers, mismatched types, or parsing inconsistencies—would have manifested as execution failures or empty database sinks. The complete absence of such issues across the full dataset affirms that the generator produces well-formed, type-safe, and operationally sound pipeline specifications from the outset.

The Jayvee system, as evaluated here, proves capable of performing robust schema inference and template synthesis at scale. It requires no correction loops or fallback heuristics, offering a fully automated route from tabular input to structured pipeline deployment. This makes it a viable candidate for integration into larger ETL frameworks and DataOps environments, especially those that demand high throughput, strong correctness guarantees, and minimal human intervention.

=== Edge Cases in CSV Schema Inference

To further stress-test the pipeline's robustness, a dedicated suite of hand-crafted edge cases
was implemented independently of the 10,000-file run. These tests targeted specific
vulnerabilities in schema inference and execution.

Key edge cases addressed:

- Missing or default headers: Auto-renamed based on first-row values (e.g., `col_name`, `col_value`)
- Whitespace normalization: Leading/trailing spaces stripped from headers
- Quoted fields with internal delimiters: Handled via CSV dialect-aware parsing
- Type inference: Based on pandas’ dtypes mapped to Jayvee types (boolean, integer, decimal, text); datetimes coerced to text
- Header repair propagation: Renamed headers dynamically propagated to downstream blocks
- Boolean type detection: Used pandas-native logic (without extended normalization)
- File/path normalization: Filenames auto-normalized to CamelCase block identifiers

Additionally, runtime logging captured read/write errors with timestamps,
ensuring issues could be traced without halting the batch process.

Some complex challenges were identified but remain unimplemented in this iteration:

- Unicode normalization for multilingual headers
- Robust date coercion beyond ISO formats
- Semantic handling of diverse null patterns

These edge-case tests, though limited in scope compared to the full 10,000 pipeline runs,
demonstrate the system’s flexibility and provide a foundation for future enhancements
in schema inference under non-ideal input conditions.

== LLM-Based Schema Inference

The large-scale evaluation setup for header-row inference using transformer models under SLURM orchestration is detailed here.

=== Evaluation Workflow

The evaluation framework for Jayvee’s schema inference module was designed
to rigorously test the model’s ability to identify header rows in CSV files
that reflect real-world messiness, ambiguity, and inconsistency.
Rather than focusing on architectural constraints, the design centers on controlled variation,
scalability, and error surface visibility—all essential to understanding the strengths and
limitations of LLM-driven schema detection.

To generate a structurally diverse and realistic set of test CSV files for evaluation,
synthetic data was created using ChatGPT as a controlled generative source.
The generation process was guided by prompt engineering:
ChatGPT was explicitly instructed to simulate CSV files that reflect a
wide variety of noise patterns and formatting irregularities typically found in real-world datasets.
These prompts included multiple example CSVs containing preambles,
comment lines, mixed delimiters, unit annotations, and irregular metadata blocks,
which helped steer the model toward producing files that mirrored the complexity
of practical data ingestion scenarios.

One key constraint enforced during generation was that the actual
header row should always appear within the first 10 lines of each file.
This constraint reflects the empirical observation that, in most practical datasets,
structural metadata or introductory content rarely exceeds this threshold before the tabular schema begins.
It also helped establish a consistent search window for evaluation,
allowing models to focus on early sections of the file without assuming unlimited context.

To validate the fidelity and diversity of the generated files, a manual spot-checking procedure
was employed.
Random samples from the 10,000-file corpus were reviewed to verify that they met key criteria:
the presence of varying forms of noise (such as comment blocks, unit rows, encoding hints),
differences in header positioning within the allowed range,
and legitimate variability in schema complexity.
This qualitative inspection confirmed that the files spanned a representative spectrum
of realistic CSV challenges and that the header annotations aligned with plausible human expectations.

Overall, this methodology enabled the creation of a high-variance synthetic benchmark that
effectively stresses header detection models across a wide range of structural ambiguity,
 without requiring extensive hand-labeling. The controlled use of ChatGPT for generation,
 combined with spot validation, provided both scale and quality in dataset preparation.

Every file is paired with a ground truth label specifying the correct header row,
stored in a separate JSON file.
This design ensures high-throughput testing while enabling exact comparisons between
predicted and expected schema locations.

To operationalize this testing benchmark, the system employs a SLURM-based batch processing design.
Once launched, the master script configures the compute environment, loads necessary modules,
activates the relevant Conda environment, and sets up directories for logs, inputs, outputs, and metrics.
Each CSV is then passed through a uniform evaluation harness that locally loads the Hugging Face model,
constructs a prompt using the same few-shot template as production inference,
and performs local, deterministic generation using the transformers library.
Each model is launched in a separate SLURM array task (parallel_evaluation.sh) and evaluated
independently for fair comparison.

Models output a structured JSON with two keys: `columnNameRow` (integer) and `Explanation` (string).
The former is compared against ground truth to assess accuracy.

The model's output is parsed, validated, and compared against the known header index.
This comparison feeds directly into an aggregated accuracy score. For each file, detailed logs are captured—including the full prompt, model output, any exceptions raised, and metadata about runtime behavior. This transparent logging framework supports prompt audits, error tracing, and cross-run reproducibility.

The script `evaluate.py` coordinates evaluation per model, while `aggregate_results.py`
consolidates all partial evaluations into final JSON outputs.
This two-stage design decouples inference from aggregation,
allowing partial results to be recovered and reused if jobs fail mid-run.


What distinguishes this implementation is its emphasis on semantic difficulty over syntactic cleanliness.
The diversity and density of obfuscating preamble content test not just the model's token-level
pattern recognition, but its higher-order reasoning about what defines a schema.
Rather than simply identifying the most densely delimited or capitalized row,
models must interpret intent, context, and structure—skills central to robust schema understanding.

=== Evaluation Results

Due to persistent computational issues—including CUDA out-of-memory exceptions and
unexpected timeouts introduced by parallel batch execution under SLURM—the
full-scale evaluation across all 10,000 CSVs could not be completed.
As a result, no definitive percentage-based accuracy scores are available at this time.
Nevertheless, a qualitative review of a subset of successfully processed files yields important
insights into model behavior, including strengths and recurring failure patterns.

Despite lacking quantitative aggregates, the structure and logging of the evaluation
harness allowed for manual inspection of dozens of intermediate outputs.
These example cases reveal how LLMs navigate noisy metadata, ambiguous preambles,
and deceptive formatting—all of which are central to realistic schema inference scenarios.

=== Exemplary Model Outputs

In one illustrative case, the model was prompted with a CSV that began with a brief metadata block followed by a clean, semicolon-delimited schema row:

#figure(
image("./CSVExample_1.png", width: 100%),
caption: [Example CSV 1],
) <CSVExample_1>

The model correctly identified the header as residing on line 4:

#figure(
image("./ModelResponse_1.png", width: 100%),
caption: [Model Response for Example CSV 1],
) <ModelResponse_1>

This demonstrates the model’s ability to filter out boilerplate and recognize semantically
relevant schema rows—even amid multilingual licensing text and comment-style prefixes.
The clear structure and consistent formatting likely contributed to the model's confident
and correct identification.
Still, the model's response also contained some extraneous text, which is a common issue in LLM outputs.
Although the model correctly identified the header row,
it included additional commentary that was not part of the expected output
format since it was instructed to strictly follow a specified json schema that
was displayed in the three few shot examples before and also introduced int the beginning of the prompt.
Still, the answer contained parsable JSON with the expected keys.


A particularly revealing failure occurred with a file where preamble noise
was interleaved with markers resembling structural delimiters:

#figure(
image("./CSVExample_2.png", width: 60%),
caption: [Example CSV 2],
) <CSVExample_2>

In this case, the model erroneously
selected the second line (---------------------------------------) as the header row:

#figure(
image("./ModelResponse_2.png", width: 100%),
caption: [Model Response for Example CSV 2],
) <ModelResponse_2>

This result reflects a significant weakness: although the actual schema header (ID;Name;Industry;...)
appears on line 4, the model was misled by contextual cues such as \# --- End of header ---,
which appeared to indicate that the header immediately followed.
In fact, these lines were merely decorative dividers or formatting noise—common in real-world data
but potentially misinterpreted as delimiters of meaningful sections.

The model's misjudgment here likely stems from its over-reliance on literal cue phrases
and structural regularity. Phrases like “End of header” created a strong expectation
that what follows must be the schema, even though no semantic content had yet appeared.
This pattern illustrates how certain forms of pseudo-structure can bias model inference,
especially when combined with visually uniform separators (e.g., dashes, hashes)
that mimic human-readable section breaks.

Such noise elements—while innocuous to humans—pose a substantial challenge
to LLMs because they hijack superficial priors learned from documentation-style corpora.
Rather than evaluating semantic alignment of row contents with a schema pattern,
the model responded to syntactic decoration as if it carried programmatic significance.

Even within this partially executed evaluation, the system exposed key differentiators
in semantic precision, robustness to formatting noise, and reasoning fidelity
across multiple LLM architectures.
DeepSeek-Coder-Instruct stood out in its ability to filter through
metadata noise and identify headers correctly.
In contrast, smaller or less specialized models faltered on hybrid preambles or
ambiguous structure cues—highlighting the semantic, rather than syntactic, nature of the task.