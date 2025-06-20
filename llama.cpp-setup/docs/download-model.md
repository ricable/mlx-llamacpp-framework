# Downloading Models for llama.cpp

This document provides instructions for downloading compatible models for llama.cpp.

## Compatible Model Formats

llama.cpp requires models in GGML or GGUF format. These are optimized formats that allow running large language models efficiently on consumer hardware.

## Option 1: Download from Hugging Face

Many pre-converted models are available on Hugging Face:

1. Visit [Hugging Face](https://huggingface.co/)
2. Search for models with "ggml" or "gguf" in their name
3. Download the model files to your `models` directory

Popular model repositories:
- TheBloke's quantized models: https://huggingface.co/TheBloke
- Llama 2 GGUF models: https://huggingface.co/TheBloke/Llama-2-7B-GGUF

## Option 2: Convert Models Yourself

If you have a model in a different format, you can convert it:

1. Clone the llama.cpp repository if you haven't already
2. Use the conversion scripts in the `convert` directory
3. See the llama.cpp documentation for specific conversion instructions

## Option 3: Use the download-model.py script

You can use the following command to download models from Hugging Face:

```bash
python3 llama.cpp/examples/download-model.py TheBloke/Llama-2-7B-GGUF
```

## Recommended Models for Beginners

For those new to llama.cpp, here are some good starter models:

1. **Llama 2 7B Q4_K_M**: A good balance of quality and speed
   - Size: ~4GB
   - Command: `python3 llama.cpp/examples/download-model.py TheBloke/Llama-2-7B-GGUF llama-2-7b.Q4_K_M.gguf`

2. **Mistral 7B Q4_K_M**: Great performance for its size
   - Size: ~4GB
   - Command: `python3 llama.cpp/examples/download-model.py TheBloke/Mistral-7B-v0.1-GGUF mistral-7b-v0.1.Q4_K_M.gguf`

3. **Tiny Llama 1.1B Q4_0**: Very small and fast
   - Size: ~700MB
   - Command: `python3 llama.cpp/examples/download-model.py TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF tinyllama-1.1b-chat-v1.0.Q4_0.gguf`

After downloading, you can run the model with:

```bash
./run-model.sh models/model-name.gguf "Your prompt here"
```

Or start the server with:

```bash
./run-server.sh models/model-name.gguf 8080
```

## Model Selection Based on Hardware

| Mac Model | RAM | Recommended Model Size | Quantization |
|-----------|-----|------------------------|--------------|
| MacBook Air M1/M2 | 8GB | 7B | Q4_0, Q4_K_M |
| MacBook Pro M1/M2 | 16GB | 7B-13B | Q4_K_M, Q5_K_M |
| Mac Mini M1/M2 | 8-16GB | 7B-13B | Q4_K_M, Q5_K_M |
| MacBook Pro/Mac Studio M1/M2 Max | 32GB+ | 7B-33B | Q6_K, Q8_0 |
| Mac Studio M1/M2 Ultra | 64GB+ | 7B-70B | Q8_0, F16 |

Always start with a smaller, more quantized model and work your way up based on your Mac's performance.