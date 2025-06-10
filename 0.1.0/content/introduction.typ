#import "@preview/abbr:0.2.3"

= Introduction

In this thesis, the generation of Jayvee templates from CSV files with a locally hosted LLM for shema inference is explored.
Focus is the header detection in irregular datasets without relying on extensive user input or pre-cleaned files.
Studies indicate that prompt-engineered #abbr.pla[LLM] can effectively detect column headers in noisy CSV files,
surpassing traditional heuristic methods in real-world applications @sui2024tap4llm @liu2024autodw.
A study on prompt engineering for LLMs demonstrates improved performance over traditional heuristic methods
in processing complex tabular data, achieving accuracy gains of 0.8% to 4.07%.
The traditional approaches evaluated include random sampling, evenly spaced sampling,
and content snapshot sampling—all heuristic-based techniques.
@sui2024tap4llm
== Jayvee Template Generation

For the Jayvee Template Generation, a Python script is developed to automate the process of generating templates
from CSV files.
It infers the column types, renames columns if needed and generates a JSON schema that defines the extraction,
interpretation, and loading of data into a SQLite database.
The program supports handling local files, URLs, or lists of URLs from a text file.
The schema is then converted to Jayvee.
The program also includes a #abbr.add("GUI", "Graphical User Interface") #abbr.a[GUI] built with Tkinter to let users select files or enter URLs easily.
Errors during reading or processing are logged, and the tool supports batch processing of many CSV links.
Overall, this tool streamlines the pipeline creation and data ingestion steps needed for tabular data engineering projects.

== LLM Schema Inference

The schema inference covers the detection of the header row in anomalous CSV files.
This referrs to the case where the first few rows of the provided file contain random metadata or comments.
Since there's no standard way to identify the header row in such cases, the inference is done using a locally hosted #abbr.a[LLM].
Different Models were evaluated, including DeepSeek-R1 granite-3.2-8b-instruct and Qwen3-235B-A22B.
The evaluation was performed on a set of 1000 CSV files, which were generated from the original CSV files by adding random noise to the header rows and preambles.

The table below summarizes the selected models used in the evaluation, followed by a detailed description of each.

#figure(
  table(
    columns: 3,
    [Model Family], [Selected Model], [Reason],
    [LLaMA (Meta)], [LLaMA 3 - 70B], [Top-class on general benchmarks (math, logic); noisy input resilience via long context; very large (slow) inference],
    [Mistral], [Mixtral (MoE 12.9B active)], [Outperforms Llama2-70B with 6× faster inference; supports many languages; cost-efficient sparse MoE (12.9B active)],
    [Gemma (Google)], [Gemma 3 - 12B],[Beats much larger models on human-eval; function-calling for JSON/schema; quantized versions for speed],
    [Qwen 2.5 (Alibaba)],[Qwen 2.5 - 32B],[State-of-the-art on structured-output tasks; “understands tables”; huge context (up to 1M) enables full-file inputs],
    [Phi-3 (Microsoft)],[Phi-3 - 14B],[Outperforms much larger GPT-3.5 on reasoning; very efficient (ONNX/DirectML optimized); ideal for on-device/low-latency use],
    [DeepSeek],[DeepSeek R1 - 13B distill],[RL-trained reasoning model; matches GPT-3.5 on complex reasoning; focused on novel inference skills (e.g. pattern discovery) but less tested on standard tasks],
  ),
  caption: [Selected Models for Evaluation],
)

Meta’s LLaMA 3 (70B) is an open large language model with strong reasoning abilities and support for long inputs,
up to 128K tokens.
It uses grouped query attention and a new positional encoding scheme for improved efficiencywith long sequences.
Although not specifically benchmarked on CSV/header extraction,
it performs well on general reasoning tasks (e.g. logic, math) and handles unstructured or messy inputs robustly.
Due to its size, it requires significant compute for inference but is often ranked among the top-performing open models. @iravani2024tabletext

Mixtral (8×7B, ~12.9B active) is a Mixture-of-Experts model developed by Mistral.
Only 2 out of 8 expert subnetworks are active per token, so despite having 46.7B total parameters,
it operates with the cost of a ~12.9B model. It supports 32K-token inputs and performs well on logic and code tasks,
making it suitable for structured data like tables. It offers efficient inference and has been shown to outperform
some larger models (e.g., LLaMA 2 70B) on various benchmarks. @mistral2023mixtral

Google’s Gemma 3 (12B) supports inputs up to 128K tokens and includes built-in functionality for generating structured outputs
such as JSON.
Although it is smaller than some models, it performs competitively in human evaluation rankings
and is available in optimized formats for faster inference.
These characteristics make it useful for processing large or complex documents, including CSV files. @farabet2025gemma3 @gemma2025technical

Alibaba’s Qwen 2.5 (32B) is designed specifically with structured and tabular data in mind.
Some variants, like Qwen 2.5-14B, support extremely long inputs (up to 1 million tokens).
It includes functionality for structured output generation (e.g., JSON schemas)
and performs well in instruction following, code, and math benchmarks.
Its design makes it suitable for reading and interpreting large CSV files. @alibaba2025qwen

Microsoft’s Phi-3 (14B) supports 128K-token inputs and has been optimized for efficiency,
including compatibility with ONNX and DirectML for faster inference.
It shows strong results in logic and math tasks, often performing better than larger models.
Phi-3’s ability to handle long documents with low latency makes it a good option for large-scale structured data processing. @bilenko2024phi3

DeepSeek R1 (~14B) is trained through reinforcement learning to focus on logical and mathematical reasoning.
While it is not explicitly tested on CSV-related tasks,
its strong performance on code and logic suggests potential for handling structured data.
The models are still in early-stage development and mainly focused on research,
but they show capabilities comparable to larger proprietary systems on reasoning benchmarks. @deepseek2025r1

