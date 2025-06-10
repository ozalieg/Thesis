#import "../utils/todo.typ":*
= Architecture
== JV Template Generation
The JV Template Generation Script was developed to automate schema generation from heterogeneous CSV sources, addressing the need to process and unify both local and remote datasets within a standardized pipeline model. This utility facilitates the transformation of arbitrary CSV data into structured, visualizable pipelines (.jv format), thereby bridging the gap between unstructured tabular data and domain-specific pipeline execution engines. A key motivation behind this tool is the lack of consistent metadata in CSV datasets, which complicates downstream ETL and pipeline configuration processes.

At its core, the architecture follows a component-based,
modular design philosophy.
Execution is file-driven, simulating an implicit dataflow-style execution pattern common in ETL tools.
While architected as a monolithic Python script, the tool emulates service-like boundaries through modular functions.
It operates in a hybrid interaction model, combining a lightweight GUI for user-friendly operations
and CLI compatibility for automated or batch processing scenarios.

=== Core Components

The JV Template Generation Script is composed of several tightly integrated architectural components,
each designed to handle a distinct responsibility within the pipeline generation lifecycle.
At the front end, a minimal graphical user interface (GUI) built with tkinter provides users with an intuitive mechanism for selecting CSV files,
whether stored locally or accessed via URLs, while also displaying processing logs for transparency.
This GUI feeds into the Input Management subsystem, which is responsible for loading one or more CSV files using standard I/O or network retrieval via urllib,
thereby supporting both local workflows and remote data sourcing.

Once data is ingested, control passes to the Schema Inference Engine.
a lightweight analytics layer that uses pandas and heuristic rules to detect and infer column-level data types and patterns across the CSV dataset.
This inferred schema serves as the foundation for the Pipeline Generator, a transformation module that converts the columnar structure into a structured,
domain-aligned pipeline schema, represented internally as a JSON object. This abstraction models the data flow logic and sets the stage for export.

Subsequently, the JSON & JV Writer modules serialize this pipeline schema into two primary output formats:
a JSON version used for inspection and interoperability, and a .jv file tailored for consumption by domain-specific pipeline engines that expect this format.
Underpinning all these layers is a suite of Naming and Path Utilities, which enforce naming conventions,
sanitize file paths, and ensure filesystem-safe identifiers across the pipeline lifecycle.
These components collectively form a streamlined, extensible toolchain that transforms raw CSV data into structured, executable pipeline blueprints.

#figure(
image("./Datagram_TempGen.png", width: 40%),
caption: [System-Level Data Flow Diagram – From CSV Ingestion to JV Output],
) <dataflowdiagram_tempgen>

These components work together to deliver a seamless transformation from raw,
unstructured CSV data into structured, executable pipeline definitions.
To better understand how data moves through the system, @dataflowdiagram_tempgen (see the System-Level Data Flow Diagram)
provides a high-level overview of the end-to-end process, beginning with CSV ingestion and culminating in final output formats, JSON and .jv.
Initially, raw CSV input files are processed by the Schema Inference Engine, which analyzes the data structure to infer column data types.
This inferred schema is then passed to the Pipeline Generator, responsible for constructing a logical and structured representation of the pipeline,
known as the JSON pipeline schema. Serving as the authoritative model for the pipeline, this JSON schema forms the foundation for serialization.
Dedicated writer components subsequently convert this schema into two distinct outputs: a human-readable JSON file for
inspection and interoperability, and a .jv file tailored for domain-specific pipeline execution engines.
This data flow demonstrates the implicit ETL-like behavior of the script and highlights its transformation-oriented architecture,
where each stage builds upon the previous output to create a standardized, interoperable pipeline configuration.

=== Execution Environment

The script runs across Windows, macOS, and Linux, with optimal performance observed in local development settings.
Written in Python 3.x, it depends on core libraries including pandas, tkinter, json, urllib, pathlib, and logging.
It interacts with both file systems and web endpoints to load CSVs and export structured files.
The typical user persona is a data engineer or technical analyst working to operationalize CSV-based data inputs into pipeline-compatible formats.



== LLM Schema Inference

The architecture for LLM-schema inference can be viewed as a multi-component LLM inference system designed to serve large language models (LLMs) efficiently to clients via a standard API interface. It includes three main layers:

#figure(
  table(
    columns: 3,
    [Layer], [Role], [Key Components],
    [Client Layer], [API consumers], [Python scripts, LangChain agents, external apps using OpenAI API],
    [Inference Layer], [Model serving & inference], [vLLM API server (OpenAI-compatible), running on GPU nodes],
    [Orchestration Layer], [Resource scheduling & job management],[SLURM workload manager, cluster nodes],
  ),
  caption: [Architecure Overview],
)

The system architecture is organized into three distinct layers that interact to provide a scalable,
OpenAI-compatible large language model (LLM) inference service.

The client layer is responsible for offering users a familiar and standardized interface for sending inference
requests in OpenAI API formats such as /v1/completions and /v1/chat/completions.
This layer abstracts the underlying model backend, ensuring a seamless "LLM-as-a-Service" experience,
which allows users to interact with the models without needing to understand the complexities of model deployment
or GPU resource management.

The inference layer serves as the core of the system,
hosting the LLM, for example, the Qwen2.5-1.5B model, on GPU nodes and exposing REST API endpoints
compatible with the OpenAI API standards.
This layer supports advanced features such as batching,
streaming responses, and optimized memory management, which enable efficient and performant inference even
for large and complex requests.

Finally, the orchestration layer dynamically manages GPU resources by leveraging SLURM,
scheduling the vLLM server process as a SLURM job within a shared GPU cluster.
This approach ensures fair resource allocation across multiple users and workloads
and supports horizontal scalability by launching additional SLURM jobs as demand increases.

Together, these layers form a robust and efficient system that delivers an accessible LLM inference service to users
while abstracting and managing the underlying infrastructure and resource allocation transparently.

#figure(
image("./DataFlowDiagram_LLMInference.png", width: 50%),
caption: [Data Flow Diagram],
) <dataflowdiagram>

The data flow within this architecture is illustrated in @dataflowdiagram,
where the Client Layer sends inference requests to the Inference Layer via OpenAI-compatible REST API endpoints,
ensuring a standardized and user-friendly interface.
The Inference Layer, responsible for executing these requests,
manages model loading, batching, and memory optimization on GPU nodes,
facilitating efficient large-scale inference. The Orchestration Layer operates behind the scenes,
leveraging SLURM to dynamically allocate and manage GPU resources by scheduling the vLLM server processes as jobs
on a shared GPU cluster. This setup enables fair resource distribution, supports horizontal scalability,
and maintains system responsiveness even under varying workloads.




