#!/usr/bin/env python3

from pathlib import Path
import pandas as pd
import argparse

def parse_nanostat(base_dir):
    
    base_dir = Path(base_dir)

    results = []

    for run_dir in base_dir.iterdir():

        # Only process directories
        if not run_dir.is_dir():
            continue

        nanostat_dir = run_dir / "a1-nanostat-raw-reads"

        if not nanostat_dir.exists():
            continue

        # Loop through all barcode files
        for file in nanostat_dir.glob("barcode*_raw_read_nanostat.txt"):

            nanostats_num_reads = None
            nanostat_length_n50 = None
            nanostat_median_read_length = None

            with open(file, "r") as f:
                for line in f:

                    if line.startswith("Number of reads:"):
                        nanostats_num_reads = float(
                            line.split(":", 1)[1].strip().replace(",", "")
                        )

                    elif line.startswith("Read length N50:"):
                        nanostat_length_n50 = float(
                            line.split(":", 1)[1].strip().replace(",", "")
                        )

                    elif line.startswith("Median read length:"):
                        nanostat_median_read_length = float(
                            line.split(":", 1)[1].strip().replace(",", "")
                        )

            # Extract run and barcode names
            run = run_dir.name
            barcode = file.name.split("_")[0]

            results.append({
                "run": run,
                "barcode": barcode,
                "nanostats_num_reads": nanostats_num_reads,
                "nanostat_length_n50": nanostat_length_n50,
                "nanostat_median_read_length": nanostat_median_read_length
            })

    return pd.DataFrame(results)

def parse_pychopper(base_dir):
    base_dir = Path(base_dir)

    results = []

    for run_dir in base_dir.iterdir():

        # Only process directories
        if not run_dir.is_dir():
            continue

        pychopper_dir = run_dir / "b0-pychopper-trimmed"

        if not pychopper_dir.exists():
            continue

        # Loop through all barcode files
        for file in pychopper_dir.glob("barcode*_pychopper_stats.tsv"):

            pychopper_primers_found = None
            pychopper_rescue = None
            pychopper_unusable = None
            pychopper_pos_strand = None
            pychopper_neg_strand = None

            with open(file, "r") as f:
                for line in f:

                    if line.startswith("Classification\tPrimers_found"):
                        pychopper_primers_found = float(
                            line.split()[-1].strip().replace(",", "")
                        )

                    elif line.startswith("Classification\tRescue"):
                        pychopper_rescue = float(
                            line.split()[-1].strip().replace(",", "")
                        )

                    elif line.startswith("Classification\tUnusable"):
                        pychopper_unusable = float(
                            line.split()[-1].strip().replace(",", "")
                        )

                    elif line.startswith("Strand\t+"):
                        pychopper_pos_strand = float(
                            line.split()[-1].strip().replace(",", "")
                        )

                    elif line.startswith("Strand\t-"):
                        pychopper_neg_strand = float(
                            line.split()[-1].strip().replace(",", "")
                        )

            # Calculate strand bias
            if pychopper_neg_strand is not None and pychopper_neg_strand != 0:
                pychopper_inferred_strand_bias = (
                    pychopper_pos_strand / pychopper_neg_strand
                )
            else:
                pychopper_inferred_strand_bias = None

            # Extract run and barcode names
            run = run_dir.name
            barcode = file.name.split("_")[0]

            results.append({
                "run": run,
                "barcode": barcode,
                "pychopper_primers_found": pychopper_primers_found,
                "pychopper_rescue": pychopper_rescue,
                "pychopper_unusable": pychopper_unusable,
                "pychopper_pos_strand": pychopper_pos_strand,
                "pychopper_neg_strand": pychopper_neg_strand,
                "pychopper_inferred_strand_bias": pychopper_inferred_strand_bias
            })

    return pd.DataFrame(results)


def main():

    parser = argparse.ArgumentParser(
        description="Parse Pychopper statistics from multiple sequencing runs."
    )

    parser.add_argument(
        "-i",
        "--input",
        required=True,
        help="Base directory containing run directories."
    )

    parser.add_argument(
        "-o",
        "--output",
        required=True,
        help="Output directory."
    )

    args = parser.parse_args()

    input_dir = Path(args.input)
    output_dir = Path(args.output)

    # Check input directory
    if not input_dir.exists():
        raise FileNotFoundError(
            f"Input directory does not exist: {input_dir}"
        )

    # Create output directory if needed
    output_dir.mkdir(parents=True, exist_ok=True)

    # Parse statistics
    nanostat_df = parse_nanostat(input_dir)
    pychopper_df = parse_pychopper(input_dir)

    # Merge df
    merged_df = pd.merge(
        nanostat_df,
        pychopper_df,
        on=["run", "barcode"],
        how="outer"
    )

    # Save output
    output_file = output_dir / "nanostat_pychopper_read_qc.tsv"
    merged_df.to_csv(output_file, sep="\t", index=False)

    print(f"Processed {len(merged_df)} barcode files.")
    print(f"Output saved to: {output_file}")

if __name__ == "__main__":
    main()