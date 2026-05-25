#!/bin/bash

#SBATCH --job-name=DHEEGmatjob        	# job name
#SBATCH --nodes=1                	# node count
#SBATCH --ntasks=1               	# total number of tasks across all nodes
#SBATCH --mail-type=end          	# send email when job ends
#SBATCH --mail-user=cknowlto@fiu.edu  # email address
#SBATCH --mem=128G
#SBATCH --cpus-per-task=1
#SBATCH --account=iacc_gbuzzell	# SLURM account name (delete these 3 lines if not running a highmem job)
#SBATCH --partition=highmem1       # partition name (use high memory nodes)
#SBATCH --qos=highmem1             # QOS
#SBATCH --output=%x-%j.out

module load matlab-2021b;
pwd; hostname; date

matlab -nodisplay -r "cd('/home/data/NDClab/analyses/diverse-hair-eeg-alpha/code/postprocessing/erp/'); run('create_mat_s1.m'); exit"
