"""
Core module for Flow2
=====================

Contains core functionality including Flash Attention implementation,
baseline benchmarks, and common utilities.
"""

from .flash_attention import OptimizedMLXMultiHeadAttention, FlashAttentionBenchmark

__all__ = [
    "OptimizedMLXMultiHeadAttention",
    "FlashAttentionBenchmark",
]