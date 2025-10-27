#!/bin/bash 
#SBATCH --job-name=subsample_60k_1000i
#SBATCH --output=subsample_1k_%j.out
#SBATCH --error=subsample_1k_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=gpu
#SBATCH --mem=16G       # 4-6 GB should be enough for files having about 2M reads
#SBATCH --mail-user=shyam.solanki@sdstate.edu
#SBATCH --mail-type=ALL
#SBATCH --time=35:00:00


# Set working directory.Change if needed. No need to inclued if already in the same directory.
cd /mmfs1/scratch/jacks.local/SolankiLab/Solanki/Oglala_Lakota_College || exit 1

# Constants
SEED=42
SCRIPT="seed_fastq_r1k_i1.py"
OUTDIR="1k_subsets_1i"

mkdir -p "$OUTDIR"
# Process each FASTQ file
for FASTQ in *.fastq; do
    BASENAME="${FASTQ%.fastq}"
    OUTNAME="${BASENAME}_seed${SEED}"
    
    echo "Subsampling $FASTQ with seed $SEED"
    python3 "$SCRIPT" "$FASTQ" -n 1000 -s 1 -o "${OUTNAME}.fastq" --seed $SEED

    mkdir -p "${OUTDIR}/${OUTNAME}"
    mv "${OUTNAME}.fastq" "${OUTDIR}/${OUTNAME}/"
    mv "${OUTNAME}_headers.txt" "${OUTDIR}/${OUTNAME}/"
done

echo "Done!! Subsampling completed and outputs saved to $OUTDIR"
