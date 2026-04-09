# Vision Transformer (ViT) from Scratch — CIFAR-10 Classification

> Course project for **732A82 Deep Learning** at Linköping University

## Overview

A full Vision Transformer implemented from scratch in TensorFlow/Keras, trained on CIFAR-10. The project builds every component manually — from scaled dot-product attention up to the complete ViT classifier — and compares it against a CNN baseline in both accuracy and carbon footprint.

## Architecture

The ViT follows the original paper ([Dosovitskiy et al., 2020](https://arxiv.org/abs/2010.11929)) with these components built from scratch:

```
Input image (32×32×3)
  → PatchExtraction (patch_size=16 → 4 patches)
  → PatchEncoder (linear projection to 768d + learnable positional embeddings + CLS token)
  → 12× Transformer Encoder Layers
       ├── Multi-Head Self-Attention (12 heads, 768d)
       ├── Layer Normalization + Residual Connection
       ├── MLP (feed-forward)
       └── Layer Normalization + Residual Connection
  → CLS token → MLP Classification Head (3074 units) → 10 classes
```

**Model config**: `patch_size=16`, `embedding_dim=768`, `num_heads=12`, `transformer_layers=12`, `msa_dropout=0.1` — ~371M parameters.

## Components Implemented

| Component | Description |
|-----------|-------------|
| **Scaled Dot-Product Attention** | `softmax(QK^T / √d_k) · V` with optional masking |
| **Multi-Head Self-Attention** | Parallel attention heads with separate Q/K/V projections, concatenated and linearly projected |
| **Transformer Encoder Layer** | MHSA → Add & LayerNorm → MLP → Add & LayerNorm |
| **PatchExtraction** | Splits input images into non-overlapping patches (Keras layer) |
| **PatchEncoder** | Linear projection of flattened patches + learnable positional embeddings + prepended CLS token |
| **ViT Classifier** | Full stack: PatchExtraction → PatchEncoder → N × Encoder Layer → CLS → MLP head |

## Data

CIFAR-10 (60,000 32×32 color images, 10 classes):
- 75/25 train/validation split via `train_test_split`
- Normalized to [-1, 1] range (float32)
- Labels as integers (not one-hot)

## Evaluation & Findings

- **Accuracy**: Compared ViT vs. CNN baseline trained under identical conditions
- **Carbon footprint**: Measured energy consumption (kWh) and CO₂ emissions — ViT had a significantly higher footprint due to the ~371M parameter count vs. the much smaller CNN
- **Regularization analysis**: Discussed data augmentation (not applied in this lab but used in CNN lab) as a potential improvement for ViT generalization on small datasets
- **Segmentation potential**: Explored how patch-level outputs (rather than CLS-only) could be repurposed for dense prediction tasks
- **Pre-trained ViT**: Loaded a HuggingFace pre-trained ViT model for comparison on natural images

## How to Run

```bash
# Ensure utilities.py is in the same directory
jupyter notebook Vision_transformers.ipynb
```

Requires TensorFlow 2.x (GPU recommended), NumPy, Matplotlib, scikit-learn, HuggingFace `transformers` (for pre-trained model section).

## Key Takeaways

- Building attention from scratch clarifies the relationship between Gaussian kernels and the scaled dot-product formulation
- Self-attention in ViT computes attention over all patches simultaneously (O(n²)), unlike the sequential Bahdanau attention in RNNs
- ViTs are data-hungry — on small datasets like CIFAR-10 without heavy augmentation, CNNs can match or outperform ViTs at a fraction of the compute cost
- Residual connections and layer normalization are essential for training deep transformer stacks

## Author

**Xiaochen Liu** — Linköping University  
xiali125@student.liu.se
