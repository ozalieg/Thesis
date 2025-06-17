= Future Work

everal avenues remain open for enhancing both the template generation and LLM inference components.
On the template side, migrating the core logic into a headless CLI or lightweight web service
would enable seamless integration into automated ETL pipelines and cloud environments.
Building a plugin framework for custom extractors, interpreters,
and loaders would allow domain experts to extend block types without touching the core code,
while performance profiling and parallelization of the pandas‑based type inference and serialization steps
could drive down latency and support larger datasets. Strengthening security around
remote data ingestion—through sandboxed downloads, schema validation, and configurable
network policies—would guard against malicious inputs and broaden adoption in enterprise contexts.

For the LLM schema inference module, improving accuracy and stability is paramount.
Experimenting with ensemble prompts, retrieval‑augmented generation,
or adapter‑based fine‑tuning on a curated corpus of header‑annotated CSVs could
substantially reduce hallucinations and misclassifications. Developing lightweight,
distilled model variants or on‑the‑fly model swapping would lower resource requirements
and enable near real‑time header detection.
Scaling beyond single‑file inference will require distributed orchestration—using frameworks like Dask
or Ray to parallelize across multiple GPUs or nodes—and pairing heuristic validation rules
with model predictions to catch and correct errors.
Finally, expanding benchmark datasets to include multilingual and non‑standard CSV formats will surface
additional edge cases, guiding prompt refinements and model improvements
that ensure robustness across diverse real‑world scenarios.