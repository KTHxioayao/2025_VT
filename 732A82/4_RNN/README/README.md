# Sequence-to-Sequence Machine Translation: Swedish → English

> Course project for **732A82 Deep Learning** at Linköping University

## Overview

An encoder–decoder model with Bahdanau attention that translates short Swedish sentences into English, trained on the Tatoeba/Anki parallel corpus.

## Architecture

```
Swedish input → Embedding (128d) → Bi-GRU (256 hidden) → Encoder output
                                                              ↓
              Bahdanau Attention ← Decoder hidden state ← Uni-GRU (256 hidden)
                     ↓
              Context vector + prev embedding → GRU step → Dense → English token
```

**Encoder**: Embedding layer (5,000 source tokens, 128 dims) followed by a bidirectional GRU (256 hidden units per direction → 512-dim output). A linear projection maps the concatenated final states down to 256 dims as the decoder's initial hidden state.

**Attention**: Bahdanau (additive) attention — computes alignment scores over all encoder positions, applies a source mask to ignore `<pad>` tokens, and returns a weighted context vector plus attention weights for visualization.

**Decoder**: Unidirectional GRU unrolled step-by-step. At each position, the previous token embedding is concatenated with the attention context vector, fed through the GRU, and projected to the target vocabulary (5,000 tokens). Trained with teacher forcing.

## Data

The [Tatoeba Project](https://tatoeba.org/en) Swedish–English sentence pairs (via [Anki](http://www.manythings.org/anki/)):
- Sentences ≤ 15 tokens (pre-tokenized with NLTK `toktok`)
- Four special tokens: `<pad>` (0), `<unk>` (1), `<bos>` (2), `<eos>` (3)
- Vocabularies: top 5,000 tokens per language, mapped via Keras `StringLookup`

## Evaluation

- **BLEU score** (via `sacrebleu`) computed on the validation set after each epoch
- Attention heatmaps visualized to inspect alignment between Swedish source tokens and English predictions — particularly interesting for sentences where word order differs between the two languages

## How to Run

```bash
# Open the notebook
jupyter notebook RNN_Lab.ipynb
```

Requires TensorFlow 2.x (GPU recommended), NumPy, Matplotlib, sacrebleu, NLTK.

## Key Takeaways

- Bahdanau attention substantially improves over a plain encoder–decoder by allowing the decoder to focus on relevant source positions at each generation step
- The attention weight heatmaps confirm that the model learns reasonable word-level alignments, including handling of Swedish–English word order differences
- With only 5k vocabularies and short sentences, the model trains quickly while still demonstrating core seq2seq concepts

## Author

**Xiaochen Liu** — Linköping University  
xiali125@student.liu.se
