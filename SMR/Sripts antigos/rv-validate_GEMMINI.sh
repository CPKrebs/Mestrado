#!/usr/bin/env bash

#
# IMPORTS
#
source rv-utils_GEMMINI.sh


#
# GLOBALS
#
#KERNELS=("2mm" "3mm" "gemm" "syrk" "atax" "bicg" "mvt" "SGEMM" "SGEMV")
KERNELS=("SGEMM" "SGEMV")
REFERENCE_DIR="bin/validate/reference"  # CPU only binaries/results
GEMMINI_DIR="bin/validate/gemmini"  # Gemmini accelerated binaries/results


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
  mkdir -p $GEMMINI_DIR $REFERENCE_DIR

  # report
  logKernel "Validating SMR optimized FIR ${kernel^^} Kernel"
  logInfo "Running SMR..."

  # generate SMR optimized binary
  SMRBinary "$input_file" "./patterns/$kernel.pat" "$GEMMINI_DIR/$kernel" "gemmini"
  echo $SUBDIVIDER

  # run SMR-Gemmini optimized binary and fetch output
  logInfo "Generating ${1^^} Gemmini accelerated output to be validated ($GEMMINI_DIR/$kernel.out)"
  echo "$(spike --extension=gemmini pk $GEMMINI_DIR/$kernel)" > $GEMMINI_DIR/$kernel.dirty
  tail +5 $GEMMINI_DIR/$kernel.dirty > $GEMMINI_DIR/$kernel.out

  # generate CPU reference binary and fetch output
  logInfo "Generating reference CPU output ($REFERENCE_DIR/$kernel.out)"
  FIRBinary "$input_file" "$REFERENCE_DIR/$kernel" ""
  echo "$(spike --extension=gemmini pk $REFERENCE_DIR/$kernel)" > $REFERENCE_DIR/$kernel.dirty
  tail +5 $REFERENCE_DIR/$kernel.dirty > $REFERENCE_DIR/$kernel.out

  # check if binaries results are equal
  logInfo "Comparing outputs..."
  python3 compare.py $GEMMINI_DIR/$kernel.out $REFERENCE_DIR/$kernel.out

done

echo $DIVIDER
