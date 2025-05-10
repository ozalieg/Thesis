= Architecture


== JV Template Generation Script

=== High-Level Structure

- Modular design: functionality split into purpose-specific functions, encouraging code reuse and testability
- Entry point: a `main()` function launches a Tkinter GUI as the user-facing interface for initiating processing
- Input agnostic: accepts local CSV files, URLs, or text files with URL lists

=== Core Functional Components

==== User Interface (Tkinter GUI)

- Simple front-end with three triggers:
    - Select CSV file
    - Enter CSV URL
    - Choose a text file of links

==== Data Source Abstraction

- Supports both local paths and URLs
- Dynamically assigns extractor class:
    - `LocalFileExtractor`
    - `HttpExtractor`

==== Pipeline Schema Generator

- Constructs a schema made of functional blocks, including:
     - `Extractor`
     - `TextFileInterpreter`
     - `CSVInterpreter`
     - Optional: `CellWriter` for unnamed columns
     - `TableInterpreter` with type annotations
     - `SQLiteLoader`
- Connections between blocks are directional pipes
- Output is a structured JSON object

==== Output Modules

- JSON Export: `save_to_json()` writes the pipeline schema to `./JsonFiles/`
- JV Conversion: `convert_json_to_jv()` turns JSON into `.jv` format

==== Workflow Coordination

- Central Orchestration:
    - `process_file_or_url()` integrates all steps:
        - Reads source (local or URL)
        - Infers types
        - Generates schema
        - Saves JSON and `.jv` if configured

- Batch Processing:
 `process_links_file()` loads URLs from a file and calls `process_file_or_url()` for each
- Utility Tools:
    - `extract_file_name()`, `to_camel_case()`, `sanitize_name()` for normalization and safety
    - `column_index_to_label()` maps index → Excel-style label


==== Error Handling & Resilience

- Defensive coding ensures graceful failure on:
    - Missing files
    - URL errors
    - Unparseable CSVs
    - Malformed JSON
- Logging via Python `logging` module (errors saved to `error_log.txt`)




