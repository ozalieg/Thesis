= Future Work

== Template Generation System

Enhancing the Jayvee template generation engine includes both standalone improvements and tighter integration into broader data infrastructure—especially the JValue Hub ecosystem.

A high-priority direction is embedding the template generator as a native feature in JValue Hub. This would allow users to select a CSV file or remote data source via the Hub’s UI and automatically receive a pre-generated .jv pipeline—complete with inferred schema, ready-to-run transformations, and downstream sinks. This "one-click pipeline generation" experience would empower non-technical users and accelerate onboarding in data-centric workflows. Internally, the generator can be wrapped as a web API microservice callable from the Hub’s backend, preserving modularity and enabling scalable deployment.

Beyond platform integration, the core generator itself can be improved in several ways.
Migrating the system into a lightweight web service would provide broader deployment flexibility
and facilitate use in automated workflows or CI/CD environments.
Introducing a plugin framework would allow users to define custom extractors,
converters, and sinks without modifying the core logic, increasing extensibility
for domain-specific applications. Performance can be further optimized by profiling
and parallelizing the pandas-based type inference and serialization logic,
which is especially valuable for handling large or high-frequency datasets. Additionally,
strengthening the security model—such as sandboxing remote file access, validating input schemas,
and defining fetch policies—will be essential for safe adoption in enterprise and cloud-based settings.

To increase versatility, the generator should support multilingual column header normalization
and be fully Unicode-aware to accommodate international datasets.
Allowing for configurable coercion strategies, particularly for temporal, boolean, or nullable fields,
would provide more control over schema fidelity.
Finally, enabling real-time validation and preview of inferred pipelines within interactive
environments—whether via notebook, IDE extension, or web frontend—would improve
user trust and rapid feedback during the authoring process.

By combining modular extensibility with seamless platform integration, the template generation
tool can evolve from a developer-centric utility into a foundational automation layer within JValue Hub,
reinforcing the platform’s vision of composable and declarative data workflows.

== LLM Schema Inference Module

The LLM-based schema inference module remains fertile ground for innovation,
with priorities centered on improving accuracy, robustness, and scalability.

To improve prediction quality, future work should explore
retrieval-augmented generation and adapter-based fine-tuning using a curated corpus of annotated CSVs.
These techniques could significantly reduce hallucinations and improve semantic consistency.
Incorporating heuristic fallbacks will further stabilize inference in edge cases,
such as files with embedded units, metadata rows, or irregular formatting.
Expanding the prompt design to support multilingual header interpretations will enhance generalization
across non-English and locale-specific datasets.

From a systems perspective, efficiency and portability can be improved by developing distilled
or quantized variants of the best-performing models. Such variants would enable inference
in resource-constrained environments, including browser-based clients or serverless runtimes.
It may also be beneficial to implement dynamic model selection logic, allowing the system
to switch between lightweight and heavyweight models depending on file complexity, size, or domain metadata.

Employing checkpointing mechanisms and caching partial results will reduce recomputation during
long-running batch jobs and make iterative runs more efficient.
In tandem, expanding the benchmark suite to cover diverse file formats such as TSVs,
XLSX files, and fixed-width tables, along with scraped or non-standard real-world examples,
will ensure generalization and provide a more rigorous evaluation baseline.

Ultimately, integrating the schema inference module directly into JValue Hub
as a schema-suggestion feature would complement the template generator.
Together, they would form a seamless “infer + generate” workflow, substantially
lowering the barrier from raw data to validated, runnable pipelines and
making the entire process accessible to a broader audience.