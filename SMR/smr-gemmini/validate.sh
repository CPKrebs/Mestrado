#!/usr/bin/env bash

#
# IMPORTS
#
source utils.sh


#
# GLOBALS
#
KERNELS=("2mm" "3mm" "gemm" "syrk" "atax" "bicg" "mvt")
DEF="-DSMALL_DATASET -DPOLYBENCH_DUMP_ARRAYS -DDATA_TYPE=real -DDATA_PRINTF_MODIFIER=\"(f0.2,1x)\",advance='no'"
GFOR_DIR="bin/validate/gfortran"
TEST_DIR="bin/validate/smr"


#
# SCRIPT
#

# create required directories
mkdir -p tmp/

# build utils library (uses utils.sh method)
buildPolybenchUtils

# kernel set: run only specified kernels
if [[ "$1" != "" ]]
then KERNELS=($1)
fi

# validate correctnes of each SMR kernel rewrite
for kernel in ${KERNELS[@]}; do
  input_file="polybench-fortran-1.0/linear-algebra/kernels/$kernel/$kernel.F90"
  mkdir -p $TEST_DIR $GFOR_DIR

  # report
  logKernel "Validating SMR optimized FIR ${kernel^^} Kernel"
  logInfo "Running SMR..."

  # generate SMR optimized binary
  SMRBinary "$input_file" "./patterns/$kernel.pat" "$TEST_DIR/$kernel"
  echo $SUBDIVIDER

  # run SMR binary and fetch output
  logInfo "Generating ${1^^} output to be validated ($TEST_DIR/$kernel.txt)"
  ./$TEST_DIR/$kernel > $TEST_DIR/$kernel.txt

  # generate gfortran reference binary and fetch output
  logInfo "Generating reference gFortran output ($GFOR_DIR/$kernel.txt)"
  gFortranBinary "$input_file" "$GFOR_DIR/$kernel"
  ./$GFOR_DIR/$kernel > ./$GFOR_DIR/$kernel.txt

  # check if binaries results are equal
  logInfo "Comparing outputs..."
  python3 compare.py $TEST_DIR/$kernel.txt $GFOR_DIR/$kernel.txt

done

echo $DIVIDER
