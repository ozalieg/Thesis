#import "@preview/abbr:0.2.3"

Jayvee is a #abbr.add("DSL", "domain-specific language") #abbr.a[DSL] designed for defining and executing
data pipelines.
This thesis consists of two standalone yet thematically related parts: (1) the development
 of a template generation system for Jayvee based on structured data inputs, more specifically,
 CSV files and (2) the evaluation of schema inference using locally hosted #abbr.add("LLM", "Large Language Model") #abbr.pla[LLM].

The first part introduces a template generation system aimed at non-programmers who need to create data pipelines from structured input files.
This system operates independently of LLMs and is capable of handling well-formed and mildly noisy CSVs by skipping unparseable lines while extracting usable column headers.
It produces ready-to-use Jayvee templates, streamlining the process of pipeline creation for users with minimal coding experience.
A large-scale evaluation of the template generator was conducted on 10,000 synthetic CSV files in an #abbr.add("HPC","High Performance Computing") #abbr.a[HPC] environment using a custom SLURM-based test harness. Metrics include template validity, runtime, and SQLite output completeness.

The second part evaluates the capability of LLMs to detect the correct header row in noisy or non-standard CSV files—a common challenge in practical data processing.
A corpus of 10,000 synthetically perturbed CSV files, each paired with a ground truth JSON annotation, serves as the benchmark dataset.
The models evaluated include DeepSeek-Coder, Qwen3-4B, and CodeLlama-7B-Instruct, all hosted local with Huggingface Transformers.
Results highlight that reliable schema detection under real-world conditions demands GPU-level hardware, as CPU-only deployments yield poor accuracy.
Given the absence of large-scale task-specific training data, the approach focuses on prompt engineering to optimize zero-shot performance, resulting in improved outcomes over naive prompting.

Although the two parts of this thesis are functionally and architecturally independent, they are conceptually aligned.
In future work, the schema inference component could be integrated into the template generation pipeline to extend its robustness to messier datasets.
For now, however, each component is developed and evaluated in isolation to allow for focused analysis and modular reuse.