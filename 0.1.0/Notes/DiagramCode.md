sequence diagram tempgen

sequenceDiagram
autonumber
participant User
participant GUI as GUI Component
participant Input as Input Management
participant Schema as CSV Type Inference
participant Pipeline as Pipeline Schema Builder
participant Writer as JV Writer
participant Naming as Naming Utilities

    User->>GUI: Select CSV / URL / Links file
    GUI->>GUI: Lock interface & show progress

    alt Single file or URL
        GUI->>Input: process_file_or_url(file_or_url)
    else Links file
        GUI->>Input: process_links_file(file_path)
        loop For each link
            Input->>Input: process_file_or_url(link)
        end
    end

    Input->>Schema: infer_csv_column_types()
    Schema->>Naming: map_inferred_type()
    Schema-->>Input: column_types

    Input->>Pipeline: generate_pipeline_schema(...)
    Pipeline->>Naming: extract_file_name(), to_camel_case()
    alt if unnamed headers
        Pipeline->>Naming: column_index_to_label()
    end
    Pipeline-->>Input: JSON schema

    alt CREATE_JSON=true
        Input->>Writer: save_to_json(schema)
    end

    Input->>Writer: convert_json_to_jv(schema)
    Writer->>Writer: write JV file
    Writer-->>User: JV file created successfully

    GUI->>GUI: Unlock interface & show done


Architecture Diagram LLMInf

graph TD
%% Layers
subgraph Orchestration_Layer[Orchestration Layer]
SLURM[SLURM Job Script (array jobs)]
end

subgraph Input_Layer[Input Layer]
CSV[CSV Files (10k noisy samples)]
GT[Ground Truth (ground_truth.json)]
end

subgraph Inference_Layer[Inference Layer]
Eval[evaluate.py]
Header[find_header.py]
HF[Hugging Face Transformers (local)]
end

subgraph Evaluation_Layer[Evaluation Layer]
Agg[aggregate_results.py]
ER[evaluation_results.json]
ES[evaluation_summary.json]
EL[evaluation.log]
end

%% Flow
SLURM --> CSV
CSV --> Eval
GT --> Eval
Eval --> Header --> HF --> Agg
SLURM --> Agg
Agg --> ER
Agg --> ES
Agg --> EL


Architecture TempGen

graph TD
%% Layers
subgraph Input_Layer[Input Layer]
CSV[CSV file, folder, or URL]
end

subgraph Template_Generation_Engine[Template Generation Engine]
Ingest[Ingestion & Preprocessing]
Infer[CSV Type Inference]
Schema[Pipeline Schema Construction]
end

subgraph Generated_Artifacts[Generated Artifacts]
JV[.jv File Output]
JSON[Optional .json Schema]
end

%% Flow
CSV --> Ingest --> Infer --> Schema --> JV
Schema --> JSON



Architecture Diagram LLMInf

flowchart TD
subgraph Orchestration_Layer["Orchestration Layer"]
SLURM["SLURM Job Script (array jobs)"]
end
subgraph Input_Layer["Input Layer"]
CSV["CSV Files (10k noisy samples)"]
GT["Ground Truth (JSON)"]
end
subgraph Inference_Layer["Inference Layer"]
Eval["Evaluation Logic"]
Header["CSV Analyzation"]
HF["Hugging Face Transformers (local)"]
end
subgraph Evaluation_Layer["Evaluation Layer"]
Agg["Result Aggregation"]
ER["Evaluation Log"]
ES["Evaluation Summary"]
end
Orchestration_Layer --> Evaluation_Layer & Inference_Layer
Input_Layer --> Inference_Layer
Inference_Layer --> Evaluation_Layer
Agg --> ER & ES

    style SLURM stroke:#a41fb6, fill:#FFFFFF, color:#545454
    style CSV stroke:#a41fb6, fill:#FFFFFF, color:#545454
    style GT stroke:#a41fb6, fill:#FFFFFF, color:#545454
    style Eval stroke:#a41fb6, fill:#FFFFFF, color:#545454
    style Header stroke:#a41fb6, fill:#FFFFFF, color:#545454
    style HF stroke:#a41fb6, fill:#FFFFFF, color:#545454
    style Agg stroke:#a41fb6, fill:#FFFFFF, color:#545454
    style ER stroke:#a41fb6, fill:#FFFFFF, color:#545454
    style ES stroke:#a41fb6, fill:#FFFFFF, color:#545454
    style Orchestration_Layer stroke:#efc2f3, fill:#fff3fd, color:#545454
    style Evaluation_Layer stroke:#efc2f3, fill:#fff3fd, color:#545454
    style Inference_Layer stroke:#efc2f3, fill:#fff3fd, color:#545454
    style Input_Layer stroke:#efc2f3, fill:#fff3fd, color:#545454
    linkStyle 0 stroke:#686868,fill:none
    linkStyle 1 stroke:#686868,fill:none
    linkStyle 2 stroke:#686868,fill:none
    linkStyle 3 stroke:#686868,fill:none
    linkStyle 4 stroke:#efc2f3,fill:none
    linkStyle 5 stroke:#E1BEE7,fill:none

plant uml code for architecture diagram llminf

@startuml
title Inference Pipeline - Layered Component Architecture (Refactored)

' Orchestration Layer
package "Orchestration Layer" {
[SLURM Job Script\n(array jobs)] as SLURM
}

' Input Layer
package "Input Layer" {
[CSV Files\n(10k noisy samples)] as CSV
[Ground Truth\n(JSON)] as GT
}

' Inference Layer
package "Inference Layer" {
[CSV Analyzation\n+Model Inference] as InferenceLogic
[Hugging Face Transformers\n(local)] as HF
}

' Evaluation Layer
package "Evaluation Layer" {
[Evaluation Logic] as Eval
[Result Aggregation] as Agg
[Evaluation Log] as ER
[Evaluation Summary] as ES
}

' Dependencies (data/control flow)
SLURM ..> InferenceLogic : triggers
CSV ..> InferenceLogic : input data
HF ..> InferenceLogic : transformer call
InferenceLogic ..> Eval : outputs prediction
GT ..> Eval : reference truth
Eval ..> Agg : evaluation results
Agg ..> ER : writes log
Agg ..> ES : generates summary
@enduml



@startuml

' Orchestration Layer
package "Orchestration Layer" {
[CLI Interface\n(main function)] as CLI
}

' Input Layer
package "Input Layer" {
[CSV file, folder, or URL] as CSV
[Links File\n(multiple URLs)] as LinksFile
[File Handling & Validation] as FileUtils
}

' Template Generation Engine
package "Template Generation Engine" {
[Ingestion &\nPreprocessing] as Ingest
[CSV Type\nInference] as Infer
[Pipeline Schema\nConstruction] as Schema
[Jayvee Conversion\n(JSON to Jayvee)] as JVConv
}

' Generated Artifacts
package "Generated Artifacts" {
[Jayvee File\nOutput] as JV
[Optional .json\nSchema] as JSON
}

' Cross-cutting Concern
package "Logging & Error Handling" {
[Error Logger] as Logger
}

' Flow / Dependencies
CLI ..> CSV : input source
CLI ..> LinksFile : input source
CSV ..> FileUtils : process file
LinksFile ..> FileUtils : process each file individually

FileUtils ..> Ingest : raw data
Ingest ..> Infer : cleaned data
Infer ..> Schema : inferred types
Schema ..> JVConv : JSON schema
JVConv ..> JV : write Jayvee file

CLI ..> Logger : logs errors
FileUtils ..> Logger
Ingest ..> Logger
Infer ..> Logger
Schema ..> Logger
JVConv ..> Logger

' Conditional JSON output (env var CREATE_JSON)
Schema -[#blue,dashed]-> JSON : optional
@enduml


sequenceDiagram TempGen

@startuml
title Sequence Diagram – Jayvee Template Generation

actor User
participant CLI
participant InputManagement as Input
participant SchemaInference as Schema
participant PipelineBuilder as Pipeline
participant NamingUtilities as Naming
participant JVWriter as Writer

User -> CLI : jv_template_generator --csv file.csv \nor --url http://... \nor --links links.txt
CLI -> CLI : parse arguments\nlock CLI interface
alt links file provided
CLI -> Input : process_links_file(links.txt)
loop for each link
Input -> Input : process_file_or_url(link)
... subprocess continues below ...
end
else single file or URL
CLI -> Input : process_file_or_url(source)
end

activate Input
Input -> Schema : infer_csv_column_types(source)
activate Schema
Schema -> Naming : map_inferred_type(dtype)
activate Naming
Naming --> Schema : type string
deactivate Naming
Schema --> Input : column_types
deactivate Schema

Input -> Pipeline : generate_pipeline_schema(source, column_types)
activate Pipeline
Pipeline -> Naming : extract_file_name(source)
activate Naming
Naming --> Pipeline : baseName
deactivate Naming
Pipeline -> Naming : to_camel_case(baseName)
activate Naming
Naming --> Pipeline : CamelCaseName
deactivate Naming

alt renamed columns exist
Pipeline -> Naming : column_index_to_label(index)
activate Naming
Naming --> Pipeline : label
deactivate Naming
end

Pipeline --> Input : schema_JSON
deactivate Pipeline
deactivate Input

alt CREATE_JSON=true
Input -> Writer : save_to_json(schema_JSON)
activate Writer
Writer --> Input : confirmation
deactivate Writer
end

Input -> Writer : convert_json_to_jv(schema_JSON)
activate Writer
Writer -> Writer : write .jv file
Writer --> CLI : "JV file created successfully"
deactivate Writer

CLI -> CLI : unlock CLI interface\nshow completion message
CLI --> User : display success

@enduml


title Sequence Diagram – LLM-Based Schema Inference Evaluation Pipeline
@startuml

actor Slurm
participant "evaluate.py\n(Task Controller)" as Eval
participant "find_header.py\n(Header Inference)" as FH
participant "Hugging Face\nTransformers" as HF
participant "ground_truth.json\nLoader" as GT
participant "partial_results.json\nWriter" as PR
participant "aggregate_results.py\n(Aggregator)" as AG

Slurm -> Eval : launch(task_id, model_dir,\nstride, offset, parallel)
activate Eval

Eval -> GT : load_ground_truth()
activate GT
GT --> Eval : ground_truth_map
deactivate GT

Eval -> Eval : shard_csv_list(stride, offset)
Eval -> Eval : init_process_group() [if GPUs]

Eval -> FH : submit jobs via\nmultiprocessing.Pool
activate FH
loop for each CSV in shard
FH -> FH : load_csv_as_text(csv_path)
FH -> FH : build_prompt(first20_lines)
FH -> HF : run_model(prompt)
activate HF
HF --> FH : raw_response
deactivate HF

    FH -> FH : extract_json(raw_response)
    FH -> FH : parse to Header object
    FH --> Eval : return {filename, prediction}
end
deactivate FH

Eval -> Eval : compare predictions vs ground_truth\ncompute metrics
Eval -> PR : save_partial_results(model, summary,\nevaluations)
activate PR
PR --> Eval : write_confirmation
deactivate PR

Slurm -> AG : after all jobs complete
activate AG
AG -> AG : merge all partial_results.json
AG --> Slurm : evaluation_results.json\nevaluation_summary.json
deactivate AG

deactivate Eval
@enduml

