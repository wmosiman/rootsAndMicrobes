# Root traits and microbes
Created: 2025-01-17 by Wyatt Mosiman

## Description
This repository was created to store files and work related to the population root microbiome project (a project of many names) led by Dr. Alicia Foxx. It was originally made by Wyatt Mosiman for building a semi-automated data extraction pipeline via LLMs, but could be expanded for use with other aspects of the project.


## Table of contents
1. [Description](#description)
1. [Table of contents](#table-of-contents)
1. [Useful links](#useful-links)
1. [About API Keys](#about-api-keys)
1. [LLM background info](#llm-background-info)
    a. [Vocab](#vocab)
    a. [General Knowledge](#general-knowledge)
    a. [Existing LLMs](#existing-llms)
    a. [Prompting](#prompting)
    a. [RAG (retrieval augmented generation)](#rag-(retreival-augmented-generation))
    a. [Fine tuning](#fine-tuning)
    a. [Using LLMs in R](#using-llms-in-r)
    a. [Further reading](#further-reading)
1. [PDF text extraction](#pdf-text-extraction)
    a. [Why convert PDF to text?](#why=convert-pdf-to-text?)
    a. [LlamaParse](#llamaparse)
    a. [Progress](#progress)


## Useful links
- [Main Google Drive folder](https://drive.google.com/drive/folders/13n5oNAA_4tZlhchlCmc5z0CIBpMomJJ-)
- [Root MA project map](https://docs.google.com/presentation/d/1v9bMP6py5EJiusGZSslJJxxM5KupGfdX/edit#slide=id.p1)
- [Team screening sheet](https://docs.google.com/spreadsheets/d/19eey5xnubweUFjWB6cQsIqWE0NVbR3iI/edit?usp=drive_web&ouid=107437607939897430548&rtpof=true)
- [Wyatt meeting notes](https://docs.google.com/document/d/1Ll896NO8CuWZX9OfZVd0EX9DRcJygswy/edit)
- [Semi-automated pipeline flowchart](https://miro.com/app/board/uXjVLwQZ-h8=/)


## About API Keys

[Application programming interface (API)](https://www.ibm.com/think/topics/api) and API keys are critical for integrating many types of software into your workflow. This section provides some brief background and best practices tips for working with API.

APIs are a way of connecting computers and computer programs. They're the communication link between a client (like you, me, or a program) and a server (some software). Universal logins are a good example of this; when you select the "login with Google" option on some third-party nothing-to-do-with-Google website, that website is using an API to interface with Google, securly communicating information to allow you to login with your Gmail account. APIs allow you to use programs designed by other people without seeing all the behind the scenes stuff, which is both useful to you (keeps things simple) and to the developers of the programs (keeps their secrets).

Oftentimes, to use an API, you will need an [API Key](https://www.fortinet.com/resources/cyberglossary/api-key). You can think of this like an ID badge: it is a unique identifier that gives you certain, specified permissions and tracks how it is used. And - like an ID badge, you want to keep it secure. Not just anyone should have access to it! One security measure is to limit the permissions of your API key to only what you need for a specific task or project. Another trick is to rotate them periodically, so you aren't using the same one forever. It's also important to not share them, so no copy pasting them directly into your code that others can see! What I did to keep keys hidden while still keeping it easy to call them in R was by storing my API keys locally, so they only exist on my computer's hard drive. Here's how to copy what I did:

1. Locate your .Renviron file (location differs by computer)
1. Add a line to your this file with something like: `MY_API_KEY = "myCopyPastedApiKey1234567654321"`
1. Save this file and restart your R session
1. You can now assign your API key to a variable in R with the following code: `apiKey <- Sys.getenv("MY_API_KEY")`



## LLM background info
### Vocab
There is a fair amount of unique terms that are thrown around when using LLMs, and it's good to know what they mean! Provided below are brief definitions, but follow the links to visit Google's machine learning glossary for further details.

- [Artificial intelligence](https://developers.google.com/machine-learning/glossary#artificial-intelligence): Non-human program that can complete complex tasks; LLMs fall under the AI umbrella
- [Bias](https://developers.google.com/machine-learning/glossary#bias-ethicsfairness): Just like people, LLMs can hold prejudices. These biases reflect the material the LLM was trained on, thus, LLMs tend to hold biases prevalent in the human world. Dang it!
- [Hallucination](https://developers.google.com/machine-learning/glossary#hallucination): When AI makes a false assertion as if it is fact (e.g., "The United States was founded in 1387"). LLMs like to be confident, so hallucinations can be hard to spot if not obvious, and can become a serious issue when left unaddressed.
- [Language model](https://developers.google.com/machine-learning/glossary#language-model): A program that estimates the probability of a token(s) appearing in a larger sequence of tokens
- [Large language model (LLM)](https://developers.google.com/machine-learning/glossary#large-language-model): Language models with a relatively high number of parameters
- [Self-attention](https://developers.google.com/machine-learning/glossary#self-attention-also-called-self-attention-layer): A way of scoring the relevance of a word to every other word around it. A key building block for how LLMs interpret context. 
- [Token](https://developers.google.com/machine-learning/glossary#token): The smallest unit of text a model trains and makes predictions on, typically a word, subword, or character

### General knowledge
Large language models (LLMs), such as [OpenAI's ChatGPT](https://platform.openai.com/docs/overview), [Google's Gemini](https://ai.google.dev/gemini-api/docs), and [Meta's Llama](https://www.llama.com/docs/get-started/) are tools, tools that are new enough that we're still figuring out how they work, when and where we can use them, and how to do so effectively. Generally, LLMs look at a series of tokens (an English word is, on average, ~1.5 tokens) and predict what token(s) are likely to follow or are missing. They do this by using self-attention, a form of evaluating the context of a word by determining its relevance to every other word around it. By training LLMs on countless sequences of tokens (think articles, papers, books, blogs, social media, you name it), they get pretty good at this context evaluation and prediction game. You can think of an LLM as similar to the auto-complete mechanism on a smartphone, only good enough to produce whole, coherent essays rather than just your next word.

We're interested in using LLMs to extract data from scientific papers. Specifically, we want to give an LLM a laundry list of data points we expect to be in the text of the methods section (e.g., study species, treatment, inocula taxa, etc.), have the LLM read the methods, and then perform the data entry. We are essentially looking to replace the work of human data enterers with AI. This has the potential to be pretty slick! It also has the potential to be tricky, given potential pitfalls such as hallucinations, biases, and costs (including financial, computational, and environmental). See the links below for some general background info:

- [Google's LLM crash course](https://developers.google.com/machine-learning/crash-course/llm)
  - Get a ~30 min background on the inner workings of an LLM
  - Not nitty gritty, maybe just nitty
- [ellmer's getting started guide](https://ellmer.tidyverse.org/articles/ellmer.html)
  - A guide to what we actually experience as users of LLMs
  - Given within the context of the ellmer package for R, which allows for integration of AI into R code

### Existing LLMs 
Despite being the most famous, ChatGPT is far from the only LLM available for use (as every company besides OpenAI would like you to be aware of). Here are descriptions and comparisons of the primary contenders for our use:

#### [GPT-4o](https://platform.openai.com/docs/models#gpt-4o)
Your standard ChatGPT LLM.

#### [GPT-4o mini](https://platform.openai.com/docs/models#gpt-4o-mini)
A miniature model of GPT-4o which is cheaper good for fine tuning for specific tasks

#### [o1-mini](https://platform.openai.com/docs/models#o1)
Model that "thinks" before it answers using an extensice internal thought chain. Good for fine tuning for complex tasks, but more expensive

#### [Claude 3.5 Sonnet](https://docs.anthropic.com/en/docs/about-claude/models#model-comparison-table)
Most intelligent and capable Anthropic model

#### [Claude 3.5 Haiku](https://docs.anthropic.com/en/docs/about-claude/models#model-comparison-table)
Fastest Anthropic model

#### [Gemini 1.5 Pro](https://ai.google.dev/gemini-api/docs/models/gemini#gemini-1.5-pro)
Optimized for wide range of reasoning tasks

#### [Gemini 1.5 Flash](https://ai.google.dev/gemini-api/docs/models/gemini#gemini-1.5-flash)
Fast and versatile for diverse tasks

#### [AQA](https://ai.google.dev/gemini-api/docs/models/gemini#aqa)
Designed for asking question about a document and getting answers grounded in the provided source for minimizing hallucinations

- Designed with saying "I don't know" in mind
- Maybe what notebook LM is based on? unclear

#### [Llama 3.3](https://github.com/meta-llama/llama-models/blob/main/models/llama3_3/MODEL_CARD.md)
Pretrained versions can be effectively adapted to specific language tasks


#### [Llama 3.2](https://github.com/meta-llama/llama-models/blob/main/models/llama3_2/MODEL_CARD.md)
Instruction-tuned models are intended for applications including knowledge retrieval and summarization


#### [Llama 3.2-Vision](https://github.com/meta-llama/llama-models/blob/main/models/llama3_2/MODEL_CARD_VISION.md)
Adapted for analyzing and answering questions about an image

#### [Deepseek V3](https://github.com/deepseek-ai/DeepSeek-V3)
Primary DeepSeek model. Uses context caching to lower costs.

#### [DeepSeek R1](https://github.com/deepseek-ai/DeepSeek-R1)
A model that uses chain-of-thought reasoning, similar strategy and performance to GPT-o1 and o1-mini. Uses context caching to lower costs.


#### Comparison table

| Company   | Model             | Context window (tokens) | Max output (tokens) | Input price (per M tokens) | Output price (per M tokens) | Open source | Text only |
| :------   | :-----            | ----------------------: | ------------------: | -------------------------: | --------------------------: | :---------: | :-------: |
| OpenAI    | GPT-4o            | 128,000                 | 16,384              | $2.50                      | $10.00                      | FALSE       | FALSE     | 
| OpenAI    | GPT-4o mini       | 128,000                 | 16,384              | $0.15                      | $0.60                       | FALSE       | FALSE     |
| OpenAI    | o1-mini           | 200,000                 | 100,000             | $3.00                      | $12.00                      | FALSE       | FALSE     |
| Anthropic | Claude 3.5 Sonnet | 200,000                 | 8,192               | $3.00                      | $15.00                      | FALSE       | FALSE     |
| Anthropic | Claude 3.5 Haiku  | 200,000                 | 8,192               | $0.80                      | $4.00                       | FALSE       | FALSE     |
| Google    | Gemini 1.5 Pro    | 2,097,152               | 8,192               | Free (to an extent)        | Free (to an extent)         | FALSE       | FALSE     |
| Google    | Gemini 1.5 Flash  | 1,048,576               | 8,192               | Free (to an extent)        | Free (to an extent)         | FALSE       | FALSE     |
| Google    | AQA               | 7,168                   | 1,024               | ????                       | ????                        | FALSE       | TRUE      |
| Meta      | Llama 3.3         | 128,000                 | ????                | Free                       | Free                        | TRUE        | TRUE      |
| Meta      | Llama 3.2         | 8k-128k                 | ????                | Free                       | Free                        | TRUE        | TRUE      |
| Meta      | Llama 3.2-Vision  | 128,000                 | ????                | Free                       | Free                        | TRUE        | FALSE     |
| DeepSeek  | DeepSeek V3       | 64,000                  | 8,000               | $0.07-$0.27                | $1.10                       | TRUE        | FALSE     |
| DeepSeek  | DeepSeek R1       | 64,000                  | 8,000               | $0.14-$0.55                | $2.19                       | TRUE        | FALSE     |

- Last updated 2025-01-24 wm
- [Google Gemini pricing](https://ai.google.dev/pricing#1_5pro)


### Prompting


### RAG (retrieval-augmented generation)


### Fine tuning


### Using LLMs in R


### Further reading



## PDF text extraction
### Why convert pdf to text?


### Manual
I tried manual text extraction with 22 studies that Alicia had already marked as suitable and had extracted the methods data for. This took me 30 minutes on the dot, including one study where copy-paste did not work at all (Brunner 2001, indicated with [UNABLE TO COPY TEXT]). These studies will give us a baseline to evaluate the efficacy of the LLMs' extraction abilities.

I created 2 folders in the google drive, one a collection of the PDFs of the suitable studies and the other full of txt files with names corresponding to each of the studies. I did this manually, but this could be automated if we wanted to do this at scale. I opened one study's pdf and txt file (using google txt editor) and copied over the paper title, the methods section header, and all the text contained in that section. I omitted figures, headers and footers, etc. I copied one column at a time, adding a space or new line where appropriate in between pastes. Otherwise I did not do any beautification of the results. The timer started when I opened the first files and ended when I copied and saved the last copy paste.


### LlamaParse


### Progress

