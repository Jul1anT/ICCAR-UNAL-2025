#!/bin/bash

#SBATCH --job-name=openmp_job      # Job name
#SBATCH --output=openmp_job_%j.out # Standard output and error log
#SBATCH --error=openmp_job_%j.err  # %j is replaced with the job ID
#SBATCH --nodes=1                  # Request 1 node
#SBATCH --ntasks=1                 # Request 1 task (your OpenMP program is a single task)
#SBATCH --cpus-per-task=8          # Request 8 CPUs for this task (adjust as needed for your program)
#SBATCH --time=00:10:00            # Wall-clock time limit (HH:MM:SS)
#SBATCH --mem=4G                   # Memory per node (adjust as needed)

# Load any necessary modules (e.g., GCC if it's not in your default path)
# module load gcc/11.2.0 # Example

# Set the number of OpenMP threads
# This should ideally be equal to --cpus-per-task for optimal performance
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

echo "Starting OpenMP job on node: $(hostname)"
echo "Number of requested CPUs per task: $SLURM_CPUS_PER_TASK"
echo "OMP_NUM_THREADS set to: $OMP_NUM_THREADS"

# Run your OpenMP program
./a.out

echo "OpenMP job finished."