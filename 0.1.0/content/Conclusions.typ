= Conclusions

== Template Generation

I found that the Template Generation component reliably extracts and transforms CSV schemas
into .jv templates, and my regex‑based heuristics capture the essential structure of most input files.
Implementing the tool as a desktop‑only Tkinter application accelerated development and testing,
but I acknowledge this choice limits the tool to GUI environments and prevents
headless or web‑based automation. While pandas‑powered type inference handles batch processing smoothly,
I did not optimize for low‑latency or real‑time performance in this initial version.
Remote URL handling also proved a weak point: without robust sandboxing or validation,
the system remains vulnerable.
I opted for static, hardcoded block definitions to simplify early development,
though this decision sacrificed runtime extensibility by omitting a plugin mechanism for custom block types.
On the upside, the modular, function‑level code structure has made maintenance and
future enhancements straightforward. Comprehensive logging ensures I can trace and diagnose errors,
and the deterministic, file‑based I/O design has enabled reliable automated testing.

== LLM Schema Inference

Through developing the LLM Schema Inference module, I explored a novel method for header‑row detection
using local large language models.
This work revealed that the approach demands substantial computational resources and that even large,
instruction‑tuned models can hallucinate or misidentify headers in challenging cases.
Although deploying inference on HPC hardware improved throughput,
response times remain too slow for interactive or real‑time use.
By building around powerful LLM backends, I achieved strong performance in controlled experiments,
but this design limits adoption in resource‑constrained environments.
The system currently targets single‑file workflows, and scaling to massive batch jobs will require
additional orchestration and parallelization logic. From a security standpoint,
sending raw CSV content directly to the model endpoint exposes potential data‑leak and injection risks.
Finally, the inherent non‑determinism of LLM outputs has complicated reproducibility,
highlighting the need for further work on prompt stabilization or ensemble strategies
to produce consistent results.