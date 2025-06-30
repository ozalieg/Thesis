#import "@preview/abbr:0.2.3"

= Introduction

As already mentioned in the abstract, this thesis explores schema inference through two complementary
approaches: a rule-based Jayvee template generation system for structured data,
and an evaluation framework for CSV schema inference using locally hosted #abbr.pla[LLM].

Jayvee is designed to define, execute, and maintain data pipelines.
It enables non-programmers to orchestrate complex data workflows using high-level constructs.
However, a significant barrier to adoption lies in the manual effort required to create initial
templates from raw data—especially when that data arrives in the form of messy or irregular CSV files.

The first part of this work introduces a system that automates Jayvee template
generation from CSV inputs. It targets well-formed or mildly noisy files,
using a deterministic parsing approach that skips malformed rows, extracts usable column headers,
and emits ready-to-edit Jayvee programs.
This system enables users with limited technical expertise to rapidly bootstrap pipelines
from data they already possess.

The second part focuses on a more challenging problem: detecting the correct header row
in CSV files with substantial noise, ambiguity, or structural irregularity.
This task, central to reliable schema inference, is particularly difficult in real-world
files that may contain metadata blocks, multiline comments, unit descriptors, or multilingual preambles.
Traditional heuristic-based approaches—such as evenly spaced sampling, content snapshot selection,
or rule-based parsing—tend to degrade significantly under these conditions (Jiang et al., 2021 @Jiang2021).
Recent work, however, has shown that LLMs prompted with structured instructions
can outperform these heuristics in identifying headers under noisy conditions.
Studies such as Sui et al. (2024) @Sui2024 and Liu et al. (2024) @Liu2024 report measurable
gains in schema identification accuracy, with LLMs outperforming conventional
 baselines by 0.8% to 4.07% when carefully engineered prompts are used.

While the Jayvee template generator and the LLM-based evaluation system were developed and analyzed independently, their conceptual connection lies in their shared goal: automating the translation of imperfect, semi-structured data into structured pipeline-ready representations. Future work may integrate the two components, embedding LLM-based schema inference directly into the Jayvee generation flow to handle messier inputs end-to-end. For now, their modular separation allows for targeted improvements, easier experimentation, and clearer insights into each component’s strengths and limitations.


== Jayvee Template Generation

To automate Jayvee template creation, a Python script was developed that ingests CSV files from local paths, URLs, or lists of URLs.
The script infers column data types, handles irregular or unnamed columns by renaming them with meaningful identifiers,
and generates a JSON schema describing the extraction, interpretation, and loading steps into a SQLite database.

This intermediate JSON format serves as a modular and reproducible representation of the inferred pipeline logic.
It decouples the data interpretation phase from the final Jayvee template generation, allowing for schema validation, unit testing, format conversion, and parallel execution.
The JSON captures all pipeline semantics in a structured, portable way—ensuring that downstream processes like .jv rendering or debugging can operate independently and repeatably without re-parsing the original data.

This schema is subsequently converted into Jayvee format.
A user-oriented #abbr.add("CLI", "Command-Line Interface") #abbr.a[CLI] enables efficient file and URL selection, as well as batch processing of multiple CSV sources. Although no graphical interface currently exists, the CLI supports intuitive interaction patterns and structured input via command arguments or links files. Robust error handling and logging mechanisms ensure stable operation across diverse datasets and facilitate troubleshooting during execution.

Overall, this tool simplifies data pipeline creation for tabular data engineering projects by automating schema inference and template generation.


== LLM-Based Schema Inference


A core challenge addressed in this work is the detection of header rows in anomalous CSV files where the initial rows may contain arbitrary metadata or comments,
breaking assumptions of standard parsers.
To tackle this, schema inference is performed using a locally hosted #abbr.a[LLM] that analyzes the file content and predicts the correct header structure.

One of the evaluated models is DeepSeek-Coder, a code-centric transformer model optimized for program synthesis and structured data tasks. Although not explicitly instruction-tuned, its strong token-level precision and generalization on semi-structured inputs make it suitable for header detection in adversarial CSVs (Guo et al., 2024 @Guo2024).

The second model, Qwen3-4B, is a compact yet capable transformer from the Qwen3 family, trained with alignment techniques that improve instruction adherence and tabular comprehension (Yang et al., 2025 @Yang2025).

Lastly, CodeLlama-7B-Instruct, an instruction-tuned variant of Meta’s CodeLlama model, was evaluated for its practical trade-off between scale, instruction fidelity, and local deployability. It is designed to follow natural language prompts and handle semi-structured data representations (Rozière et al., 2024 @Roziere2024).

The following table summarizes the technical profile and empirical performance notes for each model in the context of this schema inference task:

#figure(
table(
columns: 4,
[Model], [Parameters], [Architecture], [Key Capabilities],
[DeepSeek-Coder], [Unknown (medium scale)], [Code-focused transformer], [High token-level precision, performs well on structured data (Guo et al., 2024 @Guo2024)],
[Qwen3-4B], [4 billion], [Instruction-tuned transformer], [Lightweight yet instruction-aware, capable of handling structural noise (Yang et al., 2025 @Yang2025)],
[CodeLlama-7B-Instruct], [7 billion], [Instruction-tuned transformer], [Designed for prompt following and semi-structured data understanding (Rozière et al., 2024 @Roziere2024)],
),
caption: [Comparison of Evaluated Language Models for Schema Inference in Noisy CSV Files],
)

This comprehensive evaluation of state-of-the-art language models lays the groundwork for the subsequent exploration of related research,
detailed requirements, and the architectural and implementation strategies that underpin the development of an effective schema inference system for noisy CSV data.