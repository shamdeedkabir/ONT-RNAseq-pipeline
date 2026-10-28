from pathlib import Path
import pandas as pd
import argparse


def parse_oarfish(base_dir):
    base_dir = Path(base_dir)
    series_list = []

    for run_dir in sorted(base_dir.iterdir()):
        # only process dirs
        if not run_dir.is_dir():
            continue

        oarfish_dir = run_dir / "d0i-oarfish-transcriptome-aligned"
        if not oarfish_dir.exists():
            continue

        # loop through all barcode files
        for file in sorted(oarfish_dir.glob("barcode*_oarfish_quant_transcriptome_aligned.quant")):
            barcode = file.name.split("_")[0]          # -> "barcode02"

            quant = pd.read_csv(file, sep="\t", usecols=["tname", "num_reads"])
            counts = quant.set_index("tname")["num_reads"]
            counts.name = (run_dir.name, barcode)      # becomes the row label
            series_list.append(counts)

    if not series_list:
        return pd.DataFrame(columns=["run_dir", "barcode"])

    # columns = files, rows = transcripts -> transpose so rows = files
    df = pd.concat(series_list, axis=1).T
    df.index = df.index.set_names(["run_dir", "barcode"])
    df = df.fillna(0).reset_index()
    df.columns.name = None
    return df


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Merge oarfish .quant files into one count matrix")
    parser.add_argument("--base_dir", help="Directory containing run directories")
    parser.add_argument("-o", "--output", help="Output TSV path")
    args = parser.parse_args()

    df = parse_oarfish(args.base_dir)
    df.to_csv(args.output, sep="\t", index=False)
    print(f"Wrote {df.shape[0]} samples x {df.shape[1] - 2} transcripts to {args.output}")