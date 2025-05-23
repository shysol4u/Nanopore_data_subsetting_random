# Nanopore_data_subsetting_random
Varius steps in 16s data analysis


# seed_fastq_r60k_i1000.py

### Randomly Extract 60,000 Nanopore Reads Using 1000 Simulations (Reproducible)

This script performs robust, reproducible random subsampling of Oxford Nanopore reads from a FASTQ file. It runs multiple simulation rounds to ensure sampling diversity and selects a final representative subset of reads. The script is reproducible with a user-defined seed and suitable for downstream applications such as benchmarking, assembly polishing, and data reduction. 
Note: seed can be used as null for a true randomization each time!

---

## Features

- Reads full Nanopore FASTQ file into memory
- Performs N random sampling simulations (default: 1000)
- Aggregates all unique reads observed across simulations
- Draws a final random set of reads from the union
- Writes output as:
  - `.fastq` file
  - `.gz` compressed FASTQ
  - Header-only `.txt` file
- Ensures reproducibility via `--seed`

---

## Requirements

- Python 3.6+
- Standard library only (no third-party packages needed)
-HPC usage preferred
---

## Usage

```bash
python seed_fastq_r60k_i1000.py <input.fastq> [options]
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

You're working with a Nanopore dataset containing 1,000,000 reads. You want to sample 60,000 reads in a way that is representative and reproducible:

```bash
python seed_fastq_r60k_i1000.py reads.fastq --seed 2024
```

This gives you:
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

[Your Name] – Functional Genomics Lab  
South Dakota State University
