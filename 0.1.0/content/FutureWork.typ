= Future Work

While the systems described in this work have demonstrated substantial progress toward scalable, automated schema-to-pipeline workflows, several key areas remain open for future enhancement. This chapter outlines strategic directions for extending the Template Generation and LLM-Based Schema Inference components. These recommendations reflect not only unmet technical challenges, but also emerging opportunities revealed during deployment—especially around platform integration, robustness under variability, and end-user accessibility. By focusing on modularization, usability, and cross-system synergy, future iterations could aim to mature the tooling into core infrastructure within the JValue ecosystem and beyond.

== Template Generation System

Advancing the Jayvee template generator entails both technical refinements and deeper integration into the broader JValue Hub platform.

=== Platform Integration

A top priority could be embedding the generator as a native backend service within JValue Hub. This would enable a streamlined “upload-and-generate” workflow, allowing users to select a CSV or remote source via the UI and instantly receive a runnable .jv pipeline with inferred schema, preconfigured transformations, and output sinks. Architecturally, the generator can be modularized as a lightweight microservice exposed via REST or gRPC, enabling reusability across environments.

=== Extensibility and Modularity

The generator should evolve into a plugin-capable engine. Allowing user-defined blocks—such as extractors, transformers, and sinks—would make the system adaptable to domain-specific needs without core modification. This aligns with the broader goal of creating a declarative, composable data automation layer.

=== Performance and Reliability

Batch throughput can be improved by profiling and parallelizing the current pandas-based logic. Additionally, enhancing input sanitation—particularly around quoting, encoding, and whitespace normalization—will increase robustness against irregular CSVs. Sandbox-enforced remote fetching, schema validation, and fetch policies will be critical for secure deployment in enterprise or cloud-native settings.

=== Internationalization and Feedback Loop

Supporting multilingual column normalization and full Unicode compliance will increase applicability to global datasets. Introducing configurable coercion and real-time previewing of inferred pipelines—via web frontends, IDEs, or notebooks—will improve transparency and accelerate iterative refinement.

Together, these directions would push the generator from a developer tool into a user-facing automation layer tightly embedded in the JValue vision of frictionless, declarative data pipelines.

== LLM-Based Schema Inference

The transformer-based schema inference module—while promising—remains architecturally immature relative to the generator, and presents multiple fronts for enhancement.

=== Model Accuracy and Generalization

Fine-tuning with annotated CSV datasets, or applying retrieval-augmented generation, can improve semantic accuracy while reducing hallucinations. Prompt engineering should account for multilingual headers, embedded units, and semantic cues like abbreviations or context rows. Where LLMs fail, hybrid heuristics should act as fallbacks.

=== Systemic Stability and Resource Efficiency

Lessons from benchmarking highlight how runtime instability—especially CUDA OOMs and decoding errors—can break batch workflows. Future versions should:

- Use adapter-based model compression (e.g., quantization, distillation)
- Implement checkpointing and caching to prevent full re-runs
- Dynamically route inputs to lightweight or heavyweight models based on content complexity
- Adopt container-level job isolation to contain GPU failures

These mitigations would stabilize performance across heterogeneous environments, from SLURM-managed clusters to low-power edge deployments.

=== Benchmark Coverage and Data Diversity

Current evaluations were limited to synthetic noisy CSVs. Expanding the test suite to real-world files—including TSVs, XLSX, fixed-width formats, or scraped HTML tables—will provide a more representative baseline. Future benchmarks should also explicitly quantify robustness to token noise, locale variance, and field-level ambiguity.

=== JValue Hub Integration

Integrating the LLM inference module as a schema-suggestion tool in the Hub would complete the automation arc. In tandem with the generator, it would enable a “smart import” workflow—from raw file to running pipeline in just a few clicks.

Ultimately, the schema inference engine can evolve into an intelligent frontend layer that bootstraps structured knowledge from messy inputs—lowering onboarding friction and enhancing the accessibility of data engineering workflows.