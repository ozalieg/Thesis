#import "../utils/todo.typ":*
#import "@preview/abbr:0.2.3"

= Implementation

This section describes how each subsystem is realized in code, mapping design to concrete Python scripts and workflows.

== Jayvee Template Generation

The Jayvee Template Generation Script transforms CSV inputs into Jayvee pipeline templates via a layered ETL process, all driven from the command line.

=== Design Overview

The Jayvee Template Generation Script implements a
modular #abbr.add("ETL", "Extract-Transform-Load") #abbr.a[ETL] pipeline
for transforming raw CSV datasets—whether sourced locally or remotely—into
formalized data extraction templates.
These templates are expressed in both JSON and Jayvee format,
 enabling downstream processing in structured data integration workflows,
such as automated database population, analytical pipeline configuration, or data quality validation.

The system adopts a layered architecture with clear data flow between its input management, schema inference, pipeline construction, and file output stages. This separation of concerns enables modular development, testing, and maintenance.

The system begins with the user initiating an operation via #abbr.a[CLI],
which supports three input modes: single file selection, direct URL input,
or batch processing from a file of links.
The selected source is passed to an input handling component, which normalizes file or URL data,
reads the content, and forwards it to the schema inference stage.
Here, column headers and sample values are examined to infer data types,
using both heuristics and fallback logic.
The normalized schema is then passed to the pipeline generator, which constructs a JSON representation
of an extraction pipeline composed of extractor, interpreter, and loader blocks,
along with associated metadata and identifiers.
Optionally, the generated pipeline is saved as a JSON file, and is always converted and saved in Jayvee.
A dedicated set of naming utilities ensures identifier consistency and
filesystem-safe naming conventions throughout.


=== Components Responsibilities

The system is organized around six loosely coupled components:

The #abbr.a[CLI] Component presents the user interface, handling interactions such as file selection, URL input, and links-file browsing. A links file refers to a plain-text file containing a list of remote data sources (e.g., CSV URLs), allowing users to batch-load and preview multiple resources through the interface. The #abbr.a[CLI] enables users to browse these entries interactively and choose specific links for processing. It also locks controls during execution and appends real-time logs to a progress window.

The Input Management Component processes the chosen data source,
loading the file from disk or fetching it via HTTP.
In the case of batch input, it iterates over a links file and handles each entry sequentially.

The Schema Inference Component reads the CSV data using Pandas and generates a structured schema.
It identifies unnamed columns, assigns default labels and types, and calls type-mapping utilities
to map Pandas dtypes to Jayvee datatypes: text, integer, decimal, or boolean.

The Pipeline Generation Component receives the normalized schema and
constructs a JSON pipeline specification.
It uses the original filename or URL to generate internal names and metadata.
If columns were renamed, it additionally maps column indices to spreadsheet-style labels.

The JSON & Jayvee Writer Component saves the pipeline structure as a JSON file (when enabled),
and always writes the corresponding Jayvee template.
It ensures consistent naming and manages file paths and directories.

The Naming/Path Utilities Component supports the above stages with functions for sanitizing filenames,
converting names to CamelCase, generating valid identifiers, and labeling columns by index.
CamelCase naming for pipeline and block identifiers is derived from filenames
or URLs using a utility function.
Spreadsheet-style column labels (A1, B1, ...) are generated for unnamed headers
via a separate index-mapping utility.

=== Edge Cases in CSV Schema Inference

During the implementation of the Jayvee template generation system,
I focused on several key edge cases to ensure robustness in CSV template generation.
Columns with missing or default "Unnamed" headers are automatically renamed
based on the first data value in each column—for example,
renamed to "col_name" if the first value is a string, or "col_value"
if numeric—so that every column remains addressable.
Leading and trailing whitespaces around column headers are removed to prevent mismatches during processing.
The CSV parser respects quoted fields containing delimiters by using appropriate options such
as a quote character and skipping initial spaces, adhering to common CSV dialect conventions
rather than simply splitting on commas.
Column data types are inferred from pandas’ dtype detection and mapped
Jayvee datatypes including boolean, integer, decimal, and text; notably,
datetime types are coerced to text to handle their variability.
When column headers are renamed, the pipeline schema dynamically includes an intermediate
step to write these corrected headers, ensuring downstream components consume consistent column names.
Boolean types are inferred from pandas native detection,
although explicit normalization of different boolean representations was not implemented beyond this.
Additionally, the system normalizes file names extracted from file paths or URLs into
CamelCase for consistent naming of pipelines and processing blocks.
Throughout processing, errors during CSV reading or JSON file saving are logged
with timestamps to facilitate troubleshooting without interrupting the overall workflow.
While more complex edge cases such as Unicode normalization for multilingual headers,
flexible date format coercion, and semantic handling of null values were identified as challenges,
they remain unimplemented in the current system iteration.

=== Data Flow and Intermediate Formats

The system accepts as input either local CSV files or remote URLs,
including batch-mode processing from a newline-delimited links file.
The intermediate schema is transformed into a JSON pipeline description.
When the CREATE_JSON environment flag is enabled,
this JSON is persisted to disk alongside the default Jayvee output.
The final Jayvee output format is a human-readable, line-based representation of the extraction template.


=== Technology Stack

The system accepts as input either local CSV files or remote URLs,
including batch-mode processing from a newline-delimited links file.
The intermediate schema is represented as a list of {name, type} objects,
which is transformed into a pipeline JSON document with blocks, pipes,
and supporting metadata.
The final Jayvee output format is a human-readable, line-based representation of the extraction template.

=== Error Handling

Input boundaries are actively validated.
Missing files, broken URLs, or malformed links trigger #abbr.a[CLI] warnings and are logged to disk.
Defaulting behavior in the schema inference stage ensures that unknown or unnamed columns
are still incorporated, using generic labels and default types.
All critical errors, including malformed inputs or I/O failures,
are logged to a centralized `error_log.txt`.
Structured error reporting avoids stack trace noise and supports batch evaluation.


=== Implementation Details

Each component is implemented as a pure Python function or class that communicates
via in-memory data structures. The #abbr.a[CLI] uses standard file and dialog agrument interpretation to capture user input,
disabling interactions while tasks are running and re-enabling them when complete.
Input handling selects the appropriate loading mechanism—open() for local files,
urllib.request.urlopen() for remote sources—and supports batch iteration over links files.

Schema inference is performed via pd.read_csv() followed by column-level inspection.
Unnamed or ambiguous columns are labeled generically and assigned a fallback type of "text".
A helper function maps Pandas-inferred dtypes to the restricted set of Jayvee types.

Pipeline generation constructs a hierarchical structure of extractor and interpreter blocks,
automatically embedding metadata such as file name and table name. Naming utilities like
to_camel_case() and column_index_to_label() are used to produce valid and readable identifiers.

The final stage involves optional JSON serialization and always produces a Jayvee output file.
The writing component creates directories if needed and generates filenames derived
from the original data source. Sanitization ensures compatibility across platforms.

The following sequence diagram captures the complete workflow,
illustrating the order and nature of interactions between user interface, core logic components,
and file writing subsystems:

#figure(
image("./SequenceDiagram_TempGen.png", width: 130%),
caption: [Sequence Diagram - Jayvee Template Generation],
) <sequence_diagram_tempgen>

The sequence diagram above delineates the end‑to‑end implementation workflow
of the Jayvee Template Generation Script, tracing each interaction from the moment a user initiates
the process through to the successful creation of a Jayvee template.
Upon clicking “Select CSV,” “Enter URL,” or “Select Links File,” the #abbr.a[CLI] component immediately
locks the interface and begins logging progress to prevent conflicting inputs during execution.
In the case of a single file or direct URL, the #abbr.a[CLI] delegates control to the Input Management module,
which either prompts for a file or accepts the URL before normalizing and processing the data source.
 If a links file is chosen, the Input Management module reads each link in turn, invoking
 the same processing routine for every entry in the batch.

Within the process_file_or_url operation, control shifts to the Schema Inference component,
which inspects the first 20 lines of the CSV to infer column types, consulting the Naming/Path Utilities
to map Pandas data types to canonical categories. With the inferred column types in hand,
the Pipeline Generation component assembles a JSON schema for the #abbr.a[ETL] pipeline, again leveraging
the naming utilities to generate valid identifiers—extracting and CamelCasing file names, parsing URLs,
and computing spreadsheet‑style column labels for any renamed headers.
Should JSON output be enabled via the CREATE_JSON flag, the JSON & Jayvee Writer first persists
the intermediate schema to disk; regardless, it then converts the JSON representation
into the final Jayvee format, sanitizing all names and writing the template file.
Finally, control returns to the #abbr.a[CLI], which unlocks the user interface and completes the progress logs,
signaling that the template generation cycle has concluded cleanly and transparently.

An auxiliary evaluation script, test_pipeline_generation.py, supports batch testing and performance profiling. It ingests CSVs from a directory, invokes jv_template_generation.py as a subprocess, verifies generation of Jayvee templates, and executes them via the Jayvee #abbr.a[CLI] to produce SQLite outputs. Metrics such as execution time, return codes, and output file status are logged centrally. The script supports parameterization via #abbr.a[CLI] flags for parallelism (--parallel) and sub-sampling (--every-nth).


== LLM-Based Schema Inference

This section details the offline, Slurm-driven pipeline for using LLMs to infer CSV header rows at scale.

=== Design Overview

The LLM-based schema inference subsystem addresses the task of identifying the header row
in noisy or ambiguous CSV files using an autoregressive transformer model executed entirely offline.
The system is designed for scale, repeatability, and modularity,
enabling benchmarking across multiple models on large input corpora without internet access
or server dependencies.

At its core, the system processes each CSV file using a standalone script (find_header.py)
that prepares a structured prompt using few-shot examples, executes inference via a Hugging Face model,
and returns a machine-readable JSON output. The workflow is orchestrated through Slurm job arrays
(parallel_evaluation.sh), where each task handles one model independently.
Evaluation results are serialized to disk, allowing partial recovery, reproducibility, and aggregate analysis.

This architecture replaces earlier API-driven designs with fully #abbr.a[CLI]-based workflows that are portable and privacy-preserving. Inference is conducted directly within the Python runtime using locally stored model weights. All outputs conform to a strict schema for downstream compatibility, and each stage is instrumented with structured logging to support debugging, validation, and performance tracking.

=== Component Responsibilities

The evaluation process begins by reading the first 20 lines of each CSV file. This sampling strategy captures enough structural variation and noise to provide meaningful context while keeping the prompt size within model token limits. Once read, the snippet is passed to find_header.py, which appends it to a few-shot prompt template consisting of three curated examples. The prompt is crafted to follow a consistent and readable layout, with newline padding and clearly delimited JSON answers.

Inference is executed locally using the Hugging Face transformers library. The model and tokenizer are loaded directly from disk using standard APIs such as AutoModelForCausalLM and AutoTokenizer. To enforce determinism, the decoding parameters are fixed: the temperature is set to zero, maximum token limits are specified, and if applicable, a stop sequence is used to terminate generation cleanly. These settings ensure consistent outputs regardless of the underlying hardware or parallelism configuration.

After generation, the model’s response is expected to contain a valid JSON object with two keys: columnNameRow, indicating the 1-based index of the header row, and Explanation, providing natural language reasoning for the choice. The response is parsed using Python’s standard json library. If the model output is malformed or extraneous text appears before the JSON block, the parser attempts to extract the first valid JSON-like substring using regular expressions. Any parsing failures trigger a fallback mechanism that returns a default result and logs the incident for later analysis.

Evaluation is carried out per model using evaluate.py, which applies this inference process across a large CSV corpus and records whether each prediction matches the corresponding value in a ground_truth.json file. All predictions, explanations, correctness flags, and metadata are written to disk in structured form. These intermediate results are aggregated post-hoc using aggregate_results.py, which merges per-model results into global summaries and evaluation metrics.


=== Data Flow

The evaluation pipeline initiates with directory traversal to locate all target CSV files, typically capped at 10,000 instances for large-scale benchmarking. For each file, a 20-line preview is extracted and sent to find_header.py, where a prompt is generated by inserting this snippet into a few-shot template. The transformer model processes the prompt and produces a structured response.

This response is then parsed and compared to a reference value from the ground truth dataset. The outcome is logged, with both the predicted and expected values recorded. If parsing fails or the result is invalid, the system logs the error, substitutes a default row index (typically 1), and attaches a diagnostic message. This process continues for each file in the corpus.

After all files have been evaluated for a given model, the results are saved in a partial results directory. When all models have been processed—typically via Slurm job arrays—aggregate_results.py is executed to compile the individual logs into a comprehensive results file (evaluation_results.json) and a summary statistics file (evaluation_summary.json).

=== I/O Formats & Schemas

The input to the system consists of a plain text string made up of the first 20 lines of a given CSV file. This preview may include noise such as comments, blank lines, or inconsistent delimiters, and is not sanitized prior to processing. This design choice reflects the real-world messiness of CSVs and challenges the model to generalize beyond cleanly formatted input.

The output expected from the model is a strict JSON object containing two fields. The columnNameRow field holds an integer indicating the row where the column headers appear, using 1-based indexing. The Explanation field is a free-form natural language string that justifies the model’s choice. This output is parsed with the standard json module and validated against these schema constraints. If any structural or semantic issues are detected, the system returns a fallback output along with a log entry that includes the raw response for debugging purposes.

This consistent format facilitates integration with possible downstream workflows, such as automated template generation, performance analytics, or error inspection tools. The structure also ensures compatibility with a wide range of evaluation and post-processing utilities.

=== Technology Stack

The implementation is written in Python 3.12 and uses Hugging Face’s transformers library to load and run language models offline. Inference is conducted entirely within the Python runtime, eliminating the need for any API servers or internet access. The evaluate.py and aggregate_results.py scripts are modular and self-contained, designed for efficient batch execution on high-performance clusters. Logging is handled through Python’s built-in logging module, which outputs both human-readable and machine-readable logs for debugging and analysis.

The system architecture is fully portable and compatible with a variety of computing environments, ranging from local workstations to Slurm-managed GPU clusters. Models are loaded from disk without requiring Hugging Face Hub access, and no tokenizers or resources are fetched remotely during runtime. This guarantees operational stability in air-gapped or privacy-sensitive environments.

=== Error Handling

The system is designed with layered exception handling at every stage. If a CSV file is unreadable or improperly formatted, the corresponding error is logged and the file is skipped. When the model returns an output that fails to parse as JSON, a regular expression is used to extract the most likely JSON block. If parsing still fails or required fields are missing, a default result is generated and recorded. These fallbacks include the assumed header row (typically the first row) along with an explanation of the error, allowing users to trace and debug failures systematically.

All logs are serialized to disk and grouped by model, making it easy to review the performance of individual models and track recurring issues. The design ensures that evaluation is never halted due to a single failure. Instead, the system continues processing remaining files while isolating and documenting any errors encountered along the way. This robustness is critical for large-scale model benchmarking and reproducible experimentation.

=== Implementation Details

The overall evaluation process is illustrated by the sequence diagram below. It captures the orchestration between Slurm, the individual scripts, and the modular components of the schema inference workflow.

#figure(
  image("./SequenceDiagram_LLMInf.png", width: 130%),
  caption: [Sequence Diagram – LLM-Based Schema Inference Evaluation Pipeline],
) <sequence_diagram_llminf>

The evaluation begins with the submission of a Slurm job array using the parallel_evaluation.sh script. Each array task selects one transformer model from a predefined list and runs the evaluate.py script in an isolated environment. This script reads all target CSV files, invokes find_header.py for each one via a subprocess, and compares the model’s prediction to the known ground truth. Results are written to model-specific JSON files inside the partial_results directory.

Once evaluation is complete for all models, the aggregate_results.py script is executed. It reads each partial results file, merges the per-file evaluations, and produces two output files: evaluation_results.json, which contains the full set of predictions, and evaluation_summary.json, which summarizes accuracy and statistics for each model.

This architecture supports graceful degradation, parallel execution, modular restarts, and detailed logging. It is optimized for batch operation and reproducible benchmarking, making it well-suited for systematic evaluation of header inference capabilities in large language models.