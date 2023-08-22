#!/usr/bin/env bash

#
# IMPORTS
#
source rv-utils.sh


#
# GLOBALS
#
#KERNELS=("2mm" "3mm" "gemm" "syrk" "atax" "bicg" "mvt" "SGEMM" "SGEMV")

KERNELS=("2mm" "3mm" "gemm" "syrk" "atax" "bicg" "mvt" "SGEMM" "SGEMV")
REFERENCE_DIR="bin/validate/reference"  # CPU only binaries/results
OPENBLAS_DIR="bin/validate/openblas"  # OpenBLAS accelerated binaries/results
GEMMINI_DIR="bin/validate/gemmini"  # Gemmini accelerated binaries/results
HWACHA_DIR="bin/validate/hwacha"  # Hwacha accelerated binaries/results


#
# SCRIPT
#

# create required directories
mkdir -p tmp/

# kernel set: run only specified kernels
if [[ "$1" != "" ]]
then KERNELS=($1)
fi

# validate correctnes of each SMR kernel rewrite
for kernel in ${KERNELS[@]}; do
  input_file="polybench-fortran-1.0/linear-algebra/kernels/$kernel/$kernel.F90"
  mkdir -p $OPENBLAS_DIR $GEMMINI_DIR $REFERENCE_DIR $HWACHA_DIR

  # report
  logKernel "Validating SMR optimized FIR ${kernel^^} Kernel"
  logInfo "Running SMR..."

  # build utils library (uses utils.sh method)
  buildPolybenchUtils_gcc

  # generate SMR optimized binary
  SMRBinary "$input_file" "./patterns/$kernel.pat" "$GEMMINI_DIR/$kernel" "gemmini"
  echo $SUBDIVIDER

  # run SMR-Gemmini optimized binary and fetch output
  logInfo "Generating ${1^^} Gemmini accelerated output to be validated ($GEMMINI_DIR/$kernel.out)"
  echo "$(spike --extension=gemmini pk $GEMMINI_DIR/$kernel)" > $GEMMINI_DIR/$kernel.dirty
  tail +5 $GEMMINI_DIR/$kernel.dirty > $GEMMINI_DIR/$kernel.out

  # generate SMR optimized binary
  SMRBinary "$input_file" "./patterns/$kernel.pat" "$HWACHA_DIR/$kernel" "hwacha"
  echo $SUBDIVIDER

  # run SMR-Hwacha optimized binary and fetch output
  logInfo "Generating ${1^^} Hwacha accelerated output to be validated ($HWACHA_DIR/$kernel.out)"
  #echo "$(spike --isa=rv64gc --extension=hwacha pk $HWACHA_DIR/$kernel)" > $HWACHA_DIR/$kernel.dirty
  #tail +5 $HWACHA_DIR/$kernel.dirty > $HWACHA_DIR/$kernel.out

  # build utils library (uses utils.sh method)
  buildPolybenchUtils_Fortran

  # generate SMR optimized binary
  SMRBinary "$input_file" "./patterns/$kernel.pat" "$OPENBLAS_DIR/$kernel" "OPENBLAS"
  echo $SUBDIVIDER

  # run SMR-BLAS optimized binary and fetch output
  logInfo "Generating ${1^^} OpenBLAS accelerated output to be validated ($OPENBLAS_DIR/$kernel.out)"
  echo "$(spike --extension=gemmini pk $OPENBLAS_DIR/$kernel)" > $OPENBLAS_DIR/$kernel.dirty
  tail +5 $OPENBLAS_DIR/$kernel.dirty > $OPENBLAS_DIR/$kernel.out

  # generate CPU reference binary and fetch output
  logInfo "Generating reference CPU output ($REFERENCE_DIR/$kernel.out)"
  FIRBinary_Fortran "$input_file" "$REFERENCE_DIR/$kernel" ""
  echo "$(spike --extension=gemmini pk $REFERENCE_DIR/$kernel)" > $REFERENCE_DIR/$kernel.dirty
  tail +5 $REFERENCE_DIR/$kernel.dirty > $REFERENCE_DIR/$kernel.out




  # check if binaries results are equal
  logInfo "Comparing outputs [CPU vs Gemmini]..."
  python3 compare.py $GEMMINI_DIR/$kernel.out $REFERENCE_DIR/$kernel.out
  logInfo "Comparing outputs [CPU vs OpenBLAS]..."
  #python3 compare.py $OPENBLAS_DIR/$kernel.out $REFERENCE_DIR/$kernel.out


done

echo $DIVIDER
