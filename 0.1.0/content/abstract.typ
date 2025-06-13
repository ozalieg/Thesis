#import "@preview/abbr:0.2.3"

Jayvee is a #abbr.add("DSL", "domain-specific language") #abbr.a[DSL] designed for defining and executing data pipelines.
This thesis consists of two standalone yet thematically related parts: (1) the evaluation of schema inference using locally hosted #abbr.add("LLM", "Large Language Model") #abbr.pla[LLM]s,
and (2) the development of a template generation system for Jayvee based on structured data inputs such as CSV (Comma-Separated Values) files.

The first part evaluates the capability of LLMs to detect the correct header row in noisy or non-standard CSV files—a common challenge in practical data processing.
A corpus of 10,000 synthetically perturbed CSV files, each paired with a ground truth JSON annotation, serves as the benchmark dataset.
The models evaluated include DeepSeek-R1, Qwen3-235B-A22B, and Granite-3.2-8B-Instruct, all executed in a local environment.
 Results highlight that reliable schema detection under real-world conditions demands GPU-level hardware, as CPU-only deployments yield poor accuracy.
 Given the absence of large-scale task-specific training data, the approach focuses on prompt engineering to optimize zero-shot performance, leading to notable improvements.

The second part introduces a template generation system aimed at non-programmers who need to create data pipelines from structured input files.
 This system operates independently of LLMs and is capable of handling well-formed and mildly noisy CSVs by skipping unparseable lines while extracting usable column headers.
 It produces ready-to-use Jayvee templates, streamlining the process of pipeline creation for users with minimal coding experience.

Although the two parts of this thesis are functionally and architecturally independent, they are conceptually aligned.
In future work, the schema inference component could be integrated into the template generation pipeline to extend its robustness to messier datasets.
For now, however, each component is developed and evaluated in isolation to allow for focused analysis and modular reuse.