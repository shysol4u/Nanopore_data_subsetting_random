import random
from pathlib import Path
from itertools import islice
import argparse
import gzip

def read_fastq(fastq_path):
    """Yield one full FASTQ read (4 lines)."""
    with open(fastq_path, 'r') as f:
        while True:
            lines = list(islice(f, 4))
            if not lines:
                break
            yield lines

def main():
    parser = argparse.ArgumentParser(description="Extract 1k random Nanopore reads from multiple simulations.")
    parser.add_argument("fastq", type=Path, help="Input FASTQ file")
    parser.add_argument("-n", "--n_reads", type=int, default=1000, help="Number of reads to extract")
    parser.add_argument("-s", "--simulations", type=int, default=1, help="Number of simulations to run")
    parser.add_argument("-o", "--output", type=Path, default="final_sampled_1k.fastq", help="Output FASTQ filename")
    parser.add_argument("--seed", type=int, default=None, help="Random seed (optional, for reproducibility)")

    args = parser.parse_args()

    # Ensure output filename has .fastq extension
    if args.output.suffix != ".fastq":
        args.output = args.output.with_suffix(".fastq")

    # Set random seed for reproducibility
    if args.seed is not None:
        print(f"Setting random seed: {args.seed}")
        random.seed(args.seed)

    print("Reading FASTQ into memory...")
    all_reads = list(read_fastq(args.fastq))
    print(f"Total reads in file: {len(all_reads)}")

    if len(all_reads) < args.n_reads:
        raise ValueError(f"Not enough reads to sample {args.n_reads}!")

    print(f"Running {args.simulations} simulations of {args.n_reads} reads each...")
    seen_read_indices = set()

    for i in range(args.simulations):
        sampled_indices = random.sample(range(len(all_reads)), args.n_reads)
        seen_read_indices.update(sampled_indices)

    print(f"Unique reads across all simulations: {len(seen_read_indices)}")

    if len(seen_read_indices) < args.n_reads:
        raise ValueError("Not enough unique reads collected from simulations.")

    print(f"Sampling final {args.n_reads} reads from the union set...")
    final_indices = random.sample(list(seen_read_indices), args.n_reads)

    print("Sorting reads by header...")
    final_reads = [all_reads[i] for i in final_indices]
    final_reads.sort(key=lambda x: x[0])  # sort by header line

    print(f"Writing final {args.n_reads} reads to: {args.output}")
    with open(args.output, 'w') as out:
        for read in final_reads:
            out.writelines(read)

    # Create header file name from output base
    header_filename = args.output.with_name(args.output.stem + "_headers.txt")
    print(f"Writing headers to {header_filename}")
    with open(header_filename, 'w') as header_out:
        for read in final_reads:
            header_out.write(read[0])  # write only the header line (@...)

    print("Job done.")

if __name__ == "__main__":
    main()
