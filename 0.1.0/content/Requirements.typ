= Requirements
== JV Template Generation Script
=== Functional Requirements

FR-T1: Generate a pipeline model template from a CSV input.
FR-T2: Read column names from the CSV to access the data correctly.
FR-T3: Use cars.jv as a base, including predefined basic blocks.
FR-T4: For debugging, first generate an intermediate .json, then convert it to .jv.
FR-T5: Ensure the generated model template is a valid .jv file.

=== Non-Functional Requirements

NFR-T1: The process should not save any intermediate or temporary files to local disk.
NFR-T2: Test template generation with up to 10,000 CSV files.

=== Constraints & Assumptions

C-T1: Template structure must align with JV user documentation.


== LLM based Header Detection
=== Functional Requirements

FR-L1: A locally hosted LLM should detect the row containing column names in malformed or anomalous CSVs.
FR-L2: Output from the LLM should be in .json format.
FR-L3: Apply prompt engineering techniques to generate optimized output.
FR-L4: Evaluate various models and parameter combinations to determine best fit for the task.

=== Non-Functional Requirements

NFR-L1: The LLM component should support evaluation across up to 10,000 CSV files.
NFR-L2: Prefer prompt engineering over fine-tuning for performance and efficiency.
=== Constraints & Assumptions

C-L1: The LLM must be hosted locally (no external API or cloud dependency).
C-L2: Output format is strictly JSON (no .jv conversion at this stage).




=== Old
Template
- with a csv as input generate a template for a pipeline model working with the data in the provided csv
- read the column names to access the data correctly
- basis for this template is cars.jv, including basic blocks
- for debugging purposes, first generate json then transform to jv
- in the end no tmp files should be needed/no intermediate files should be saved to local disk
- the generated model template should be a valid jv file
- test the generation with up to 10 000 csv files

LLM Part
- a llm locally hosted should detect the row with the column names in anomal csvs
- the output of the llm should be json
- use prompt engineering as a more efficient way than finetuning for generating optimal output
- evaluate which models with which parameters are best suited for the task
- test this with up to 10 000 csv files

