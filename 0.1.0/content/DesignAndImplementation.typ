#import "../utils/todo.typ":*
= Design and Implementation

== CSV Parsing & Column Type Inference

Function: `infer_csv_column_types()`

- Uses `pandas.read_csv()` for loading and previewing data
- Checks for `"Unnamed"` columns, infers types (e.g., numeric, string) based on content
- Maps pandas dtypes to internal schema types via `map_inferred_type()`
- Rename lists `renamed_cols`, `new_names` maintain consistency
#TODO("Refactor no global variables")

== Schema Construction

Function: `generate_pipeline_schema()`

- Creates a list of blocks that define ETL logic
- Dynamically includes or skips certain blocks based on input characteristics
- Handles structural naming (e.g., column names, file names) using utilities like `sanitize_name()`
- All schema relationships defined explicitly via directional `pipes`

== JSON and JV Output

JSON Export
- `save_to_json()` serializes pipeline to a JSON structure
- Ensures file creation with `os.makedirs(..., exist_ok=True)`
- Filename formatting via `to_camel_case()` ensures readability and consistency

JV Conversion
- `convert_json_to_jv()` handles:
    - Scalar fields (e.g., `"type": "string"`)
    - Lists (e.g., `"pipes": [...]`)
    - Nested dictionaries
- Outputs JV syntax in `.jv` files, saved under `./JvFiles/`


== GUI Integration

Function: `main()`

- Initializes and launches a basic Tkinter window
- Provides three buttons:
    - Select local file
    - Enter URL
    - Load list of URLs
- Each button triggers its respective handler to invoke the core pipeline functions

== Defensive Design Principles

- Try/Except blocks guard file operations, schema generation, and format conversion
- Centralized logging ensures all errors are visible and traceable
- Default behaviors (e.g., setting unknown columns to `"text"`) prevent crashes on ambiguity
- File safety: checks for null paths, invalid types, and filename conflicts


== Design Priorities

- Extensibility: New interpreter or loader blocks can be added with minimal change
- Maintainability: Functions have single responsibilities, simplifying testing and updates
- User-Friendly: GUI abstracts complexity for non-technical users
- Robustness: Defensive code ensures smooth handling of malformed or unexpected input
