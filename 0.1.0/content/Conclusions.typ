= Conclusions

== Template Generation

The Jayvee template generation pipeline has matured into a robust, modular system capable of transforming diverse and often messy CSV schemas into executable Jayveepipelines at scale. The updated batch-driven architecture, powered by a SLURM-managed HPC setup, successfully processed 10,000 files without manual intervention and maintained sub-second generation latency per file.

Key robustness features—such as fallback renaming of unnamed columns, whitespace trimming, quoted field handling, and consistent CamelCase pipeline naming—ensure that input irregularities do not propagate downstream. Data type inference via pandas provides effective generalization across boolean, numeric, and text types, though datetime normalization remains a known limitation.

The system’s deterministic, file-based I/O and centralized logging strategy has enabled full automation, observability, and testability. While complex cases like multilingual headers and semantic null handling are not yet supported, the current implementation offers a strong foundation for scaling and iterative enhancement. Future iterations could integrate plugin support for custom block types and improve remote URL handling for better security and extensibility.
== LLM Schema Inference

The LLM-based schema inference module demonstrates the viability of using transformer models for detecting CSV header rows under real-world obfuscation. Leveraging a synthetic benchmark of 10,000 noisy, variably structured files, the evaluation framework revealed critical differences in accuracy, robustness, and reasoning depth across models.

The instruction-tuned DeepSeek-Coder model performed best, highlighting the benefits of task-specific tuning. Smaller or less specialized models, such as Qwen3-4B and CodeLlama-7B-Instruct, showed sensitivity to superficial token patterns and struggled with hybrid or metadata-laden preambles. These findings affirm that header detection is a semantic task requiring more than delimiter detection or capitalization heuristics.

The evaluation harness—modular, traceable, and SLURM-parallelized—supports reproducible benchmarking and detailed error analysis. However, reliance on local GPU-backed inference constrains scalability and limits accessibility in low-resource settings. Furthermore, the non-determinism of generative outputs complicates reproducibility, suggesting the value of prompt freezing, scoring ensembles, or hybrid approaches combining LLMs with regex-based heuristics.
