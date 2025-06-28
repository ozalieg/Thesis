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
image("./Evaluation_Summary_TempGen.png", width: 80%),
caption: [Evaluation Summary for Jayvee Template Generation],
) <eval_sum_tempgen>

The results:

- 100% execution success rate across 10,000 pipelines
- No empty SQLite outputs or runtime errors encountered
- Average generation time per file: under 1 second
- Total generation time for 10,000 templates: ~2.5 hours

These results confirm the structural soundness of the Jayvee schema inference process.
Although the full corpus did not contain highly noisy or malformed CSVs, the test still covered a broad
range of consistent, real-world formats. The successful execution of each pipeline validates that
the emitted templates are not only syntactically correct but semantically operable,
highlighting the system’s readiness for scaled production deployment.

Execution success functioned as both a benchmark and a quality filter:
any misalignment—such as broken headers, invalid types,
or parsing failures—would have led to execution errors or incomplete database sinks.
The absence of such issues affirms the generator’s ability to synthesize valid,
well-formed pipelines from structurally sound inputs.

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

== LLM Schema Inference Evaluation

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

A synthetic benchmark of 10,000 structurally diverse CSV files was used to evaluate three transformer-based language models on their ability to correctly identify header rows. Each prediction was considered accurate only when it precisely matched the annotated ground truth. The benchmark deliberately included edge cases such as lengthy multi-line preambles, non-standard delimiters, multilingual comments, and hybrid metadata patterns to rigorously test the models’ semantic understanding.

Performance across the three models revealed substantial variation, shaped by differences in parameter size, instruction tuning, and schema inference capabilities. The instruction-tuned DeepSeek-Coder model achieved the highest accuracy, with ~85% of headers identified correctly. It exhibited strong generalization across noisy and irregular file structures, showing resilience to comment-laden preambles and embedded metadata. In contrast, Qwen3-4B, a smaller model with more limited schema-specific fine-tuning, reached around 72–75% accuracy. While it performed reliably on simple or moderately obfuscated headers, its performance degraded when encountering files with complex metadata layering or pre-header unit annotations. Surprisingly, CodeLlama-7B-Instruct, despite having more parameters than Qwen3-4B, delivered less consistent results, hovering around 65–68% accuracy. It often prioritized superficial text features like capitalization or row length over semantic cues, and frequently misclassified visually dense rows without adequately interpreting their functional roles.

An in-depth error analysis revealed several common failure modes. Models frequently mistook rows containing unit descriptions—such as “All values in USD”—for actual headers, particularly when those lines were short, capitalized, and well-formatted. This tendency indicates an overreliance on surface-level heuristics in the absence of semantic understanding. Another recurring issue was the misidentification of document footers or introductory comments as header lines, pointing to the models’ limited ability to temporally contextualize structural elements within the typical progression of a CSV file. The inability to resolve multi-row headers further exposed a structural weakness: rather than aggregating schema information spread across adjacent lines, models typically fixated on a single row, leading to partial or incorrect extractions. Lastly, all three models demonstrated a strong bias toward visually regular patterns—favoring consistent delimiters, token length, and uppercase tokens—even when such rows carried no semantic weight as headers.

These patterns suggest that accurate schema inference remains a partially emergent capability among general-purpose LLMs. Instruction tuning—exemplified by the superior performance of DeepSeek-Coder—clearly enhances robustness and contextual understanding, but persistent failure modes underscore the absence of domain-specific inductive bias and the lack of hierarchical reasoning. Notably, the results also challenge the assumption that larger models inherently perform better on structural tasks; CodeLlama’s comparatively weak results demonstrate that parameter count without targeted training does not guarantee semantic precision.

From a practical standpoint, these findings have direct implications for deploying LLMs in data ingestion and integration pipelines. In production environments, where files often contain noise, metadata, and domain-specific annotations, relying solely on LLM predictions without safeguards may lead to brittle performance. Incorporating fallback strategies—such as rule-based validation layers, confidence-based filtering, or hybrid pipelines combining symbolic and neural methods—could mitigate these risks. Additionally, fine-tuning on curated corpora of annotated, messy CSVs could further align model predictions with real-world schema patterns.

The experimental setup itself, grounded in synthetic data with controlled complexity and transparent, traceable evaluation criteria, provides a solid foundation for future benchmarking and iterative refinement. It not only demonstrates the current feasibility of LLM-based header detection but also delineates the performance ceiling and the kinds of architectural or training interventions that may be necessary to push it further.