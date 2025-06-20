# MLX Troubleshooting Guide for Apple Silicon

This document provides solutions for common issues when installing and running MLX and MLX-LM on Mac with Apple Silicon.

## Installation Issues

### Python Version Compatibility

**Issue**: Error messages about incompatible Python version.

**Solution**:
- MLX works best with Python 3.8 - 3.11
- Install a compatible version using Homebrew:
```bash
brew install python@3.10
```
- Create a virtual environment with the correct Python version:
```bash
python3.10 -m venv mlx-env
source mlx-env/bin/activate
```

### Pip Installation Failures

**Issue**: Errors when installing MLX via pip.

**Solution**:
1. Ensure pip is up to date:
```bash
python -m pip install --upgrade pip
```
2. Try installing with verbose output to see errors:
```bash
pip install mlx -v
```
3. If you see compilation errors, make sure Xcode Command Line Tools are installed:
```bash
xcode-select --install
```

### Virtual Environment Issues

**Issue**: Problems with virtual environments.

**Solution**:
1. Create a fresh virtual environment:
```bash
python3 -m venv fresh-env
source fresh-env/bin/activate
pip install mlx mlx-lm
```
2. If that doesn't work, try using conda:
```bash
conda create -n mlx-env python=3.10
conda activate mlx-env
pip install mlx mlx-lm
```

## Runtime Issues

### Metal Acceleration Not Working

**Issue**: MLX isn't using Metal acceleration.

**Solution**:
1. Check if Metal is available:
```python
import mlx.core as mx
print(mx.metal.is_available())
```
2. If it returns `False`:
   - Make sure you're running on Apple Silicon (M1/M2/M3)
   - Update macOS to the latest version
   - Check if other Metal apps are working
   - Restart your Mac
3. Set the default device explicitly:
```python
import mlx.core as mx
mx.set_default_device(mx.gpu)
```

### Out of Memory Errors

**Issue**: "Out of memory" errors when loading models.

**Solution**:
1. Use a more quantized model:
```python
model, tokenizer = load("llama-2-7b", quantization="int4")
```
2. Reduce batch size or context length
3. Close other memory-intensive applications
4. For larger models on systems with limited RAM:
   - Use the smallest model that meets your needs (7B instead of 13B)
   - Always use INT4 quantization on 8GB systems
   - Consider using a model from the Phi or Gemma family for 8GB systems

### Slow Performance

**Issue**: Model runs slower than expected.

**Solution**:
1. Check if Metal acceleration is working (see above)
2. Measure CPU vs GPU performance:
```python
import mlx.core as mx
import time

# Create large arrays
a = mx.random.normal((2000, 2000))
b = mx.random.normal((2000, 2000))

# Test GPU (Metal)
mx.set_default_device(mx.gpu)
start = time.time()
c = mx.matmul(a, b)
mx.eval(c)
print(f"GPU: {time.time() - start:.4f}s")

# Test CPU
mx.set_default_device(mx.cpu)
start = time.time()
c = mx.matmul(a, b)
mx.eval(c)
print(f"CPU: {time.time() - start:.4f}s")
```
3. Optimize model loading:
   - Load models once and reuse them
   - Keep models in memory between requests

### Model Not Found

**Issue**: Error that model file or directory cannot be found.

**Solution**:
1. Check that you've downloaded the model correctly:
```bash
python -m mlx_lm.download --model llama-2-7b
```
2. Make sure you're specifying the correct path:
```python
model, tokenizer = load("./llama-2-7b")  # If in current directory
```
3. Check file permissions and ownership

## Model-Specific Issues

### HuggingFace Conversion Problems

**Issue**: Errors when converting models from HuggingFace.

**Solution**:
1. Make sure you have git-lfs installed:
```bash
brew install git-lfs
```
2. For some models, you may need HuggingFace authentication:
```bash
pip install huggingface_hub
huggingface-cli login
```
3. For large models, try downloading in parts:
```bash
python -m mlx_lm.convert --hf-path meta-llama/Llama-2-7b --mlx-path llama-2-7b --revision main
```

### Quantization Issues

**Issue**: Errors during model quantization.

**Solution**:
1. Make sure you have enough memory (16GB+ recommended for quantizing 7B models)
2. If you get "out of memory" errors, try:
   - Closing other applications
   - Using a different quantization level (try INT8 instead of INT4)
   - Quantizing on a machine with more RAM
3. Use our helper script which handles memory management better:
```bash
./scripts/quantize-model.sh llama-2-7b int4
```

### Generation Quality Issues

**Issue**: Poor quality outputs after quantization.

**Solution**:
1. Try a less aggressive quantization (INT8 instead of INT4)
2. For critical applications, use FP16 (no quantization) if memory allows
3. Some models are more robust to quantization than others:
   - Mistral models typically handle quantization well
   - Gemma models are designed to work well with quantization

## Apple Silicon Specific Issues

### M1 vs M2 vs M3 Performance

**Issue**: Unexpected performance differences between chip generations.

**Facts**:
- M3 chips typically show 30-40% better performance than M1 for MLX
- M2 chips typically show 15-20% better performance than M1 for MLX
- The Ultra variants show the largest gains due to additional compute units

**Solution**:
- Adjust your expectations based on your specific chip
- For best results on M1, use smaller models or more aggressive quantization
- M3 chips have improved matrix multiplication units that benefit MLX significantly

### Memory Configuration Impacts

**Issue**: Different memory configurations yield different performance.

**Facts**:
- Unified memory architecture in Apple Silicon benefits ML workloads
- More RAM allows for larger models and longer contexts
- RAM size impacts which models you can run:
  - 8GB: Limited to 7B models with INT4 quantization
  - 16GB: Can run 7B models at INT8/FP16 or 13B models at INT4
  - 32GB: Can run 13B models at INT8/FP16 or 33B models at INT4
  - 64GB+: Can run most models at higher precision

**Solutions**:
- Match your model size and quantization to your available RAM
- For systems with limited RAM, prefer INT4 quantization
- Consider using smaller but high-quality models like Phi-2 or Gemma-2B on 8GB systems

### Thermal Throttling

**Issue**: Performance degradation during long running tasks.

**Facts**:
- MacBook Air has no fan and will thermal throttle faster
- MacBook Pro models handle sustained loads better
- Desktop Macs (Mac Mini, Mac Studio) have the best thermal performance

**Solutions**:
- On MacBook Air, use shorter generation sessions
- Ensure good ventilation for your Mac
- Monitor temperature with:
```bash
sudo powermetrics --samplers thermal
```
- Consider an external cooling pad for MacBook models during extended use

## Advanced Troubleshooting

### MLX Environment Variables

You can set these environment variables to troubleshoot MLX:

- `MLX_USE_CPU=1`: Force CPU execution instead of Metal
- `MLX_METAL_TRACE=1`: Enable Metal tracing for debugging
- `MLX_MEMPOOL_THRESHOLD`: Control memory pool allocation
- `MLX_METAL_DEBUG=1`: Enable detailed Metal debugging information
- `MLX_AUTOTUNE=0`: Disable operation auto-tuning

Example:
```bash
MLX_USE_CPU=1 python your_script.py  # Force CPU execution
```

### Checking Metal Status

Use this code to check Metal device information:

```python
import mlx.core as mx

# Check if Metal is available
print(f"Metal available: {mx.metal.is_available()}")

# Get device information
if mx.metal.is_available():
    device = mx.metal.get_device()
    print(f"Metal device name: {device.name}")
    print(f"Metal device registry ID: {device.registry_id}")
    print(f"Metal device low power: {device.low_power}")
    print(f"Metal device removable: {device.removable}")
    print(f"Metal device max transfer rate: {device.max_transfer_rate}")
    print(f"Metal device has unified memory: {device.has_unified_memory}")
```

### Profiling Performance

Use this code to profile MLX operations:

```python
import mlx.core as mx
import time

def profile_operation(operation, name, size=1000, iterations=10):
    a = mx.random.normal((size, size))
    b = mx.random.normal((size, size))
    
    # Warmup
    for _ in range(3):
        c = operation(a, b)
        mx.eval(c)
    
    # Timing
    times = []
    for _ in range(iterations):
        start = time.time()
        c = operation(a, b)
        mx.eval(c)
        times.append(time.time() - start)
    
    avg_time = sum(times) / len(times)
    print(f"{name} ({size}x{size}): {avg_time:.4f}s (avg of {iterations} runs)")

# Profile different operations
profile_operation(lambda a, b: mx.matmul(a, b), "Matrix multiplication")
profile_operation(lambda a, b: a + b, "Addition")
profile_operation(lambda a, b: mx.softmax(a) @ mx.transpose(b), "Softmax+Matmul")
```

## Common Error Messages and Solutions

### "Metal device not found"

**Cause**: Metal acceleration is not available.

**Solution**:
- Update macOS to latest version
- Check if running on Apple Silicon
- If the issue persists, fall back to CPU:
```python
import mlx.core as mx
mx.set_default_device(mx.cpu)
```

### "RuntimeError: mlx.core.array: invalid argument: shapes mismatch"

**Cause**: Incompatible array shapes in operations.

**Solution**:
- Check the shapes of your arrays:
```python
print(a.shape, b.shape)
```
- Reshape arrays as needed before operations

### "ImportError: Library not loaded: @rpath/libmlx.dylib"

**Cause**: MLX dynamic library cannot be found.

**Solution**:
- Reinstall MLX with pip:
```bash
pip uninstall -y mlx
pip install mlx
```
- Make sure you're using the same Python environment where MLX was installed

### "ValueError: is not a directory containing MLX weights or a Hugging Face repo"

**Cause**: Model path is incorrect or model files are missing.

**Solution**:
- Verify the model path exists and contains the expected files
- If using a HuggingFace model, try downloading it again:
```bash
python -m mlx_lm.download --model llama-2-7b
```

## Resources and Support

### Official Resources
- [MLX GitHub Repository](https://github.com/ml-explore/mlx)
- [MLX Documentation](https://ml-explore.github.io/mlx/build/html/index.html)
- [MLX-LM GitHub Repository](https://github.com/ml-explore/mlx-examples/tree/main/llms)
- [Apple Developer Forums](https://developer.apple.com/forums/)

### Community Resources
- [MLX Discord Community](https://discord.gg/mlx)
- [MLX Discussions on GitHub](https://github.com/ml-explore/mlx/discussions)
- [Stack Overflow - MLX Tag](https://stackoverflow.com/questions/tagged/mlx)

### Filing Bug Reports
If you encounter persistent issues not covered in this guide, please file a bug report:
- [MLX Issues on GitHub](https://github.com/ml-explore/mlx/issues)
- [MLX-LM Issues on GitHub](https://github.com/ml-explore/mlx-examples/issues)

Include the following information in your bug report:
- macOS version
- Mac model and specs (chip, RAM)
- MLX version (`pip show mlx`)
- Python version
- Complete error messages
- Minimal code example that reproduces the issue