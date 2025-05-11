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


    Platform: Cross-platform but tested best on local environments (Windows/Mac/Linux)
    Runtime: Python 3.x, with pandas, tkinter, logging, json, urllib, pathlib
    I/O: GUI-based file selection, file I/O, internet access for downloading URLs
    Users: Likely data engineers or technical users needing to transform CSVs into domain-specific pipeline configurations


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