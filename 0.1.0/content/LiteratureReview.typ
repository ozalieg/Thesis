#import "@preview/abbr:0.2.3"
#import "../utils/todo.typ":*

= Literature Review

This literature review surveys foundational and emerging approaches to schema inference,
prompt engineering, retrieval-augmented reasoning, multimodal table understanding,
and automated pipeline synthesis—each directly informing the dual focus of this thesis.
The first half of the review evaluates how classical heuristics, machine learning,
and large language models (LLMs) address the challenge of detecting header rows
and semantic structure in noisy CSV files, aligning with the thesis’ empirical study
on local LLM-based schema inference. It then explores advances in prompt engineering
and retrieval-augmented models, both central to enhancing zero-shot performance without fine-tuning.
The second half pivots to pipeline generation,
highlighting domain-specific language (DSL) frameworks like Jayvee
and automated systems such as Auto-Pipeline and AlphaClean,
which contextualize the design of this thesis’ template generation engine.
Together, these works underscore the relevance and novelty of integrating schema-aware
interpretation with DSL-based pipeline synthesis for real-world tabular data processing.

== Prompt Engineering

Prompt engineering offers significant advantages over fine-tuning, especially in terms of cost, resource requirements, and adaptability.
Executing a well-crafted prompt is significantly less resource-intensive than full model fine-tuning,
which can be prohibitively expensive in compute and data requirements—particularly when working with large language models (LLMs).
It also bypasses the need for labeled datasets, leveraging the pre-trained model’s knowledge directly without supervised training data. @PORNPRASIT2024107523 @shin2025promptengineeringfinetuningempirical

While fine-tuning still generally yields higher peak performance, prompt engineering can achieve surprising effectiveness in certain applications.
For example, in medical question-answering tasks using GPT‑4, few-shot prompting with structured reasoning steps not only matched but occasionally
surpassed the performance of fine-tuned baselines such as PubMedBERT, even under stringent conditions like removal of key input tokens @zhang2024comparison.
In code-domain benchmarks, careful prompting strategies have demonstrated competitive BLEU scores compared to fine-tuned models,
especially when human feedback is integrated conversationally @turn0search5 @turn0search8.

Prompt-based methods also exhibit greater flexibility and robustness:
models like GPT‑4 maintain performance stability even with significant prompt perturbations or content omission,
 and are compatible with diverse prompting styles—including zero-shot, few-shot, chain-of-thought,
 and conversational formats—making them highly adaptable for varied downstream tasks@zhang2024comparison.


== Schema Inference and Tabular Data Understanding

=== Heuristic and Rule-Based Methods for Header Detection

Early approaches to schema inference in tabular data primarily relied on heuristic and rule-based methods.
HUSS, a heuristic algorithm for understanding the semantic structure of spreadsheets,
exemplifies this class of techniques by leveraging layout and formatting cues such as font style and alignment to infer header roles,
operating effectively under assumptions of consistent structure @dint_a_00201.
Similarly, Fang et al. present a rule-based classifier for header detection in digital libraries that utilizes features like
 pairwise similarity between consecutive rows—a classic form of pattern recognition—to distinguish between header and data regions @fang2012table.
 Milosevic et al. adopt a multi-layered approach that integrates functional and structural heuristics with machine learning,
 thereby acknowledging and partially addressing the limitations of purely rule-based strategies when faced with complex table layouts @milovsevic2018multi.

These early methods generally assumed well-formed, homogeneous data structures with clearly defined headers and uniform formatting across rows.
In practice, however, such assumptions rarely hold. HUSS, for instance,
shows diminished performance when applied to spreadsheets with noisy layouts or ambiguous header usage,
underscoring the brittleness of heuristic approaches under real-world conditions @dint_a_00201.
Fang et al. similarly note the challenge of generalizing across diverse table styles,
especially when extraneous metadata or multi-row headers are present @fang2012table.
Milosevic et al. explicitly highlight the difficulties posed by visual and semantic
variability in biomedical tables, motivating their integration of learning-based components as a means of enhancing robustness @milovsevic2018multi.

In summary, while classical rule-based methods like HUSS and those proposed by Fang and Milosevic demonstrate utility under idealized conditions,
their reliance on structural consistency and formatting regularity often limits applicability.
As files increasingly include comments, metadata, or inconsistent row structures, these techniques encounter substantial challenges in header row detection
and schema generation—a gap that modern machine learning methods seek to address.

=== Machine Learning Approaches

With the advent of machine learning, researchers began exploring more robust methods for schema inference.
For example, Strudel applies a supervised learning method to classify lines and cells in CSV-like tables,
linking each cell to types such as header, data, derived or footnote.
It uses content-based, contextual, and computational features—and includes post-processing steps to correct classification
errors—significantly improving header row detection in noisy datasets @koci2016machine.

Likewise, Khusro et al. (2018) developed a supervised classification model for header detection in PDFs,
leveraging textual and layout features (like bounding box and whitespace cues) with a decision-tree classifier that showed strong performance
after a repair-oriented post-processing stage @budhiraja2020supervised. These hybrid systems demonstrate that applying machine learning—especially combined
with heuristic repair mechanisms—can substantially enhance header detection accuracy in messy real-world files.

=== Modern Techniques Leveraging Language Models

Recent advancements have brought #abbr.pla[LLM] into schema inference workflows,
enabling powerful new capabilities in table understanding.
One prominent example is Schema-Driven Information Extraction from Heterogeneous Tables, which frames table schema inference as an extraction problem:
given a JSON-defined schema, instruction-tuned transformer models like GPT‑4 or Code‑Davinci can parse noisy tables (HTML, LaTeX, CSV)
and output structured JSON records matching the schema.
This method significantly outperforms traditional heuristic approaches in real-world settings, achieving F1 scores from 74.2% to 96.1% across diverse domains,
while using prompt-based error-recovery to handle formatting inconsistencies.@bai2024schema

These systems leverage instruction-following transformer models that are trained or tuned for schema compliance,
delivering robust interpretation of tabular context even under noise and structural complexity.
The result: schema-aware LLMs can accurately detect column headers and align table cells with schema fields—far surpassing brittle
rule-based methods that assume clean, uniform CSV inputs.
Prompt engineering techniques such as structured JSON schemas, content-aware context, and iterative error correction are central to this performance boost.

== Retrieval-Augmented Language Models and Context Injection

Retrieval-augmented language models (RALMs) like DeepSeek-R1 enhance reasoning and disambiguation in data tasks by integrating external knowledge sources
at inference time. DeepSeek-R1, developed as part of the DeepSeek initiative, employs a multi-stage training process—including cold-start data,
supervised fine-tuning, and reinforcement learning with human feedback (RLHF)—that enhances its ability to reason over structured and semi-structured inputs
such as tables and CSV files @deepseek2024deepseek.
This augmentation strategy allows models to dynamically pull in domain-relevant information,
which improves both factual accuracy and interpretability in schema inference tasks @bai2024schema.

In header detection for noisy CSV files, RALMs can use retrieval to resolve ambiguous or missing context.
For example, when column names are absent, truncated, or inconsistent, a retrieval module can query relevant documents
(e.g., documentation, similar datasets, or metadata repositories) to infer likely schema roles @bai2024schema.
This makes retrieval-enhanced models significantly more robust than static models that rely solely on training-set priors.
Practical implementations, including experiments involving DeepSeek-R1 with LangChain or LangGraph frameworks,
have demonstrated that recursive retrieval pipelines improve disambiguation and classification in real-world CSV tasks @lijin2024structured.

Furthermore, retrieval capabilities enable language models to adapt more flexibly to new or evolving data formats without requiring extensive re-training.
Unlike fixed classifiers, RALMs like DeepSeek-R1 use retrieval-augmented generation (RAG) to externalize parts of the reasoning process,
leading to better generalization in unseen formats or edge cases @deepseek2024deepseek.
This makes them especially suited to schema inference applications, where file variability, semantic ambiguity, and format drift are common @bai2024schema.


== Multi-modal Models for Tabular Data Analysis

Recent work has focused on large multimodal models like Qwen‑VL and TableGPT‑2, which can jointly process text,
table structures, and images. Models such as InternLM‑xComposer and TableLLaMA illustrate how integrating visual and textual modalities enhances schema inference
in complex tables by understanding layout, spatial relationships, and semantic content simultaneously @turn0search7.
The PubTables‑1M dataset, containing nearly one million tables, has enabled training of such multimodal models and demonstrated
that transformer-based object-detection architectures improve detection, structure recognition, and functional analysis across diverse
domains without specialized architectures @turn0academia12.

Nonetheless, recent findings show that even state-of-the-art multimodal LLMs struggle with reconstructing table structures reliably,
especially from images alone, highlighting the necessity for improved visual grounding and spatial reasoning in these models @turn0search11 @turn0search2.

== Performance Evaluation Metrics and Benchmark Datasets for Schema Inference

Model evaluation relies on metrics like accuracy, F1 score, substring match, and ROUGE‑L, reflecting both structural and content correctness in schema inference
tasks @turn0search2. PubTables‑1M sets a high water mark for table structure recognition,
while TabLeX provides a benchmark for extracting both table content and structure from scientific sources @turn0academia12 @turn0academia13.

However, annotation inconsistencies such as over‑segmentation remain prevalent across datasets,
and researchers have proposed canonicalization methods to standardize annotations to ensure reliable performance estimation @turn0search5.

Benchmarking tools emphasize that metrics must capture per‑cell integrity and end‑to‑end table accuracy to truly reflect a model’s robustness
to real-world format variations @turn0search5 @turn0search0.

== Extending Prior Work: Local LLMs for Noisy CSV Header Detection

In light of the developments surveyed, this thesis positions itself at the intersection
of prompt-based schema inference and pipeline automation for tabular data,
responding directly to several critical gaps in the literature.

First, while traditional heuristic and rule-based systems like HUSS and multi-stage classifiers
offer some utility in idealized contexts, their effectiveness sharply declines under the noise
and irregularity characteristic of real-world CSV files.
The rise of instruction-following large language models (LLMs) provides a compelling alternative:
by leveraging prompt engineering rather than dataset-specific fine-tuning,
these models—such as DeepSeek-R1, Qwen3-235B-A22B, and Granite-3.2-8B-Instruct—demonstrate
promising zero-shot capabilities in discerning header rows and tabular semantics,
even under structural ambiguity. The use of locally hosted LLMs marks a distinct methodological pivot,
offering privacy-preserving and cost-effective schema inference workflows that operate entirely
offline—an underexplored but increasingly important deployment paradigm.

Moreover, while much of the current research emphasizes large-scale,
cloud-based LLM systems, this work evaluates model performance in a local execution context,
where hardware limitations and model optimization constraints present unique challenges.
In doing so, it brings empirical clarity to the practical feasibility of deploying such models
for tabular understanding outside of centralized, compute-rich infrastructures.

The second component of the thesis—the design of a template generation engine for Jayvee
pipelines—extends this focus from structural understanding to operational synthesis.
Existing literature has largely treated table understanding and downstream task orchestration
as disjoint problems. This work, by contrast, treats noisy tabular inputs as both the target
of structural interpretation and the source for generating executable,
user-friendly transformation pipelines.
This dual usage represents a holistic and novel approach to data usability engineering,
especially for users with limited technical expertise.

Together, the thesis advances the field by (1) evaluating the boundaries of LLM generalization
in schema inference under realistic constraints,
and (2) designing a DSL-centric automation layer that translates this understanding
into actionable pipelines.
In a research landscape increasingly concerned with modular, interpretable,
and accessible AI tools for data handling, this work offers both a proof of concept
and a practical system architecture for next-generation tabular data interfaces.

== Automated DSL-based Pipeline Synthesis

Building upon the discussion of schema inference,
the second stream of this thesis focuses on template-driven pipeline
synthesis using Jayvee’s domain-specific language.
Empirical evaluation of Jayvee has demonstrated that DSL-based workflows significantly lower the barrier
to pipeline creation for non-professional developers,
improving both development speed and comprehension of data architectures @heltweg2025empirical.
This aligns with broader efforts in automated pipeline construction—for instance,
the Auto‑Pipeline system synthesizes transformation sequences by leveraging target table
representations and reinforcement‑learning-guided search,
achieving successful generation of 60–70% of complex pipelines @yang2021autopipeline.
Similarly, AlphaClean explores generative frameworks that combine operator libraries
with quality metric-driven search, producing robust cleaning pipelines without manual scripting @krishnan2019alphaclean.
Earlier work on component-based synthesis in PLDI-style systems demonstrates
how DSL blocks can be composed to perform table manipulation and consolidation from example inputs,
offering a conceptual blueprint for constructing Jayvee interpreters and loaders programmatically @feng2017component.
Finally, template systems such as the Variational Template Machine illustrate
how structured outputs can be automatically abstracted into reusable templates,
supporting the idea of deriving Jayvee “pipeline skeletons” from data‑derived schemas @ye2020variational.
The combined insight from these sources supports your implementation: by parsing CSV-based schema metadata
and mapping it to structured Jayvee DSL pipelines, your work bridges schema inference with executable,
user-friendly pipeline templates—extending schema-aware tabular reasoning into
practical data engineering artifacts.

== Conclusion

This literature review has traced a path from heuristic and rule-based methods
to modern transformer-based approaches for schema inference, prompt engineering, and pipeline synthesis.
The progression reflects a broader paradigm shift—from rigid, format-dependent techniques to flexible,
language-model-driven reasoning that can adapt to diverse and noisy data environments.

The limitations of early methods underscore a persistent gap: most classical approaches falter
in the face of structural irregularity, semantic ambiguity, and data heterogeneity common
in real-world CSV files. Modern techniques, particularly those involving prompt-based large language models
and retrieval-augmented systems, directly address these challenges.
They offer not only enhanced robustness and generalization,
but also the capacity for schema-compliant output generation without extensive fine-tuning
or labeled datasets.

Simultaneously, the field of automated pipeline synthesis has evolved from hand-crafted templates
and domain-specific heuristics to increasingly sophisticated DSL-based systems capable of translating
structural understanding into executable transformations.
Yet, the link between schema inference and downstream pipeline construction remains underdeveloped.

This thesis positions itself at the intersection of these research trajectories.
By focusing on the use of local LLMs for header detection in noisy CSVs and on translating inferred schema
into Jayvee-based transformation pipelines, it contributes both a practical framework
and a methodological lens for schema-aware automation.
The resulting system not only advances zero-shot tabular understanding under real-world constraints,
but also bridges structural interpretation with user-oriented pipeline design—pushing
the boundaries of interpretable, private, and accessible AI for data engineering.
