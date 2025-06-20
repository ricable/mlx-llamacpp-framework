# MLX Usage Guide for Mac Silicon

This guide covers common usage patterns for running and fine-tuning large language models with MLX on Apple Silicon Macs.

## Getting Started

### Basic Setup

If you haven't already installed MLX and MLX-LM, run the setup script:

```bash
./scripts/setup.sh
```

The setup creates a virtual environment and installs all necessary packages.

### Running a Model

The simplest way to run a model is with our helper script:

```bash
# Navigate to your MLX runtime directory
cd mlx-runtime

# Run a model with a prompt
./run-model.sh llama-2-7b "Explain quantum computing in simple terms"
```

### Interactive Chat Mode

For an interactive chat experience:

```bash
# Start a chat session
./chat.sh llama-2-7b
```

## Command-Line Options

Our helper scripts support various options:

### run-model.sh Options

```bash
./run-model.sh <model_dir> [prompt] [options]
```

Available options:
- `--temp <value>`: Temperature (default: 0.7)
- `--top-p <value>`: Top-p sampling (default: 0.9)
- `--top-k <value>`: Top-k sampling (default: 40)
- `--max-tokens <value>`: Maximum tokens to generate (default: 512)
- `--quantization <type>`: Model quantization (int4, int8, none)
- `--interactive`: Run in interactive chat mode

Examples:
```bash
# Run with custom generation parameters
./run-model.sh llama-2-7b "Write a short story about AI" --temp 0.9 --max-tokens 1024

# Run with INT4 quantization
./run-model.sh llama-2-7b "Explain the benefits of Apple Silicon" --quantization int4
```

### chat.sh Options

```bash
./chat.sh <model_dir> [options]
```

This script is a wrapper around `run-model.sh` with the `--interactive` flag enabled. It accepts the same options:

```bash
# Chat with a quantized model
./chat.sh llama-2-7b --quantization int4

# Chat with custom parameters
./chat.sh mistral-7b-instruct-v0.1 --temp 0.8 --top-p 0.95
```

## Python API Usage

If you prefer to write your own Python code, here are some common patterns:

### Basic Text Generation

```python
import mlx.core as mx
from mlx_lm import load, generate

# Load the model
model, tokenizer = load("llama-2-7b", quantization="int4")

# Generate text
prompt = "Explain the concept of quantum entanglement in simple terms"
output = generate(
    model,
    tokenizer,
    prompt,
    max_tokens=512,
    temp=0.7,
    top_p=0.9,
    top_k=40
)

# Print the generated text
print(tokenizer.decode(output))
```

### Streaming Generation

```python
import mlx.core as mx
from mlx_lm import load, generate

# Load the model
model, tokenizer = load("llama-2-7b", quantization="int4")

# Prepare prompt
prompt = "Write a short poem about artificial intelligence"
print(prompt, end="\n\n")

# Generate with streaming
for token in generate(
    model,
    tokenizer,
    prompt,
    max_tokens=200,
    temp=0.7,
    top_p=0.9,
    stream=True  # Enable streaming
):
    print(token, end="", flush=True)
print("\n")
```

### Interactive Chat

```python
import mlx.core as mx
from mlx_lm import load, generate

# Load model
model, tokenizer = load("llama-2-7b-chat", quantization="int4")

def format_prompt(user_message):
    # Using LLaMA 2 chat template
    return f"<s>[INST] <<SYS>>\nYou are a helpful assistant.\n<</SYS>>\n\n{user_message} [/INST]"

# Chat loop
print("Assistant: Hello! How can I help you today? (Type 'exit' to quit)")
while True:
    user_input = input("\nYou: ")
    if user_input.lower() in ["exit", "quit", "bye"]:
        print("\nAssistant: Goodbye!")
        break
        
    prompt = format_prompt(user_input)
    
    print("\nAssistant: ", end="", flush=True)
    for token in generate(
        model,
        tokenizer,
        prompt,
        max_tokens=512,
        temp=0.7,
        top_p=0.9,
        stream=True
    ):
        print(token, end="", flush=True)
    print()
```

### Batch Processing

```python
import mlx.core as mx
from mlx_lm import load, generate

# Load model once
model, tokenizer = load("llama-2-7b", quantization="int4")

# Process multiple prompts
prompts = [
    "Explain the concept of artificial intelligence",
    "What are the benefits of machine learning?",
    "How does deep learning work?",
    "What is transfer learning?"
]

# Generate responses for all prompts
for i, prompt in enumerate(prompts):
    print(f"Prompt {i+1}: {prompt}")
    print("\nResponse:")
    
    output = generate(
        model,
        tokenizer,
        prompt,
        max_tokens=256,
        temp=0.3  # Lower temperature for more deterministic responses
    )
    
    print(tokenizer.decode(output))
    print("\n" + "-"*80 + "\n")
```

## Advanced Usage

### Memory Optimization

For running larger models or longer contexts:

```python
import mlx.core as mx
from mlx_lm import load, generate
import gc

# Enable memory-efficient attention (saves memory for long contexts)
mx.enable_memory_efficient_attention()

# Load with minimal memory footprint
model, tokenizer = load(
    "llama-2-13b", 
    quantization="int4",
    max_tokens=4096  # Pre-allocate for context length
)

# Generate text
prompt = "Write a comprehensive guide about machine learning"
output = generate(model, tokenizer, prompt, max_tokens=2048)
print(tokenizer.decode(output))

# Clean up to free memory
del model
gc.collect()
mx.clear_memory_pool()
```

### Custom Model Loading

```python
import mlx.core as mx
from mlx_lm.models import Llama
from mlx_lm.utils import load_tokenizer

# Load tokenizer
tokenizer = load_tokenizer("meta-llama/Llama-2-7b")

# Create model architecture
model = Llama.from_config("llama-2-7b/config.json")

# Load weights
weights = mx.load("llama-2-7b/weights.safetensors")
model.update(weights)

# If you want to quantize after loading
from mlx_lm.utils import quantize_model
model = quantize_model(model, nbits=4, group_size=64)
```

### Custom Model Saving

```python
import mlx.core as mx
from mlx_lm import load, save

# Load and potentially modify a model
model, tokenizer = load("llama-2-7b")

# Save the model
save("llama-2-7b-modified", model, tokenizer)
```

## Fine-Tuning Models

MLX supports several fine-tuning approaches:

### Full Fine-Tuning

```python
import mlx.core as mx
import mlx.nn as nn
import mlx.optimizers as optim
from mlx_lm import load, save
import numpy as np

# Load model
model, tokenizer = load("llama-2-7b")

# Prepare data (example)
train_data = [
    {"input": "What is the capital of France?", "output": "The capital of France is Paris."},
    {"input": "Who wrote Romeo and Juliet?", "output": "William Shakespeare wrote Romeo and Juliet."}
]

# Tokenize data
def prepare_samples(samples, tokenizer):
    inputs, targets = [], []
    for sample in samples:
        input_ids = tokenizer.encode(sample["input"])
        output_ids = tokenizer.encode(sample["output"])
        
        # Combine input and output for the full sequence
        combined_ids = input_ids + output_ids
        
        # For targets, we mask the input tokens with -100 (ignored in loss)
        target_ids = [-100] * len(input_ids) + output_ids
        
        inputs.append(combined_ids)
        targets.append(target_ids)
    
    # Create arrays and pad sequences
    max_len = max(len(seq) for seq in inputs)
    padded_inputs = [seq + [tokenizer.pad_id] * (max_len - len(seq)) for seq in inputs]
    padded_targets = [seq + [-100] * (max_len - len(seq)) for seq in targets]
    
    return mx.array(padded_inputs), mx.array(padded_targets)

# Create optimizer
optimizer = optim.AdamW(learning_rate=1e-5)

# Training function
def loss_fn(model, inputs, targets):
    logits = model(inputs)
    logits = logits.reshape(-1, logits.shape[-1])
    targets = targets.reshape(-1)
    
    # Mask padding tokens
    mask = targets != -100
    logits = logits[mask]
    targets = targets[mask]
    
    return nn.losses.cross_entropy(logits, targets)

# Train step
def train_step(model, inputs, targets):
    loss, grads = nn.value_and_grad(model, loss_fn)(model, inputs, targets)
    optimizer.update(model, grads)
    return loss

# Training loop
batch_size = 1  # Adjust based on memory constraints
num_epochs = 3

for epoch in range(num_epochs):
    inputs, targets = prepare_samples(train_data, tokenizer)
    loss = train_step(model, inputs, targets)
    print(f"Epoch {epoch+1}, Loss: {loss}")

# Save fine-tuned model
save("llama-2-7b-finetuned", model, tokenizer)
```

### LoRA Fine-Tuning

```python
import mlx.core as mx
import mlx.nn as nn
import mlx.optimizers as optim
from mlx_lm import load, save
from mlx_lm.lora import apply_lora

# Load model
model, tokenizer = load("llama-2-7b", quantization="int4")

# Apply LoRA
model = apply_lora(
    model,
    r=16,            # LoRA rank
    alpha=32,        # LoRA alpha scaling
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj"]  # Which modules to apply LoRA to
)

# Then use the same training loop as above
# Only the LoRA parameters will be updated
# This is much more memory efficient
```

### Saving and Loading LoRA Weights

```python
import mlx.core as mx
from mlx_lm import load, save
from mlx_lm.lora import apply_lora

# After fine-tuning, save only the LoRA weights
lora_params = {}
for name, param in model.parameters().items():
    if "lora" in name:
        lora_params[name] = param

mx.save("lora_weights.npz", lora_params)

# To load the LoRA weights later
base_model, tokenizer = load("llama-2-7b", quantization="int4")
base_model = apply_lora(
    base_model,
    r=16,
    alpha=32,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj"]
)

# Load and apply LoRA weights
lora_params = mx.load("lora_weights.npz")
base_model.update(lora_params)
```

## Optimizing Performance

### Metal Acceleration Settings

```python
import mlx.core as mx

# Ensure using Metal
mx.set_default_device(mx.gpu)

# For operations where CPU might be faster
def cpu_operation(array):
    mx.set_default_device(mx.cpu)
    result = mx.some_operation(array)
    mx.set_default_device(mx.gpu)
    return result
```

### Memory Management

```python
import mlx.core as mx
import gc

# Clear memory pool after large operations
def run_large_generation():
    # ... generate text ...
    output = generate(model, tokenizer, prompt, max_tokens=2048)
    
    # Clear memory
    mx.clear_memory_pool()
    gc.collect()
    
    return output
```

### Batch Size Optimization

```python
import mlx.core as mx
from mlx_lm import load, generate

# Load model
model, tokenizer = load("llama-2-7b", quantization="int4")

# Prepare multiple prompts
prompts = [
    "Explain quantum computing",
    "What is machine learning?",
    "How does a neural network work?"
]

# Tokenize all prompts
tokenized_prompts = [tokenizer.encode(p) for p in prompts]

# Find max length
max_len = max(len(p) for p in tokenized_prompts)

# Pad to same length
padded_prompts = [p + [tokenizer.pad_id] * (max_len - len(p)) for p in tokenized_prompts]

# Create batch
batch = mx.array(padded_prompts)

# Generate for the entire batch
# Note: Currently MLX-LM's generate() doesn't support batching directly
# This is a conceptual example of the approach
```

## Troubleshooting

### Memory Issues

If you encounter "out of memory" errors:

1. Use more aggressive quantization:
```python
model, tokenizer = load("llama-2-7b", quantization="int4")
```

2. Reduce context length:
```python
# Limit context window
model, tokenizer = load("llama-2-7b", max_tokens=1024)
```

3. Clear memory between runs:
```python
import gc
import mlx.core as mx

# After heavy operations
del large_variables
gc.collect()
mx.clear_memory_pool()
```

### Slow Performance

If performance is slower than expected:

1. Verify Metal is being used:
```python
import mlx.core as mx
print(f"Metal available: {mx.metal.is_available()}")
mx.set_default_device(mx.gpu)  # Ensure using GPU
```

2. Monitor system resources:
```bash
# In a separate terminal
sudo powermetrics --samplers cpu_power,gpu_power
```

3. Optimize your prompt length:
```python
# Shorter prompt = faster initial processing
prompt = "Summarize: " + long_text[-1000:]  # Take just the last 1000 chars
```

## Working with Long Contexts

For working with longer documents:

```python
import mlx.core as mx
from mlx_lm import load, generate

# Load with support for longer context
model, tokenizer = load("llama-2-7b", quantization="int4", max_tokens=8192)

# Read a large document
with open("large_document.txt", "r") as f:
    document = f.read()

# Truncate to fit context if needed
tokens = tokenizer.encode(document)
if len(tokens) > 8000:  # Leave room for generation
    tokens = tokens[-8000:]  # Take the last 8000 tokens
    document = tokenizer.decode(tokens)

# Generate summary
prompt = f"{document}\n\nSummarize the above text:"
output = generate(model, tokenizer, prompt, max_tokens=512)
summary = tokenizer.decode(output)
print(summary)
```

## Integration Examples

### Web Server with FastAPI

```python
from fastapi import FastAPI, BackgroundTasks
import mlx.core as mx
from mlx_lm import load, generate
import uvicorn
from pydantic import BaseModel
import time

app = FastAPI()
model = None
tokenizer = None

class GenerationRequest(BaseModel):
    prompt: str
    max_tokens: int = 512
    temperature: float = 0.7
    top_p: float = 0.9
    top_k: int = 40

class GenerationResponse(BaseModel):
    text: str
    generation_time: float

@app.on_event("startup")
async def startup_event():
    global model, tokenizer
    print("Loading model...")
    model, tokenizer = load("llama-2-7b", quantization="int4")
    print("Model loaded")

@app.post("/generate")
async def generate_text(request: GenerationRequest):
    global model, tokenizer
    
    start_time = time.time()
    output = generate(
        model,
        tokenizer,
        request.prompt,
        max_tokens=request.max_tokens,
        temp=request.temperature,
        top_p=request.top_p,
        top_k=request.top_k
    )
    text = tokenizer.decode(output)
    generation_time = time.time() - start_time
    
    return GenerationResponse(text=text, generation_time=generation_time)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### Document Q&A System

```python
import mlx.core as mx
from mlx_lm import load, generate

# Load model
model, tokenizer = load("llama-2-7b-chat", quantization="int4")

def format_prompt(document, question):
    return f"""<s>[INST] <<SYS>>
You are a helpful assistant that answers questions based on the provided document.
<</SYS>>

Document:
{document}

Question: {question}

Please answer the question based only on the information in the document. [/INST]"""

def answer_question(document, question):
    prompt = format_prompt(document, question)
    
    output = generate(
        model,
        tokenizer,
        prompt,
        max_tokens=512,
        temp=0.3  # Lower temperature for more factual responses
    )
    
    return tokenizer.decode(output)

# Example usage
document = """
Apple Silicon is the family of system on a chip (SoC) and system in a package (SiP) 
processors designed by Apple Inc. primarily using the ARM architecture. It replaced 
Intel processors in Mac computers beginning in 2020. The first generation includes 
the M1, M1 Pro, M1 Max, and M1 Ultra, featuring unified memory architecture and 
significant performance and efficiency improvements over previous Intel-based Macs.
"""

question = "When did Apple start using their own processors in Macs?"
answer = answer_question(document, question)
print(answer)
```

## Further Resources

- [MLX GitHub Repository](https://github.com/ml-explore/mlx)
- [MLX Documentation](https://ml-explore.github.io/mlx/build/html/index.html)
- [MLX-LM GitHub Repository](https://github.com/ml-explore/mlx-examples/tree/main/llms)
- [MLX Discord Community](https://discord.gg/mlx)

For more detailed information about model handling, refer to the [Models Guide](models-guide.md).
For troubleshooting assistance, see the [Troubleshooting Guide](troubleshooting.md).