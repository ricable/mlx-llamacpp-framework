"""
Flow2: AI Model Training and Inference Toolkit
===============================================

A comprehensive toolkit for AI model training, inference, and optimization
with support for MLX and LlamaCpp frameworks, Flash Attention optimization,
and comprehensive performance utilities.

Key Features:
- Multi-framework support (MLX, LlamaCpp)
- Flash Attention integration for performance optimization
- Complete training pipeline (LoRA, QLoRA, full fine-tuning)
- Interactive chat interfaces (CLI and Web)
- Advanced quantization utilities
- Comprehensive benchmarking and performance analysis

Modules:
    core: Core functionality and Flash Attention implementation
    frameworks: Framework-specific implementations (MLX, LlamaCpp)
    chat: Interactive chat interfaces and utilities
    inference: Model inference and generation utilities
    training: Fine-tuning and training pipelines
    quantization: Model quantization utilities
    performance: Benchmarking and performance analysis
    utils: Common utilities and helpers
"""

__version__ = "1.0.0"
__author__ = "Claude Code Assistant"
__description__ = "AI Model Training and Inference Toolkit with Flash Attention"

# Core imports (conditional)
try:
    from .core import OptimizedMLXMultiHeadAttention, FlashAttentionBenchmark, FLASH_ATTENTION_AVAILABLE
except ImportError:
    OptimizedMLXMultiHeadAttention = None
    FlashAttentionBenchmark = None
    FLASH_ATTENTION_AVAILABLE = False

# Framework detection
try:
    import mlx.core as mx
    MLX_AVAILABLE = True
except ImportError:
    MLX_AVAILABLE = False

try:
    import llama_cpp
    LLAMACPP_AVAILABLE = True
except ImportError:
    LLAMACPP_AVAILABLE = False

# Framework imports based on availability
if MLX_AVAILABLE:
    from .frameworks.mlx import *

if LLAMACPP_AVAILABLE:
    from .frameworks.llamacpp import *

__all__ = [
    "OptimizedMLXMultiHeadAttention",
    "FlashAttentionBenchmark",
    "FLASH_ATTENTION_AVAILABLE",
    "MLX_AVAILABLE", 
    "LLAMACPP_AVAILABLE",
]