# Running LLMs on Apple Silicon

A comprehensive framework for running, quantizing, and fine-tuning large language models locally on Apple Silicon hardware using llama.cpp and MLX frameworks.

## Quick Links

- [Complete Documentation](docs/README.md)
- [Getting Started Guide](docs/getting-started.md)
- [Project Overview](docs/project-overview.md)
- [Hardware Recommendations](docs/hardware/hardware-recommendations.md)

## Features

- **Multiple Framework Support**:
  - llama.cpp for cross-platform C/C++ implementation
  - MLX for native Apple Silicon optimization

- **Full Lifecycle Management**:
  - Easy installation and setup
  - Model downloading and management
  - Inference and generation
  - Quantization for memory efficiency
  - Fine-tuning for customization

- **Optimized for Apple Silicon**:
  - Metal acceleration for GPU computation
  - Memory-efficient implementations
  - Performance optimizations for M1/M2/M3 series chips

- **Multiple User Interfaces**:
  - Command-line tools
  - Interactive chat applications
  - Web interfaces
  - API servers

## Quick Start

### Installation

1. Set up llama.cpp:
```bash
cd llama.cpp-setup
./scripts/setup.sh
```

2. Set up MLX:
```bash
cd mlx-setup
./scripts/setup.sh
```

3. Download models:
```bash
cd model_utils
python model_cli.py download llama-2-7b
```

### Basic Usage

#### Text Generation with llama.cpp

```bash
cd llama.cpp-setup
./bin/main -m ../models/llama-2-7b-q4_0.gguf --metal -p "Tell me about Apple Silicon" -n 256
```

#### Text Generation with MLX

```python
from mlx_lm import load, generate

model, tokenizer = load("llama-2-7b", quantization="int4")
tokens = generate(model, tokenizer, "Tell me about Apple Silicon", max_tokens=256)
print(tokenizer.decode(tokens))
```

#### Interactive Chat

```bash
cd chat_interfaces
./init.sh
python llama_cpp/cli/chat_cli.py --model ../models/llama-2-7b-q4_0.gguf
```

## Documentation

- [Framework Guides](docs/frameworks/framework-comparison.md): Choose between llama.cpp and MLX
- [Use Case Guides](docs/use-cases/inference-guide.md): Inference, chat, and fine-tuning
- [Hardware Guides](docs/hardware/hardware-recommendations.md): Choose the right Mac for your needs
- [Performance Optimization](docs/hardware/performance-optimization.md): Get the best performance

## Hardware Requirements

| Usage Level | Minimum | Recommended | Optimal |
|-------------|---------|-------------|---------|
| Basic Inference | MacBook Air M1/M2 (8GB) | MacBook Pro M1/M2 Pro (16GB) | Mac Studio M1/M2 Max/Ultra (32GB+) |
| Quantization | MacBook Air M1/M2 (8GB) | MacBook Pro M1/M2 Pro (16GB) | MacBook Pro M1/M2 Max (32GB+) |
| Fine-tuning | MacBook Pro M1/M2 Pro (16GB) | MacBook Pro M1/M2 Max (32GB) | Mac Studio M1/M2 Ultra (64GB+) |

## Model Compatibility

This project supports most modern open-source LLMs, including:

- LLaMA (1, 2, and 3)
- Mistral (7B and Mixtral)
- Phi-2 and Phi-3
- Falcon
- MPT
- And many others

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [llama.cpp](https://github.com/ggerganov/llama.cpp)
- [MLX](https://github.com/ml-explore/mlx)
- [Apple Machine Learning Research](https://machinelearning.apple.com/)