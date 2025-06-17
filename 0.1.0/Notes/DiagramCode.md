Data Flow Diagram TempGen
```mermaid
flowchart TB
A["CSV Input Files"] --> B["Schema Inference Engine"]
B --> C["Pipeline Generator"]
C --> D["JSON Pipeline Schema"]
D --> E["JSON Writer"]
D --> F["JV Writer"]

    style A stroke:#AA00FF,stroke-width:2px
    style B stroke:#AA00FF,stroke-width:2px
    style C stroke:#AA00FF,stroke-width:2px
    style D stroke:#AA00FF,stroke-width:2px
    style E stroke:#AA00FF,stroke-width:2px
    style F stroke:#AA00FF,stroke-width:2px
```

Data Flow Diagram LLMInf
```mermaid

---
config:
  layout: dagre
---
flowchart TD
A["Clients (Python scripts, API consumers)"] -- HTTP requests --> B["vLLM API Server (SLURM-managed GPU node)"]
B -- API responses --> A
B -- Model loading & inference --> C["LLM Model"]
style A stroke:#AA00FF
style B stroke:#AA00FF
style C stroke:#AA00FF

```
Template Generation Implementation Sequence Diagram
```mermaid
sequenceDiagram
    autonumber
    participant User
    participant GUI as GUI Component
    participant Input as Input Management
    participant Schema as Schema Inference
    participant Pipeline as Pipeline Generation
    participant JSONJV as JSON & JV Writer
    participant Naming as Naming/Path Utilities

    User->>GUI: Click “Select CSV” / “Enter URL” / “Select Links File”
    GUI->>GUI: lock interface
    GUI->>GUI: display progress logs

    alt Single file or URL
        GUI->>Input: start_file_selection() or get_url_from_user()
        Input->>Input: choose_file() / get URL
        Input->>Input: process_file_or_url(file_or_url)
    else Links file
        GUI->>Input: choose_links_file()
        Input->>Input: process_links_file(file_path)
        loop for each link
            Input->>Input: process_file_or_url(link)
        end
    end

    Note over Input: process_file_or_url  
    Input->>Schema: infer_csv_column_types(renamed_cols, new_names, file_or_url)  
    Schema->>Naming: map_inferred_type(dtype) for each column  
    Schema-->>Input: column_types  

    Input->>Pipeline: generate_pipeline_schema(renamed_cols, new_names, file_or_url, column_types)  
    Pipeline->>Naming: extract_file_name(file_or_url)  
    Pipeline->>Naming: to_camel_case(base_name)  
    Pipeline->>Naming: urlparse(file_or_url)  
    alt if renamed_cols not empty
        Pipeline->>Naming: column_index_to_label(index) for each renamed column
    end
    Pipeline-->>Input: schema  

    alt CREATE_JSON=true
        Input->>JSONJV: save_to_json(schema, file_or_url)  
        JSONJV-->>Input: "Saved: JsonFiles/<name>.json"  
    end

    Input->>JSONJV: convert_json_to_jv(schema, output_folder)  
    JSONJV->>Naming: sanitize_name(pipeline and block names)  
    JSONJV->>JSONJV: write JV file to disk  
    JSONJV-->>User: display “JV file created successfully”

    GUI->>GUI: unlock interface
    GUI->>GUI: finalize progress logs

```
llm schema inference sequence diagram
```mermaid
sequenceDiagram
    participant SLURM as run_vllm_models.sh
    participant ModelServer as vLLM Model Server (api_server)
    participant TestScript as test_find_header.py
    participant HeaderScript as vllm_find_header.py
    participant FileSystem as File System / Logs

    Note over SLURM: Job Submission and Setup
    SLURM->>SLURM: Setup environment, load modules, activate conda
    SLURM->>FileSystem: Validate CSV_DIR and ground_truth.json exist
    SLURM->>FileSystem: Create model_logs directory
    SLURM->>SLURM: Set OPENAI_API_KEY

    loop For each model in MODEL_IDS
        SLURM->>ModelServer: Launch model API server (background process)
        ModelServer->>SLURM: Server listens on port, logs output
        SLURM->>SLURM: Poll until port is open or timeout

        alt Server started successfully
            SLURM->>SLURM: Set OPENAI_API_BASE env var (e.g. http://localhost:PORT)
            SLURM->>TestScript: Run test_find_header.py with MODEL_NAME argument

            Note over TestScript: Evaluates CSVs by running HeaderScript subprocess
            loop For each CSV file in CSV_DIR
                TestScript->>HeaderScript: Run vllm_find_header.py <csv_path> <model_name> (subprocess)
                HeaderScript->>FileSystem: Read CSV file lines
                HeaderScript->>ModelServer: Query vLLM local model with prompt
                ModelServer->>HeaderScript: Return JSON response
                HeaderScript->>TestScript: Output JSON result to stdout
                TestScript->>TestScript: Parse JSON, compare with ground truth
            end

            TestScript->>FileSystem: Write evaluation_results.json, evaluation_summary.json, evaluation.log
            TestScript->>SLURM: Return control when finished

            SLURM->>ModelServer: Kill model server process
        else Server failed to start
            SLURM->>SLURM: Log error and cleanup
        end
    end
    SLURM->>SLURM: Echo "All models completed."
```
TempGen Test Architecture Diagram
```mermaid
flowchart LR
 subgraph SLURM["SLURM"]
        SJ["SLURM Job Script"]
  end
 subgraph Harness["Harness"]
        TH["Test Harness"]
  end
 subgraph JV_CLI["JV CLI"]
        JG["JV Generator CLI - 
        process CSV → .jv"]
  end
 subgraph JV_Exec["JV Execution"]
        JE["JV Executor - 
        run .jv → .sqlite"]
  end
 subgraph Artifacts["Artifacts"]
        TF["Template Files - .jv"]
        DB["SQLite Databases - .sqlite"]
  end
 subgraph Logs["Logs"]
        CL["Central Logs - errors & metrics"]
  end
    SJ --> TH
    TH --> JG & JE & CL
    JG --> TF & CL
    JE --> DB & CL

    style SJ color:#424242, stroke:#AA00FF
    style TH stroke:#AA00FF,color:#424242
    style JG stroke:#AA00FF,color:#424242 
    style JE stroke:#AA00FF,color:#424242
    style TF stroke:#AA00FF,color:#424242 
    style DB stroke:#AA00FF,color:#424242 
    style CL stroke:#AA00FF
    style Harness stroke:#E1BEE7,color:#616161    
    style JV_CLI stroke:#E1BEE7,color:#616161    
    style JV_Exec stroke:#E1BEE7,color:#616161  
    style Logs stroke:#E1BEE7,color:#616161  
    style Artifacts stroke:#E1BEE7,color:#616161  
    style SLURM color:#616161    ,stroke:#E1BEE7
    linkStyle 0 stroke:#757575,fill:none
    linkStyle 1 stroke:#757575,fill:none
    linkStyle 2 stroke:#757575,fill:none
    linkStyle 3 stroke:#757575,fill:none
    linkStyle 4 stroke:#757575,fill:none
    linkStyle 5 stroke:#757575,fill:none
    linkStyle 7 stroke:#757575,fill:none


```

Schema Inference Test Architecture Diagram
```mermaid
flowchart LR
  subgraph SLURM["SLURM"]
    SJ["SLURM Job Script - model launcher & orchestrator"]
  end

  subgraph Harness["Evaluation Harness"]
    EH["test_find_header.py - evaluation runner"]
  end

  subgraph Models["Model API Servers"]
    MS1["deepseek-vl2-small (via vLLM API server)"]
  end

  subgraph Evaluation["Evaluation & Metrics"]
    GT["Ground Truth - ground_truth.json"]
    ER["evaluation_results.json"]
    ES["evaluation_summary.json"]
    EL["evaluation.log"]
  end

  subgraph Inputs["Test Artifacts"]
    CSV["Noisy CSVs - 10k files"]
    KEY["openai_key.txt"]
  end

  subgraph Scripts["Code"]
    FH["vllm_find_header.py"]
  end

  SJ --> MS1
  SJ --> EH
  SJ --> KEY
  SJ --> GT
  SJ --> CSV

  EH --> MS1
  EH --> CSV
  EH --> FH
  EH --> GT
  EH --> ER
  EH --> ES
  EH --> EL

  FH --> MS1

  style SJ stroke:#AA00FF,color:#424242
  style EH stroke:#AA00FF,color:#424242
  style MS1 stroke:#AA00FF,color:#424242
  style GT stroke:#AA00FF,color:#424242
  style ER stroke:#AA00FF,color:#424242
  style ES stroke:#AA00FF,color:#424242
  style EL stroke:#AA00FF,color:#424242
  style CSV stroke:#AA00FF,color:#424242
  style FH stroke:#AA00FF,color:#424242
  style KEY stroke:#AA00FF,color:#424242

  style SLURM stroke:#E1BEE7,color:#616161
  style Harness stroke:#E1BEE7,color:#616161
  style Models stroke:#E1BEE7,color:#616161
  style Evaluation stroke:#E1BEE7,color:#616161
  style Inputs stroke:#E1BEE7,color:#616161
  style Scripts stroke:#E1BEE7,color:#616161

  linkStyle default stroke:#757575,fill:none
```