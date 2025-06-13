= Requirements

The system developed in this thesis is guided by a set of functional and non-functional requirements,
as well as explicit constraints and assumptions, structured around two primary components:
Jayvee template generation and schema inference using local large language models (LLMs).

== Jayvee Template Generation

From a functional perspective, the template generation system is expected
to create a Jayvee pipeline model template from structured input, specifically CSV files.
To achieve abstraction and improve modularity, the system first generates
an intermediate JSON representation, which is subsequently transformed into a .jv template file.
It is imperative that the resulting output conforms to the Jayvee specification and is syntactically valid.
The system must also support diverse data sources:
it should correctly handle both local CSV files and those retrieved via remote URLs.
Furthermore, it should be resilient to typical irregularities encountered in CSVs—such
as leading white spaces and unnamed columns—which are to be ignored during parsing.

On the non-functional side, the system’s scalability is assessed by its ability to process
up to 10,000 CSV files in a single batch, ensuring performance under high-volume workloads.

Certain assumptions and constraints govern the system's architecture: most notably,
the structure of the generated templates must strictly adhere to the guidelines
specified in the official Jayvee user documentation.

== LLM-Based Schema Inference

The second major component addresses schema inference from malformed or anomalous CSV files
using locally hosted large language models.
Functionally, the system must identify the row that contains column headers,
even in cases where the CSV structure is inconsistent or corrupted.
The output of this schema inference is to be formatted strictly in JSON,
aligning with the intermediate format used in the template generation process.
To enhance model performance under zero-shot conditions,
the approach incorporates prompt engineering techniques tailored to guide the model output.
The evaluation phase involves experimenting with various models and parameter configurations
to determine which combination yields the most accurate and reliable results.

From a non-functional standpoint, this component, like the template generation system,
must also be capable of handling inference for up to 10,000 CSV files.
This establishes a consistent benchmark across both systems for evaluating throughput and reliability.

Finally, there are two core constraints underpinning this component.
First, the language models must be hosted locally; no reliance on external APIs or cloud-based inference
 services is permitted. Second, all output must be serialized in JSON format to maintain compatibility
  with downstream components in the pipeline generation process.

Together, these requirements define the operational scope and design principles of the systems
developed in this thesis. Each module operates independently,
allowing for targeted optimization and testing,
while maintaining potential for future integration into a unified pipeline automation toolchain.

