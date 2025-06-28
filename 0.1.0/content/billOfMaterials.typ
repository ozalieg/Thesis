#v(20mm)

= Bill Of Materials

== Jayvee Template Generation

The Jayvee template generation pipeline, including the auxiliary schema inference module, relies on the following runtime environment and software dependencies:
- Jayvee version: 0.6.4
- node.js version: v22.16.0
- Python version: 3.8 or higher (validated with Python 3.10)
- Python packages:
  - `pandas==2.0.3`
  - `jsonpatch==1.33`
  - `python-dateutil==2.8.2`
  - `typing-extensions==4.6.0`
  - `pytz==2023.3`


== LLM-Based Schema Inference


This module requires:

- A transformer-based language model backend (e.g., HuggingFace-compatible model)
- Schema definitions in JSON Schema 2020-12 format
- Output post-processing with `jsonpatch` for iterative refinement


=== Notes

- The listed Python packages are version-pinned to guarantee reproducibility and cross-platform compatibility.
- The development and testing environment was verified on MacOS and Linux.
