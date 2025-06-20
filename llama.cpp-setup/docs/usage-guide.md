# llama.cpp Usage Guide

This guide covers common usage patterns for llama.cpp on Mac with Apple Silicon.

## Basic Usage

### Running a Model

The simplest way to run a model is:

```bash
./run-model.sh models/your-model.gguf "Your prompt here"
```

This will generate text based on your prompt.

### Running the Server

To start the web server interface:

```bash
./run-server.sh models/your-model.gguf 8080
```

Then visit http://localhost:8080 in your browser.

## Advanced Usage

### Command-Line Options

Here are some useful command-line options for the `main` binary:

- `-m MODEL`: Path to the model file (required)
- `-n N`: Number of tokens to generate (default: 128)
- `--ctx-size N`: Context window size (default: 2048)
- `--threads N`: Number of threads to use (default: auto-detected)
- `--temp N`: Temperature (default: 0.8)
- `--top_p N`: Top-p sampling (default: 0.9)
- `--repeat_penalty N`: Repetition penalty (default: 1.1)
- `-p "TEXT"`: Input prompt (required)
- `--color`: Enable colorized output
- `--seed N`: RNG seed (default: -1, random)
- `--metal`: Enable Metal acceleration (always use on Apple Silicon)
- `--metal-mmq`: Enable Metal matrix multiplication (may improve performance)

Example with advanced parameters:

```bash
./main -m models/your-model.gguf \
    -n 256 \
    --metal \
    --ctx-size 4096 \
    --threads 8 \
    --temp 0.7 \
    --top_p 0.95 \
    --repeat_penalty 1.2 \
    -p "Write a short story about a robot that learns to paint."
```

### Server Options

For the server, useful options include:

- `-m MODEL`: Path to the model file (required)
- `--port N`: Server port (default: 8080)
- `--host HOST`: Server host (default: 127.0.0.1)
- `--threads N`: Number of threads to use
- `--ctx-size N`: Context window size
- `--metal`: Enable Metal acceleration (always use on Apple Silicon)

Example:

```bash
./server -m models/your-model.gguf \
    --metal \
    --port 8080 \
    --host 0.0.0.0 \
    --threads 8 \
    --ctx-size 4096
```

## Using Different Models

Different models have different capabilities. Here are some general guidelines:

- **Larger models** (30B+): More capable but slower and more memory intensive
- **Medium models** (7B-13B): Good balance of performance and resource usage
- **Small models** (1B-3B): Fast but less capable

Different quantization levels trade quality for size:

- **Q8_0**: Highest quality, larger size
- **Q6_K**: High quality, good balance
- **Q5_K_M**: Good quality, moderate size
- **Q4_K_M**: Decent quality, smaller size
- **Q4_0**: Lowest quality, smallest size

## Prompting Techniques

Different models respond better to different prompting styles:

### For Chat Models

Chat models often expect a specific format:

```
USER: Your question or instruction here.
ASSISTANT: 
```

Some models use different formats like:

```
<|USER|>: Your question or instruction here.
<|ASSISTANT|>: 
```

Check the model's documentation for the recommended format.

### For Instruct Models

Instruct models often respond well to clear, direct instructions:

```
Write a poem about a cat in the style of Shakespeare.
```

### For Base Models

For base (non-instruct) models, providing examples can help:

```
The capital of France is Paris.
The capital of Germany is Berlin.
The capital of Italy is Rome.
The capital of Spain is
```

## Performance Optimization

To get the best performance:

1. **Use Metal acceleration**: Always include the `--metal` flag on Apple Silicon
2. **Right-size the context window**: Only use what you need (--ctx-size)
3. **Optimize thread count**: Usually matches your CPU core count
4. **Choose appropriate quantization**: More quantized models run faster
5. **Adjust batch size**: Can improve throughput (--batch-size)

## Interactive Chat Mode

For a more interactive experience:

```bash
./main -m models/your-model.gguf \
    --metal \
    --interactive \
    --color \
    -i \
    -r "User:" \
    -f prompts/chat-template.txt
```

Create a chat template file first:

```
<|im_start|>system
You are a helpful assistant.
<|im_end|>
<|im_start|>user
{prompt}
<|im_end|>
<|im_start|>assistant
```

## Web UI Features

When using the server mode, the web UI provides:

- Chat interface
- Parameter adjustment
- Model selection (if multiple models are loaded)
- Session history

## API Usage

The server also provides a JSON API for programmatic access:

- Endpoint: `http://localhost:8080/completion`
- Method: POST
- Body: JSON with prompt and parameters

Example API request:

```bash
curl -X POST http://localhost:8080/completion -d '{
  "prompt": "Once upon a time",
  "n_predict": 128,
  "temperature": 0.7,
  "stop": ["\n\n"]
}'
```