#import "@preview/abbr:0.2.3"

Jayvee is a #abbr.add("DSL", "domain-specific language") #abbr.a[DSL] for defining and running data pipelines.
This thesis explores the generation of Jayvee templates from CSV files and the evaluation of locally hosted #abbr.add("LLM", "Large Language Model") #abbr.pla[LLM] for schema detection.

The template generation is aimed at users with little programming experience, allowing them to create data pipelines without extensive coding knowledge.
When working with CSV files, users often encounter challenges such as irregular header rows, metadata-heavy preambles, and inconsistent formatting.
Some of those irregularities can be addressed using simple #abbr.add("RegEx", "Regular Expressions" ) #abbr.a[RegEx] or heuristics, but they may not be robust enough for all cases.
Therefore, this thesis proposes a solution that leverages #abbr.pla[LLM] to identify the row containing the column names in noisy or actually any CSV file, followed by generating structured #abbr.add("JSON", "JavaScript Object Notation") #abbr.a[JSON] responses for downstream processing.
Since the template generation system uses the column names to access the data in the CSV
files, the focus of evaluating the #abbr.pla[LLM] is on the detection of the column name row.

Evaluated were LLaMA 3 (Meta, 70B), Mistral (Mixtral MoE, 8×7B active, 46.7B total), Google Gemma 3 (12B), Google Gemma 1 (7B Instruct), Alibaba Qwen 2.5 (32B), Microsoft Phi-3 (14B), and DeepSeek R1 (≈14B distilled) as most promising, state of the art models.
The evaluation was performed on a set of 1000 CSV files, which were generated from the original CSV files by adding random noise to the header rows and preambles.
The evaluation led to the conclusion, that extensive processing capabilites are needed to locally host #abbr.pla[LLM] that are capable of this task at the current state of technology.
Smaller Models (mistral:7b and Llama2 7b hf) without the necessity of a #abbr.add("GPU", "Graphics Processing Unit") #abbr.a[GPU] (running on #abbr.add("CPU", "Central Processing Unit") #abbr.a[CPU] only) performend badly on complex CSV files.
The lack of trainingsdata (to finetune a #abbr.a[LLM] at least 1k and 2k of examples are needed to achieve a performance deterioration @arxiv2024language) for the task of schema detection lead to the approach of using prompt engineering to optimize the performance of the #abbr.pla[LLM], which did improve the output quality significantly.
The template generation system without any #abbr.a[LLM] inference is able to handle well formed data and even handles some anomalies correctly by scipping non parsable lines as long as the column names are parsable and thus the data can be accessed.


