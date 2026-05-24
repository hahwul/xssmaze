# XSSMaze Benchmark Scripts

This directory contains automated benchmark tools for measuring XSS scanner performance against XSSMaze.

## Files

- **`benchmark.py`**: Main Python benchmark script
- **`benchmark.sh`**: Convenience shell wrapper

## Quick Start

```bash
# Start XSSMaze (in one terminal)
cd ..
./bin/xssmaze -b 0.0.0.0

# Run benchmark (in another terminal)
cd scripts
./benchmark.sh http://localhost:3000
```

## Requirements

- Python 3.x
- `requests` library (automatically installed by `benchmark.sh`)
- Optional: Scanner tools like [Nuclei](https://github.com/projectdiscovery/nuclei)

## Usage

### Basic Benchmark

```bash
python3 benchmark.py http://localhost:3000
```

### With Verbose Output

```bash
python3 benchmark.py http://localhost:3000 -v
```

### Generate Markdown Report

```bash
python3 benchmark.py http://localhost:3000 -o report.md
```

### Run Specific Scanner

```bash
python3 benchmark.py http://localhost:3000 --scanner nuclei
```

### Custom Scanner

```bash
python3 benchmark.py http://localhost:3000 \
  --custom-scanner "curl -s {URL}" \
  --custom-scanner-name "cURL"
```

## Output

The tool generates:

1. **Console Output**: Summary table with detection rates
2. **Detailed Statistics**: Breakdown by category
3. **Markdown Report** (optional): Exportable benchmark results

Example:
```
======================================================================
XSSMaze Scanner Benchmark Results
======================================================================

Target: http://localhost:3000
Total Registered Endpoints: 957
Categories: 162

Scanner              Detected     Missed       Rate         Time (s)
----------------------------------------------------------------------
Nuclei               234          723          24.5%        125.3s
```

## Adding Scanner Support

### Option 1: Custom Scanner Command

Use the `--custom-scanner` option:

```bash
python3 benchmark.py http://localhost:3000 \
  --custom-scanner "myxss {URL}" \
  --custom-scanner-name "MyScanner"
```

### Option 2: Extend benchmark.py

Add a new scanner method to `benchmark.py`:

```python
def run_my_scanner(self) -> ScannerResult:
    """Run My Scanner against endpoints."""
    import time

    self.log("\n=== Running My Scanner ===", force=True)
    start_time = time.time()
    detected = set()

    # Your scanner logic here
    for ep in self.endpoints:
        full_url = self.get_full_url(ep['url'])
        # Run your scanner and update detected set

    elapsed = time.time() - start_time
    return ScannerResult('My Scanner', detected,
                        len(self.endpoints), elapsed)
```

Then call it in the `main()` function.

## Troubleshooting

### "requests module not found"

```bash
pip3 install requests
```

### "nuclei: command not found"

Install Nuclei or skip it:
```bash
python3 benchmark.py http://localhost:3000 --scanner all
```

### "Connection refused"

Make sure XSSMaze is running and accessible:
```bash
curl http://localhost:3000/health
```

## Notes

- The benchmark tool uses the `/map/json` endpoint to discover all vulnerability scenarios
- Detection matching uses URL path comparison
- Scanners that don't output findings won't count detections
- Custom scanners need to output results to stdout or return 0 exit code for detection
