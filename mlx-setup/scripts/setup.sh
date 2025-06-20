#!/bin/bash
# setup.sh - Installation script for MLX and MLX-LM on Mac with Apple Silicon

set -e  # Exit immediately if a command exits with a non-zero status

echo "==== MLX and MLX-LM Setup for Mac with Apple Silicon ===="
echo "This script will install MLX and MLX-LM frameworks optimized for Apple Silicon."
echo

# Check if running on Mac with Apple Silicon
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is only for macOS systems."
    exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
    echo "Warning: This script is optimized for Apple Silicon (M1/M2/M3). You appear to be using a different architecture."
    echo "The script will continue, but performance may not be as expected."
    echo
    read -p "Do you want to continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create directory structure
echo "Creating directory structure..."
BASEDIR="$(pwd)/mlx-runtime"
mkdir -p "$BASEDIR"
mkdir -p "$BASEDIR/models"
mkdir -p "$BASEDIR/logs"
mkdir -p "$BASEDIR/scripts"

# Install Xcode Command Line Tools if not already installed
echo "Checking for Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "A dialog should have appeared to install Xcode Command Line Tools."
    echo "Please complete the installation and then press Enter to continue."
    read -p "Press Enter when Xcode Command Line Tools installation is complete..." 
fi

# Check if Homebrew is installed
echo "Checking for Homebrew..."
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Check if Python is installed
echo "Checking for Python..."
if ! command -v python3 &>/dev/null; then
    echo "Installing Python..."
    brew install python@3.10
fi

# Install pip if not already installed
echo "Checking for pip..."
if ! python3 -m pip --version &>/dev/null; then
    echo "Installing pip..."
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python3 get-pip.py
    rm get-pip.py
fi

# Setup Python virtual environment
echo "Setting up Python virtual environment..."
python3 -m pip install --upgrade pip
python3 -m pip install virtualenv

# Create and activate virtual environment
cd "$BASEDIR"
python3 -m virtualenv venv
source venv/bin/activate

# Install MLX and MLX-LM
echo "Installing MLX and MLX-LM frameworks..."
pip install mlx mlx-lm

# Create a configuration file
echo "Creating configuration file..."
cat > "$BASEDIR/config.sh" << 'EOF'
#!/bin/bash
# Configuration for MLX

# Base directory
export MLX_BASE_DIR="$(dirname "$(realpath "$0")")"

# Model directory
export MLX_MODEL_DIR="$MLX_BASE_DIR/models"

# Python environment
export MLX_PYTHON="$MLX_BASE_DIR/venv/bin/python3"

# Default parameters
export MLX_DEFAULT_CTX_SIZE=2048
export MLX_DEFAULT_TEMP=0.7
export MLX_DEFAULT_TOP_P=0.9
export MLX_DEFAULT_TOP_K=40
EOF
chmod +x "$BASEDIR/config.sh"

# Create helper scripts
echo "Creating helper scripts..."

# Model downloader script
cat > "$BASEDIR/scripts/download-model.sh" << 'EOF'
#!/bin/bash
# Script to download models for MLX

source "$(dirname "$(dirname "$0")")/config.sh"

if [ -z "$1" ]; then
    echo "Usage: ./download-model.sh <model_name>"
    echo "Example: ./download-model.sh llama-2-7b"
    echo
    echo "Available models:"
    echo "  - llama-2-7b: Meta's LLaMA 2 7B model"
    echo "  - mistral-7b-v0.1: Mistral AI's 7B model"
    echo "  - phi-2: Microsoft's Phi-2 model"
    echo "  - gemma-2b: Google's Gemma 2B model"
    echo "  - gemma-7b: Google's Gemma 7B model"
    exit 1
fi

MODEL_NAME="$1"

echo "Downloading model: $MODEL_NAME"
cd "$MLX_BASE_DIR"
source venv/bin/activate
python -m mlx_lm.download --model "$MODEL_NAME"

echo "Model downloaded successfully to: $MLX_BASE_DIR/$MODEL_NAME"
echo "You can now run the model with: ./run-model.sh $MODEL_NAME"
EOF
chmod +x "$BASEDIR/scripts/download-model.sh"

# Model converter script
cat > "$BASEDIR/scripts/convert-model.sh" << 'EOF'
#!/bin/bash
# Script to convert models from Hugging Face to MLX format

source "$(dirname "$(dirname "$0")")/config.sh"

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./convert-model.sh <huggingface_model_path> <output_dir_name>"
    echo "Example: ./convert-model.sh meta-llama/Llama-2-7b llama-2-7b-custom"
    exit 1
fi

HF_MODEL_PATH="$1"
OUTPUT_DIR="$2"

echo "Converting model from Hugging Face: $HF_MODEL_PATH"
echo "Output directory: $MLX_BASE_DIR/$OUTPUT_DIR"

cd "$MLX_BASE_DIR"
source venv/bin/activate
python -m mlx_lm.convert --hf-path "$HF_MODEL_PATH" --mlx-path "$OUTPUT_DIR"

echo "Model converted successfully to: $MLX_BASE_DIR/$OUTPUT_DIR"
echo "You can now run the model with: ./run-model.sh $OUTPUT_DIR"
EOF
chmod +x "$BASEDIR/scripts/convert-model.sh"

# Model quantizer script
cat > "$BASEDIR/scripts/quantize-model.sh" << 'EOF'
#!/bin/bash
# Script to quantize MLX models

source "$(dirname "$(dirname "$0")")/config.sh"

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./quantize-model.sh <model_dir> <quantization>"
    echo "Example: ./quantize-model.sh llama-2-7b int4"
    echo
    echo "Available quantization options:"
    echo "  - int4: 4-bit integer quantization (75% size reduction)"
    echo "  - int8: 8-bit integer quantization (50% size reduction)"
    exit 1
fi

MODEL_DIR="$1"
QUANT_TYPE="$2"

if [[ "$QUANT_TYPE" != "int4" && "$QUANT_TYPE" != "int8" ]]; then
    echo "Error: Invalid quantization type. Must be 'int4' or 'int8'."
    exit 1
fi

echo "Quantizing model: $MODEL_DIR with $QUANT_TYPE quantization"

# Create Python script for quantization
TEMP_SCRIPT="$MLX_BASE_DIR/quantize_temp.py"
cat > "$TEMP_SCRIPT" << PYEOF
import os
import mlx.core as mx
from mlx_lm import load, save
from mlx_lm.utils import quantize_model

# Load the model
print(f"Loading model from {os.path.join(os.getcwd(), '$MODEL_DIR')}")
model, tokenizer = load("$MODEL_DIR")

# Quantize the model
print(f"Quantizing model to $QUANT_TYPE")
nbits = 4 if "$QUANT_TYPE" == "int4" else 8
model = quantize_model(model, nbits=nbits, group_size=64)

# Save the quantized model
output_dir = "${MODEL_DIR}_${QUANT_TYPE}"
print(f"Saving quantized model to {os.path.join(os.getcwd(), output_dir)}")
save(output_dir, model, tokenizer)
print("Quantization complete")
PYEOF

cd "$MLX_BASE_DIR"
source venv/bin/activate
python "$TEMP_SCRIPT"
rm "$TEMP_SCRIPT"

echo "Model quantized successfully to: $MLX_BASE_DIR/${MODEL_DIR}_${QUANT_TYPE}"
echo "You can now run the model with: ./run-model.sh ${MODEL_DIR}_${QUANT_TYPE}"
EOF
chmod +x "$BASEDIR/scripts/quantize-model.sh"

# Run model script
cat > "$BASEDIR/run-model.sh" << 'EOF'
#!/bin/bash
# Script to run an MLX model

source "$(dirname "$0")/config.sh"

if [ -z "$1" ]; then
    echo "Usage: ./run-model.sh <model_dir> [prompt] [options]"
    echo "Example: ./run-model.sh llama-2-7b \"Tell me about Apple Silicon\""
    echo
    echo "Options:"
    echo "  --temp <value>      : Temperature (default: 0.7)"
    echo "  --top-p <value>     : Top-p sampling (default: 0.9)"
    echo "  --top-k <value>     : Top-k sampling (default: 40)"
    echo "  --max-tokens <value>: Maximum tokens to generate (default: 512)"
    echo "  --quantization <type>: Model quantization (int4, int8, none)"
    echo "  --interactive       : Run in interactive chat mode"
    exit 1
fi

MODEL_DIR="$1"
shift

# Check if model exists
if [ ! -d "$MLX_BASE_DIR/$MODEL_DIR" ]; then
    echo "Error: Model directory not found: $MLX_BASE_DIR/$MODEL_DIR"
    echo "Please download or convert a model first."
    exit 1
fi

# Parse options
TEMP="$MLX_DEFAULT_TEMP"
TOP_P="$MLX_DEFAULT_TOP_P"
TOP_K="$MLX_DEFAULT_TOP_K"
MAX_TOKENS=512
QUANTIZATION=""
INTERACTIVE=false
PROMPT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --temp)
            TEMP="$2"
            shift 2
            ;;
        --top-p)
            TOP_P="$2"
            shift 2
            ;;
        --top-k)
            TOP_K="$2"
            shift 2
            ;;
        --max-tokens)
            MAX_TOKENS="$2"
            shift 2
            ;;
        --quantization)
            QUANTIZATION="$2"
            shift 2
            ;;
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        *)
            PROMPT="$1"
            shift
            ;;
    esac
done

cd "$MLX_BASE_DIR"
source venv/bin/activate

if [ "$INTERACTIVE" = true ]; then
    # Create temporary chat script
    CHAT_SCRIPT="$MLX_BASE_DIR/chat_temp.py"
    cat > "$CHAT_SCRIPT" << PYEOF
import mlx.core as mx
from mlx_lm import load, generate

# Load model
quant = "$QUANTIZATION" if "$QUANTIZATION" in ["int4", "int8"] else None
model, tokenizer = load("$MODEL_DIR", quantization=quant)

# Chat loop
history = "You are a helpful assistant.\n\n"
print("Assistant: Hello! How can I help you today?")

while True:
    try:
        user_input = input("\nYou: ")
        if user_input.lower() in ["exit", "quit", "bye"]:
            print("\nAssistant: Goodbye!")
            break
            
        prompt = history + f"User: {user_input}\nAssistant: "
        history = prompt
        
        print("\nAssistant: ", end="", flush=True)
        response = ""
        for token in generate(
            model, 
            tokenizer, 
            prompt, 
            max_tokens=$MAX_TOKENS,
            temp=$TEMP,
            top_p=$TOP_P,
            top_k=$TOP_K,
            stream=True
        ):
            print(token, end="", flush=True)
            response += token
        
        history += response + "\n"
    except KeyboardInterrupt:
        print("\n\nExiting chat...")
        break
PYEOF

    python "$CHAT_SCRIPT"
    rm "$CHAT_SCRIPT"
else
    # Create temporary inference script
    INFER_SCRIPT="$MLX_BASE_DIR/infer_temp.py"
    cat > "$INFER_SCRIPT" << PYEOF
import mlx.core as mx
from mlx_lm import load, generate

# Load model
quant = "$QUANTIZATION" if "$QUANTIZATION" in ["int4", "int8"] else None
model, tokenizer = load("$MODEL_DIR", quantization=quant)

# Generate text
prompt = """$PROMPT"""
print(f"Prompt: {prompt}")
print("\nGenerating response...\n")

tokens = generate(
    model, 
    tokenizer, 
    prompt, 
    max_tokens=$MAX_TOKENS,
    temp=$TEMP,
    top_p=$TOP_P,
    top_k=$TOP_K
)

print(tokenizer.decode(tokens))
PYEOF

    python "$INFER_SCRIPT"
    rm "$INFER_SCRIPT"
fi
EOF
chmod +x "$BASEDIR/run-model.sh"

# Create a chat script
cat > "$BASEDIR/chat.sh" << 'EOF'
#!/bin/bash
# Simple wrapper to start chat mode

source "$(dirname "$0")/config.sh"

if [ -z "$1" ]; then
    echo "Usage: ./chat.sh <model_dir> [options]"
    echo "Example: ./chat.sh llama-2-7b --quantization int4"
    exit 1
fi

MODEL_DIR="$1"
shift

"$MLX_BASE_DIR/run-model.sh" "$MODEL_DIR" --interactive "$@"
EOF
chmod +x "$BASEDIR/chat.sh"

# Create verification script
cat > "$BASEDIR/verify-installation.sh" << 'EOF'
#!/bin/bash
# Script to verify MLX installation

source "$(dirname "$0")/config.sh"

echo "Verifying MLX installation..."
echo

# Check Python installation
if ! command -v python3 &>/dev/null; then
    echo "Error: Python not found"
    exit 1
fi

echo "✓ Python is installed"

# Check virtual environment
if [ ! -d "$MLX_BASE_DIR/venv" ]; then
    echo "Error: Virtual environment not found at $MLX_BASE_DIR/venv"
    exit 1
fi

echo "✓ Virtual environment exists"

# Activate virtual environment and check MLX installation
cd "$MLX_BASE_DIR"
source venv/bin/activate

# Check MLX
if ! pip list | grep -q "mlx "; then
    echo "Error: MLX not installed"
    exit 1
fi

echo "✓ MLX is installed: $(pip list | grep 'mlx ' | awk '{print $2}')"

# Check MLX-LM
if ! pip list | grep -q "mlx-lm"; then
    echo "Error: MLX-LM not installed"
    exit 1
fi

echo "✓ MLX-LM is installed: $(pip list | grep 'mlx-lm' | awk '{print $2}')"

# Check if Metal is available
python -c "import mlx.core as mx; print('✓ Metal is available' if mx.metal.is_available() else '✗ Metal is not available')"

# Check for models directory
if [ ! -d "$MLX_MODEL_DIR" ]; then
    echo "Warning: models directory not found. Creating it..."
    mkdir -p "$MLX_MODEL_DIR"
fi

echo "✓ models directory exists"

# Check for scripts
if [ ! -f "$MLX_BASE_DIR/scripts/download-model.sh" ] || [ ! -f "$MLX_BASE_DIR/scripts/convert-model.sh" ]; then
    echo "Error: helper scripts not found"
    exit 1
fi

echo "✓ helper scripts exist"

# Check script permissions
if [ ! -x "$MLX_BASE_DIR/scripts/download-model.sh" ]; then
    echo "Warning: download-model.sh is not executable. Fixing permissions..."
    chmod +x "$MLX_BASE_DIR/scripts/download-model.sh"
fi

if [ ! -x "$MLX_BASE_DIR/scripts/convert-model.sh" ]; then
    echo "Warning: convert-model.sh is not executable. Fixing permissions..."
    chmod +x "$MLX_BASE_DIR/scripts/convert-model.sh"
fi

if [ ! -x "$MLX_BASE_DIR/scripts/quantize-model.sh" ]; then
    echo "Warning: quantize-model.sh is not executable. Fixing permissions..."
    chmod +x "$MLX_BASE_DIR/scripts/quantize-model.sh"
fi

# Check for models
MODEL_COUNT=$(find "$MLX_BASE_DIR" -type d -maxdepth 1 -name "llama-*" -o -name "mistral-*" -o -name "phi-*" -o -name "gemma-*" | wc -l)
if [ "$MODEL_COUNT" -eq 0 ]; then
    echo "Note: No models found in the runtime directory."
    echo "  Please download a model using the scripts/download-model.sh script."
else
    echo "✓ Found $MODEL_COUNT model(s) in the runtime directory"
fi

# Basic MLX test
echo "Running basic MLX test..."
python -c "
import mlx.core as mx
import numpy as np

# Create a simple array
a = mx.array([[1, 2, 3], [4, 5, 6]])
b = mx.array([[7, 8, 9], [10, 11, 12]])

# Perform operations
c = mx.add(a, b)
d = mx.matmul(a, mx.transpose(b))

# Convert back to numpy for printing
print('MLX test successful!')
print('Sample operations:')
print(f'a + b = {np.array(c)}')
print(f'a @ b.T = {np.array(d)}')
"

echo
echo "✓ Verification complete. MLX appears to be installed correctly."
echo
echo "Next steps:"
if [ "$MODEL_COUNT" -eq 0 ]; then
    echo "1. Download a model using: $MLX_BASE_DIR/scripts/download-model.sh <model_name>"
    echo "   Example: $MLX_BASE_DIR/scripts/download-model.sh llama-2-7b"
    echo "2. Run a model with: $MLX_BASE_DIR/run-model.sh <model_dir> \"Your prompt here\""
    echo "3. Or start a chat with: $MLX_BASE_DIR/chat.sh <model_dir>"
else
    # Extract model name from found directories
    MODEL_NAME=$(find "$MLX_BASE_DIR" -type d -maxdepth 1 -name "llama-*" -o -name "mistral-*" -o -name "phi-*" -o -name "gemma-*" | head -1 | xargs basename)
    echo "1. Run a model with: $MLX_BASE_DIR/run-model.sh $MODEL_NAME \"Your prompt here\""
    echo "2. Or start a chat with: $MLX_BASE_DIR/chat.sh $MODEL_NAME"
    echo "3. Quantize the model with: $MLX_BASE_DIR/scripts/quantize-model.sh $MODEL_NAME int4"
fi
echo
echo "For detailed usage instructions, see the docs directory."
EOF
chmod +x "$BASEDIR/verify-installation.sh"

# Create a simple test script
cat > "$BASEDIR/test-mlx.py" << 'EOF'
#!/usr/bin/env python3
# Simple test script for MLX

import mlx.core as mx
import numpy as np
import time
import os

def run_basic_operations():
    print("Testing basic MLX operations...")
    
    # Create arrays
    a = mx.random.normal((1000, 1000))
    b = mx.random.normal((1000, 1000))
    
    # Time matrix multiplication
    start = time.time()
    c = mx.matmul(a, b)
    mx.eval(c)  # Force evaluation
    end = time.time()
    
    print(f"Matrix multiplication (1000x1000): {end - start:.4f} seconds")
    
    # Test other operations
    start = time.time()
    d = mx.softmax(a, axis=1)
    e = mx.sigmoid(b)
    f = mx.relu(mx.add(d, e))
    mx.eval(f)
    end = time.time()
    
    print(f"Combined operations: {end - start:.4f} seconds")
    return True

def check_metal_performance():
    print("\nChecking Metal performance...")
    
    # Compare CPU vs GPU (Metal) performance
    array_size = 2000
    
    # Create large arrays
    a = mx.random.normal((array_size, array_size))
    b = mx.random.normal((array_size, array_size))
    
    # CPU computation
    mx.set_default_device(mx.cpu)
    start = time.time()
    c_cpu = mx.matmul(a, b)
    mx.eval(c_cpu)
    cpu_time = time.time() - start
    
    # GPU (Metal) computation
    if mx.metal.is_available():
        mx.set_default_device(mx.gpu)
        start = time.time()
        c_gpu = mx.matmul(a, b)
        mx.eval(c_gpu)
        gpu_time = time.time() - start
        
        speedup = cpu_time / gpu_time
        print(f"CPU time: {cpu_time:.4f} seconds")
        print(f"GPU time: {gpu_time:.4f} seconds")
        print(f"Metal speedup: {speedup:.2f}x")
        
        if speedup > 1.5:
            print("✓ Metal acceleration is working correctly")
            return True
        else:
            print("⚠ Metal acceleration seems slower than expected")
            return False
    else:
        print("✗ Metal is not available on this system")
        return False

def check_system_info():
    print("\nSystem information:")
    
    # Python version
    import sys
    print(f"Python version: {sys.version.split()[0]}")
    
    # MLX version
    import mlx
    print(f"MLX version: {mlx.__version__}")
    
    # OS information
    import platform
    print(f"Platform: {platform.platform()}")
    
    # CPU information
    os.system("sysctl -n machdep.cpu.brand_string")
    
    # Memory information
    os.system("top -l 1 -s 0 | grep PhysMem")

def main():
    print("===== MLX Test Suite =====")
    check_system_info()
    
    basic_ops = run_basic_operations()
    metal_perf = check_metal_performance()
    
    print("\n===== Test Results =====")
    print(f"Basic operations: {'✓ Passed' if basic_ops else '✗ Failed'}")
    print(f"Metal performance: {'✓ Passed' if metal_perf else '⚠ Needs investigation'}")
    
    if basic_ops:
        print("\n✓ MLX is working correctly on this system")
        if not metal_perf:
            print("  Note: Metal acceleration may not be optimal")
    else:
        print("\n✗ MLX tests failed, please check your installation")

if __name__ == "__main__":
    main()
EOF
chmod +x "$BASEDIR/test-mlx.py"

# Final message
echo
echo "==== Installation Complete ===="
echo "MLX and MLX-LM have been installed to: $BASEDIR"
echo
echo "Next steps:"
echo "1. Run the verification script: $BASEDIR/verify-installation.sh"
echo "2. Download a model: $BASEDIR/scripts/download-model.sh llama-2-7b"
echo "3. Try running a model: $BASEDIR/run-model.sh llama-2-7b \"Tell me about Apple Silicon\""
echo "4. Or start a chat: $BASEDIR/chat.sh llama-2-7b"
echo
echo "For detailed documentation, see the docs directory."
echo "Enjoy using MLX!"