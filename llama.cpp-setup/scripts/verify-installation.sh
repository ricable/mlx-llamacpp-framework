#!/bin/bash
# Script to verify llama.cpp installation

# Check if runtime directory exists
RUNTIME_DIR="./llama.cpp-runtime"
if [ ! -d "$RUNTIME_DIR" ]; then
    echo "Error: llama.cpp runtime directory not found at $RUNTIME_DIR"
    echo "Please run the setup.sh script first."
    exit 1
fi

# Source the configuration file if it exists
CONFIG_FILE="$RUNTIME_DIR/config.sh"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: Configuration file not found at $CONFIG_FILE"
    echo "Please run the setup.sh script first."
    exit 1
fi

echo "Verifying llama.cpp installation..."
echo

# Check if llama.cpp directory exists
if [ ! -d "$RUNTIME_DIR/llama.cpp" ]; then
    echo "Error: llama.cpp source directory not found at $RUNTIME_DIR/llama.cpp"
    exit 1
fi

echo "✓ llama.cpp source directory exists"

# Check if main binary exists
MAIN_BIN="$RUNTIME_DIR/main"
if [ ! -f "$MAIN_BIN" ]; then
    echo "Error: main binary not found at $MAIN_BIN"
    exit 1
fi

echo "✓ main binary exists"

# Check if server binary exists
SERVER_BIN="$RUNTIME_DIR/server"
if [ ! -f "$SERVER_BIN" ]; then
    echo "Error: server binary not found at $SERVER_BIN"
    exit 1
fi

echo "✓ server binary exists"

# Check if the binaries are executable
if [ ! -x "$MAIN_BIN" ]; then
    echo "Warning: main binary is not executable. Fixing permissions..."
    chmod +x "$MAIN_BIN"
fi

if [ ! -x "$SERVER_BIN" ]; then
    echo "Warning: server binary is not executable. Fixing permissions..."
    chmod +x "$SERVER_BIN"
fi

# Check Metal support
if [ "$(uname -m)" == "arm64" ]; then
    echo "Checking Metal support..."
    if otool -L "$MAIN_BIN" | grep -q Metal; then
        echo "✓ Metal framework is linked"
    else
        echo "✗ Metal framework not found in binary. Metal acceleration may not be available."
        echo "  Try rebuilding with Metal support: cmake .. -DLLAMA_METAL=ON"
    fi
fi

# Check for models directory
if [ ! -d "$RUNTIME_DIR/models" ]; then
    echo "Warning: models directory not found. Creating it..."
    mkdir -p "$RUNTIME_DIR/models"
fi

echo "✓ models directory exists"

# Check for run scripts
if [ ! -f "$RUNTIME_DIR/run-model.sh" ]; then
    echo "Error: run-model.sh script not found"
    exit 1
fi

if [ ! -f "$RUNTIME_DIR/run-server.sh" ]; then
    echo "Error: run-server.sh script not found"
    exit 1
fi

echo "✓ utility scripts exist"

# Check script permissions
if [ ! -x "$RUNTIME_DIR/run-model.sh" ]; then
    echo "Warning: run-model.sh is not executable. Fixing permissions..."
    chmod +x "$RUNTIME_DIR/run-model.sh"
fi

if [ ! -x "$RUNTIME_DIR/run-server.sh" ]; then
    echo "Warning: run-server.sh is not executable. Fixing permissions..."
    chmod +x "$RUNTIME_DIR/run-server.sh"
fi

# Check for models
MODEL_COUNT=$(find "$RUNTIME_DIR/models" -name "*.gguf" | wc -l)
if [ "$MODEL_COUNT" -eq 0 ]; then
    echo "Note: No models found in the models directory."
    echo "  Please download a model by following instructions in the docs/download-model.md file."
else
    echo "✓ Found $MODEL_COUNT model(s) in the models directory"
fi

echo
echo "✓ Verification complete. llama.cpp appears to be installed correctly."
echo
echo "Next steps:"
if [ "$MODEL_COUNT" -eq 0 ]; then
    echo "1. Download a model by following instructions in the docs/download-model.md file"
    echo "2. Run a model with: ./llama.cpp-runtime/run-model.sh <model_file> 'Your prompt here'"
    echo "3. Or start the server with: ./llama.cpp-runtime/run-server.sh <model_file> 8080"
else
    echo "1. Run a model with: ./llama.cpp-runtime/run-model.sh models/your-model.gguf 'Your prompt here'"
    echo "2. Or start the server with: ./llama.cpp-runtime/run-server.sh models/your-model.gguf 8080"
fi
echo
echo "For detailed usage instructions, see the docs/usage-guide.md file."