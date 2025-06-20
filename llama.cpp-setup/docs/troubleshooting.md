# llama.cpp Troubleshooting Guide

This document provides solutions for common issues when installing and running llama.cpp on Mac with Apple Silicon.

## Installation Issues

### Xcode Command Line Tools

**Issue**: Error message about missing compiler or build tools.

**Solution**:
```bash
xcode-select --install
```
Then follow the prompts to complete installation.

### Homebrew Installation Fails

**Issue**: Unable to install Homebrew.

**Solution**:
1. Check your internet connection
2. Try the alternate installation command:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
3. Make sure to add Homebrew to your PATH:
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### CMake Not Found

**Issue**: CMake command not found.

**Solution**:
```bash
brew install cmake
```

### Build Errors

**Issue**: Errors during the build process.

**Solution**:
1. Make sure you have the latest Xcode Command Line Tools
2. Update llama.cpp to the latest version:
```bash
cd llama.cpp
git pull
```
3. Clean and rebuild:
```bash
rm -rf build
mkdir build
cd build
cmake .. -DLLAMA_METAL=ON -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release
```

### Metal Support Issues

**Issue**: Metal acceleration not working.

**Solution**:
1. Ensure you built with Metal support:
```bash
cd llama.cpp
mkdir -p build
cd build
cmake .. -DLLAMA_METAL=ON -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release
```
2. Verify Metal framework is linked:
```bash
otool -L build/bin/main | grep Metal
```
3. Make sure you're using a recent macOS version (Monterey or later recommended)

## Runtime Issues

### Out of Memory Errors

**Issue**: Program crashes with out of memory errors.

**Solution**:
1. Use a smaller model or a more quantized version (e.g., Q4_0 instead of Q5_K_M)
2. Reduce the context size:
```bash
./main -m models/your-model.gguf --ctx-size 1024 -p "Your prompt"
```
3. Close other memory-intensive applications

### Slow Performance

**Issue**: Model runs slower than expected.

**Solution**:
1. Ensure Metal acceleration is enabled (see above)
2. Use the optimal number of threads:
```bash
./main -m models/your-model.gguf --threads $(sysctl -n hw.ncpu) -p "Your prompt"
```
3. Try a smaller or more quantized model
4. Increase batch size for more efficient processing:
```bash
./main -m models/your-model.gguf --threads $(sysctl -n hw.ncpu) --batch-size 512 -p "Your prompt"
```

### Model Not Found

**Issue**: Error that model file cannot be found.

**Solution**:
1. Make sure the model path is correct
2. If using a relative path, check your current directory
3. Use absolute paths to avoid confusion:
```bash
./main -m /absolute/path/to/models/your-model.gguf -p "Your prompt"
```

### Server Connection Issues

**Issue**: Cannot connect to the server.

**Solution**:
1. Ensure the server is running with correct port:
```bash
./server -m models/your-model.gguf --port 8080
```
2. Check if another process is using the same port
3. Try connecting to http://localhost:8080 in your browser
4. Check firewall settings if connecting from another device

## Advanced Issues

### GPU Memory Issues

**Issue**: Metal: out of memory errors.

**Solution**:
1. Use a smaller model
2. Reduce the batch size:
```bash
./main -m models/your-model.gguf --batch-size 128 -p "Your prompt"
```
3. Reduce the context size:
```bash
./main -m models/your-model.gguf --ctx-size 1024 -p "Your prompt"
```

### Compatibility Issues with Older Macs

**Issue**: Problems on older Mac models.

**Solution**:
1. Try building without Metal support:
```bash
cd llama.cpp
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release
```
2. Use smaller models and context sizes
3. Consider running with reduced parameters:
```bash
./main -m models/your-model.gguf --threads 4 --ctx-size 512 -p "Your prompt"
```

### Specific Model Issues

**Issue**: Problems with specific models.

**Solution**:
1. Try a different quantization level
2. Check the model's documentation for specific requirements
3. For newer models, ensure you have the latest version of llama.cpp