#import "@preview/abbr:0.2.3"

= Introduction

This thesis explores the generation of Jayvee templates from CSV files by leveraging a locally hosted Large Language Model (LLM) for schema inference,
with a particular focus on robust header detection in irregular and noisy datasets.
Unlike traditional methods that rely on clean input data or extensive user input,
this approach aims to automatically infer the correct schema even when the CSV files contain metadata, comments, or inconsistent header rows.

Recent studies have demonstrated that prompt-engineered #abbr.pla[LLM]s can effectively identify column headers in noisy CSV files,
outperforming conventional heuristic-based approaches in real-world scenarios @sui2024tap4llm @liu2024autodw.
These heuristic methods typically include random sampling, evenly spaced sampling, and content snapshot sampling, which struggle with noisy or non-standard CSV formats.

For example, @sui2024tap4llm report accuracy improvements ranging from 0.8% to 4.07% when using LLMs guided by carefully crafted prompts
compared to heuristic baselines. This highlights the growing potential of LLMs in complex tabular data understanding tasks,
especially where structured metadata is missing or inconsistent.

== Jayvee Template Generation

To automate Jayvee template creation, a Python script was developed that ingests CSV files from local paths, URLs, or lists of URLs.
The script infers column data types, handles irregular or unnamed columns by renaming them with meaningful identifiers,
and generates a JSON schema describing the extraction, interpretation, and loading steps into a SQLite database.

This schema is subsequently converted into Jayvee (JV) format, a domain-specific language for pipeline definitions.
 A user-friendly #abbr.add("GUI", "Graphical User Interface") #abbr.a[GUI] implemented with Tkinter facilitates file or URL selection
 and batch processing of multiple CSV sources. Error handling and logging ensure robustness in processing diverse datasets.

Overall, this tool simplifies data pipeline creation for tabular data engineering projects by automating schema inference and template generation.

== LLM Schema Inference


A core challenge addressed in this work is the detection of header rows in anomalous CSV files where the initial rows may contain arbitrary metadata or comments,
breaking assumptions of standard parsers.
To tackle this, schema inference is performed using a locally hosted #abbr.a[LLM] that analyzes the file content and predicts the correct header structure.
The evaluation compares several state-of-the-art LLMs, including granite-3.2-8b-instruct,
an 8-billion parameter instruction-tuned transformer model known for its strong performance on text understanding and generation tasks.
This model is optimized for instruction-following scenarios, making it well-suited for schema inference where precise interpretation of tabular context is needed @granite2025v3.2.

Another model evaluated is DeepSeek-R1, a retrieval-augmented language model designed to enhance information retrieval tasks
by combining generative abilities with retrieval-based context injection.
It supports schema inference by leveraging external data to improve accuracy on ambiguous inputs @deepseekai2025deepseekr1incentivizingreasoningcapability.

Finally, the very large Qwen3-235B-A22B model, with 235 billion parameters and advanced context comprehension and multi-modal capabilities, was tested.
Its scale allows robust interpretation of complex and noisy tabular inputs, supporting accurate header detection in challenging CSV files @qwen3technicalreport.
These models were evaluated on a curated dataset of 1000 CSV files artificially augmented by adding random noise to header rows and preamble sections,
simulating real-world messy data scenarios.

The following table summarizes the main characteristics and performance metrics of these models.

#figure(
  table(
    columns: 5,
    [Model], [Parameters], [Architecture], [Key Capabilities], [Evaluation Notes],
    [granite-3.2-8b-instruct], [8 billion], [Instruction-tuned transformer], [Strong instruction-following, excels in tabular context understanding], [Optimized for schema inference, achieves robust header detection @granite2025v3.2],
    [DeepSeek-R1], [~varies; medium scale], [Retrieval-augmented transformer], [Integrates retrieval context for improved reasoning, enhanced ambiguity resolution], [Improves accuracy on noisy headers by leveraging external data @deepseekai2025deepseekr1incentivizingreasoningcapability],
    [Qwen3-235B-A22B], [235 billion], [Large-scale multimodal transformer], [Advanced context comprehension, multi-modal input handling, very large capacity], [Excels on complex and noisy data, highest accuracy in header detection @qwen3technicalreport],
  ),
  caption: [Comparison of Evaluated Language Models for Schema Inference in Noisy CSV Files],
)

This comprehensive evaluation of state-of-the-art language models lays the groundwork for the subsequent exploration of related research,
detailed requirements, and the architectural and implementation strategies that underpin the development of an effective schema inference system for noisy CSV data.