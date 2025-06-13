#v(20mm)

= Bill Of Materials
#v(20mm)

== Jayvee Template Generation

The Jayvee template generation pipeline, including the auxiliary schema inference module, relies on the following runtime environment and software dependencies:

- Python version: 3.8 or higher (validated with Python 3.10)
- Python packages:
  - `pandas==2.0.3`
  - `jsonformer==0.12.0`
  - `jsonpatch==1.33`
  - `python-dateutil==2.8.2`
  - `typing-extensions==4.6.0`

The `tkinter` library is utilized for GUI-based folder selection dialogs and is part of the standard Python distribution (v3.8+). In addition, the pipeline depends on the `jv` command-line tool, which must be installed and available in the system’s `PATH` for interpreting `.jv` files and generating intermediate SQLite databases.

== LLM-Based Schema Inference

A key enhancement to the pipeline involves automatic inference of JSON schema structures using a language model. This step leverages the `jsonformer` package to produce structured outputs conforming to a predefined schema.

This module requires:

- A transformer-based language model backend (e.g., HuggingFace-compatible model)
- Schema definitions in JSON Schema 2020-12 format
- Output post-processing with `jsonpatch` for iterative refinement

This component can be run independently or integrated into the larger generation pipeline. Its output is cached and reused to improve development efficiency and ensure stability of generated structures.

=== Notes

- The listed Python packages are version-pinned to guarantee reproducibility and cross-platform compatibility.
- The development and testing environment was verified on _[insert OS here, e.g., Windows 10 / Ubuntu 22.04]_.
- The `python_requires` field in the `setup.cfg`/`setup.py` enforces minimum interpreter version requirements.
