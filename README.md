# Composable Memory
Scripts and information related to using composable memory on ACES.

File                      |    Description
--------------------------|--------------------------------------
matrixMult_1.4.R          | R script that conducts matrix multiplication.
matrixMult_largeSwap.sh   | Bash scrip used to run the R script on nodes with increased swap space
matrixMult_memVerge.sh    | Bash script used to run the R script using MemVerge interactively on ACES
matrixMult_memVerge.sh    | Slurm script used to run the R script using MemVerge through the job submission software on ACES
mm                        | Wrapper script for using Memory Machine with mvmalloc.so located in the same directory
mvmalloc_250.yml          | Yaml file used to configure DRAM tier (250Gb)
mvmalloc_450.yml          | Yaml file used to configure DRAM tier (450Gb)
mvmalloc.so               | Library designed by MemVerge to be used with R
