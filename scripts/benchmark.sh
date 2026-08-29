#!/usr/bin/env bash
#
# benchmark.sh - Shell wrapper for the XSSMaze benchmark scorecard
#
# Checks the Python side is usable, then hands every argument straight to
# benchmark.py. See scripts/README.md for the scoring model and the detection
# contract a custom scanner has to satisfy.
#
#   ./benchmark.sh http://localhost:3000 --scanner nuclei
#   ./benchmark.sh http://localhost:3000 --scanner none \
#       --custom-scanner "mytool -l {URLFILE} -json" --detect-json 'results[].url'

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
            echo "Run 'pip3 install requests', or use a virtualenv:" >&2
            echo "  python3 -m venv .venv && .venv/bin/pip install requests" >&2
            echo "  .venv/bin/python ${BENCHMARK_PY} <target>" >&2
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
