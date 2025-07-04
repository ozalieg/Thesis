#import "../utils/todo.typ":*
#import "@preview/abbr:0.2.3"

= Architecture

This chapter explores the internaFl architecture of two core subsystems that underpin the overall functionality of the project: Jayvee Template Generation and LLM-Based Schema Inference.
 Each system is architected as a layered pipeline, encapsulating distinct concerns such as orchestration, data ingestion, transformation, inference, and output generation.
Through detailed component breakdowns and accompanying diagrams, this chapter provides insight into how raw tabular data is transformed into structured metadata or executable pipeline templates.
The goal is to convey both a conceptual overview and a practical account of each subsystem’s modular design, control flow, and extensibility mechanisms.

== Jayvee Template Generation

This section presents the architecture of the Jayvee Template Generation subsystem, which automates the conversion of CSV datasets into structured Jayvee pipeline templates.

Despite being implemented as a single command-line script, the system adopts a layered, component-based design typical of modern ETL tools. Each layer—from input parsing and schema inference to DSL code generation—is purpose-built to support modularity, extensibility, and robust error handling. By examining the responsibilities and data flow within each layer, this section provides a comprehensive look at how raw input files are transformed into ready-to-run Jayvee specifications.

The Jayvee Template Generation system automates the creation of structured Jayvee pipeline templates by extracting metadata—such as column names, types and overall schema—from heterogeneous CSV datasets. Although implemented as a single #abbr.a[CLI]-driven script, its internal architecture follows a modular, layered component model that mirrors data-flow principles common in modern ETL tooling. At the top sits the orchestration layer, embodied by a command-line interface that parses user arguments to determine whether inputs come from a single CSV file, a URL, a list of URLs, or an existing JSON schema; it also configures output directories and flags for optional JSON schema emission. Once arguments have been interpreted, the execution controller routes control flow to the input layer.

The input layer encompasses a CSV/URL reader for fetching raw data, a links-file processor for iterating over multiple URLs in a text file, and a file-handling utility responsible for normalizing paths, sanitizing names and validating resource availability. After raw data has been ingested, the template generation engine takes over. In its ingestion and preprocessing stage, raw CSV content is parsed into a DataFrame with correct quoting and whitespace handling; unnamed columns are automatically renamed according to simple heuristics that distinguish strings from numerics. The cleaned data then flows into the type inference component, which leverages Pandas dtypes and custom mappings to derive Jayvee-compatible types such as boolean, integer, decimal or text. These inferred types feed into the schema construction stage, which assembles a JSON schema conforming to Draft-07: it defines pipeline blocks (extractors, interpreters, loaders and optional header-writers) and pipes (the directed edges that represent data flow).

Once the JSON schema is complete, the Jayvee conversion component translates it into a Jayvee file by emitting Jayvee DSL code with explicit pipeline, block and arrow-based flow syntax. If the CREATE_JSON flag is enabled, the generated JSON schema is also saved as an intermediate artifact. Throughout every stage—from ingestion through conversion—a centralized error logger captures exceptions and writes them to a persistent error_log.txt, enabling post-mortem debugging without halting batch processing.

The result is a pair of generated artifacts: a production-ready Jayvee pipeline template suitable for execution by the Jayvee interpreter, and, when requested, a machine-readable JSON schema. This layered, component-based architecture ensures clear separation of concerns, straightforward extensibility (for example, adding new interpreter types or validation stages), and robust error handling, all while maintaining an internal structure that aligns with enterprise ETL frameworks.

The following @tempgen_architecture shows the component diagram that visualizes this architecture:

The architecture is depicted in the following diagram:
#figure(
image("./Architecture_TempGen.png", width: 60%),
caption: [Architecture Component Diagram - Jayvee Template Generation],
) <tempgen_architecture>

The diagram illustrates these layers, their responsibilities and the flow of data and control between them. The orchestration layer sits at the top, directing input sources toward the input layer; the input layer prepares data for the core engine, which itself is subdivided into ingestion, inference, schema construction and conversion stages; finally, generated artifacts emerge at the bottom while a cross-cutting logging component captures errors at every step.
This visualizes how each component contributes to the end-to-end transformation from raw CSV inputs to executable Jayvee pipelines, how optional JSON schema emission is handled, and how robust error handling is woven throughout the process.

== LLM-Based Schema Inference

This section details the architecture of the LLM-Based Schema Inference subsystem, which utilizes large language models to extract structured metadata from CSV datasets. Designed as a distributed, multi-layered pipeline orchestrated by Slurm, the system balances high-throughput batch processing with modular flexibility. It integrates components for job orchestration, input validation, prompt-based model inference, and evaluation, each operating in parallel across GPU nodes. The architecture emphasizes scalability, fault isolation, and extensibility—making it well-suited for large-scale schema inference tasks in high-performance computing environments.

At its highest level, a Slurm job script serves as the orchestration layer: it submits an array of tasks across GPU nodes, configures environment modules (Python, CUDA), activates a dedicated Conda environment, and ensures each Slurm array task isolates a specific model and data shard. Once a job is dispatched, the execution controller invokes evaluate.py, which parses command-line arguments (model directory, stride, offset, parallelism) and initializes distributed process groups when GPUs are available.

In the input layer, evaluate.py locates and validates CSV files from a designated directory, loads ground-truth annotations from JSON, and shards the file list across ranks and strides for data parallelism. Each selected CSV path, paired with its model identifier and an environment mapping of CUDA device assignments, is passed to a multiprocessing pool that executes run_find_header_job tasks in parallel.

Within the inference layer, each worker invokes a subprocess running find_header.py, which itself loads the first 20 lines of a CSV as text, constructs a prompt enriched with examples, and calls a local Hugging Face transformer model (via AutoTokenizer and AutoModelForCausalLM) to predict the header row. The model response is logged, cleaned of extraneous text, parsed into JSON using a Pydantic schema, and emitted back to the parent process.

The evaluation layer consumes these JSON‐encoded predictions alongside the ground truth. It tallies parsed files, missing annotations, correct and incorrect inferences, computes an accuracy percentage, and aggregates detailed records into a per-model summary. Partial results—both summary metrics and individual file evaluations—are serialized to disk under partial_results. A final aggregation step then merges these per-model JSON outputs into a consolidated report, which can be consumed downstream or visualized separately.

Throughout every stage—from Slurm orchestration through model inference and evaluation—a rotating file logger captures informational messages, warnings, and errors without interrupting the pipeline, thereby enabling fault isolation and continuous batch processing.

Below in @llm_schema_diagram this layered architecture is illustrated by a component diagram icluding the flow of control and data between components as well as the cross-cutting logging concern:
#figure(
image("./Architecture_LLMInf.png", width: 120%),
caption: [Architecture Component Diagram – LLM-Based Schema Inference ],
) <llm_schema_diagram>

By depicting the Slurm script at the top,
the diagram emphasizes that each array job fully encapsulates its own model instance and GPU allocation.
The input layer’s separation of raw CSV loading and ground‐truth ingestion clarifies data validation duties,
while the inference layer splits control logic
from per‐file modeling.
The evaluation layer then systematically computes and aggregates results,
and a dedicated logging component captures runtime behavior.
This modular, layered design ensures that new models, alternative parsing strategies
or enhanced evaluation metrics can be introduced independently,
while Slurm’s array mechanism guarantees horizontal scalability and fault isolation across
high‐performance computing environments.

== Conclusion

The architectural designs of both the Jayvee Template Generation and LLM-Based Schema Inference
subsystems exemplify modular, layered pipelines tailored for data-centric transformation tasks.
Each system applies distinct orchestration strategies—CLI-based execution versus Slurm-based
job arrays—while adhering to common principles such as clear separation of concerns,
robust error handling, and data-driven control flow.
Their component-based structures enable independent evolution of subsystems such as schema inference,
data preprocessing, or evaluation logic.
Together, these designs support scalable, fault-tolerant processing of heterogeneous tabular
data across both interactive and distributed execution environments.