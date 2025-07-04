#!/bin/bash
#SBATCH --job-name=omp_test
#SBATCH --output=output_%j.txt
#SBATCH --error=error_%j.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=00:02:00

# Cargar módulos si es necesario
# module load gcc/10.2.0

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# Ejecutar con parámetro N = 10000000
./programa 10000000
