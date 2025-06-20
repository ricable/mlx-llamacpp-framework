# MLX and MLX-LM Setup for Mac Silicon

This repository contains scripts and documentation for setting up and using Apple's MLX and MLX-LM frameworks on Apple Silicon Macs. MLX is a machine learning framework specifically optimized for Apple Silicon hardware, enabling efficient execution of large language models.

## Features

- Easy installation of MLX and MLX-LM frameworks
- Helper scripts for downloading, converting, and quantizing models
- Detailed documentation for common use cases
- Interactive chat and inference scripts
- Troubleshooting guides specific to Apple Silicon

## Requirements

- Mac with Apple Silicon (M1, M2, or M3 series)
- macOS 12.0 (Monterey) or later
- Python 3.8 or newer
- 8GB RAM minimum (16GB+ recommended)

## Directory Structure

```
mlx-setup/
├── scripts/               # Installation and helper scripts
│   ├── setup.sh           # Main installation script
│   └── ...                # Other helper scripts
├── docs/                  # Documentation
│   ├── troubleshooting.md # Common issues and solutions
│   ├── models-guide.md    # Guide for working with models
│   └── usage-guide.md     # Usage examples and patterns
└── models/                # Directory for downloaded models (created during setup)
```

## Quick Start

1. **Clone this repository**:
   ```bash
   git clone <repository-url>
   cd mlx-setup
   ```

2. **Run the setup script**:
   ```bash
   ./scripts/setup.sh
   ```
   This will:
   - Check and install prerequisites
   - Create a Python virtual environment
   - Install MLX and MLX-LM
   - Set up helper scripts and directory structure

3. **Verify installation**:
   ```bash
   ./mlx-runtime/verify-installation.sh
   ```

4. **Download a model**:
   ```bash
   ./mlx-runtime/scripts/download-model.sh llama-2-7b
   ```

5. **Run the model**:
   ```bash
   ./mlx-runtime/run-model.sh llama-2-7b "Explain quantum computing in simple terms"
   ```

6. **Start a chat session**:
   ```bash
   ./mlx-runtime/chat.sh llama-2-7b
   ```

## Helper Scripts

### Download Models
```bash
./mlx-runtime/scripts/download-model.sh <model_name>
```
Available models: llama-2-7b, llama-2-7b-chat, mistral-7b-v0.1, phi-2, gemma-2b, gemma-7b, and more.

### Convert Models from Hugging Face
```bash
./mlx-runtime/scripts/convert-model.sh <huggingface_path> <output_dir>
```
Example: `./mlx-runtime/scripts/convert-model.sh meta-llama/Llama-2-7b llama-2-7b-custom`

### Quantize Models
```bash
./mlx-runtime/scripts/quantize-model.sh <model_dir> <quantization>
```
Quantization options: int4, int8
Example: `./mlx-runtime/scripts/quantize-model.sh llama-2-7b int4`

## Documentation

- [Model Guide](docs/models-guide.md): Detailed information about model selection, downloading, and quantization
- [Usage Guide](docs/usage-guide.md): Examples and patterns for using MLX and MLX-LM
- [Troubleshooting](docs/troubleshooting.md): Common issues and solutions specific to Apple Silicon

## Model Selection Guide

| Mac Configuration | RAM | Recommended Models | Notes |
|-------------------|-----|-------------------|-------|
| MacBook Air M1/M2 | 8GB | Phi-2, Gemma-2B | Use INT4 quantization |
| MacBook Pro/Air | 16GB | LLaMA-2 7B, Mistral 7B | INT8 or INT4 quantization |
| MacBook Pro/Mac Mini | 32GB | LLaMA-2 13B, LLaMA-2 7B | INT4 for 13B, FP16/INT8 for 7B |
| Mac Studio/Mac Pro | 64GB+ | Most models | FP16 for 7B/13B, INT8 for larger models |

## Performance Expectations

Performance varies by hardware:

| Model | Size | M1 | M2 | M3 |
|-------|------|----|----|----| 
| LLaMA-2 (INT4) | 7B | 40-50 tok/s | 55-65 tok/s | 75-90 tok/s |
| Mistral (INT4) | 7B | 45-55 tok/s | 60-70 tok/s | 80-95 tok/s |
| Phi-2 (INT4) | 2.7B | 80-95 tok/s | 100-120 tok/s | 130-150 tok/s |

## Examples

### Basic Generation
```bash
./mlx-runtime/run-model.sh llama-2-7b "Explain how transistors work" --max-tokens 512
```

### Interactive Chat
```bash
./mlx-runtime/chat.sh llama-2-7b-chat --quantization int4
```

### Custom Parameters
```bash
./mlx-runtime/run-model.sh mistral-7b-v0.1 "Write a short story about AI" --temp 0.9 --max-tokens 1024
```

## Common Issues

- **Out of Memory**: Use more aggressive quantization (INT4) or a smaller model
- **Slow Performance**: Ensure Metal acceleration is working and update macOS
- **Model Not Found**: Check download path and permissions

For more details, see the [Troubleshooting Guide](docs/troubleshooting.md).

## Resources

- [MLX GitHub Repository](https://github.com/ml-explore/mlx)
- [MLX Documentation](https://ml-explore.github.io/mlx/build/html/index.html)
- [MLX-LM GitHub Repository](https://github.com/ml-explore/mlx-examples/tree/main/llms)
- [Apple Developer Documentation](https://developer.apple.com/machine-learning/)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- Apple for creating MLX and MLX-LM
- The open-source ML community for model development and improvements