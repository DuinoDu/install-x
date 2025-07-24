# install-x

A comprehensive MCP (Model Context Protocol) server that automates library installation across multiple programming languages including Python, JavaScript, Rust, C, and C++. This server provides intelligent library detection and installation capabilities with support for complex dependencies like CUDA, PyTorch, and specialized ML libraries.

## Features

- **Multi-language Support**: Python, JavaScript/Node.js, Rust, C, and C++
- **Smart Detection**: Automatically detects available package managers and libraries
- **CUDA Integration**: Intelligent CUDA version detection for PyTorch and ML libraries
- **Comprehensive Library Coverage**: Supports popular libraries across all languages
- **Cache Management**: Efficient caching system to avoid redundant installations
- **MCP Server**: Full Model Context Protocol integration for AI assistants

## Installation

### Prerequisites

- Python 3.8 or higher
- Node.js and npm (for JavaScript packages)
- Cargo (for Rust packages)
- CUDA (optional, for ML libraries)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd install-x
```

2. Install dependencies using rye:
```bash
rye sync
```

3. Activate the virtual environment:
```bash
source .venv/bin/activate
```

## Usage

### As MCP Server

#### Using MCP Inspector
```bash
npx @wong2/mcp-cli python3 src/install_x/mcp_server.py
```

#### Using Claude Desktop
Add to your Claude Desktop configuration:

```json
{
  "mcpServers": {
    "install-x": {
      "command": "python3",
      "args": ["/path/to/install-x/src/install_x/mcp_server.py"]
    }
  }
}
```

### Available Tools

#### 1. `is_supported(library_name)`
Check if a library is supported for installation.

**Parameters:**
- `library_name` (str): Name of the library to check

**Returns:**
- `library_name`: The normalized library name
- `is_supported`: Boolean indicating if the library is supported

**Example:**
```python
result = is_supported("numpy")
# Returns: {"library_name": "numpy", "is_supported": true}
```

#### 2. `install(library_name)`
Install a library in the current directory.

**Parameters:**
- `library_name` (str): Name of the library to install

**Returns:**
- `success`: Boolean indicating installation success
- `message`: Human-readable status message
- `details`: Detailed installation results for each language

**Example:**
```python
result = install("torch")
# Returns detailed installation results
```

## Supported Libraries

### Python
- **ML/AI**: torch, MinkowskiEngine, spconv, finegrasp_graspnet1b, graspnetAPI
- **General**: numpy, pandas, matplotlib, requests, flask, django
- **Data Science**: scikit-learn, tensorflow, opencv-python, pillow

### JavaScript/Node.js
- **Frameworks**: express, react, vue, angular, next.js
- **Utilities**: lodash, axios, moment, chalk
- **Development**: typescript, webpack, jest, eslint, prettier

### Rust
- **Web**: tokio, axum, rocket, reqwest
- **CLI**: clap, anyhow, thiserror
- **Database**: diesel, sqlx
- **Serialization**: serde

### C
- **System**: ssl, crypto, curl, zlib, sqlite3
- **Graphics**: png, jpeg, opengl
- **XML**: libxml2, libxslt

### C++
- **Boost**: boost-all-dev
- **Computer Vision**: opencv-dev
- **Math**: eigen3-dev
- **ML**: tensorflow-dev
- **3D**: pcl-dev

## Installation Scripts

The project includes specialized installation scripts for complex libraries:

### Available Scripts
- `torch.sh`: PyTorch with CUDA support and version detection
- `MinkowskiEngine.sh`: NVIDIA Minkowski Engine for sparse tensor operations
- `spconv.sh`: Sparse convolution library for 3D data
- `finegrasp_graspnet1b.sh`: Grasp detection models
- `graspnetAPI.sh`: GraspNet API installation
- `RoboTwin.sh`: Robotics simulation tools

### Script Features
- **Automatic CUDA Detection**: Detects CUDA version and selects appropriate PyTorch builds
- **Cache Management**: Uses local cache to speed up repeated installations
- **Dependency Resolution**: Handles complex dependency chains
- **Error Handling**: Provides helpful error messages and troubleshooting guides

## Testing

Run the comprehensive test suite:

```bash
python -m pytest tests/
```

Or run specific tests:

```bash
# Test library support detection
python -m pytest tests/test_mcp_server.py::TestLibraryInstaller::test_is_supported_known_python_library

# Test numpy installation (as requested in PRD)
python -m pytest tests/test_mcp_server.py::TestLibraryInstaller::test_numpy_specific_installation

# Run all tests with verbose output
python -m pytest tests/ -v
```

## Development

### Project Structure
```
install-x/
├── src/install_x/
│   ├── __init__.py
│   ├── mcp_server.py          # Main MCP server implementation
│   └── install/               # Installation scripts
│       ├── base.sh            # Common utilities
│       ├── torch.sh           # PyTorch installation
│       ├── MinkowskiEngine.sh # NVIDIA Minkowski Engine
│       ├── spconv.sh          # Sparse convolution
│       ├── _template.sh       # Template for new scripts
│       └── *.patch            # Patches for specific libraries
├── tests/
│   └── test_mcp_server.py     # Comprehensive test suite
├── pyproject.toml             # Project configuration
└── requirements.lock          # Locked dependencies
```

### Adding New Libraries

1. **For simple libraries**: Add to the appropriate language category in `LibraryInstaller.SUPPORTED_LANGUAGES`
2. **For complex libraries**: Create a new installation script in `src/install_x/install/`
3. **For patches**: Create `.patch` files alongside installation scripts

### Environment Variables

- `INSTALL_X_CACHE`: Custom cache directory (default: `~/.cache/install-x`)
- `FORCE_CUDA_VERSION`: Force specific CUDA version (e.g., "cu121", "cu124")
- `FORCE_INSTALL_TORCH`: Force PyTorch reinstallation even if already installed

## Examples

### Installing PyTorch with CUDA Support
```bash
# The server will automatically detect CUDA version
python3 src/install_x/mcp_server.py
# Then call: install("torch")
```

### Installing Multiple Libraries
```bash
# Check support for various libraries
python3 -c "
from install_x.mcp_server import is_supported
libraries = ['numpy', 'react', 'tokio', 'opencv-dev']
for lib in libraries:
    print(f'{lib}: {is_supported(lib)}')
"
```

### Integration with AI Assistants

When used as an MCP server, AI assistants can:
1. Query library availability before installation
2. Install required dependencies automatically
3. Handle complex installation scenarios (CUDA, GPU support, etc.)
4. Provide installation feedback and troubleshooting

## Troubleshooting

### Common Issues

1. **CUDA Detection Issues**
   - Ensure CUDA is properly installed: `nvcc --version`
   - Set `FORCE_CUDA_VERSION` if auto-detection fails

2. **Permission Errors**
   - Run with appropriate permissions for system-wide installations
   - Use virtual environments when possible

3. **Network Issues**
   - Check internet connectivity for package downloads
   - Configure proxy settings if behind corporate firewall

4. **Cache Issues**
   - Clear cache: `rm -rf ~/.cache/install-x`
   - Reset virtual environments if needed

### Getting Help

- Check the test suite for usage examples
- Review installation scripts for specific library requirements
- Examine error messages in the detailed installation results

## License

This project is provided as-is for educational and development purposes. Individual libraries installed may have their own licenses.
