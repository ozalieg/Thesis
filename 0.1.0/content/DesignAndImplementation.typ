#import "../utils/todo.typ":*
= Design and Implementation

== JV Template Generation Script

=== Design Overview

The JV Template Generation Script implements a modular ETL (Extract-Transform-Load) pipeline generator that accepts CSV data from either local files or remote URLs, infers the structure and types of the data, and produces a machine-readable pipeline configuration in both JSON and a custom JV format.  This design ensures that each stage of the workflow—input handling, schema inference, pipeline generation, and output writing—is encapsulated as an independent component, enabling clarity of logic, ease of testing, and future extensibility.

==== Components Responsibilities

The system is organized into six collaborating components, each with a well-defined responsibility:

- The GUI Component interacts with the user, providing file dialogs and URL prompts, locking the interface during execution, and displaying progress logs. It acts as the presentation layer that initiates the processing sequence.
- The Input Management Component handles the acquisition of CSV data, deciding between local file loading or HTTP requests, normalizing the incoming data, and routing each source to the core processing function.
- The Schema Inference Component reads the CSV content using Pandas, examines column headers and sample values, infers data types for each column (including fallback logic for unnamed columns), and returns a normalized schema of name–type pairs.
- The Pipeline Generation Component receives the inferred schema and constructs the pipeline JSON: it defines extractor, interpreter, and loader blocks along with their interconnecting pipes, embeds metadata such as pipeline and table names, and leverages naming utilities to ensure valid identifiers.
- The JSON & JV Writer Component serializes the pipeline structure to a JSON file when requested, and always transforms the JSON into the custom .jv format, handling file creation, naming conventions, and output directory management.
- The Naming/Path Utilities Component provides string sanitation and formatting: converting file names to CamelCase, generating spreadsheet-style column labels, and ensuring all file and identifier names are compatible across operating systems.

==== I/O Formats & Schemas

Inputs consist of raw CSV data either from local disk or retrieved over HTTP.
The intermediate representation is a normalized schema:
a list of objects each containing a column name and its inferred type.
The primary pipeline format is a JSON document with `blocks`, `pipes`, and supporting metadata.
Finally, the custom JV output is a human‑readable, line‑based schema definition.

==== Technology Stack

This script is written in Python 3.x for broad compatibility.
The GUI is built with Tkinter to remain lightweight and desktop‑focused.
Pandas provides robust CSV parsing and data‑type inference.
Standard libraries such as `urllib`, `pathlib`, `logging`, `json`, and `threading`
round out the implementation.
Alternatives like a Java or C++ GUI were deemed too heavyweight for a simple ETL tool,
while Node.js lacked a native desktop UI.
Future directions may include a web‑based frontend or extraction of core logic into microservices.

==== Error Handling

At the design level, all input boundaries perform validation:
missing files or invalid URLs trigger GUI alerts and logging.
The inference component defaults ambiguous or unnamed columns to a safe “text” type.
Error conditions at any stage are logged both to a file and to the GUI progress pane,
and execution locks ensure that failures do not leave the interface in an inconsistent state.

=== Implementation Details

==== Component Implementations

Each component is implemented as a set of Python functions that communicate via in‑memory data structures.
The GUI uses Tkinter's `askopenfilename` and modal dialogs to gather user input,
disabling buttons during processing and updating a log widget.
Input handling decides between `open()` for local files or `urllib.request.urlopen()` for HTTP sources,
with a batch‑mode workflow iterating through a links file.

The schema inference component calls `pd.read_csv()` on the first rows of data,
then iterates columns to detect “Unnamed” headers, renaming and appending fallback types.
The helper `map_inferred_type()` maps raw Pandas dtypes to text, integer, decimal, or boolean.

The pipeline generator builds a dictionary of blocks—extractor, various interpreters,
optional header writer, and loader—with properties and column definitions.
It uses `extract_file_name()`, `to_camel_case()`, and `column_index_to_label()`
from the Naming/Path Utilities to produce valid identifiers.

The sequence of calls for generating a JV file is illustrated in the following sequence diagram,
which documents the end‑to‑end flow from the GUI trigger through JSON and JV writing:

#figure(
image("./TempGen_Seq.png", width: 50%),
caption: [Sequence Diagram for JV Template Generation Script Execution Steps],
) <sequence_diagram_tempgen>

==== Interfaces in Code

Primary functions define clear contracts: `load_csv(path_or_url)` returns a DataFrame,
`infer_schema(df)` returns a list of {name, type} pairs, `generate_pipeline(schema)`
returns a JSON‑serializable dict, and `write_json(config)` and `write_jv(config)`
perform side‑effecting file writes. Data is passed purely in dictionaries and lists,
with no persistent caches.

==== Technology Stack (Code Usage)

Under the hood, core libraries are:

- Tkinter for dialogs and event loops
-  Pandas for CSV parsing and type inference
-  urllib, io.BytesIO for remote data streams
- logging, threading, pathlib, json, re, os for infrastructure

==== Error Handling (Implementation)

All I/O points are wrapped in `try/except` blocks: failures log full tracebacks to the configured log file and append user-friendly messages to the GUI. Missing or malformed inputs prompt dialogs or status warnings. The inference code defaults unknown types to “text”.

==== Misc Implementation Notes

No formal unit tests are provided, but the deterministic logic and static templates make
the script readily testable.
The architecture favors a single‑script distribution,
with simple CLI detection of batch mode based on file extension.

== LLM Schema Inference
=== Design Overview

A CSV schema-header row inference tool powered by a local OpenAI-compatible LLM and structured prompt engineering. Outputs are validated using pydantic models.

==== Components Responsibilities

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
==== Data Flow

Input → Preview Extraction → Prompt Generation → LLM Inference → JSON Extraction → Validation → Result Output
==== I/O Formats & Schemas

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

==== Technology Stack

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
==== Error Handling

- All I/O and API calls are wrapped in exception handling
- Fallbacks:
    - Missing JSON → raises ValueError
    - Validation error → raises ValidationError with traceback
    - Raw LLM output preserved for debugging
    - Uses GUI log or console print for errors and responses
=== Implementation Details

==== Component Implementations

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
==== Interfaces in Code

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


#figure(
image("./LLMInf_SequenceDiagram.png", width: 50%),
caption: [Sequence Diagram LLM Schema Inference Implementation Steps],
) <LLMInfSequenceDiagram>
