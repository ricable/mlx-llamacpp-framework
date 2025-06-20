# llama.cpp for Mac with Apple Silicon

This package provides a complete setup for running llama.cpp on Mac computers with Apple Silicon (M1/M2/M3). It includes installation scripts, documentation, and utilities to help you get started with running large language models locally.

## Features

- Optimized for Apple Silicon with Metal GPU acceleration
- Easy-to-use scripts for common operations
- Comprehensive documentation and troubleshooting guide
- Follows best practices for directory organization

## Directory Structure

```
llama.cpp-setup/
├── scripts/          # Installation and utility scripts
│   └── setup.sh      # Main installation script
├── docs/             # Documentation
│   ├── download-model.md     # Model download instructions
│   ├── troubleshooting.md    # Common issues and solutions
│   └── usage-guide.md        # Usage instructions
└── models/           # Empty directory for model files
```

After running the setup script, a new `llama.cpp-runtime` directory will be created with:

```
llama.cpp-runtime/
├── llama.cpp/        # The llama.cpp source code
├── models/           # Directory for storing model files
├── logs/             # Directory for log files
├── prompts/          # Directory for storing prompt templates
├── config.sh         # Configuration settings
├── run-model.sh      # Script to run a model with a prompt
├── run-server.sh     # Script to run the llama.cpp web server
└── verify-installation.sh  # Script to verify the installation
```

## System Requirements

- Mac with Apple Silicon (M1/M2/M3)
- macOS Monterey or later (12.0+)
- At least 8GB RAM (16GB+ recommended for larger models)
- 5GB+ free storage space (more for models)

## Installation

1. Clone this repository or download the files
2. Run the setup script:

```bash
cd llama.cpp-setup
chmod +x scripts/setup.sh
./scripts/setup.sh
```

The script will:
- Install prerequisites (Xcode Command Line Tools, Homebrew)
- Clone the llama.cpp repository
- Build llama.cpp with Metal support
- Create helper scripts and configuration

## After Installation

1. Download a model (see [docs/download-model.md](docs/download-model.md))

2. Verify your installation:
```bash
cd llama.cpp-runtime
./verify-installation.sh
```

3. Run a model:
```bash
./run-model.sh models/your-model.gguf "Your prompt here"
```

4. Or start the server:
```bash
./run-server.sh models/your-model.gguf 8080
```

## Documentation

- [download-model.md](docs/download-model.md) - Instructions for downloading models
- [troubleshooting.md](docs/troubleshooting.md) - Solutions for common issues
- [usage-guide.md](docs/usage-guide.md) - Detailed usage instructions

## Quick Start Guide

After installation and downloading a model, try these commands:

```bash
# Run a basic inference
./run-model.sh models/mistral-7b-v0.1.Q4_K_M.gguf "Explain quantum computing in simple terms"

# Start the web UI server
./run-server.sh models/mistral-7b-v0.1.Q4_K_M.gguf 8080
# Then visit http://localhost:8080 in your browser
```

## Common Issues

See [docs/troubleshooting.md](docs/troubleshooting.md) for solutions to common issues.