# Nanopore_data_subsetting_random
Various steps in 16S data analysis. Standalone (V1) and Script‑based Approach (V2 update).
This repository contains utilities to subsample Oxford Nanopore sequencing reads. The original implementation relied on running one‑off commands to draw random subsets; this update introduces a modular Python script and an accompanying SLURM batch script to simplify reproducibility and large‑scale jobs. This script performs reproducible random subsampling of Oxford Nanopore reads from a FASTQ file. It can carry out multiple simulation rounds to ensure sampling diversity and then selects a final representative subset of reads. The process is reproducible with a user‑defined seed and suitable for downstream tasks such as benchmarking, assembly polishing, or simply reducing dataset size. If needed, can adjust the number of reads (-n) and simulations (-s) to suit your needs.

---

# Why subsampling?

Nanopore runs often generate millions of reads, and output can be variable among sample runs, making downstream analyses time‑consuming, computationally expensive, and messy. Randomly selecting a representative subset of reads could allow rapid prototyping and benchmarking.

---

# Overview

The goal is to extract a defined number of reads from large Nanopore FASTQ files at random, optionally repeating the process multiple times with different random seeds and collating the unique reads. The updated workflow consists of:

1. seed_fastq_r60k_i1000.py/seed_fastq_r1k_i1.py – A Python script that reads a FASTQ file into memory and performs reproducible random sampling. It can run multiple simulations to increase the pool of potential reads, then selects the requested number of unique reads from the union of those simulations. It writes both the subsampled FASTQ file and a companion text file listing the read headers.

2. subsample_r60k_1000i.slurm/subsample_r1k__1i.slurm – An example SLURM batch script for running the Python script on a high‑performance computing (HPC) cluster. It loops through all .fastq files in the current directory, invokes the Python script on each file and organizes the outputs into a structured directory for specific read extraction (n) and simulation (s).


### Requirements

* Python 3.6+.
* Uses only the Python standard library; no external dependencies.
* Works best on systems with enough RAM to hold the entire FASTQ file.

---


# Automation-Version 2: `.py` + `.slurm`

### Description

This updated version introduces a more flexible Python script (`seed_fastq_r60k_i1000.py`) and an optional SLURM batch script for HPC environments (subsample_r60k__1000i.slurm).  You can extract any number of reads and run any number of simulations.  The script reads the input FASTQ into memory, runs the simulations, sorts the final reads by header, and writes both the subsampled FASTQ and a header list.  The SLURM script automates running the Python script on many FASTQ files and organises the outputs.


## HPC usage – SLURM batch script

The `.slurm` file illustrates how to run `.py` on multiple FASTQ files within a SLURM‑based HPC environment.  The script sets job parameters (job name, CPU count, memory, time limit, etc.), iterates over all `.fastq` files in the working directory, runs the Python script on each file, and organizes the outputs into a directory structure.

**To run the SLURM script:**

```bash
sbatch subsample_r60k__1000i.slurm
```

**Points to customise, if needed:**

1. **Working directory** – update the `cd` command in the SLURM script to point to the folder containing your FASTQ files.
2. **Resource allocation** – adjust `--cpus-per-task`, `--mem`, `--time`, and `--partition` to suit your cluster.
3. **Parameters** – within the SLURM script, you can change the values of `SEED`, `SCRIPT`, `OUTDIR`, and the `-n` and `-s` arguments passed to the Python script.

After submission, outputs will appear in the directory specified by `OUTDIR`, with each input file having its own subdirectory containing the `.fastq` and `_headers.txt` files.


### Features

* Reads the entire FASTQ file into memory.
* Performs `s` simulation rounds (default: 1000).  Each simulation draws `n` reads (default: 60000) without replacement.
* Aggregates unique reads across all simulations and selects the final `n` reads (default: 60000) from this union.
* Sorts reads by their header to produce deterministic output ordering.
* Writes output as:
  - `.fastq` file containing the sampled reads.
  -   - `.gz` compressed FASTQ
  - Header‑only `.txt` file (`<output>_headers.txt`).
* Ensures reproducibility via the optional `--seed` parameter (set to any integer).

# Local usage- Version 1 – seed_fastq_r60k_i1000.py

This script performs robust, reproducible random subsampling of Oxford Nanopore reads from a FASTQ file. 
Note: seed can be used as null for a true randomization each time!

## Usage- Local execution

```bash
python seed_fastq_r60k_i1000.py <input.fastq> [options]

python seed_fastq_r1k_i1.py <path/to/input.fastq> \
       -n <number_of_reads> \
       -s <simulations> \
       -o <output_filename> \
       --seed <integer_seed>
```

### Basic example:

```bash
python seed_fastq_r60k_i1000.py sample.fastq
```

### Custom example:

```bash
python seed_fastq_r60k_i1000.py sample.fastq \
  -n 60000 \
  -s 1000 \
  -o extracted_reads.fastq \
  --seed 42
```

---

## Arguments

| Argument               | Type     | Required | Default                   | Description |
|------------------------|----------|----------|---------------------------|-------------|
| `fastq`                | Path     | ✅ Yes   | —                         | Input FASTQ file |
| `-n`, `--n_reads`      | Integer  | No       | 60000                     | Number of reads to extract |
| `-s`, `--simulations`  | Integer  | No       | 1000                      | Number of simulation rounds |
| `-o`, `--output`       | Path     | No       | `final_sampled_60k.fastq` | Output file name |
| `--seed`               | Integer  | No       | None                      | Random seed for reproducibility |

---

## Output Files

| File                         | Description |
|------------------------------|-------------|
| `<output>.fastq`             | Final 60,000 sampled reads |
| `<output>.fastq.gz`          | Gzipped version of the FASTQ |
| `final_read_headers.txt`     | List of sampled read headers (`@read_id`) |

---

## Example Scenario

Dataset containing 1,000,000 reads. Sample 60,000 reads in a way that is representative and reproducible:

```bash
python seed_fastq_r60k_i1000.py reads.fastq --seed 2024
```

This gives:
- `final_sampled_60k.fastq`
- `final_sampled_60k.fastq.gz`
- `final_read_headers.txt`

---

## License

Copyright (c) 2025 [Shyam Solanki]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this work and associated documentation files by acknowledging the original work.



---

## Author

Shyam Solanki, with the help of various AI coding platforms.
