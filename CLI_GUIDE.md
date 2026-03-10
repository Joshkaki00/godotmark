# Command Line Interface (CLI) Guide

GodotMark supports command-line arguments for automation, CI/CD, and headless testing.

---

## Quick Start

```bash
# Show help
./godotmark --help

# Run specific benchmark
./godotmark --benchmark nature-island

# Run with custom output path
./godotmark --benchmark model-showcase --output-path ./results/test1.json

# Quick test for CI
./godotmark --quick-test --skip-intro
```

---

## Available Arguments

### Help & Version

| Argument | Short | Description |
|----------|-------|-------------|
| `--help` | `-h` | Show help message and exit |
| `--version` | `-v` | Show version information and exit |

### Benchmark Control

| Argument | Short | Description |
|----------|-------|-------------|
| `--run-benchmarks` | — | Run all benchmarks sequentially |
| `--quick-test` | — | Run 10-second quick test |
| `--benchmark NAME` | `-b NAME` | Run specific benchmark |

**Benchmark names:**
- `model-showcase` - GPU stress test with PBR materials
- `nature-island` - Draw call efficiency test

### Output Control

| Argument | Short | Description |
|----------|-------|-------------|
| `--output-path PATH` | `-o PATH` | Custom path for results JSON |

**Default:** `user://benchmark_results_<timestamp>.json`

**Examples:**
```bash
# Absolute path
--output-path /home/pi/results/benchmark.json

# Relative path
--output-path ./results/test.json

# Automatic naming with benchmark suffix
--output-path ./results.json
# → Creates: results_nature-island.json
```

### Quality Settings

| Argument | Short | Description |
|----------|-------|-------------|
| `--quality PRESET` | `-q PRESET` | Set quality preset |

**Quality presets:**
- `low` - Minimum quality, best performance
- `medium` - Balanced (default)
- `high` - High quality
- `ultra` - Maximum quality, slowest

### Miscellaneous

| Argument | Description |
|----------|-------------|
| `--skip-intro` | Skip splash screen, go straight to menu |
| `--verbose` | Enable verbose logging for debugging |

---

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `GODOTMARK_OUTPUT_DIR` | Default output directory | `/home/pi/benchmark_results` |
| `GODOTMARK_QUALITY` | Default quality preset | `low`, `medium`, `high`, `ultra` |

**Example:**
```bash
export GODOTMARK_OUTPUT_DIR="/home/pi/results"
export GODOTMARK_QUALITY="low"
./godotmark --benchmark nature-island
```

---

## Usage Examples

### Interactive Testing

```bash
# Normal launch with GUI menu
./godotmark

# Skip splash screen
./godotmark --skip-intro
```

### Automated Testing

```bash
# Run specific benchmark
./godotmark --benchmark nature-island --output-path ./results/test1.json

# Run all benchmarks
./godotmark --run-benchmarks --output-path ./results/full_test.json

# Quick CI test
./godotmark --quick-test --skip-intro --verbose
```

### Quality Testing

```bash
# Test on low quality
./godotmark --benchmark model-showcase --quality low

# Test on all quality levels
for quality in low medium high ultra; do
    ./godotmark --benchmark nature-island \
        --quality $quality \
        --output-path ./results/nature_${quality}.json
done
```

### Results Management

```bash
# Organized by date
DATE=$(date +%Y%m%d)
./godotmark --run-benchmarks --output-path ./results/${DATE}/benchmark.json

# Organized by platform
PLATFORM=$(uname -m)
./godotmark --benchmark nature-island \
    --output-path ./results/${PLATFORM}_nature.json
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Benchmark Tests

on: [push, pull_request]

jobs:
  benchmark:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build GodotMark
        run: |
          scons platform=linux target=template_release -j4
      
      - name: Run Quick Test
        run: |
          ./godotmark --quick-test --skip-intro --verbose
      
      - name: Run Full Benchmarks
        run: |
          mkdir -p results
          ./godotmark --run-benchmarks \
            --output-path results/benchmark_${{ github.sha }}.json
      
      - name: Upload Results
        uses: actions/upload-artifact@v3
        with:
          name: benchmark-results
          path: results/*.json
```

### Shell Script Example

```bash
#!/bin/bash
# run_benchmarks.sh - Automated benchmark runner

set -e

OUTPUT_DIR="./benchmark_results/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "Running GodotMark benchmarks..."
echo "Output directory: $OUTPUT_DIR"

# Run each benchmark with different quality settings
for benchmark in model-showcase nature-island; do
    for quality in low medium high; do
        echo ""
        echo "Running $benchmark on $quality quality..."
        
        ./godotmark \
            --benchmark $benchmark \
            --quality $quality \
            --output-path "$OUTPUT_DIR/${benchmark}_${quality}.json" \
            --verbose
        
        echo "✓ Complete: ${benchmark}_${quality}.json"
    done
done

echo ""
echo "All benchmarks complete!"
echo "Results saved to: $OUTPUT_DIR"
```

---

## Output Format

Results are saved as JSON files:

```json
{
  "benchmark": "Nature Island",
  "duration": 60.0,
  "platform": "Linux",
  "timestamp": "2026-02-08T19:30:45",
  "phases": {
    "phase_1": {
      "fps": [58.2, 59.1, 58.8, ...],
      "frame_times": [17.2, 16.9, 17.0, ...],
      "cpu": [...],
      "temps": [...],
      "gpu": [...],
      "timestamps": [...]
    },
    ...
  }
}
```

---

## Exit Codes

| Code | Description |
|------|-------------|
| `0` | Success |
| `1` | Invalid arguments or validation error |
| `2` | Benchmark execution error |

**Example:**
```bash
./godotmark --benchmark invalid
echo $?  # Prints: 1

./godotmark --benchmark nature-island
echo $?  # Prints: 0 (on success)
```

---

## Troubleshooting

### "Invalid benchmark name"
- Check spelling: `model-showcase` or `nature-island` (lowercase, with hyphen)

### "Output directory does not exist"
- Create the directory first: `mkdir -p /path/to/results`
- Or use relative path: `--output-path ./results/test.json`

### "Invalid quality preset"
- Valid options: `low`, `medium`, `high`, `ultra` (lowercase)

### Verbose mode not showing output
- Ensure you're running from terminal, not through IDE
- Check that logging is enabled in project settings

---

## See Also

- [`BUILD_AND_RUN.md`](BUILD_AND_RUN.md) - Build instructions
- [`TESTING_GUIDE.md`](TESTING_GUIDE.md) - Testing procedures
- [`README.md`](README.md) - Project overview

---

**Last Updated:** February 8, 2026
