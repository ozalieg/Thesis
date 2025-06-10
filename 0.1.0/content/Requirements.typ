= Requirements
== JV Template Generation
=== Functional Requirements

FR-T1: Generate a pipeline model template from CSV input.  \
FR-T4: As an abstraction layer, first generate an intermediate .json, then convert it to .jv. \
FR-T5: Ensure the generated model template is a valid .jv file. \
FR-T7: Both local CSV-Files and remote URLs should be handled correctly. \
FR-T8: Regular anomalies like leading white spaces/unnamed columns should be ignored. \

=== Non-Functional Requirements

NFR-T2: Test template generation with up to 10,000 CSV files. \

=== Constraints & Assumptions

C-T1: Template structure must align with JV user documentation. \


== LLM Schema Inference
=== Functional Requirements

FR-L1: A locally hosted LLM should detect the row containing column names in malformed or anomalous CSVs.  \
FR-L2: Output from the LLM should be in .json format. \
FR-L3: Apply prompt engineering techniques to generate optimized output. \
FR-L4: Evaluate various model and parameter combinations to determine best fit for the task. \

=== Non-Functional Requirements

NFR-L1: Evaluate correct schema inference across up to 10,000 CSV files. \

=== Constraints & Assumptions

C-L1: The LLM must be hosted locally (no external API or cloud dependency). \
C-L2: Output format is strictly JSON. \

