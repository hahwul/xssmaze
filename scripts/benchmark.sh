#!/usr/bin/env bash
#
# benchmark.sh - Shell wrapper for XSSMaze benchmark tool
#
# This script provides a convenient shell interface to the Python benchmark tool.
# It handles common setup tasks and provides helpful error messages.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCHMARK_PY="${SCRIPT_DIR}/benchmark.py"

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 is required but not found in PATH" >&2
    echo "Please install Python 3 to use this tool" >&2
    exit 1
fi

# Check if benchmark.py exists
if [ ! -f "$BENCHMARK_PY" ]; then
    echo "Error: benchmark.py not found at $BENCHMARK_PY" >&2
    exit 1
fi

# Check for required Python packages
check_python_deps() {
    if ! python3 -c "import requests" 2>/dev/null; then
        echo "Warning: 'requests' package not found" >&2
        echo "Installing requests package..." >&2
        python3 -m pip install requests --quiet --user || {
            echo "Error: Failed to install requests package" >&2
            echo "Please run: pip3 install requests" >&2
            return 1
        }
    fi
}

# Show help if no arguments
if [ $# -eq 0 ]; then
    python3 "$BENCHMARK_PY" --help
    exit 0
fi

# Check dependencies before running
check_python_deps || exit 1

# Run the benchmark with all provided arguments
exec python3 "$BENCHMARK_PY" "$@"
