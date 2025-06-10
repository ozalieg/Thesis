#import "../utils/todo.typ":*
= Design and Implementation
== JV Template Generation Script
=== High-Level Design (HLD)

modular ETL (Extract-Transform-Load) pipeline generator and converter from CSV/URL inputs to .json and .jv representations.

=== Components Responsibilities

- GUI Component:
    - Accept user inputs via file dialog
    - Trigger processing sequence
    - Display progress logs
    - Lock interface during execution
- Input Management Component:
    - Load CSV files from local or remote sources
    - Route to appropriate loader
    - Normalize data for downstream processing
- Schema Inference Component:
    - Analyze CSV structure
    - Infer data types for each column
    - Handle unnamed columns
- Pipeline Generation Component:
    - Map inferred schema to pipeline blocks
    - Assign IDs and structure logical flow
    - Generate metadata and config for downstream use
- JSON & JV Writer Component:
    - Serialize pipeline schema to JSON
    - Convert JSON to custom JV format
    - Ensure file naming and path validity
- Naming/Path Utilities Component:
    - Clean and format strings for use in code
    - Generate valid identifiers
    - Ensure OS-safe filenames and paths

=== Data Flow

- Event-driven invocation (via GUI)
- Linear stage transitions: Input → Schema → Pipeline → Output
- Intermediate representation: memory-held schema & pipeline
- File-based persistence


=== I/O Formats & Schemas

- Input: CSV from file or HTTP
- Intermediate format:
    - Normalized schema: `[ { name, type }, … ]`
    - Pipeline JSON: blocks, pipes, metadata
- Output:
    - `.json`: serialized config
    - `.jv`: custom line-based schema

=== Technology Stack

(as architectural decision, not implementation detail)

- Chosen stack:
    - Language: Python 3.x
    - GUI: Tkinter (desktop-focused)
    - Data: Pandas for inference abstraction
- Rationale:
    - Broad OS support
    - Familiar libraries for rapid development
    - Script-oriented architecture for flexibility
- Alternatives considered:
    - Java: Too heavyweight for a simple script
    - C++: Overkill for the task, complex GUI handling
    - Node.js: Not suitable for desktop GUI applications
- Future considerations:
    - Potential for web-based GUI if needed
    - Modularization for microservices architecture

=== Error Handling

(Design-Level View)

- Validation at input boundary (file/URL)
- Fallback types for ambiguous columns
- Logging architecture for tracking issues
- GUI interlocks for bad states
- Separation of concerns prevents error cascade


== Implementation Details

=== Component Implementations

- GUI (`tkinter`)
    - `Tk()` window with `askopenfilename` and `ScrolledText` widget
    - Callback binds: `Run` button triggers main logic
    - UI lock/unlock using `state=DISABLED/ENABLED`
    - Uses `threading.Thread` to prevent UI freezing
- Input Handling
    - Local file: `open(file, 'r')` with encoding fallback
    - Remote file: `urllib.request.urlopen()` with `BytesIO` fallback
    - Batch mode: detects `.link` file, iterates over entries
- Schema Inference
    - `pandas.read_csv()` with `nrows=1000`
    - Column dtype mapping logic:
        - `object` → Text
        - `float64` → Number
        - Simple type reduction via `df[col].apply(type).nunique()`
        - Empty/ambiguous columns dropped

- Pipeline Generator
    - Constructs dictionary with:
        - `blocks[]` from column names/types
        - `pipes[]` connecting input → block → output
        - `meta{}` for title, timestamp, etc.
    - Static block templates (e.g. `{'type': 'NumberBlock', 'params': {...}}`)

- Output Writer
    - `json.dump()` for `.json`
    - `.jv` format: line-by-line write with tabular key-value representation
    - `safe_name()` used for filenames
    - Output folder auto-created with `os.makedirs()` if needed

- Naming & Path Utilities
    - `safe_name(name)` sanitizes with `re.sub()` for unsafe chars
    - Uses `Path(...).resolve()` for consistent path handling
    - Converts spaces, special characters in column names

=== Control & Data Flow

- Single-threaded logic outside GUI callbacks
- Sequential:
  1. Load CSV
  2. Infer schema
  3. Build pipeline
  4. Write outputs
- Logging via `logging.info()` and `ScrolledText` redirect

=== Interfaces in Code
- Functions:
    - `load_csv(path_or_url)`
    - `infer_schema(df)`
    - `generate_pipeline(schema)`
    - `write_json(config)`
    - `write_jv(config)`
- Data contracts: Python dicts passed between steps
- Temporary in-memory formats only, no DB/cache

=== Technology Stack (Code Usage)

- `tkinter` for GUI
- `pandas` for CSV parsing & type inference
- `urllib`, `io.BytesIO` for remote input
- `logging`, `threading`, `pathlib`, `json`, `re`, `os`

=== Error Handling

- `try/except` around all I/O points
- Logs error with traceback to GUI log pane
- Missing files: show GUI popup or log warning
- Type inference fallback to "Text" if uncertain
- GUI shows status: success, failure, or warnings


=== Misc Implementation Notes
- No unit tests, but deterministic logic for testability
- Static templates mean no dynamic codegen or plugin loading
- Script architecture (vs package) for ease of use
- CLI batch mode inferred from `.link` file extension

== LLM Schema Inference
=== High-Level Design (HLD)

A CSV schema-header row inference tool powered by a local OpenAI-compatible LLM and structured prompt engineering. Outputs are validated using pydantic models.

=== Components Responsibilities

- CSV Loader:
    - Opens local CSVs and reads the first 20 lines
    - Supports files with various encodings
- Prompt Builder:
    - Uses examples to construct a few-shot prompt
    - Formats request strictly per schema requirements
- LLM Client (OpenAI):
    - Connects to a local OpenAI-compatible API endpoint
    - Sends prompts with system/user message roles
    - enforces JSON output
- Output Parser (LangChain + Pydantic):
    - Uses a JsonOutputParser with the Header model
    - Extracts JSON from potentially noisy responses
    - Validates field types (columnNameRow, Explanation)
- Error Handler:
    - Wraps API and parsing in try/except block
    - Logs or prints informative error and fallback data
=== Data Flow

Input → Preview Extraction → Prompt Generation → LLM Inference → JSON Extraction → Validation → Result Output
=== I/O Formats & Schemas

- Input:
        Raw CSV lines (first 20)
- Prompt: Few-shot prompt string with embedded examples
- Output Schema:
        {
            "type": "object",
            "properties": {
                "columnNameRow": {"type": "integer"},
                "Explanation":   {"type": "string"}
            },
            "required": ["columnNameRow", "Explanation"]
        }

=== Technology Stack

- Language: Python 3.10+
- LLM Backend: Locally hosted GPT-compatible endpoint (OpenAI API interface)
- Prompt/Output:
    - LangChain’s JsonOutputParser
    - Pydantic for schema enforcement
- Tools Used:
    - openai (via openai.Client)
    - re, json, pydantic, langchain_core.output_parsers
- Rationale:
    - Local model for privacy and speed
    - Pydantic for strong validation
    - LangChain to simplify structured extraction
=== Error Handling

- All I/O and API calls are wrapped in exception handling
- Fallbacks:
    - Missing JSON → raises ValueError
    - Validation error → raises ValidationError with traceback
    - Raw LLM output preserved for debugging
    - Uses GUI log or console print for errors and responses
== Implementation Details

=== Component Implementations

- CSV Loader
    - load_csv_as_text(path) opens and reads lines using 'utf-8-sig' encoding
- Prompt Builder
    - build_prompt(csv_20_lines) formats structured prompt with 3 few-shot examples
    - Encodes example content, reference answers, and schema rules
- LLM Inference
    - client.chat.completions.create() with:
    - Model: "deepseek" /others to be evaluated
    - Role: "system" and "user"
    - Format: {"type": "json_object"}
    - Temperature: 0 (deterministic)
    - Timeout: 60s
- JSON Parser
    - extract_json(text) uses regex to pull JSON block from LLM output
    - parser.parse(json_str) validates against schema
- Schema Validation
    - Uses Header pydantic class
    - Enforces int/string types and key presence
- Error Catching
    - Print tracebacks and raw output
    - Graceful degradation for debugging
=== Interfaces in Code

- Functions:
    - load_csv_as_text(path)
    - build_prompt(csv_str)
    - extract_json(response_text)
- Model Usage:
    - Header pydantic class
    - LangChain JsonOutputParser(pydantic_object=Header)
- Data Contracts:
    - Input: string of 20 lines
    - Output: validated JSON object
=== Control & Data Flow

Single-run flow with no persistent state
Sequence:
    - Load file
    - Build prompt
    - Call API
    - Extract JSON
    - Validate and print