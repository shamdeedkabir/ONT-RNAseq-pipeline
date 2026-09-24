#!/bin/bash

set -euo pipefail

### USAGE
usage() {
    echo "Usage: $0 --transcript-counts <FILE> --isoquant-gtf <FILE> --classification <FILE> --output-ncounts <FILE> --output-source-labels <FILE> --output-classification <FILE>"
    echo ""
    echo "Arguments:"
    echo "  --transcript-counts      TSV of per-sample transcript counts from IsoQuant"
    echo "  --isoquant-gtf           IsoQuant extended annotation GTF"
    echo "  --classification         SQANTI3 classification file"
    echo "  --output-ncounts         Output path for per-transcript sample counts"
    echo "  --output-source-labels   Output path for transcript source labels"
    echo "  --output-classification  Output path for annotated SQANTI3 classification"
    exit 1
}

### PARSE NAMED ARGS
TRANSCRIPT_COUNTS=""
ISOQUANT_GTF=""
CLASSIFICATION_FILE=""
OUTPUT_NCOUNTS=""
OUTPUT_SOURCE_LABELS=""
OUTPUT_CLASSIFICATION=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --transcript-counts)     TRANSCRIPT_COUNTS="$2";     shift 2 ;;
        --isoquant-gtf)          ISOQUANT_GTF="$2";          shift 2 ;;
        --classification)        CLASSIFICATION_FILE="$2";   shift 2 ;;
        --output-ncounts)        OUTPUT_NCOUNTS="$2";        shift 2 ;;
        --output-source-labels)  OUTPUT_SOURCE_LABELS="$2";  shift 2 ;;
        --output-classification) OUTPUT_CLASSIFICATION="$2"; shift 2 ;;
        *) echo "ERROR: Unknown argument: $1" >&2; usage ;;
    esac
done

### CHECK ALL ARGS PROVIDED
for var in TRANSCRIPT_COUNTS ISOQUANT_GTF CLASSIFICATION_FILE OUTPUT_NCOUNTS OUTPUT_SOURCE_LABELS OUTPUT_CLASSIFICATION; do
    [[ -n "${!var}" ]] || { echo "ERROR: Missing required argument" >&2; usage; }
done

### VALIDATE INPUT FILES
for f in "$TRANSCRIPT_COUNTS" "$ISOQUANT_GTF" "$CLASSIFICATION_FILE"; do
    [[ -f "$f" ]] || { echo "ERROR: File not found: $f" >&2; exit 1; }
done

### ENSURE OUTPUT DIRECTORIES EXIST
for f in "$OUTPUT_NCOUNTS" "$OUTPUT_SOURCE_LABELS" "$OUTPUT_CLASSIFICATION"; do
    mkdir -p "$(dirname "$f")"
done

### STEP 1: Count supporting samples per transcript
echo "Counting supporting samples per transcript..."
awk -F'\t' '
    NR == 1 { next }
    $3 > 0  { seen[$1]++ }
    END      { print "gene_id\tN_samples"; for (id in seen) print id, seen[id] }
' OFS='\t' "$TRANSCRIPT_COUNTS" > "$OUTPUT_NCOUNTS"

### STEP 2: Label transcript sources from GTF
echo "Labeling transcript sources from GTF..."
awk -F'\t' -v OFS='\t' '
    !/^#/ && $3 == "transcript" {
        match($9, /transcript_id "([^"]+)"/, a)
        if (a[1] != "") {
            print a[1], ($2 == "IsoQuant" ? "isoquant" : "keep")
        }
    }
' "$ISOQUANT_GTF" > "$OUTPUT_SOURCE_LABELS"

### STEP 3: Join N_samples and source_label onto SQANTI3 classification file
echo "Joining onto SQANTI3 classification file..."
awk -F'\t' -v OFS='\t' '

    # Read N_samples lookup file
    ARGIND == 1 {
        if (FNR > 1)
            samples[$1] = $2
        next
    }

    # Read transcript source labels
    ARGIND == 2 {
        labels[$1] = $2
        next
    }

    # SQANTI3 header
    ARGIND == 3 && FNR == 1 {
        sub(/\r$/, "")
        print $0, "N_samples", "source_label"
        next
    }

    # SQANTI3 records
    ARGIND == 3 {
        sub(/\r$/, "")

        n_samples = (($1 in samples) ? samples[$1] : 0)
        source = (($1 in labels) ? labels[$1] : "keep")

        print $0, n_samples, source "\r"
    }

' \
"$OUTPUT_NCOUNTS" \
"$OUTPUT_SOURCE_LABELS" \
"$CLASSIFICATION_FILE" \
> "$OUTPUT_CLASSIFICATION"

echo "Done."
echo "  Sample counts:      $OUTPUT_NCOUNTS"
echo "  Source labels:      $OUTPUT_SOURCE_LABELS"
echo "  Classification:     $OUTPUT_CLASSIFICATION"