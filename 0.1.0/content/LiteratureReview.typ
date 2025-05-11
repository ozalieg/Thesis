#import "@preview/abbr:0.2.3"
#import "../utils/todo.typ":*

= Literature Review

== Prompt Engineering

- Lower Cost and Resource Requirements:
    Running a prompt is less resource-intensive than fine-tuning a #abbr.add("LLM", "Large Language Model") #abbr.a[LLM] @PORNPRASIT2024107523 @shin2025promptengineeringfinetuningempirical.
    Fine-tuning requires significant resources and computing power, which can be expensive @PORNPRASIT2024107523. Prompt engineering is generally more accessible and practical, especially in environments with limited resources @PORNPRASIT2024107523.
- No Requirement for Labeled Datasets: Prompting has advantages over fine-tuning because it does not require labeled datasets, which are costly to acquire @PORNPRASIT2024107523 @shin2025promptengineeringfinetuningempirical. Prompt engineering can adapt pre-trained language models without needing a supervised dataset @PORNPRASIT2024107523.
- Accelerated Application Development: LLMs leveraged through prompt engineering can speed up application development, achieving decent performance @shin2025promptengineeringfinetuningempirical @make6010018. It facilitates the building of AI systems without the need for ML model training or supervision @shin2025promptengineeringfinetuningempirical.
- Avoids Fine-Tuning Issues: Prompt engineering reduces the need for expensive computational costs and challenges like catastrophic forgetting associated with fine-tuning specialized models @shin2025promptengineeringfinetuningempirical. Catastrophic forgetting occurs when models lose some of their previously learned skills while learning new domain-specific information @shin2025promptengineeringfinetuningempirical.
- Decent or Even Superior Performance in Certain Scenarios: While fine-tuning generally leads to better performance @PORNPRASIT2024107523, the performance achieved with prompt engineering is remarkable considering no specific training is conducted @PORNPRASIT2024107523. In some cases, such as medical Question & Answer tasks with Open-Source models, prompt engineering alone can outperform fine-tuning @zhang2024comparison. GPT-3.5-turbo significantly outperformed other approaches in specific multi-party dialogue tasks when using a 'reasoning' style prompt in a few-shot setting @addlesee2023multipartygoaltrackingllms. Prompt Engineering, when effectively harnessed, can even outperform fine-tuned specialized models like PubMedBERT for tasks such as identifying metastatic cancer @zhang2024comparison. It can also help leverage the versatile capabilities of LLMs @PORNPRASIT2024107523.
- Robustness and Flexibility: Prompt engineering offers flexibility @PORNPRASIT2024107523. GPT-4 demonstrated remarkable resilience when using prompt engineering for metastatic cancer identification, maintaining performance even when keywords or a significant percentage of tokens were removed from the input text @zhang2024comparison. Using concise output instructions can facilitate downstream processing @zhang2024comparison. Different prompting techniques (zero-shot, few-shot/in-context, role-playing, chain-of-thought, task-specific, conversational) can be applied in zero-shot or few-shot settings to guide the model @addlesee2023multipartygoaltrackingllms @shin2025promptengineeringfinetuningempirical @zhang2024comparison @make6010018 @maharjan2024openmedlm. Conversational prompting, which includes human feedback, shows potential for improving results @shin2025promptengineeringfinetuningempirical.
#TODO("Requirements
IEEE 830-style requirements engineering
Architecture
IEEE 42010 (architecture description)
C4 model (Context → Container → Component → Code)
RUP and TOGAF methodologies")