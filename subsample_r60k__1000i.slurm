#!/bin/bash 
#SBATCH --job-name=subsample_60k_1000i
#SBATCH --output=subsample_60k_%j.out
#SBATCH --error=subsample_60k_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --mail-user=shyam.solanki@sdstate.edu
#SBATCH --mail-type=ALL
#SBATCH --time=35:00:00
#SBATCH --partition=gpu
#SBATCH --mem=8G       # 4-6 GB should be enough for files having about 2M reads


# Set working directory.Change if needed. No need to inclued if already in the same directory.
cd /mmfs1/scratch/jacks.local/SolankiLab/Solanki/16_S_data_wrangling/EMU_test/ml_emu || exit 1

# Constants
SEED=42
SCRIPT="seed_fastq_r60k_i1000.py"
OUTDIR="60k_subsets_100i"

mkdir -p "$OUTDIR"
# Process each FASTQ file
for FASTQ in *.fastq; do
    BASENAME="${FASTQ%.fastq}"
    OUTNAME="${BASENAME}_seed${SEED}"
    
    echo "Subsampling $FASTQ with seed $SEED"
    python3 "$SCRIPT" "$FASTQ" -n 60000 -s 1000 -o "${OUTNAME}.fastq" --seed $SEED

    mkdir -p "${OUTDIR}/${OUTNAME}"
    mv "${OUTNAME}.fastq" "${OUTDIR}/${OUTNAME}/"
    mv "${OUTNAME}_headers.txt" "${OUTDIR}/${OUTNAME}/"
done

echo "Done!! Subsampling completed and outputs saved to $OUTDIR"
