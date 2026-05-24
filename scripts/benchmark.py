#!/usr/bin/env python3
"""
XSSMaze Benchmark Tool

This script runs XSS scanners against the XSSMaze lab and generates
a detection matrix scorecard showing how well each scanner performs.
"""

import argparse
import json
import subprocess
import sys
import tempfile
import os
from urllib.parse import urlparse, urljoin
from typing import List, Dict, Set, Tuple
import requests
from dataclasses import dataclass


@dataclass
class ScannerResult:
    """Represents results from a scanner run."""
    name: str
    detected_endpoints: Set[str]
    total_checked: int
    execution_time: float


class XSSMazeBenchmark:
    """Main benchmark orchestrator."""

    def __init__(self, target_url: str, verbose: bool = False):
        """
        Initialize benchmark.

        Args:
            target_url: Base URL of running XSSMaze instance
            verbose: Enable verbose output
        """
        self.target_url = target_url.rstrip('/')
        self.verbose = verbose
        self.endpoints: List[Dict] = []

    def log(self, message: str, force: bool = False):
        """Print message if verbose mode enabled."""
        if self.verbose or force:
            print(message)

    def fetch_endpoints(self) -> bool:
        """
        Fetch all XSSMaze endpoints from /map/json.

        Returns:
            True if successful, False otherwise
        """
        map_url = f"{self.target_url}/map/json"
        self.log(f"Fetching endpoints from {map_url}...", force=True)

        try:
            response = requests.get(map_url, timeout=10)
            response.raise_for_status()
            data = response.json()

            self.endpoints = data.get('endpoints', [])
            self.log(f"Retrieved {len(self.endpoints)} endpoints", force=True)
            return True

        except requests.RequestException as e:
            print(f"Error fetching endpoints: {e}", file=sys.stderr)
            return False

    def get_full_url(self, endpoint_url: str) -> str:
        """Convert relative endpoint URL to full URL."""
        if endpoint_url.startswith('http'):
            return endpoint_url
        return urljoin(self.target_url, endpoint_url)

    def run_nuclei_scanner(self) -> ScannerResult:
        """
        Run Nuclei scanner against endpoints.

        Returns:
            ScannerResult with detection data
        """
        import time

        self.log("\n=== Running Nuclei Scanner ===", force=True)
        start_time = time.time()
        detected = set()

        # Check if nuclei is available
        try:
            subprocess.run(['nuclei', '-version'],
                         capture_output=True, check=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            self.log("Nuclei not found, skipping...", force=True)
            return ScannerResult('nuclei', detected, len(self.endpoints), 0)

        # Create temporary file with URLs
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt',
                                        delete=False) as f:
            for ep in self.endpoints:
                full_url = self.get_full_url(ep['url'])
                f.write(f"{full_url}\n")
            url_file = f.name

        try:
            # Run nuclei with XSS templates
            self.log("Running nuclei (this may take a few minutes)...")

            result = subprocess.run([
                'nuclei',
                '-l', url_file,
                '-t', 'cves/',
                '-t', 'vulnerabilities/',
                '-tags', 'xss',
                '-json',
                '-silent'
            ], capture_output=True, text=True, timeout=300)

            # Parse JSON output
            for line in result.stdout.strip().split('\n'):
                if not line:
                    continue
                try:
                    finding = json.loads(line)
                    matched_url = finding.get('matched-at', '')
                    if matched_url:
                        # Extract path from matched URL
                        parsed = urlparse(matched_url)
                        path_query = parsed.path
                        if parsed.query:
                            path_query += '?' + parsed.query
                        detected.add(path_query)
                except json.JSONDecodeError:
                    continue

        except subprocess.TimeoutExpired:
            self.log("Nuclei scan timed out", force=True)
        except Exception as e:
            self.log(f"Nuclei scan error: {e}", force=True)
        finally:
            os.unlink(url_file)

        elapsed = time.time() - start_time
        self.log(f"Nuclei detected {len(detected)} endpoints in {elapsed:.1f}s")

        return ScannerResult('Nuclei', detected, len(self.endpoints), elapsed)

    def run_custom_scanner(self, name: str, command: List[str],
                          url_placeholder: str = '{URL}') -> ScannerResult:
        """
        Run a custom scanner command.

        Args:
            name: Scanner name
            command: Command to run (use {URL} as placeholder)
            url_placeholder: What to replace with each URL

        Returns:
            ScannerResult with detection data
        """
        import time

        self.log(f"\n=== Running {name} Scanner ===", force=True)
        start_time = time.time()
        detected = set()

        for ep in self.endpoints:
            full_url = self.get_full_url(ep['url'])

            # Replace URL placeholder in command
            cmd = [part.replace(url_placeholder, full_url) for part in command]

            try:
                result = subprocess.run(cmd, capture_output=True,
                                      text=True, timeout=30)

                # Simple heuristic: if exit code is 0 or output contains certain keywords
                if result.returncode == 0 or any(keyword in result.stdout.lower()
                    for keyword in ['xss', 'vulnerable', 'detected', 'found']):
                    parsed = urlparse(full_url)
                    path_query = parsed.path
                    if parsed.query:
                        path_query += '?' + parsed.query
                    detected.add(path_query)

            except (subprocess.TimeoutExpired, Exception) as e:
                self.log(f"Error scanning {full_url}: {e}")
                continue

        elapsed = time.time() - start_time
        self.log(f"{name} detected {len(detected)} endpoints in {elapsed:.1f}s")

        return ScannerResult(name, detected, len(self.endpoints), elapsed)

    def match_detections(self, detected_urls: Set[str]) -> Tuple[Set[str], Set[str]]:
        """
        Match detected URLs against registered endpoints.

        Args:
            detected_urls: Set of detected URL paths

        Returns:
            Tuple of (matched_names, unmatched_urls)
        """
        matched = set()
        unmatched = set(detected_urls)

        for detected in detected_urls:
            for ep in self.endpoints:
                ep_url = ep['url']
                ep_path = urlparse(ep_url).path
                detected_path = urlparse(detected).path

                # Match by path (exact or prefix match)
                if ep_path == detected_path or ep_url.startswith(detected):
                    matched.add(ep['name'])
                    unmatched.discard(detected)
                    break

        return matched, unmatched

    def generate_scorecard(self, results: List[ScannerResult]):
        """
        Generate and print scorecard for all scanner results.

        Args:
            results: List of ScannerResult objects
        """
        total_endpoints = len(self.endpoints)

        print("\n" + "=" * 70)
        print("XSSMaze Scanner Benchmark Results")
        print("=" * 70)
        print(f"\nTarget: {self.target_url}")
        print(f"Total Registered Endpoints: {total_endpoints}")
        print(f"Categories: {len(set(ep['type'] for ep in self.endpoints))}")
        print()

        if not results:
            print("No scanner results available.")
            return

        # Print summary table
        print(f"{'Scanner':<20} {'Detected':<12} {'Missed':<12} {'Rate':<12} {'Time (s)':<12}")
        print("-" * 70)

        for result in results:
            matched, _ = self.match_detections(result.detected_endpoints)
            detected_count = len(matched)
            missed_count = total_endpoints - detected_count
            detection_rate = (detected_count / total_endpoints * 100) if total_endpoints > 0 else 0

            print(f"{result.name:<20} {detected_count:<12} {missed_count:<12} "
                  f"{detection_rate:<11.1f}% {result.execution_time:<11.1f}s")

        print()

        # Print detailed breakdown for each scanner
        for result in results:
            matched, unmatched = self.match_detections(result.detected_endpoints)
            detected_count = len(matched)
            missed_count = total_endpoints - detected_count

            print(f"\n--- {result.name} Detailed Results ---")
            print(f"✓ True Positives: {detected_count}/{total_endpoints}")
            print(f"✗ False Negatives (Missed): {missed_count}/{total_endpoints}")

            if self.verbose and matched:
                print("\nDetected endpoints:")
                for name in sorted(matched):
                    print(f"  ✓ {name}")

            # Calculate missed by category
            if missed_count > 0:
                missed_by_category = {}
                for ep in self.endpoints:
                    if ep['name'] not in matched:
                        cat = ep['type']
                        missed_by_category[cat] = missed_by_category.get(cat, 0) + 1

                print("\nMissed by category:")
                for cat, count in sorted(missed_by_category.items(),
                                        key=lambda x: x[1], reverse=True):
                    total_in_cat = sum(1 for ep in self.endpoints
                                     if ep['type'] == cat)
                    print(f"  {cat}: {count}/{total_in_cat} missed")

    def generate_markdown_report(self, results: List[ScannerResult],
                                output_file: str):
        """
        Generate markdown report file.

        Args:
            results: List of ScannerResult objects
            output_file: Path to output markdown file
        """
        total_endpoints = len(self.endpoints)

        with open(output_file, 'w') as f:
            f.write("# XSSMaze Scanner Benchmark Report\n\n")
            f.write(f"**Target:** `{self.target_url}`  \n")
            f.write(f"**Total Endpoints:** {total_endpoints}  \n")
            f.write(f"**Categories:** {len(set(ep['type'] for ep in self.endpoints))}  \n\n")

            f.write("## Summary\n\n")
            f.write("| Scanner | Detected | Missed | Detection Rate | Time (s) |\n")
            f.write("|---------|----------|--------|----------------|----------|\n")

            for result in results:
                matched, _ = self.match_detections(result.detected_endpoints)
                detected_count = len(matched)
                missed_count = total_endpoints - detected_count
                detection_rate = (detected_count / total_endpoints * 100) if total_endpoints > 0 else 0

                f.write(f"| {result.name} | {detected_count} | {missed_count} | "
                       f"{detection_rate:.1f}% | {result.execution_time:.1f}s |\n")

            f.write("\n## Detailed Results\n\n")

            for result in results:
                matched, _ = self.match_detections(result.detected_endpoints)
                detected_count = len(matched)
                missed_count = total_endpoints - detected_count

                f.write(f"### {result.name}\n\n")
                f.write(f"- **True Positives:** {detected_count}/{total_endpoints}\n")
                f.write(f"- **False Negatives:** {missed_count}/{total_endpoints}\n")

                # Missed by category
                if missed_count > 0:
                    missed_by_category = {}
                    for ep in self.endpoints:
                        if ep['name'] not in matched:
                            cat = ep['type']
                            missed_by_category[cat] = missed_by_category.get(cat, 0) + 1

                    f.write("\n**Missed by Category:**\n\n")
                    for cat, count in sorted(missed_by_category.items(),
                                           key=lambda x: x[1], reverse=True):
                        total_in_cat = sum(1 for ep in self.endpoints
                                         if ep['type'] == cat)
                        f.write(f"- `{cat}`: {count}/{total_in_cat} missed\n")

                f.write("\n")

        print(f"\nMarkdown report saved to: {output_file}")


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Benchmark XSS scanners against XSSMaze',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Benchmark against local instance
  python benchmark.py http://localhost:3000

  # Run with verbose output
  python benchmark.py http://localhost:3000 -v

  # Generate markdown report
  python benchmark.py http://localhost:3000 -o report.md

  # Run specific scanners only
  python benchmark.py http://localhost:3000 --scanner nuclei

  # Run with custom scanner command
  python benchmark.py http://localhost:3000 --custom-scanner "myxss {URL}"
        """
    )

    parser.add_argument('target_url',
                       help='Target URL of running XSSMaze instance')

    parser.add_argument('-v', '--verbose',
                       action='store_true',
                       help='Enable verbose output')

    parser.add_argument('-o', '--output',
                       metavar='FILE',
                       help='Output markdown report to FILE')

    parser.add_argument('--scanner',
                       choices=['nuclei', 'all'],
                       default='all',
                       help='Scanner to run (default: all available)')

    parser.add_argument('--custom-scanner',
                       metavar='COMMAND',
                       help='Custom scanner command (use {URL} as placeholder)')

    parser.add_argument('--custom-scanner-name',
                       metavar='NAME',
                       default='Custom',
                       help='Name for custom scanner')

    args = parser.parse_args()

    # Initialize benchmark
    benchmark = XSSMazeBenchmark(args.target_url, verbose=args.verbose)

    # Fetch endpoints
    if not benchmark.fetch_endpoints():
        return 1

    if len(benchmark.endpoints) == 0:
        print("No endpoints found. Is XSSMaze running?", file=sys.stderr)
        return 1

    # Run scanners
    results = []

    if args.scanner == 'all' or args.scanner == 'nuclei':
        results.append(benchmark.run_nuclei_scanner())

    if args.custom_scanner:
        cmd = args.custom_scanner.split()
        results.append(
            benchmark.run_custom_scanner(args.custom_scanner_name, cmd)
        )

    # Generate reports
    benchmark.generate_scorecard(results)

    if args.output:
        benchmark.generate_markdown_report(results, args.output)

    return 0


if __name__ == '__main__':
    sys.exit(main())
