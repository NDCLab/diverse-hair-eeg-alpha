#!/bin/bash

#SBATCH --job-name=SFEpreprocess        	# job name
#SBATCH --nodes=1                	# node count
#SBATCH --ntasks=1               	# total number of tasks across all nodes
#SBATCH --mail-type=end          	# send email when job ends
#SBATCH --mail-user=cknowlto@fiu.edu  # email address
#SBATCH --mem=200G
#SBATCH --cpus-per-task=10
#SBATCH --account=iacc_gbuzzell	# SLURM account name (delete these 3 lines if not running a highmem job)
#SBATCH --partition=highmem1       # partition name (use high memory nodes)
#SBATCH --qos=highmem1             # QOS
#SBATCH --output=%x-%j.out

module load matlab-2021b;
pwd; hostname; date

matlab -nodisplay -r "addpath('/home/data/NDClab/analyses/diverse-hair-eeg-alpha/code/sfe_processing/preprocessing'); path; MADE_pipeline('social-flanker-eeg-dataset','160015/160016/160017/160018/160019/160020/160021/160022/160023/160024/160025/160026/160027/160029/160030/160032/160033/160034/160035/160036/160037/160038/160039/160040/160042/160044/160045/160046/160047/160048/160049/160051/160053/160056/160057/160058/160059/160060/160061/160062/160063/160064/160065/160066/160067/160068/160069/160070/160071/160072/160073/160074/160075/160076'); exit"
