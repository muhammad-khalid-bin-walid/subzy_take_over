# Subzy Takeover Scanner

## Introduction

**`subzy_take_over.sh`** is a powerful Bash script designed for security researchers and penetration testers to detect subdomain takeover vulnerabilities using the [Subzy](https://github.com/LukaSikic/subzy) tool. It enhances Subzy's functionality by supporting **parallel processing** of multiple input files, customizable configurations, and detailed output handling. With features like JSON output, verbose logging, adjustable timeouts, and concurrent scans, this script is a must-have for efficient reconnaissance workflows.

---

## Overview

`subzy_takeover.sh` automates subdomain takeover scanning with robust features:
- **Parallel Execution**: Processes multiple input files simultaneously using GNU Parallel.
- **Flexible Configuration**: Customize output formats, timeouts, concurrency, and parallel jobs.
- **Comprehensive Output**: Saves results with timestamps and provides detailed summaries.
- **User-Friendly**: Includes input validation, error handling, and clear usage instructions.

This script is ideal for large-scale subdomain analysis, ensuring speed and reliability in security assessments.

---

## Features

- 🔹 **Parallel Processing**: Scan multiple files concurrently for faster results.
- 🔹 **Flexible Input**: Accepts comma-separated input files with subdomains.
- 🔹 **Custom Output**: Save results as text or JSON in a specified directory.
- 🔹 **Configurable Parameters**: Adjust timeout, concurrency, and parallel job counts.
- 🔹 **Verbose Mode**: Detailed logging for debugging and analysis.
- 🔹 **Result Summaries**: Per-file vulnerability counts with sorted, unique findings.
- 🔹 **Robust Validation**: Checks for file existence, tool dependencies, and valid inputs.

---

## Requirements

To run `subzy_takeover.sh`, ensure the following are installed:

| Tool          | Description                              | Installation Command                              |
|---------------|------------------------------------------|--------------------------------------------------|
| **Subzy**     | Subdomain takeover detection tool        | `go install github.com/LukaSikic/subzy@latest`   |
| **GNU Parallel** | Enables parallel file processing         | `sudo apt-get install parallel`                 |
| **jq**        | JSON parsing for output analysis         | `sudo apt-get install jq`                       |
| **Bash**      | Unix-like environment with Bash          | Pre-installed on most Linux systems             |

- **Input Files**: Text files with one subdomain per line (e.g., `subdomains.txt`).

---

## Installation

1. **Install Dependencies**:

   ```bash
   # Install GNU Parallel and jq (Debian/Ubuntu)
   sudo apt-get install parallel jq
   # Install Subzy
   go install github.com/LukaSikic/subzy@latest
   ```

2. **Save the Script**:

   - Download or copy `subzy_takeover.sh`.
   - Make it executable:

     ```bash
     chmod +x subzy_takeover.sh
     ```

3. **Prepare Input Files**:

   - Create text files (e.g., `subdomains1.txt`, `subdomains2.txt`) with one subdomain per line.

---

## Usage

Run the script with the following syntax:

```bash
./subzy_take_over.sh -i <input_file1>,<input_file2>,... [-o <output_dir>] [-t <timeout>] [-c <concurrency>] [-v] [-j] [-p <parallel_jobs>]
```

### Options

| Flag | Description                              | Default Value |
|------|------------------------------------------|---------------|
| `-i` | Comma-separated list of input files (required) | None          |
| `-o` | Output directory for results            | `take_over`   |
| `-t` | Timeout per request (seconds)           | 30            |
| `-c` | Concurrent threads per file             | 50            |
| `-p` | Number of files to process in parallel  | 4             |
| `-v` | Enable verbose output                   | Disabled      |
| `-j` | Output results in JSON format           | Disabled      |

### Examples

1. **Scan a single file with verbose output**:

   ```bash
   ./subzy_takeover.sh -i subdomains.txt -o take_over -t 20 -c 100 -v
   ```

2. **Scan multiple files in parallel with JSON output**:

   ```bash
   ./subzy_take_over.sh -i subdomains1.txt,subdomains2.txt -o results -t 15 -c 50 -j -p 2
   ```

3. **Max verbosity and JSON output**:

   ```bash
   ./subzy_take_over.sh -i domains.txt -o output -v -j
   ```

---

## Output

- **Location**: Results are saved in the specified output directory (e.g., `take_over/`).
- **File Naming**: Each input file generates a unique file: `takeover_results_<basename>_<timestamp>.txt` or `.json`.
- **Summary**: Console output includes per-file vulnerability counts and unique subdomain findings.

**Example Output File**:
```
take_over/takeover_results_subdomains1_20250704_143022.txt
```

**Console Summary**:
```
[*] Summary for subdomains1.txt:
  - 2 instance(s) for vulnerable.example.com
  - 1 instance(s) for test.example.com
```

---

## Error Handling

The script ensures reliability by validating:
- **Input Files**: Checks for existence of all specified files.
- **Dependencies**: Verifies Subzy, GNU Parallel, and jq (for JSON output) are installed.
- **Numeric Inputs**: Ensures timeout, concurrency, and parallel jobs are positive integers.

Clear error messages are displayed if requirements are not met.

---

## Notes

- **Performance Tuning**: Adjust `-p` (parallel jobs) based on system resources (e.g., `-p 2` for low-resource systems).
- **JSON Output**: Requires `jq` for parsing summaries. Install it if using `-j`.
- **File Overwrites**: Timestamped filenames prevent overwriting existing results.
- **Dependencies**: Ensure all tools are installed to avoid runtime errors.

---

## License

This script is released under the [MIT License](https://opensource.org/licenses/MIT). Use it responsibly and only on systems you have permission to test.

---

## Contributing

Contributions are welcome! Submit pull requests or issues to the repository (if hosted) or contact the author for feedback and improvements.

---

## Author

Developed by **dark legende**.

---

## Disclaimer

This tool is for **authorized security testing only**. Ensure you have explicit permission to scan target subdomains. The author is not responsible for misuse or unauthorized scanning.
