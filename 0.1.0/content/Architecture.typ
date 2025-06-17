#import "../utils/todo.typ":*
#import "@preview/abbr:0.2.3"

= Architecture
== JV Template Generation


The JV Template Generation Script is architected to automate schema generation
from heterogeneous CSV sources, addressing the need to process and unify both local and remote datasets
 within a standardized pipeline model.
 The system facilitates transforming arbitrary CSV data into structured,
 visualizable pipelines in the domain-specific .jv format, bridging the gap
 between unstructured tabular data and pipeline execution engines.

Its architecture follows a modular, component-based organization.
Execution is file-driven, simulating an implicit dataflow-style pattern typical in ETL tools.
Though implemented as a monolithic script, it is architecturally separated into discrete,
modular function layers that define service-oriented boundaries.
Interaction modes include a lightweight GUI and a CLI, but these are outside the architectural focus.

The system consists of distinct architectural components arranged in a layered execution model.
Input ingestion components feed into a schema inference engine, which produces an abstract schema.
This schema is then passed to a pipeline generator that emits output artifacts in JSON and .jv formats.

#figure(
image("./Datagram_TempGen.png", width: 40%),
caption: [System-Level Data Flow Diagram – From CSV Ingestion to JV Output],
) <dataflowdiagram_tempgen>

The architectural data flow, illustrated in @dataflowdiagram_tempgen, depicts the journey
from CSV ingestion to schema inference, pipeline construction, and final output generation.
This architecture models a pipeline-like transformation process where each component incrementally builds
 on the output of the preceding one.
 This layered structure enables traceability, reproducibility, and structured ETL configuration generation.


=== Execution Environment

The script runs across Windows, macOS, and Linux, with optimal performance observed in local development settings.
Written in Python 3.x, it depends on core libraries including pandas, tkinter, json, urllib, pathlib, and logging.
It interacts with both file systems and web endpoints to load CSVs and export structured files.
The typical user persona is a data engineer or technical analyst working to operationalize CSV-based data inputs into pipeline-compatible formats.



== LLM Schema Inference

The LLM schema inference system is architected as a multi-layer,
scalable inference platform designed to serve large language models (LLMs)
efficiently via a standardized API interface.

The architecture is organized into three distinct layers:

The Client Layer provides a standardized interface to users,
 abstracting the underlying model complexities and exposing OpenAI-compatible API endpoints such as /v1/completions and /v1/chat/completions. This layer decouples user interaction from backend model management.

The Inference Layer hosts the LLM on GPU nodes, managing model execution, batching,
streaming, and memory optimization. It exposes REST API endpoints aligned
with OpenAI standards to serve inference requests efficiently.

The Orchestration Layer manages GPU resource allocation and job scheduling through SLURM,
running the vLLM server processes as SLURM jobs within a shared GPU cluster.
This layer ensures scalable, fair, and responsive resource management under varying workloads.

#figure(
image("./DataFlowDiagram_LLMInference.png", width: 50%),
caption: [Data Flow Diagram],
) <dataflowdiagram>

The data flow within this architecture, depicted in @dataflowdiagram,
shows the Client Layer sending inference requests to the Inference Layer, which executes model inference.
The Orchestration Layer operates in the background,
dynamically managing GPU resources by scheduling jobs on the shared cluster,
thus enabling scalability and efficient resource distribution.







