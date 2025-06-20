#!/bin/bash
# setup.sh - Installation script for llama.cpp on Mac with Apple Silicon

set -e  # Exit immediately if a command exits with a non-zero status

echo "==== llama.cpp Setup for Mac with Apple Silicon ===="
echo "This script will install llama.cpp with Metal support."
echo

# Check if running on Mac with Apple Silicon
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is only for macOS systems."
    exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
    echo "Warning: This script is optimized for Apple Silicon (M1/M2/M3). You appear to be using a different architecture."
    echo "The script will continue, but Metal acceleration may not work as expected."
    echo
    read -p "Do you want to continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create directory structure
echo "Creating directory structure..."
BASEDIR="$(pwd)/llama.cpp-runtime"
mkdir -p "$BASEDIR"
mkdir -p "$BASEDIR/models"
mkdir -p "$BASEDIR/logs"
mkdir -p "$BASEDIR/prompts"

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

# Install dependencies
echo "Installing dependencies..."
brew install cmake python@3.10 git

# Clone llama.cpp repository
echo "Cloning llama.cpp repository..."
cd "$BASEDIR"
if [ ! -d "llama.cpp" ]; then
    git clone https://github.com/ggerganov/llama.cpp.git
    cd llama.cpp
else
    cd llama.cpp
    echo "Repository already exists. Pulling latest changes..."
    git pull
fi

# Build llama.cpp with Metal support
echo "Building llama.cpp with Metal support..."
mkdir -p build
cd build
cmake .. -DLLAMA_METAL=ON -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release -j$(sysctl -n hw.ncpu)

# Create convenient symlinks
echo "Creating convenient symlinks..."
cd "$BASEDIR"
ln -sf llama.cpp/build/bin/main main
ln -sf llama.cpp/build/bin/server server
ln -sf llama.cpp/models models

# Create a simple configuration file
echo "Creating configuration file..."
cat > "$BASEDIR/config.sh" << 'EOF'
#!/bin/bash
# Configuration for llama.cpp

# Base directory
export LLAMA_BASE_DIR="$(dirname "$(realpath "$0")")"

# Model directory
export LLAMA_MODEL_DIR="$LLAMA_BASE_DIR/models"

# Binary paths
export LLAMA_MAIN="$LLAMA_BASE_DIR/main"
export LLAMA_SERVER="$LLAMA_BASE_DIR/server"

# Default parameters
export LLAMA_DEFAULT_CTX_SIZE=2048
export LLAMA_DEFAULT_THREADS=$(sysctl -n hw.ncpu)
export LLAMA_DEFAULT_TEMP=0.8
export LLAMA_DEFAULT_TOP_P=0.9
EOF
chmod +x "$BASEDIR/config.sh"

# Create a simple run script
echo "Creating run script..."
cat > "$BASEDIR/run-model.sh" << 'EOF'
#!/bin/bash
# Simple script to run a model

source "$(dirname "$0")/config.sh"

if [ -z "$1" ]; then
    echo "Usage: ./run-model.sh <model_file> [prompt]"
    echo "Example: ./run-model.sh models/7B/ggml-model-q4_0.bin 'Hello, I am a'"
    exit 1
fi

MODEL="$1"
PROMPT="${2:-"Hello, I am a"}"

if [ ! -f "$MODEL" ]; then
    if [ -f "$LLAMA_MODEL_DIR/$MODEL" ]; then
        MODEL="$LLAMA_MODEL_DIR/$MODEL"
    else
        echo "Error: Model file not found: $MODEL"
        exit 1
    fi
fi

echo "Running model: $MODEL"
echo "Prompt: $PROMPT"
echo

"$LLAMA_MAIN" \
    -m "$MODEL" \
    -n 1024 \
    --metal \
    --ctx-size $LLAMA_DEFAULT_CTX_SIZE \
    --threads $LLAMA_DEFAULT_THREADS \
    --temp $LLAMA_DEFAULT_TEMP \
    --top_p $LLAMA_DEFAULT_TOP_P \
    -p "$PROMPT"
EOF
chmod +x "$BASEDIR/run-model.sh"

# Create a simple server script
echo "Creating server script..."
cat > "$BASEDIR/run-server.sh" << 'EOF'
#!/bin/bash
# Script to run llama.cpp in server mode

source "$(dirname "$0")/config.sh"

if [ -z "$1" ]; then
    echo "Usage: ./run-server.sh <model_file> [port]"
    echo "Example: ./run-server.sh models/7B/ggml-model-q4_0.bin 8080"
    exit 1
fi

MODEL="$1"
PORT="${2:-8080}"

if [ ! -f "$MODEL" ]; then
    if [ -f "$LLAMA_MODEL_DIR/$MODEL" ]; then
        MODEL="$LLAMA_MODEL_DIR/$MODEL"
    else
        echo "Error: Model file not found: $MODEL"
        exit 1
    fi
fi

echo "Starting server with model: $MODEL"
echo "Server will be available at http://localhost:$PORT"
echo "Press Ctrl+C to stop the server"
echo

"$LLAMA_SERVER" \
    -m "$MODEL" \
    --metal \
    --ctx-size $LLAMA_DEFAULT_CTX_SIZE \
    --threads $LLAMA_DEFAULT_THREADS \
    --port $PORT
EOF
chmod +x "$BASEDIR/run-server.sh"

# Create a verification script
echo "Creating verification script..."
cat > "$BASEDIR/verify-installation.sh" << 'EOF'
#!/bin/bash
# Script to verify llama.cpp installation

source "$(dirname "$0")/config.sh"

echo "Verifying llama.cpp installation..."
echo

# Check if main binary exists
if [ ! -f "$LLAMA_MAIN" ]; then
    echo "Error: main binary not found at $LLAMA_MAIN"
    exit 1
fi

echo "✓ main binary exists"

# Check if server binary exists
if [ ! -f "$LLAMA_SERVER" ]; then
    echo "Error: server binary not found at $LLAMA_SERVER"
    exit 1
fi

echo "✓ server binary exists"

# Check Metal support
if [ "$(uname -m)" == "arm64" ]; then
    echo "Checking Metal support..."
    if otool -L "$LLAMA_MAIN" | grep -q Metal; then
        echo "✓ Metal framework is linked"
    else
        echo "✗ Metal framework not found in binary. Metal acceleration may not be available."
    fi
fi

echo "✓ Verification complete. llama.cpp appears to be installed correctly."
echo
echo "Next steps:"
echo "1. Download a model to the models directory"
echo "2. Run a model with: ./run-model.sh <model_file> 'Your prompt here'"
echo "3. Or start the server with: ./run-server.sh <model_file> [port]"
EOF
chmod +x "$BASEDIR/verify-installation.sh"

# Final message
echo
echo "==== Installation Complete ===="
echo "llama.cpp has been installed to: $BASEDIR"
echo
echo "Next steps:"
echo "1. Download a model (see download-model.md in the docs directory)"
echo "2. Run the verification script: $BASEDIR/verify-installation.sh"
echo "3. Try running a model: $BASEDIR/run-model.sh <model_file> 'Your prompt here'"
echo "4. Or start the server: $BASEDIR/run-server.sh <model_file> 8080"
echo
echo "Enjoy using llama.cpp!"