#import "../utils/todo.typ":*
= Architecture
== JV Template Generation Script

=== Purpose and Problem Context

- Automate schema generation for heterogeneous CSV data sources
- Unify local and remote CSV ingestion workflows
- Enable visual pipeline representation (.jv format) from CSV structure
- Address lack of metadata structure in arbitrary CSV datasets
- Facilitate JSON-to-JV transformation for domain-specific pipeline engines

=== Architectural Style

- Component-based modular design
- File-driven pipeline orchestration
- Implicit dataflow-style execution (simulates ETL)
- Monolithic script with service emulation via functions
- GUI + batch CLI hybrid interaction (via tkinter + os.environ)

=== Core Components

- GUI: Provides a simple UI for input selection and log display
- Input Management:
    Loads one or more CSV files (local or from URLs)
- Schema Inference Engine: Analyzes CSV data to infer column data types
- Pipeline Generator: Transforms inferred schema into a structured pipeline schema (JSON)
- JSON & JV Writer: Converts pipeline into exportable JSON and JV files
- Naming/Path Utils: Ensures all names and paths are valid for use in code & filenames

=== Execution Environment

- Platform: Cross-platform but tested best on local environments (Windows/Mac/Linux)
- Runtime: Python 3.x, with pandas, tkinter, logging, json, urllib, pathlib
- I/O: GUI-based file selection, file I/O, internet access for downloading URLs
- Users: Likely data engineers or technical users needing to transform CSVs into domain-specific pipeline configurations


=== Interaction Diagrams

- System-Level Data Flow Diagram (DFD):
    CSV input → Inference → Pipeline blocks → JSON → JV
- Service Interaction Flow (Sequence Diagram):
    User input → File parsing → Block generation → Pipe connection → Output writing
- Component Diagram:
    Logical grouping: Parsing | Transformation | Output | GUI

=== Quality Attributes

- Modifiability: Function-level isolation; extensible block system
- Scalability: Handles batch processing via link file ingestion
- Fault Tolerance: Logging mechanism for error tracking
- Testability: Deterministic, file-based inputs and outputs
- Performance: Efficient pandas-based type inference
- Security: Input sanitization for filenames and URLs

=== Constraints & Trade-offs

- Platform: Desktop-only (Tkinter), no web or headless support
- Latency: Limited optimization; not suitable for real-time processing
- Security: No sandboxing or validation for remote URLs
- Flexibility vs. Simplicity: Static block definitions hardcoded
- No plugin system: Cannot dynamically extend pipeline block types

== Header Row Inference Script (LLM-based)

=== Purpose and Problem Context

- Automatically identify header row in noisy or metadata-heavy CSV files
- Leverage LLMs to perform pattern recognition and contextual reasoning on CSV preambles
- Generate structured JSON responses for downstream pipeline alignment
- Address ambiguity in human-generated CSVs with irregular preambles
- Replace brittle heuristics with a few-shot learning approach via prompt engineering
=== Architectural Style

- LLM-backed inference-as-a-service
- Stateless function-driven processing pipeline
- Prompt engineering for structured output generation
- Few-shot learning to enhance LLM prediction quality
- Local-first OpenAI-compatible API gateway integration
=== Core Components

- CSV Loader: Loads raw text content of CSVs for analysis
- Prompt Builder: Constructs few-shot prompt by concatenating examples and input
- OpenAI Client Interface: Interfaces with locally hosted OpenAI-compatible model server
- Response Validator: Extracts JSON and validates against a pydantic schema
- Error Handling Module: Catches and logs validation or communication errors
=== Execution Environment

- Platform: Any OS with Python 3.x and internet/local model access
- Runtime: Python 3.10+ recommended
- Libraries: openai, pydantic, re, langchain_core, urllib, pathlib, threading
- Users: Developers or data engineers validating CSV structure before ingestion
=== Interaction Diagrams

- System-Level Data Flow Diagram:
CSV file → Read & Preview → Prompt Construction → LLM Inference → JSON Validation → Output
Service Interaction Flow (Sequence Diagram):
User selects file → File read → Prompt built → API call → LLM returns JSON → Schema validation
Component Diagram:
Core: Loader | Prompting | LLM Interface | Output Parser
=== Quality Attributes

Accuracy: Boosted via few-shot examples
Explainability: LLM explains rationale per output
Fault Tolerance: Graceful fallback and raw logging
Modifiability: Easily extendable examples or model parameters
Interoperability: JSON response integrates with downstream pipelines
=== Constraints & Trade-offs

Model Dependency: Requires powerful language model (e.g., GPT-4) to perform well
Latency: Dependent on LLM processing time and local server speed
Scalability: Designed for single-file analysis, not massive batch jobs
Security: Raw file content passed to external/local model endpoint
Transparency: Determinism not guaranteed; different completions possible per run
