# Root traits and microbes
Created: 2025-01-17 by Wyatt Mosiman

## Description
This repository was created to store files and work related to the population root microbiome project (a project of many names) led by Dr. Alicia Foxx. It was originally made by Wyatt Mosiman for building a semi-automated data extraction pipeline via LLMs, but could be expanded for use with other aspects of the project.


## Table of contents
1. [Description](#description)
1. [Table of contents](#table-of-contents)
1. [Useful links](#useful-links)
1. [LLM background info](#llm-background-info)
1. [PDF text extraction](#pdf-text-extraction)


## Useful links
- [Main Google Drive folder](https://drive.google.com/drive/folders/13n5oNAA_4tZlhchlCmc5z0CIBpMomJJ-)
- [Root MA project map](https://docs.google.com/presentation/d/1v9bMP6py5EJiusGZSslJJxxM5KupGfdX/edit#slide=id.p1)
- [Team screening sheet](https://docs.google.com/spreadsheets/d/19eey5xnubweUFjWB6cQsIqWE0NVbR3iI/edit?usp=drive_web&ouid=107437607939897430548&rtpof=true)
- [Wyatt meeting notes](https://docs.google.com/document/d/1Ll896NO8CuWZX9OfZVd0EX9DRcJygswy/edit)
- [Semi-automated pipeline flowchart](https://miro.com/app/board/uXjVLwQZ-h8=/)


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



| Company   | Model             | Parameter count | Context window (tokens) | Max output (tokens) | Input price (per M tokens) | Output price (per M tokens) | Open source | Text only |
| :------   | :-----            | --------------: | ----------------------: | ------------------: | -------------------------: | --------------------------: | :---------: | :-------: |
| OpenAI    | GPT-4o            |                 | 128,000                 | 16,384              | $2.50                      | $10.00                      | FALSE       | FALSE     | 
| OpenAI    | GPT-4o mini       |                 | 128,000                 | 16,384              | $0.15                      | $0.60                       | FALSE       | FALSE     |
| OpenAI    | o1-mini           |                 | 200,000                 | 100,000             | $3.00                      | $12.00                      | FALSE       | FALSE     |
| Anthropic | Claude 3.5 Sonnet |                 | 200,000                 | 8,192               | $3.00                      | $15.00                      | FALSE       | FALSE     |
| Anthropic | Claude 3.5 Haiku  |                 | 200,000                 | 8,192               | $0.80                      | $4.00                       | FALSE       | FALSE     |
| Google    | Gemini 1.5 Pro    |                 | 2,097,152               | 8,192               | Free (to an extent)        | Free (to an extent)         | FALSE       | FALSE     |
| Google    | Gemini 1.5 Flash  |                 | 1,048,576               | 8,192               | Free (to an extent)        | Free (to an extent)         | FALSE       | FALSE     |
| Google    | AQA               |                 | 7,168                   | 1,024               | ????                       | ????                        | FALSE       | FALSE     |


[Google Gemini pricing](https://ai.google.dev/pricing#1_5pro)


Last updated 2025-01-23 wm


### Prompting


### RAG (retrieval-augmented generation)


### Fine tuning


### Using LLMs in R


### Further reading



## PDF text extraction
### Why convert pdf to text?


### LlamaParse


### Progress

