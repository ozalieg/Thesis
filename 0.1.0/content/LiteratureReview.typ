#import "@preview/abbr:0.2.3"
#import "../utils/todo.typ":*

= Literature Review

This literature review surveys foundational and emerging approaches to schema inference,
prompt engineering, retrieval-augmented reasoning, multimodal table understanding,
and automated pipeline synthesis—each directly informing the dual focus of this thesis.
The first half of the review evaluates how classical heuristics, machine learning,
and #abbr.pla[LLM] address the challenge of detecting header rows
and semantic structure in noisy CSV files, aligning with the thesis’ empirical study
on local #abbr.a[LLM]-based schema inference. It then explores advances in prompt engineering
and retrieval-augmented models, both central to enhancing zero-shot performance without fine-tuning.
The second half pivots to pipeline generation,
highlighting #abbr.a[DSL] frameworks like Jayvee
and automated systems such as Auto-Pipeline and AlphaClean,
which contextualize the design of this thesis’ template generation engine.
Together, these works underscore the relevance and novelty of integrating schema-aware
interpretation with #abbr.a[DSL]-based pipeline synthesis for real-world tabular data processing.

== Prompt Engineering

Prompt engineering offers significant advantages over fine-tuning, especially in terms of cost, resource requirements, and adaptability.
Executing a well-crafted prompt is significantly less resource-intensive than full model fine-tuning,
which can be prohibitively expensive in compute and data requirements—particularly when working with #abbr.pla[LLM].
It also bypasses the need for labeled datasets, leveraging the pre-trained model’s knowledge directly without supervised training data (Pornprasit et al., 2024 @Pornprasit2024; Shin et al., 2025 @Shin2025).

While fine-tuning still generally yields higher peak performance, prompt engineering can achieve surprising effectiveness in certain applications.
For example, in medical question-answering tasks using GPT‑4, few-shot prompting with structured reasoning steps not only matched but occasionally
surpassed the performance of fine-tuned baselines such as PubMedBERT, even under stringent conditions like removal of key input tokens (Zhang et al., 2024 @Zhang2024).
In code-domain benchmarks, careful prompting strategies have demonstrated competitive BLEU scores compared to fine-tuned models,
especially when human feedback is integrated conversationally (Smock et al., 2023 @Smock2023; Shin et al., 2023 @Shin2023).

Prompt-based methods also exhibit greater flexibility and robustness:
models like GPT‑4 maintain performance stability even with significant prompt perturbations or content omission,
and are compatible with diverse prompting styles—including zero-shot, few-shot, chain-of-thought,
and conversational formats—making them highly adaptable for varied downstream tasks (Zhang et al., 2024 @Zhang2024).


== Schema Inference and Tabular Data Understanding

=== Heuristic and Rule-Based Methods for Header Detection

Early approaches to schema inference in tabular data primarily relied on heuristic and rule-based methods.
HUSS, a heuristic algorithm for understanding the semantic structure of spreadsheets,
exemplifies this class of techniques by leveraging layout and formatting cues such as font style and alignment to infer header roles,
operating effectively under assumptions of consistent structure (Wu et al., 2023 @Wu2023).
Similarly, Fang et al. present a rule-based classifier for header detection in digital libraries that utilizes features like
 pairwise similarity between consecutive rows—a classic form of pattern recognition—to distinguish between header and data regions (Fang et al., 2012 @Fang2012).
 Milosevic et al. adopt a multi-layered approach that integrates functional and structural heuristics with machine learning,
 thereby acknowledging and partially addressing the limitations of purely rule-based strategies when faced with complex table layouts (Milošević, 2018 @milovsevic2018).

These early methods generally assumed well-formed, homogeneous data structures with clearly defined headers and uniform formatting across rows.
In practice, however, such assumptions rarely hold. HUSS, for instance,
shows diminished performance when applied to spreadsheets with noisy layouts or ambiguous header usage,
underscoring the brittleness of heuristic approaches under real-world conditions (Wu et al., 2023 @Wu2023).
Fang et al. similarly note the challenge of generalizing across diverse table styles,
especially when extraneous metadata or multi-row headers are present (Fang et al., 2012 @Fang2012).
Milosevic et al. explicitly highlight the difficulties posed by visual and semantic
variability in biomedical tables, motivating their integration of learning-based components as a means of enhancing robustness (Milošević, 2018 @milovsevic2018).

In summary, while classical rule-based methods like HUSS and those proposed by Fang and Milosevic demonstrate utility under idealized conditions,
their reliance on structural consistency and formatting regularity often limits applicability.
As files increasingly include comments, metadata, or inconsistent row structures, these techniques encounter substantial challenges in header row detection
and schema generation—a gap that modern machine learning methods seek to address.

=== Machine Learning Approaches

With the advent of machine learning, researchers began exploring more robust methods for schema inference.
Strudel, developed by Koci et al. in 2016 @Koci2016, is a supervised learning approach designed
to detect structure in verbose CSV files.
It employs a random forest classifier and introduces novel features categorized into content,
contextual, and computational types.
These features enable the system to classify lines and cells effectively, even in noisy datasets.
The approach has been evaluated on real-world datasets, demonstrating its efficacy in header detection tasks.

Similarly, Khusro et al. (2018) developed a supervised classification model for header detection in PDFs.
Their method leverages textual and layout features, such as bounding box and whitespace cues,
combined with a decision-tree classifier.

Both Strudel and Khusro et al.'s methods represent significant advancements in schema inference,
combining supervised learning with heuristic strategies to address the challenges posed by noisy
and complex data formats. While they rely on labeled training data and handcrafted rules,
they paved the way for more sophisticated approaches, including those utilizing large
language models, which offer enhanced flexibility and generalization capabilities.
It uses content-based, contextual, and computational features—and includes
post-processing steps to correct classification
errors—significantly improving header row detection in noisy datasets (Koci et al., 2016 @Koci2016).

Likewise, Budhiraja et al. (2018) @Budhiraja2018 developed a supervised classification model for header detection in PDFs,
leveraging textual and layout features (like bounding box and whitespace cues) with a decision-tree classifier that showed strong performance
after a repair-oriented post-processing stage. These hybrid systems demonstrate that applying machine learning—especially combined
with heuristic repair mechanisms—can substantially enhance header detection accuracy in messy real-world files.

While machine learning strategies like Strudel and the work by Budhiraja et al. enhanced schema inference by combining supervised classification with heuristic post-processing
 — they still relied on labeled training data and handcrafted rules — modern #abbr.pla[LLM] offer a transformative advancement.

=== Modern Techniques Leveraging Language Models

Recent advancements have brought #abbr.pla[LLM] into schema inference workflows,
enabling powerful new capabilities in table understanding.
In Schema‑Driven Information Extraction from Heterogeneous Tables,
Bai et al. (2024) reformulate schema inference as a structured extraction task:
given a JSON schema and a noisy table, instruction-tuned #abbr.pla[LLM] like GPT‑4
and Code‑Davinci output structured JSON records.
They report impressive F1 scores from 74.2% to 96.1%, matching
or exceeding traditional supervised systems—all without any task-specific training (Bai et al., 2024 @Bai2024).

Further, Wu et al. (2025) apply LLMs to taxonomy inference over table data,
showing these models consistently reconstruct hierarchical entity types that align closely
with gold-standard ontologies, outperforming classic lexical-structural methods in consistency
and semantic accuracy (Wu et al., 2025 @Wu2025).

These instruction-following transformers thus provide schema-aware parsing
across contexts and noise levels—even handling multi-row headers or missing delimiters—far
surpassing feature-engineered ML pipelines.


==== Retrieval-Augmented Language Models and Context Injection

#abbr.add("RALM","Retrieval-augmented language models") #abbr.pla[RALM] like DeepSeek Coder enhance reasoning
and disambiguation in data tasks by integrating external knowledge sources at inference time.
DeepSeek Coder employs a multi-stage training process—including cold-start data,
supervised fine-tuning, and #abbr.add("RLHF","reinforcement learning with human feedback") #abbr.a[RLHF]
—that enhances its ability to reason over structured and semi-structured inputs such as tables
and CSV files.
This augmentation strategy allows models to dynamically pull in domain-relevant information,
which improves both factual accuracy and interpretability in schema inference tasks (Deepseek-AI, 2024 @Deepseek-AI2024).

In header detection for noisy CSV files, #abbr.pla[RALM] can use retrieval to resolve ambiguous or missing context.
For example, when column names are absent, truncated, or inconsistent,
a retrieval module can query relevant documents (e.g., documentation, similar datasets,
or metadata repositories) to infer likely schema roles.
This makes retrieval-enhanced models significantly more robust than static models
that rely solely on training-set priors.
Practical implementations, including experiments involving DeepSeek Coder
with LangChain or LangGraph frameworks, have demonstrated that recursive retrieval
pipelines improve disambiguation and classification in real-world CSV tasks (Deepseek-AI, 2024 @Deepseek-AI2024).

Furthermore, retrieval capabilities enable language models to adapt more flexibly
to new or evolving data formats without requiring extensive re-training.
Unlike fixed classifiers, #abbr.pla[RALM] like
DeepSeek Coder use #abbr.add("RAG","retrieval-augmented generation") #abbr.a[RAG]
to externalize parts of the reasoning process, leading to better generalization
in unseen formats or edge cases.
This makes them especially suited to schema inference applications,
where file variability, semantic ambiguity, and format drift are common (Deepseek-AI, 2024 @Deepseek-AI2024).

==== Multi-modal Models for Tabular Data Analysis

Recent work has focused on large multimodal models such as Qwen3-4B,
which can jointly process text, table structures, and images.
These models demonstrate strong capabilities in understanding complex table layouts and semantic
content by integrating visual and textual modalities.
The PubTables-1M dataset, containing nearly one million tables,
has enabled training of such multimodal models and demonstrated that
transformer-based object-detection architectures improve detection,
structure recognition, and functional analysis across diverse domains without
requiring specialized architectures (QwenLM, 2024 @QwenLM2024).

Nonetheless, even state-of-the-art multimodal LLMs like Qwen3-4B struggle
with reconstructing table structures reliably, especially from images alone,
highlighting the necessity for improved visual grounding and spatial reasoning @QwenLM2024.

==== Instruction-Tuned Models for Code and Table Tasks

Instruction-tuned language models, such as CodeLlama-7B-Instruct,
demonstrate strong performance in both code understanding and schema-oriented prompting.
CodeLlama‑7B‑Instruct is a variant of Meta's Code Llama family,
fine-tuned to follow natural language instructions rather than only generate code.
It inherits from the Llama 2 architecture and was further trained on approximately 500 billion tokens of code,
followed by ~5 billion tokens of instruction tuning to improve compliance with developer directives (Rozière et al., 2024 @Roziere2024; Meta AI, 2024 @Meta2024).

As an autoregressive transformer, CodeLlama 7B‑Instruct supports code completion,
 infilling between code snippets, and instruction-driven generation across multiple
 languages—including Python, C++, JavaScript, and more.
 Critically, it features a long context window of up to 100k tokens,
 enabling it to handle large tables or long scripts in a single prompt—an essential
 capability for batch schema inference tasks (Meta AI, 2024 @Meta2024).

Meta-released benchmark evaluations on HumanEval and MultiPL-E datasets indicate
that CodeLlama models achieve state-of-the-art performance among open-source models,
with pass\@k scores comparable to LLaMA alternatives.
The instruction-tuned variant further improves functional accuracy and compliance,
making it suitable for structured generation—such as converting CSV headers into DSL schema definitions (Rozière et al., 2024 @Roziere2024).

Importantly, CodeLlama‑7B‑Instruct supports fill‑in‑the‑middle infilling and boasts
a long‑context window of up to 100k tokens, enabling it to generate, explain,
and manipulate large code blocks or tables in one prompt—an essential capability
for schema inference workflows (Meta AI, 2024 @Meta2024).

Performance benchmarks show CodeLlama‑7B‑Instruct achieves near‑state‑of‑the‑art
results among open-source code models.
The full CodeLlama family outperforms comparable LLaMA‑2 baselines on benchmarks such as HumanEval,
 MBPP, and MultiPL‑E, with the “Instruct” variant demonstrating enhanced
 functional accuracy and instruction compliance—qualities ideal
 for structured schema generation in tabular and DSL contexts (Meta AI, 2024 @Meta2024).

In schema inference, this model’s instruction‑tuned design allows prompts
like “extract header row as JSON schema” or “fill missing schema cell based on context,”
enabling interpreters to process complete table segments in a single pass.
Its long‑context capability avoids errors from prompt truncations (Meta AI, 2024 @Meta2024).

=== Extending Prior Work: Local LLMs for Noisy CSV Header Detection

In light of these developments, this thesis positions itself at the intersection
of prompt-based schema inference and pipeline automation for tabular data,
responding directly to critical gaps in the literature.

While traditional heuristic and rule-based systems offer some utility in idealized contexts,
their effectiveness sharply declines under the noise and irregularity characteristic of real-world CSV files.
Instruction-following #abbr.pla[LLM] such as DeepSeek Coder, Qwen3-4B,
and lCodeLlama-7B-Instruct demonstrate promising zero-shot capabilities
in discerning header rows and tabular semantics, even under structural ambiguity (Deepseek-AI, 2024 @Deepseek-AI2024; QwenLM, 2024 @QwenLM2024; Meta AI, 2024 @Meta2024).
Locally hosted #abbr.pla[LLM] offer privacy-preserving and cost-effective schema inference workflows that operate entirely offline, an underexplored but increasingly important deployment paradigm (Deepseek-AI, 2024 @Deepseek-AI2024).

Moreover, while much current research emphasizes cloud-based LLM systems,
 this work evaluates model performance in a local execution context,
 where hardware limitations and model optimization constraints present unique challenges.
 This brings empirical clarity to the practical feasibility of deploying
 such models for tabular understanding outside of centralized, compute-rich infrastructures (Deepseek-AI, 2024 @Deepseek-AI2024; QwenLM, 2024 @QwenLM2024; Meta AI, 2024 @Meta2024).

The thesis also introduces a template generation engine for Jayvee pipelines,
extending focus from structural understanding to operational synthesis.
By treating noisy tabular inputs as both targets for structural interpretation
and sources for generating executable, user-friendly transformation pipelines,
it proposes a holistic approach to data usability engineering for users with
limited technical expertise.

Together, this work advances the field by (1) evaluating LLM generalization boundaries
in schema inference under realistic constraints, and (2) designing a DSL-centric automation
layer that translates understanding into actionable pipelines,
offering a practical system architecture for next-generation
tabular data interfaces.


== Automated DSL-based Pipeline Synthesis

Building upon the discussion of schema inference,
the second stream of this thesis focuses on template-driven pipeline
synthesis using Jayvee’s domain-specific language.
Empirical evaluation of Jayvee has demonstrated that DSL-based workflows significantly lower the barrier
to pipeline creation for non-professional developers,
improving both development speed and comprehension of data architectures (Heltweg et al., 2025 @Heltweg2025).
This aligns with broader efforts in automated pipeline construction—for instance,
the Auto‑Pipeline system synthesizes transformation sequences by leveraging target table
representations and reinforcement‑learning-guided search,
achieving successful generation of 60–70% of complex pipelines (Yang et al., 2021 @Yang2021).

Similarly, AlphaClean explores generative frameworks that combine operator libraries
with quality metric-driven search, producing robust cleaning pipelines without manual scripting (Krishnan et al., 2019 @Krishnan2019).

Earlier work on component-based synthesis in PLDI-style systems—
so named for their roots in the #abbr.add("PLDI","Programming Language Design and Implementation") #abbr.a[PLDI]
research community—demonstrates how #abbr.a[DSL] blocks can be composed
to perform table manipulation and consolidation from example inputs,
offering a conceptual blueprint for constructing Jayvee interpreters and loaders programmatically (Feng et al., 2017 @Feng2017).
These systems typically emphasize modularity, compositionality, and example-driven synthesis,
leveraging structured DSLs and formal semantics to generate programs that satisfy user-specified
constraints or data transformations.
Jayvee, by using templates and schema-driven synthesis, aligns with this ethos—especially
in how data schemas map to composable pipeline fragments, enabling non-expert users
to build robust workflows programmatically.

Finally, template systems such as the Variational Template Machine illustrate
how structured outputs can be automatically abstracted into reusable templates,
supporting the idea of deriving Jayvee “pipeline skeletons” from data‑derived schemas (Ye et al., 2020 @Ye2020).
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
