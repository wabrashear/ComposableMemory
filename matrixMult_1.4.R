#!/usr/bin/env Rscript
#  author Wesley Brashear <wbrashear@tamu.edu>
#
# This program was written to benchmark HPC systems by allowing users to
# conduct matrix multiplication using matrices derived from a normal distribution
# whose parameters are set by the user.
#
# Usage:
# Rscript matrixMult.R --dim1 <number> --dim2 <number> --mean <number> --stdv <number>
#
# A run with the following parameters used approximated 16Gb of memory and took ~45 seconds to run:
# Rscript matrixMult.R --dim1 50000 --dim2 10000 --mean 800 --stdv 64
#
# Parameters:
# - dim1: Number of rows in first matrix (also used as number of columns in second matrix)
# - dim2: Number of columns in first matrix (also used as number of rows in second matrix)
# - mean: Mean around which the normal distribution is defined
# - stdv: Standard deviation of the distribution
#
#

suppressPackageStartupMessages(library("argparse"))
suppressPackageStartupMessages(library("profmem"))
suppressPackageStartupMessages(library("flexiblas"))
flexiblas_set_num_threads(96)


# Create parser object and define user options

parser <- ArgumentParser()

parser$add_argument("--dim1", default=1000, type="double", metavar="matrix rows",
                    help="Number of rows in first matrix, [default %(default)s]" )
parser$add_argument("--dim2", default=1000, type="double", metavar="matrix cols",
                    help="Number of columns in first matrix, [default %(default)s]" )
parser$add_argument("--mean", default=1000, type="integer", metavar="matrix mean",
                    help="Mean for distribution of matrix elements, [default %(default)s]" )
parser$add_argument("--stdv", default=100, type="integer", metavar="matrix standard dev",
                    help="Standard deviation of distribution of matrix elements, [default %(default)s]" )
args <- parser$parse_args()

matrixCreate1 <- function(rowNumber, colNumber, mean, sd){
  mat = matrix(rnorm(rowNumber*colNumber, mean = mean, sd = sd), rowNumber, colNumber)
  return(mat)
}

matrixCreate2 <- function(rowNumber, colNumber, mean, sd){
  mat = matrix(rnorm(rowNumber*colNumber, mean = mean, sd = sd), colNumber, rowNumber)
  return(mat)
}

matrixMult <- function(){
  return(matrixCreate1(args$dim1,args$dim2,args$mean,args$stdv)%*%
                  matrixCreate2(args$dim2,args$dim1,args$mean,args$stdv))
}

startTime = Sys.time()
memUsage = profmem(matrixMult())
endTime = Sys.time()
#memUsage
paste0("Run complete with matrix of ", as.integer(args$dim1), "x", as.integer(args$dim2))
paste0("Runtime: ", round(as.numeric(difftime(endTime, startTime, units = "secs")),
                          digits = 5), " seconds")
paste0("Total memory: ", sum(na.omit(memUsage$bytes))/1e+9, " Gb")


