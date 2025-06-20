# Flow2: MLX & LlamaCpp Framework

## Project Overview
Flow2 is a comprehensive AI model training and inference toolkit with support for MLX and LlamaCpp frameworks, Flash Attention optimization, and extensive performance utilities for Apple Silicon.

## Build Commands
- `python -m pip install -e .`: Install package in development mode
- `python -m pip install -e .[mlx]`: Install with MLX dependencies  
- `python -m pip install -e .[llamacpp]`: Install with LlamaCpp dependencies
- `python -m pip install -e .[all]`: Install with all dependencies
- `python -m pytest tests/`: Run the test suite
- `python -c "import flow2; print(flow2.__version__)"`: Verify installation

## Package Structure
```
src/flow2/
├── core/              # Flash Attention & benchmarks
├── frameworks/        # MLX & LlamaCpp implementations
│   ├── mlx/          # MLX training, inference, quantization
│   └── llamacpp/     # LlamaCpp training, inference, quantization  
├── chat/             # Interactive chat interfaces
├── performance/      # Benchmarking & analysis tools
└── utils/            # Model management & utilities
```

## Quick Start

### Installation
```bash
# Clone the repository
git clone https://github.com/yourusername/mlx-llamacpp-framework.git
cd mlx-llamacpp-framework

# Install with all dependencies
pip install -e .[all]

# Or install framework-specific
pip install -e .[mlx]      # For MLX on Apple Silicon
pip install -e .[llamacpp] # For LlamaCpp
```

### Basic Usage
```python
import flow2

# Check available frameworks
print(f"MLX Available: {flow2.MLX_AVAILABLE}")
print(f"LlamaCpp Available: {flow2.LLAMACPP_AVAILABLE}")
print(f"Flash Attention: {flow2.FLASH_ATTENTION_AVAILABLE}")

# MLX usage
if flow2.MLX_AVAILABLE:
    from flow2.frameworks.mlx import load_mlx_model, generate_completion
    
# LlamaCpp usage  
if flow2.LLAMACPP_AVAILABLE:
    from flow2.frameworks.llamacpp import create_llama_model, generate_completion
```

## Examples & Workflows

### Fine-tuning with MLX
```bash
# Basic MLX fine-tuning
cd examples/mlx
python run_mlx_finetune.py

# Enhanced fine-tuning with Flash Attention
python run_mlx_finetune_improved.py --use-flash-attention --prepare-data

# Flash Attention comparison
python test_flash_attention_comparison.py
```

### Benchmarking Workflows
```bash
# Comprehensive framework comparison
cd examples/workflows
bash benchmark_comparison_workflow.sh

# MLX LoRA workflow
python mlx_lora_workflow.py

# LlamaCpp LoRA workflow  
bash llamacpp_lora_workflow.sh
```

### Chat Interfaces
```bash
# MLX chat interface
python src/flow2/chat/interfaces/cli/mlx_chat.py

# LlamaCpp chat interface
python src/flow2/chat/interfaces/cli/llamacpp_chat.py

# Web interfaces (Flask-based)
python src/flow2/chat/interfaces/web/mlx_web.py
python src/flow2/chat/interfaces/web/llamacpp_web.py
```

## Key Features

### 🚀 Multi-Framework Support
- **MLX**: Optimized for Apple Silicon with Metal acceleration
- **LlamaCpp**: Cross-platform with CPU/GPU support
- **Flash Attention**: Memory-efficient attention optimization

### 🎯 Training & Fine-tuning
- **LoRA**: Low-rank adaptation fine-tuning
- **QLoRA**: Quantized LoRA for memory efficiency
- **Full Fine-tuning**: Complete model retraining
- **Flash Attention Integration**: Automatic optimization

### 📊 Performance & Benchmarking
- **Framework Comparison**: Head-to-head MLX vs LlamaCpp
- **Quantization Analysis**: Quality vs performance trade-offs
- **Hardware Scaling**: Multi-core and memory optimization
- **Interactive Reports**: HTML dashboards with visualizations

### 💬 Chat Interfaces
- **CLI**: Terminal-based chat with both frameworks
- **Web**: Browser-based interface with real-time streaming
- **History**: Persistent conversation management
- **Templates**: Customizable prompt templates

## Framework-Specific Commands

### MLX Framework
```python
from flow2.frameworks.mlx import (
    finetune_lora,           # LoRA fine-tuning
    finetune_qlora,          # QLoRA fine-tuning  
    finetune_full,           # Full fine-tuning
    load_mlx_model,          # Model loading
    generate_completion,     # Text generation
    chat_completion,         # Chat completion
    quantize_model,          # Model quantization
    batch_quantize_models    # Batch quantization
)
```

### LlamaCpp Framework
```python
from flow2.frameworks.llamacpp import (
    finetune_lora,          # LoRA fine-tuning
    apply_lora_adapter,     # LoRA adapter application
    create_llama_model,     # Model creation
    generate_completion,    # Text generation
    chat_completion,        # Chat completion
    quantize_model,         # Model quantization
    batch_quantize_models   # Batch quantization
)
```

### Performance Tools
```python
from flow2.performance.benchmark import (
    framework_comparison,    # Compare MLX vs LlamaCpp
    quantization_comparison, # Compare quantization methods
    benchmark_workflow      # Comprehensive benchmarking
)
```

## Configuration

### Model Paths
Models are stored in `models/` directory:
```
models/
├── mlx/                    # MLX format models
│   ├── tinyllama-1.1b-chat/
│   └── qwen2.5-1.5b-instruct/
└── llamacpp/              # GGUF format models
    ├── tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf
    └── qwen2.5-1.5b-instruct-q4_k_m.gguf
```

### Training Data
Training datasets in `examples/data/`:
- `train.jsonl` - Training examples
- `valid.jsonl` - Validation examples  
- `test.jsonl` - Test examples
- Custom datasets supported

### Output Structure
Training outputs in `examples/outputs/`:
- `adapters.safetensors` - LoRA/QLoRA adapters
- `quotes_lora_adapter/` - Example fine-tuned adapter
- `qwen_enhanced/` - Enhanced model variants
- `tinyllama_enhanced/` - Enhanced model variants

## Development Guidelines

### Code Style
- Use ES modules syntax where applicable
- Follow PEP 8 for Python code
- Add type hints for all public APIs
- Include docstrings for all functions
- Prefer async/await for I/O operations

### Testing
- Run tests before committing: `pytest tests/`
- Add tests for new functionality
- Use meaningful test names
- Test both MLX and LlamaCpp code paths

### Performance
- Profile memory usage during training
- Use Flash Attention when available
- Optimize for Apple Silicon (MLX) and multi-core (LlamaCpp)
- Include benchmarks for performance-critical features

## Hardware Requirements

### Recommended for MLX
- Apple Silicon Mac (M1/M2/M3/M4)
- 16GB+ unified memory for training
- macOS 12.0+ (Monterey)

### Recommended for LlamaCpp  
- Multi-core CPU (8+ cores recommended)
- 16GB+ RAM for larger models
- GPU support optional but beneficial

## Examples

### Quick Model Inference
```python
import flow2

# MLX inference
if flow2.MLX_AVAILABLE:
    from flow2.frameworks.mlx import load_mlx_model, generate_completion
    model, tokenizer = load_mlx_model("models/mlx/tinyllama-1.1b-chat")
    response = generate_completion(model, tokenizer, "Hello, how are you?")
    print(response)

# LlamaCpp inference
if flow2.LLAMACPP_AVAILABLE:
    from flow2.frameworks.llamacpp import create_llama_model, generate_completion
    model = create_llama_model("models/llamacpp/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf")
    response = generate_completion(model, "Hello, how are you?")
    print(response)
```

### Fine-tuning Example
```python
from flow2.frameworks.mlx import finetune_lora

# Fine-tune with LoRA
finetune_lora(
    model_path="models/mlx/tinyllama-1.1b-chat",
    data_path="examples/data", 
    output_path="examples/outputs/my_adapter",
    num_iters=100,
    learning_rate=1e-4,
    use_flash_attention=True
)
```

### Benchmarking Example
```python
from flow2.performance.benchmark import framework_comparison

# Compare frameworks
results = framework_comparison(
    mlx_model="models/mlx/tinyllama-1.1b-chat",
    llamacpp_model="models/llamacpp/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf",
    prompts=["Test prompt 1", "Test prompt 2"],
    metrics=["speed", "memory", "quality"]
)
print(results)
```

## Contributing
1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality  
4. Ensure all tests pass
5. Submit a pull request

## License
MIT License - see LICENSE file for details

## Acknowledgments
- MLX team at Apple for the MLX framework
- LlamaCpp contributors for the inference engine
- Philip Turner for Metal Flash Attention research
- Hugging Face for model hosting and tools