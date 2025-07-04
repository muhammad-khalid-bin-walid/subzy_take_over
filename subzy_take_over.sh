#!/bin/bash

# Script to run Subzy for subdomain takeover detection on multiple files in parallel
# Usage: ./subzy_takeover.sh -i <input_file1>,<input_file2>,... [-o <output_dir>] [-t <timeout>] [-c <concurrency>] [-v] [-j] [-p <parallel_jobs>]

# Function to display usage
usage() {
    echo "Usage: $0 -i <input_file1>,<input_file2>,... [-o <output_dir>] [-t <timeout>] [-c <concurrency>] [-v] [-j] [-p <parallel_jobs>]"
    echo "Options:"
    echo "  -i <input_files>    Comma-separated list of input files containing subdomains"
    echo "  -o <output_dir>     Output directory (default: take_over)"
    echo "  -t <timeout>        Timeout in seconds for each request (default: 30)"
    echo "  -c <concurrency>    Number of concurrent threads per file (default: 50)"
    echo "  -v                  Enable verbose output"
    echo "  -j                  Output results in JSON format"
    echo "  -p <parallel_jobs>  Number of files to process in parallel (default: 4)"
    echo "Example: $0 -i subdomains1.txt,subdomains2.txt -o take_over -t 20 -c 100 -v -j -p 2"
    exit 1
}

# Default values
OUTPUT_DIR="take_over"
TIMEOUT=30
CONCURRENCY=50
VERBOSE=false
JSON_OUTPUT=false
PARALLEL_JOBS=4
INPUT_FILES=()

# Parse command line options
while getopts "i:o:t:c:p:vj" opt; do
    case $opt in
        i) IFS=',' read -r -a INPUT_FILES <<< "$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        t) TIMEOUT="$OPTARG" ;;
        c) CONCURRENCY="$OPTARG" ;;
        p) PARALLEL_JOBS="$OPTARG" ;;
        v) VERBOSE=true ;;
        j) JSON_OUTPUT=true ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
    esac
done

# Check if input files are provided
if [ ${#INPUT_FILES[@]} -eq 0 ]; then
    echo "Error: At least one input file is required!"
    usage
fi

# Validate input files
for file in "${INPUT_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Error: Input file '$file' not found!"
        exit 1
    fi
done

# Validate numeric inputs
if ! [[ "$TIMEOUT" =~ ^[0-9]+$ ]] || [ "$TIMEOUT" -le 0 ]; then
    echo "Error: Timeout must be a positive integer!"
    exit 1
fi

if ! [[ "$CONCURRENCY" =~ ^[0-9]+$ ]] || [ "$CONCURRENCY" -le 0 ]; then
    echo "Error: Concurrency must be a positive integer!"
    exit 1
fi

if ! [[ "$PARALLEL_JOBS" =~ ^[0-9]+$ ]] || [ "$PARALLEL_JOBS" -le 0 ]; then
    echo "Error: Parallel jobs must be a positive integer!"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check if Subzy is installed
if ! command -v subzy &> /dev/null; then
    echo "Error: Subzy is not installed. Please install it first."
    exit 1
fi

# Check if GNU Parallel is installed
if ! command -v parallel &> /dev/null; then
    echo "Error: GNU Parallel is not installed. Please install it first (e.g., 'sudo apt-get install parallel')."
    exit 1
fi

# Function to process a single file
process_file() {
    local input_file="$1"
    local output_dir="$2"
    local timeout="$3"
    local concurrency="$4"
    local verbose="$5"
    local json_output="$6"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local base_name=$(basename "$input_file" | sed 's/\.[^.]*$//')
    local output_file="${output_dir}/takeover_results_${base_name}_${timestamp}"
    [ "$json_output" = true ] && output_file="${output_file}.json" || output_file="${output_file}.txt"
    local subzy_args="--hide_fails --timeout $timeout --concurrency $concurrency"
    [ "$verbose" = true ] && subzy_args="$subzy_args --verbose"
    [ "$json_output" = true ] && subzy_args="$subzy_args --output json"

    echo "[*] Processing file: $input_file"
    echo "[*] Output file: $output_file"

    # Run Subzy for the file
    subzy run --targets "$input_file" $subzy_args | tee -a "$output_file"

    # Check results
    if [ -s "$output_file" ]; then
        if [ "$json_output" = true ]; then
            local vuln_count=$(jq '[.[] | select(.vulnerable == true)] | length' "$output_file")
            echo "[+] $input_file: $vuln_count vulnerabilities found"
        else
            local vuln_count=$(grep -c "VULNERABLE" "$output_file")
            echo "[+] $input_file: $vuln_count vulnerabilities found"
        fi
    else
        echo "[!] $input_file: No vulnerabilities found or scan failed"
    fi
}
export -f process_file

# Print scan information
echo "[*] Starting Subzy subdomain takeover scan..."
echo "[*] Input files: ${INPUT_FILES[*]}"
echo "[*] Output directory: $OUTPUT_DIR"
echo "[*] Timeout: $TIMEOUT seconds"
echo "[*] Concurrency per file: $CONCURRENCY threads"
echo "[*] Parallel jobs: $PARALLEL_JOBS"
[ "$VERBOSE" = true ] && echo "[*] Verbose mode: Enabled"
[ "$JSON_OUTPUT" = true ] && echo "[*] Output format: JSON"

# Run scans in parallel
printf "%s\n" "${INPUT_FILES[@]}" | parallel -j "$PARALLEL_JOBS" process_file {} "$OUTPUT_DIR" "$TIMEOUT" "$CONCURRENCY" "$VERBOSE" "$JSON_OUTPUT"

# Combine and summarize results
echo "[*] Summarizing results..."
for file in "${INPUT_FILES[@]}"; do
    base_name=$(basename "$file" | sed 's/\.[^.]*$//')
    result_file=$(ls -t "${OUTPUT_DIR}/takeover_results_${base_name}"* | head -n 1)
    if [ -f "$result_file" ]; then
        echo "[*] Summary for $file:"
        if [ "$JSON_OUTPUT" = true ]; then
            jq -r '.[] | select(.vulnerable == true) | .subdomain' "$result_file" | sort | uniq -c | while read -r count domain; do
                echo "  - $count instance(s) for $domain"
            done
        else
            grep "VULNERABLE" "$result_file" | awk '{print $2}' | sort | uniq -c | while read -r count domain; do
                echo "  - $count instance(s) for $domain"
            done
        fi
    fi
done

echo "[*] Scan finished at $(date)"
