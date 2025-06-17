#import "../utils/todo.typ":*
#import "@preview/abbr:0.2.3"

= Implementation

== JV Template Generation Script

=== Design Overview

The JV Template Generation Script implements a modular #abbr.add("ETL", "Ectract-Transform-Load") #abbr.a[ETL] pipeline
for transforming raw CSV datasets—whether sourced locally or remotely—into formalized
data extraction templates. These templates are expressed in both JSON and .jv format,
enabling downstream processing in structured data integration workflows.
The system adopts a layered architecture with clear data flow between its input management,
schema inference, pipeline construction, and file output stages.
This separation of concerns enables modular development, testing, and maintenance,
while the GUI wrapper ensures usability for technical and non-technical users alike.

The pipeline begins with the user initiating an operation via the GUI,
which supports three input modes: single file selection, direct URL input,
or batch processing from a file of links.
The selected source is passed to an input handling component, which normalizes file or URL data,
reads the content, and forwards it to the schema inference stage.
Here, column headers and sample values are examined to infer data types,
using both heuristics and fallback logic.
The normalized schema is then passed to the pipeline generator, which constructs a JSON representation
of an extraction pipeline composed of extractor, interpreter, and loader blocks,
along with associated metadata and identifiers.
Optionally, the generated pipeline is saved as a JSON file, and is always converted to a .jv text file.
A dedicated set of naming utilities ensures identifier consistency and
filesystem-safe naming conventions throughout.
=== Components Responsibilities

The system is organized around six loosely coupled components:

The GUI Component presents the user interface, handling interactions such as file selection,
URL input, and links-file browsing. It also locks controls during execution and appends real-time logs
to a progress window.

The Input Management Component processes the chosen data source,
loading the file from disk or fetching it via HTTP.
In the case of batch input, it iterates over a links file and handles each entry sequentially.

The Schema Inference Component reads the CSV data using Pandas and generates a structured schema.
It identifies unnamed columns, assigns default labels and types, and calls type-mapping utilities
to map Pandas dtypes into canonical categories: text, integer, decimal, or boolean.

The Pipeline Generation Component receives the normalized schema and
constructs a JSON pipeline specification.
It uses the original filename or URL to generate internal names and metadata.
If columns were renamed, it additionally maps column indices to spreadsheet-style labels.

The JSON & JV Writer Component saves the pipeline structure as a JSON file (when enabled),
and always writes the corresponding .jv template.
It ensures consistent naming and manages file paths and directories.

The Naming/Path Utilities Component supports the above stages with functions for sanitizing filenames,
converting names to CamelCase, generating valid identifiers, and labeling columns by index.


=== Data Flow and Intermediate Formats

The system accepts as input either local CSV files or remote URLs,
including batch-mode processing from a newline-delimited links file.
The intermediate schema is represented as a list of {name, type} objects,
which is transformed into a pipeline JSON document with blocks, pipes, and supporting metadata.
The final .jv output format is a human-readable, line-based representation of the extraction template.

=== Technology Stack

The system accepts as input either local CSV files or remote URLs,
including batch-mode processing from a newline-delimited links file.
The intermediate schema is represented as a list of {name, type} objects,
which is transformed into a pipeline JSON document with blocks, pipes,
and supporting metadata.
The final .jv output format is a human-readable, line-based representation of the extraction template.

=== Error Handling

Input boundaries are actively validated.
Missing files, broken URLs, or malformed links trigger GUI warnings and are logged to disk.
Defaulting behavior in the schema inference stage ensures that unknown or unnamed columns
are still incorporated, using generic labels and default types.
Failures are logged with stack traces in the backend and user-friendly summaries in the GUI.

=== Implementation Details

Each component is implemented as a pure Python function or class that communicates
via in-memory data structures. The GUI uses standard file and dialog boxes to capture user input,
disabling interactions while tasks are running and re-enabling them when complete.
Input handling selects the appropriate loading mechanism—open() for local files,
urllib.request.urlopen() for remote sources—and supports batch iteration over links files.

Schema inference is performed via pd.read_csv() followed by column-level inspection.
Unnamed or ambiguous columns are labeled generically and assigned a fallback type of "text".
A helper function maps Pandas-inferred dtypes to the restricted set of canonical types.

Pipeline generation constructs a hierarchical structure of extractor and interpreter blocks,
automatically embedding metadata such as file name and table name. Naming utilities like
to_camel_case() and column_index_to_label() are used to produce valid and readable identifiers.

The final stage involves optional JSON serialization and always produces a .jv output file.
The writing component creates directories if needed and generates filenames derived
from the original data source. Sanitization ensures compatibility across platforms.

The following sequence diagram captures the complete workflow,
illustrating the order and nature of interactions between user interface, core logic components,
and file writing subsystems:

#figure(
image("./TempGen_Seq.png", width: 143%),
caption: [Sequence Diagram for Jayvee Template Generation],
) <sequence_diagram_tempgen>

The sequence diagram above delineates the end‑to‑end implementation workflow
of the JV Template Generation Script, tracing each interaction from the moment a user initiates
the process through to the successful creation of a .jv template.
Upon clicking “Select CSV,” “Enter URL,” or “Select Links File,” the GUI component immediately
locks the interface and begins logging progress to prevent conflicting inputs during execution.
In the case of a single file or direct URL, the GUI delegates control to the Input Management module,
which either prompts for a file or accepts the URL before normalizing and processing the data source.
 If a links file is chosen, the Input Management module reads each link in turn, invoking
 the same processing routine for every entry in the batch.

Within the process_file_or_url operation, control shifts to the Schema Inference component,
which inspects the first 20 lines of the CSV to infer column types, consulting the Naming/Path Utilities
to map Pandas data types to canonical categories. With the inferred column types in hand,
the Pipeline Generation component assembles a JSON schema for the ETL pipeline, again leveraging
the naming utilities to generate valid identifiers—extracting and CamelCasing file names, parsing URLs,
and computing spreadsheet‑style column labels for any renamed headers.
Should JSON output be enabled via the CREATE_JSON flag, the JSON & JV Writer first persists
the intermediate schema to disk; regardless, it then converts the JSON representation
into the final .jv format, sanitizing all names and writing the template file.
Finally, control returns to the GUI, which unlocks the user interface and completes the progress logs,
signaling that the template generation cycle has concluded cleanly and transparently.

== LLM Schema Inference
=== Design Overview

This part of the system addresses the challenge of detecting the header row in arbitrary CSV files
by leveraging a locally hosted, OpenAI-compatible #abbr.a[LLM].
The approach is grounded in few-shot prompt engineering,
where the model is exposed to multiple examples of CSV fragments and their corresponding annotations,
enabling it to generalize to unseen files. Structured output is enforced through schema validation
using Pydantic models, and the entire interaction with the model is managed locally
to preserve privacy and optimize inference speed. The architecture focuses on robustness,
interpretability, and modularity, allowing each stage—from CSV ingestion to LLM interaction
 and output validation—to be independently tested and debugged.

=== Components Responsibilities

The process begins with a CSV Loader that handles the opening and preprocessing of input files.
To ensure broad compatibility, especially with files exported from software like Excel,
the loader reads the input using UTF-8 with a Byte Order Mark (utf-8-sig).
It extracts the first 20 lines of the file, which are used as the context window for inference.
This snapshot captures enough structure and noise for the LLM to deduce
where the actual header row is located.

Next, a Prompt Builder constructs the input that will be sent to the #abbr.a[LLM].
This prompt is composed of three few-shot examples,
each consisting of a 20-line CSV snippet followed by a JSON-formatted answer
that identifies the correct header line and explains the rationale.
The prompt ends with the actual file content to be analyzed.
Careful formatting of the prompt, including clear separation of examples
 and a reiteration of the expected schema, guides the model towards producing consistent and valid outputs.

Inference is performed through a local LLM backend that adheres to the OpenAI API specification.
This compatibility allows the use of standard tools like openai.Client or vllm.LLM,
while benefiting from local execution in terms of speed and data governance.
The inference call constructs messages with distinct system and user roles
and applies strict parameters such as a temperature of zero to encourage deterministic behavior.
Token limits and timeouts are configured to handle large prompts without risking model instability.

Once a response is received, a two-stage parsing process is initiated.
The first stage employs a regular expression to extract the first valid JSON block from the response,
accounting for potential extraneous text generated by the model.
This block is then passed to LangChain’s JsonOutputParser,
which works in tandem with a Pydantic model (Header) that specifies the expected structure:
an integer field for columnNameRow and a string field for Explanation.
This ensures that even if the LLM generates syntactically correct but semantically invalid content,
it will be flagged during validation.

To ensure resilience, the entire inference process is wrapped in structured error handling.
Any exceptions raised during loading, prompt generation, API calls,
or output validation are caught and logged.
If the output cannot be parsed or fails schema validation, a fallback JSON response is returned,
defaulting the header row to one and including an explanatory error message.
All raw responses and tracebacks are preserved to facilitate debugging and model refinement over time.

=== Data Flow

The schema inference pipeline follows a linear and modular structure.
Input data is first loaded and truncated to a 20-line preview.
This preview is embedded into a prompt that includes three labeled examples.
The prompt is then passed to the LLM, whose output undergoes JSON extraction and validation.
If the output conforms to the defined schema, it is returned;
otherwise, fallback mechanisms ensure that the pipeline continues gracefully.
This pipeline—from data ingestion to validated result—enables systematic inference
while preserving traceability at each stage.

=== I/O Formats & Schemas

The input to the inference system is a plain-text string composed of the first 20 lines from the CSV file.
This snapshot captures not only the data but also any preceding metadata, comments,
or whitespace that may exist in real-world datasets.
The prompt generated for the LLM includes this content alongside three few-shot examples,
each comprising a similar CSV excerpt followed by a JSON-formatted answer.
The output expected from the model must conform to a JSON schema specifying two fields:
an integer columnNameRow indicating the line number of the header,
and a string Explanation justifying the choice.
This structured output format allows the system to use standard validators
and simplifies downstream processing.

=== Technology Stack

The inference system is implemented in Python 3.10 and interacts with a local,
GPT-compatible LLM via the OpenAI API. The LangChain library provides the JsonOutputParser,
which integrates seamlessly with Pydantic for output schema enforcement.
Other tools used in the system include the re module for pattern extraction,
json for serialization and deserialization, and logging for diagnostics.
The LLM backend itself is provided via vllm, a performant engine that allows batched and cached inference.
The choice to run the model locally ensures that data privacy is maintained and inference latency
is minimized, making the system suitable for sensitive or large-scale data applications.

=== Error Handling

Robust error handling is embedded at every stage of the pipeline.
If the #abbr.a[LLM] output fails to parse into a valid JSON structure,
a regex-based fallback attempts to extract a plausible JSON block.
Should this still fail, or if schema validation throws an error,
the system generates a fallback output with a default header row of one
and a descriptive message indicating what went wrong.
All errors are logged using the logging module, and raw model outputs are preserved
to assist in manual review or prompt tuning.
This approach ensures graceful degradation and provides clear signals when the model underperforms
or when input data deviates from expected formats.

=== Implementation Details

The core functions of the system are designed for modularity and reuse.
The CSV loader is implemented via load_csv_as_text(path),
which reads a file and returns a list of strings.
The prompt builder function, build_prompt(csv_str),
creates the few-shot prompt by embedding labeled examples and formatting them consistently.
The LLM client, whether based on openai or vllm, handles inference calls with deterministic settings.
The response is processed by extract_json(response_text),
which applies a regular expression to locate the JSON block
and passes it to LangChain’s parser for validation.
The Header Pydantic model enforces that the output adheres to the defined schema.
If any step fails, fallback logic returns a safe, minimal output while logging the issue.

These functions operate over clear input-output contracts:
the input is a 20-line string from the CSV file,
and the output is a validated JSON object identifying the header row.
This predictability facilitates integration into broader data processing pipelines,
such as automated dataset labeling, previewing, or ingestion routines.

To complement the detailed explanation of the schema inference pipeline,
the following sequence diagram in @LLMInfSequenceDiagram illustrates the dynamic interaction between the system’s components
during an end-to-end execution of the evaluation workflow.

#figure(
image("./LLMInf_SequenceDiagram.png", width: 132%),
caption: [Sequence Diagram LLM Schema Inference],
) <LLMInfSequenceDiagram>

The orchestration begins with the submission of a SLURM job (run_vllm_models.sh),
which is responsible for setting up the computational environment, validating inputs,
and initializing the model server.
For each model under evaluation, a local vLLM instance is launched and monitored
until it becomes accessible via the OpenAI-compatible API interface.

Once the model server is confirmed to be running,
the test harness (test_find_header.py) is executed.
This script iterates over all CSV files in the evaluation directory,
delegating each file to a subprocess invocation of the schema inference script (vllm_find_header.py).
This subprocess reads the CSV file, constructs a prompt, and queries the local model instance.
The resulting JSON response is parsed and returned to the test script,
where it is compared against ground truth annotations.
Evaluation metrics and raw results are written to structured output files,
including JSON summaries and logs.

After all files have been evaluated for a given model,
the model server is gracefully terminated, and the workflow proceeds to the next model
in the evaluation loop.
In case of any startup failure, appropriate error logging
and cleanup routines are invoked to maintain workflow integrity.
The diagram captures these interactions,
file system accesses, subprocess calls,
and LLM query exchanges in a step-by-step sequence that mirrors the implemented orchestration.

This diagram provides a visual overview of the entire inference and evaluation process,
reinforcing the modular and reproducible nature of the architecture.

