#v(20mm)

= Bill Of Materials
== Jayvee Template Generation

The template generation pipeline and associated testing scripts require the following software environment and dependencies:

- Python version: 3.8 or higher (tested with Python 3.10)
- Python packages:
    - pandas==2.0.3
    - jsonformer==0.12.0
    - jsonpatch==1.33
    - python-dateutil==2.8.2
    - typing-extensions==4.6.0
The tkinter library is used for GUI-based folder selection dialogs and is included as part of the standard Python distribution (version 3.8+).

Additionally, the pipeline requires the jv command-line tool, which must be installed and accessible in the system’s PATH for executing .jv files and generating SQLite databases.

=== Notes

- The Python packages listed were installed with exact version pins to ensure reproducibility and compatibility during development and testing.
- The environment was tested on [your OS, e.g., Windows 10 / Ubuntu 22.04].
- The python_requires field in the setup configuration enforces minimum Python version requirements.