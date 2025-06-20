# MLX Models Guide for Mac Silicon

This document provides detailed instructions for downloading, converting, and working with models in MLX for Apple Silicon Macs.

## Available Models

MLX-LM supports a variety of open-source large language models:

| Model Family | Sizes | Specialized Versions | Best For |
|--------------|-------|----------------------|----------|
| LLaMA 2 | 7B, 13B, 70B | Chat, Instruct | General purpose, instruction following |
| Mistral | 7B | Instruct | Excellent performance at smaller size |
| Phi | 1.5B, 2.7B | Instruct | Compact but capable |
| Gemma | 2B, 7B | Instruct | Google's efficient models |
| Vicuna | 7B, 13B | - | Conversational |
| StableLM | 3B | - | Lightweight |
| Falcon | 7B, 40B | - | Research |
| OLMo | 7B | - | Research |

## Model Selection Guide

### By System Specifications

| Mac Configuration | RAM | Recommended Models | Quantization |
|-------------------|-----|-------------------|--------------|
| MacBook Air M1/M2 | 8GB | Phi-2, Gemma-2B, 7B models | INT4 only |
| MacBook Pro M1/M2 | 16GB | 7B models, 13B with quantization | INT8 for 7B, INT4 for 13B |
| MacBook Pro M1/M2 | 32GB | 7B-13B models | FP16 or INT8 |
| Mac Studio/Pro | 64GB+ | Any model | FP16 for most, INT8 for 70B |

### By Use Case

| Use Case | Recommended Models | Notes |
|----------|-------------------|-------|
| General assistant | Llama-2-7b-chat, Mistral-7B-Instruct | Good balance of capability and efficiency |
| Code generation | Phi-2, CodeLlama | Specialized for code tasks |
| Technical writing | Llama-2-13b-chat | Better reasoning capabilities |
| Creative writing | Mistral-7B, Llama-2-7b | Good generative capabilities |
| Knowledge tasks | Gemma-7B, Llama-2-13b | Strong factual knowledge |
| Resource-constrained | Phi-2, Gemma-2B | Excellent small models |

## Downloading Models

### Using MLX-LM Download Tool

The easiest way to download models is using the built-in download tool:

```bash
# Basic syntax
python -m mlx_lm.download --model <model_name>

# Examples
python -m mlx_lm.download --model llama-2-7b
python -m mlx_lm.download --model mistral-7b-v0.1
python -m mlx_lm.download --model phi-2
python -m mlx_lm.download --model gemma-2b
```

Available pre-converted models:
- `llama-2-7b` - Meta's LLaMA 2 7B base model
- `llama-2-7b-chat` - LLaMA 2 7B chat version
- `llama-2-13b` - Meta's LLaMA 2 13B base model
- `llama-2-13b-chat` - LLaMA 2 13B chat version
- `mistral-7b-v0.1` - Mistral AI's 7B base model
- `mistral-7b-instruct-v0.1` - Mistral 7B instruct version
- `phi-2` - Microsoft's Phi-2 model
- `gemma-2b` - Google's Gemma 2B base model
- `gemma-2b-instruct` - Gemma 2B instruct version
- `gemma-7b` - Google's Gemma 7B base model
- `gemma-7b-instruct` - Gemma 7B instruct version

### Using Our Helper Script

For convenience, we provide a helper script that includes error handling and logging:

```bash
# Navigate to your MLX runtime directory
cd mlx-runtime

# Download a model
./scripts/download-model.sh llama-2-7b
```

### Download Location

Models will be downloaded to your current working directory. For our setup, they will be stored in:

```
mlx-runtime/
├── llama-2-7b/        # Model directory
│   ├── config.json    # Model configuration
│   ├── tokenizer.json # Tokenizer configuration
│   └── weights.safetensors # Model weights
```

## Converting Models from Hugging Face

If you want to use a model that's not pre-converted, you can convert it from Hugging Face:

### Using MLX-LM Convert Tool

```bash
# Basic syntax
python -m mlx_lm.convert --hf-path <huggingface_model_id> --mlx-path <output_dir>

# Examples
python -m mlx_lm.convert --hf-path meta-llama/Llama-2-7b --mlx-path llama-2-7b-custom
python -m mlx_lm.convert --hf-path bigscience/bloom-560m --mlx-path bloom-560m
```

For models requiring authentication (like LLaMA 2):

1. Create a Hugging Face account and request access to the model
2. Log in via the Hugging Face CLI:
   ```bash
   pip install huggingface_hub
   huggingface-cli login
   ```
3. Then run the conversion

### Using Our Helper Script

We provide a helper script for model conversion:

```bash
# Navigate to your MLX runtime directory
cd mlx-runtime

# Convert a model
./scripts/convert-model.sh meta-llama/Llama-2-7b llama-2-7b-custom
```

### Supported Model Architectures

MLX-LM supports converting these architectures from Hugging Face:
- LLaMA/LLaMA 2
- Mistral
- Phi/Phi-2
- Gemma
- Falcon
- MPT
- OLMo
- Qwen
- StableLM

## Quantizing Models

Quantization reduces model size and memory usage with minimal quality loss.

### Quantization Options

| Quantization | Size Reduction | Quality Impact | Memory Required |
|--------------|----------------|----------------|----------------|
| None (FP16) | 0% (baseline) | None | ~14GB for 7B |
| INT8 | ~50% | Very low | ~7GB for 7B |
| INT4 | ~75% | Low-moderate | ~4GB for 7B |

### Using MLX-LM APIs

```python
from mlx_lm import load

# Load with INT4 quantization
model, tokenizer = load("llama-2-7b", quantization="int4")

# Load with INT8 quantization
model, tokenizer = load("llama-2-7b", quantization="int8")
```

### Using Our Helper Script

We provide a helper script for model quantization:

```bash
# Navigate to your MLX runtime directory
cd mlx-runtime

# Quantize a model to INT4
./scripts/quantize-model.sh llama-2-7b int4

# Quantize a model to INT8
./scripts/quantize-model.sh llama-2-7b int8
```

The script will create a new directory with the quantized model:
- Original: `llama-2-7b/`
- Quantized: `llama-2-7b_int4/` or `llama-2-7b_int8/`

### Quantization Recommendations

- For 8GB RAM systems: Always use INT4 quantization
- For 16GB RAM systems: 
  - Use INT8 for 7B models
  - Use INT4 for 13B models
- For 32GB+ RAM systems:
  - FP16 or INT8 for models up to 13B
  - INT8 or INT4 for larger models

## Advanced Model Operations

### Custom Model Loading

Loading specific model configurations:

```python
import mlx.core as mx
from mlx_lm import load, generate
from mlx_lm.utils import get_model_path

# Load with custom parameters
model_path = get_model_path("llama-2-7b")
model, tokenizer = load(
    model_path,
    quantization="int4",
    tensor_parallel_ranks=1,  # For multi-GPU systems
    max_tokens=4096,          # Maximum context length
)
```

### Model Merging (Weight Averaging)

```python
import mlx.core as mx
from mlx_lm import load, save

# Load models
model1, tokenizer = load("llama-2-7b-custom1")
model2, _ = load("llama-2-7b-custom2")

# Create merged weights
merged_params = {}
for key in model1.parameters():
    merged_params[key] = model1.parameters()[key] * 0.5 + model2.parameters()[key] * 0.5

# Update model with merged weights
model1.update(merged_params)

# Save merged model
save("llama-2-7b-merged", model1, tokenizer)
```

### Saving Custom Models

```python
from mlx_lm import load, save

# Load and modify a model
model, tokenizer = load("llama-2-7b")

# ... modify the model ...

# Save to a new directory
save("llama-2-7b-modified", model, tokenizer)
```

## Models Performance Benchmarks

### Inference Speed (tokens/second)

| Model | Size | M1 Pro | M2 Pro | M3 Pro |
|-------|------|--------|--------|--------|
| LLaMA 2 | 7B (FP16) | 30-35 | 40-45 | 55-65 |
| LLaMA 2 | 7B (INT8) | 35-40 | 50-55 | 65-75 |
| LLaMA 2 | 7B (INT4) | 45-50 | 55-65 | 75-90 |
| Mistral | 7B (FP16) | 32-38 | 42-48 | 58-68 |
| Mistral | 7B (INT8) | 38-45 | 52-58 | 68-78 |
| Mistral | 7B (INT4) | 48-55 | 58-68 | 78-95 |
| Phi-2 | 2.7B (FP16) | 55-65 | 70-80 | 90-110 |
| Phi-2 | 2.7B (INT4) | 80-95 | 100-120 | 130-150 |
| Gemma | 2B (INT4) | 90-105 | 110-130 | 140-160 |
| Gemma | 7B (INT4) | 45-55 | 60-70 | 80-95 |

*Note: Performance varies based on specific hardware configuration, macOS version, and prompt complexity.*

### Memory Usage

| Model | FP16 | INT8 | INT4 |
|-------|------|------|------|
| LLaMA 2 7B | ~14GB | ~7.5GB | ~4GB |
| LLaMA 2 13B | ~26GB | ~13.5GB | ~7GB |
| Mistral 7B | ~14GB | ~7.5GB | ~4GB |
| Phi-2 2.7B | ~5.5GB | ~3GB | ~1.7GB |
| Gemma 2B | ~4GB | ~2.2GB | ~1.3GB |
| Gemma 7B | ~14GB | ~7.5GB | ~4GB |

### Maximum Context Length by Hardware

| Mac Configuration | 7B (INT4) | 13B (INT4) | 7B (INT8) |
|-------------------|-----------|------------|-----------|
| MacBook Air (8GB) | 4K tokens | Not viable | Not viable |
| MacBook Pro (16GB) | 8K tokens | 4K tokens | 4K tokens |
| MacBook Pro (32GB) | 16K+ tokens | 8K tokens | 8K tokens |
| Mac Studio (64GB+) | 32K+ tokens | 16K+ tokens | 16K+ tokens |

## Chat Templates and Prompting

Different models require specific prompt formatting for optimal results:

### LLaMA 2 Chat Template

```python
prompt = f"""<s>[INST] <<SYS>>
You are a helpful assistant.
<</SYS>>

{user_message} [/INST]"""
```

### Mistral Instruct Template

```python
prompt = f"""<s>[INST] {user_message} [/INST]"""
```

### Phi-2 Template

```python
prompt = f"""Instruct: {user_message}
Output:"""
```

### Gemma Template

```python
prompt = f"""<start_of_turn>user
{user_message}<end_of_turn>
<start_of_turn>model"""
```

## Tips for Best Results

1. **Use the right prompt template** for each model
2. **Match quantization to your hardware** capabilities
3. **Start with smaller models** and scale up as needed
4. **For interactive applications**:
   - Stream tokens for better user experience
   - Keep context size reasonable
   - Use appropriate temperature settings (0.7-0.8 is often good)
5. **For batch processing**:
   - Load the model once and reuse for multiple prompts
   - Use lower temperature for more deterministic results
6. **Monitor memory usage** when working with larger contexts