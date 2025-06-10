= Conclusions
== Template Generation
- regex logic sufficient to capture most relevant aspects of the CSV files
- Platform: Desktop-only (Tkinter), no web or headless support
- Latency: Limited optimization; not suitable for real-time processing
- Security: No sandboxing or validation for remote URLs
- Flexibility vs. Simplicity: Static block definitions hardcoded
- No plugin system: Cannot dynamically extend pipeline block types
- Modifiability: Function-level isolation; extensible block system
- Scalability: Handles batch processing via link file ingestion
- Fault Tolerance: Logging mechanism for error tracking
- Testability: Deterministic, file-based inputs and outputs
- Performance: Efficient pandas-based type inference
- Security: Input sanitization for filenames and URLs

== LLM Schema Inference
- high amount of computation capacities needed to run LLM locally
- LLMs are not yet able to detect the column name row in all cases
- a lot of hallucinating problems even with rather big models
- response times are not yet fast enough for real-time applications
- Model Dependency: Requires powerful language model to perform well
- Latency: Dependent on LLM processing time and local/hpc server speed (now not really a problem but was before)
- Scalability: Designed for single-file analysis, not massive batch jobs
- Security: Raw file content passed to external/local model endpoint
- Transparency: Determinism not guaranteed; different completions possible per run

test training model on schemapile in the future@dohmen2024schemapile
