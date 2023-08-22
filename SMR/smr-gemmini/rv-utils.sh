#!/usr/bin/env bash
##
## Utilitary bash functions.
##   -DPOLYBENCH_DUMP_ARRAYS \  Ativa o print do resultado 
##   -DPOLYBENCH_NO_FLUSH_CACHE \  desativa a limpeza da cache

#
# GLOBALS
#
LIBS='/root/smr-gemmini/libs'
DIVIDER="======================================================================"
SUBDIVIDER="-------------------------------------------"
RESULT=""
POLY_UTILS="polybench-fortran-1.0/utilities"

# polybench configuration flags
POLY_DEFS="
  -DPOLYBENCH_DUMP_ARRAYS \
  -DMINI_DATASET \
  -DDATA_TYPE=real \
  -DPOLYBENCH_STACK_ARRAYS \
  -DPOLYBENCH_RISCV32 \
  -DPOLYBENCH_TIME \
  -DPOLYBENCH_CYCLE_ACCURATE_TIMER \
"

# gemmini dependencies paths
GEMMINI_TOOLS="/root/chipyard/generators/gemmini/software/gemmini-rocc-tests"
GEMMINI_INCLUDE="$GEMMINI_TOOLS/include"
GEMMINI_COMMON="$GEMMINI_TOOLS/riscv-tests/benchmarks/common"

# define GCC flags for Gemmini lib compilation
GEMMINI_FLAGS="\
    -DPREALLOCATE=1 \
    -DMULTITHREAD=1 \
    -mcmodel=medany \
    -std=gnu99 \
    -ffast-math \
    -fno-common \
    -fno-builtin-printf \
    -march=rv64gc -Wa,-march=rv64gcxhwacha \
    -lm \
    -lgcc \
    -O3 \
    -I$GEMMINI_TOOLS/riscv-tests \
    -I$GEMMINI_TOOLS/riscv-tests/env \
    -I$GEMMINI_TOOLS \
    -I$GEMMINI_COMMON \
    -nostdlib \
    -nostartfiles \
    -static \
    -DBAREMETAL=1
"


# Hwacha dependencies paths
HWACHA_TOOLS="/root/smr-gemmini/esp-tests"
HWACHA_COMMON="$HWACHA_TOOLS/benchmarks/common"

# define GCC flags for Hwacha lib compilation
HWACHA_FLAGS="\
    -DPREALLOCATE=1 \
    -DMULTITHREAD=1 \
    -mcmodel=medany \
    -static \
    -nostdlib \
    -nostartfiles \
    -lm \
    -lgcc \
    -std=gnu99 \
    -O2 \
    -ffast-math \
    -fno-common \
    -fno-builtin-printf \
    -fno-tree-loop-distribute-patterns \
    -march=rv64gcxhwacha \
    -DUSE_HWACHA \
    -I$HWACHA_TOOLS \
    -I$HWACHA_TOOLS/env \
    -I$HWACHA_COMMON \
    -DBAREMETAL=1
"

# define flags for Clang polybench LLVM IR lowering
CLANG_FLAGS="\
  -O3 \
  --target=riscv64-unknown-elf \
  -march=rv64gc -Wa,-march=rv64gcxhwacha \
  --sysroot=${RISCV}/riscv64-unknown-elf \
  --gcc-toolchain=${RISCV} \
"


#
# CODE
#

# abort on error
set -e

# create required directories
mkdir -p bin/ csv/ tmp/


function logKernel()
{
  echo $DIVIDER
  echo "    $1"
  echo $SUBDIVIDER
}


function logInfo()
{
  echo "[INFO] $1"
}


# Compiles a PolyBench utilitaries
#
function buildPolybenchUtils_Fortran()
{
  # compile polybench utilitaries library
  rm -f $POLY_UTILS/fpolybench.o
  riscv64-unknown-linux-gnu-gfortran $POLY_DEFS -c -O3 \
    $POLY_UTILS/fpolybench.c -o $POLY_UTILS/fpolybench.o 

  # compile C printf fortran wrappers
  rm -f tmp/printf.o
  riscv64-unknown-linux-gnu-gfortran -c -O3 $LIBS/printf.c -o tmp/printf.o
}

# Compiles a PolyBench utilitaries
#
function buildPolybenchUtils_gcc()
{
  # compile polybench utilitaries library
  rm -f $POLY_UTILS/fpolybench.o
  riscv64-unknown-elf-gcc $POLY_DEFS -c -O3 \
    $POLY_UTILS/fpolybench.c -o $POLY_UTILS/fpolybench.o 

  # compile C printf fortran wrappers
  rm -f tmp/printf.o
  riscv64-unknown-elf-gcc -c -O3 $LIBS/printf.c -o tmp/printf.o
}


# Compiles a Gemmini library with accelerated BLAS kernels
#
function buildGemminiAcceleratedBlasLibrary()
{
  # clean up before compiling
  rm -f ./tmp/gemminikernels.o

  # use custom gemmini parameters
  cp -f ./libs/gemmini_params.h $GEMMINI_INCLUDE/gemmini_params.h

  # generate library
  riscv64-unknown-elf-gcc $GEMMINI_FLAGS \
    libs/GemminiKernels.c -c -o ./tmp/gemminikernels.o
}

# Compiles a Hwacha library with accelerated BLAS kernels
#
function buildHwachaAcceleratedBlasLibrary()
{
  # clean up before compiling
  rm -f ./tmp/hwachakernels.o

  # generate library $LIBS/HwachaKernels.S
  riscv64-unknown-elf-gcc $HWACHA_FLAGS $LIBS/HwachaKernels.S \
    libs/HwachaKernels.c -o ./tmp/hwachakernels.o
}



# Compiles a Fotran input file using FIR's toolchain
#
# $1 - Input file to be compiled (must be .f90 or .mlir)
# $2 - Output binary file path
# $3 - Extra link targets for the binary
#
function FIRBinary_Fortran()
{
  # fetch input file extension
  extension=${1##*.}

  # input is source code: lower to MLIR
  if [[ "${extension^^}" == "F90" ]]
  then

    # digest preprocessor directives
    flang -I$POLY_UTILS $1 -E $POLY_DEFS > tmp/input.f90

    # lower Fortran to MLIR
    bbc tmp/input.f90 -o tmp/input.mlir --target=riscv64-unknown-elf -emit-fir

  # input is already MLIR: copy and rename input file
  elif [[ "${extension^^}" == "MLIR" ]]
  then
    cp $1 tmp/input.mlir
  fi

  # lower MLIR to LLVM IR
  tco tmp/input.mlir -o tmp/input.ll

  # lower LLVM IR to RISCV
  clang tmp/input.ll -c -o tmp/input.o \
    --target=riscv64-unknown-elf \
    -march=rv64gc -Wa,-march=rv64gcxhwacha \
    --sysroot=$RISCV/riscv64-unknown-elf \
    --gcc-toolchain=$RISCV

  # fix FIR symbols to match GCC
  riscv64-unknown-elf-objcopy tmp/input.o \
    --redefine-sym _QPcheck_err=check_err_ \
    --redefine-sym _QPpolybench_timer_start=polybench_timer_start_ \
    --redefine-sym _QPpolybench_timer_stop=polybench_timer_stop_ \
    --redefine-sym _QPpolybench_timer_print=polybench_timer_print_ \
    --redefine-sym _QPprintf_line=printf_line_ \
    --redefine-sym _QPprintf_num=printf_num_ \
    --redefine-sym _QQmain=main

  # fix FIR BLAS symbols to match BLAS library
  riscv64-unknown-elf-objcopy tmp/input.o \
    --redefine-sym _QPdgemm=dgemm_ \
    --redefine-sym _QPdgemv=dgemv_ \
    --redefine-sym _QPdsymm=dsymm_ \
    --redefine-sym _QPdsyr2k=dsyr2k_ \
    --redefine-sym _QPdtrmm=dtrmm_ \
    --redefine-sym _QPsgemm=sgemm_ \
    --redefine-sym _QPsgemv=sgemv_ \
    --redefine-sym _QPssymm=ssymm_ \
    --redefine-sym _QPssyr2k=ssyr2k_ \
    --redefine-sym _QPstrmm=strmm_

  # link GCC polybench utils with FIR kernel
  riscv64-unknown-linux-gnu-gfortran tmp/input.o \
    ./$POLY_UTILS/fpolybench.o \
    tmp/printf.o \
    $3 \
    -o $2 -static
}

function FIRBinary_gcc()
{
  # fetch input file extension
  extension=${1##*.}

  # input is source code: lower to MLIR
  if [[ "${extension^^}" == "F90" ]]
  then

    # digest preprocessor directives
    flang -I$POLY_UTILS $1 -E $POLY_DEFS > tmp/input.f90

    # lower Fortran to MLIR
    bbc tmp/input.f90 -o tmp/input.mlir --target=riscv64-unknown-elf -emit-fir

  # input is already MLIR: copy and rename input file
  elif [[ "${extension^^}" == "MLIR" ]]
  then
    cp $1 tmp/input.mlir
  fi

  # lower MLIR to LLVM IR
  tco tmp/input.mlir -o tmp/input.ll

  # lower LLVM IR to RISCV
  clang tmp/input.ll -c -o tmp/input.o \
    --target=riscv64-unknown-elf \
    -march=rv64gc -Wa,-march=rv64gcxhwacha \
    --sysroot=$RISCV/riscv64-unknown-elf \
    --gcc-toolchain=$RISCV

  # fix FIR symbols to match GCC
  riscv64-unknown-elf-objcopy tmp/input.o \
    --redefine-sym _QPcheck_err=check_err_ \
    --redefine-sym _QPpolybench_timer_start=polybench_timer_start_ \
    --redefine-sym _QPpolybench_timer_stop=polybench_timer_stop_ \
    --redefine-sym _QPpolybench_timer_print=polybench_timer_print_ \
    --redefine-sym _QPprintf_line=printf_line_ \
    --redefine-sym _QPprintf_num=printf_num_ \
    --redefine-sym _QQmain=main

  # fix FIR BLAS symbols to match BLAS library
  riscv64-unknown-elf-objcopy tmp/input.o \
    --redefine-sym _QPdgemm=dgemm_ \
    --redefine-sym _QPdgemv=dgemv_ \
    --redefine-sym _QPdsymm=dsymm_ \
    --redefine-sym _QPdsyr2k=dsyr2k_ \
    --redefine-sym _QPdtrmm=dtrmm_ \
    --redefine-sym _QPsgemm=sgemm_ \
    --redefine-sym _QPsgemv=sgemv_ \
    --redefine-sym _QPssymm=ssymm_ \
    --redefine-sym _QPssyr2k=ssyr2k_ \
    --redefine-sym _QPstrmm=strmm_

  # link GCC polybench utils with FIR kernel
  riscv64-unknown-elf-gcc tmp/input.o \
    ./$POLY_UTILS/fpolybench.o \
    tmp/printf.o \
    $3 \
    -o $2 
}


# Compiles a Fotran input file and rewrites it with the specified kernel
#
# $1 - Input file to be compiled
# $2 - PAT file to be used
# $3 - Optimized binary file path
# $4 - Accelerator to be used (gemmini or cpu)
#
function SMRBinary ()
{
  # process compiler directives with flang
  flang -I$POLY_UTILS $1 -E $POLY_DEFS > tmp/input.f90

  # replace polybench kernel with BLAS call using SMR
  SMR tmp/input.f90 --pat=$2 -d fir -o tmp/rewritten.mlir

  # remove module_terminator operations (unsupported by TCO)
  sed -i "/\bmodule_terminator\b/d" tmp/rewritten.mlir

  # chose which accelerated library to use
  if [[ "${4^^}" == "GEMMINI" ]]
  then
    # link with Gemmini accelerated library
    buildGemminiAcceleratedBlasLibrary
    LINK="./tmp/gemminikernels.o"
    # compile rewritten MLIR code with FIR toolchain
    FIRBinary_gcc "tmp/rewritten.mlir" "$3" "$LINK"
  elif [[ "${4^^}" == "HWACHA" ]]
  then
    # link with Hwacha accelerated library
    buildHwachaAcceleratedBlasLibrary
    LINK="./tmp/hwachakernels.o"
    # compile rewritten MLIR code with FIR toolchain
    FIRBinary_gcc "tmp/rewritten.mlir" "$3" "$LINK"
  elif [[ "${4^^}" == "BLAS" ]]
  then
    # link with referece RISCV BLAS library
    LINK="/root/builds/riscv-blas/librefblas.a"
  elif [[ "${4^^}" == "OPENBLAS" ]]
  then
    # link with referece RISCV BLAS library
    LINK="/root/OpenBLAS-0.3.20/libopenblas.a"
    # compile rewritten MLIR code with FIR toolchain
    FIRBinary_Fortran "tmp/rewritten.mlir" "$3" "$LINK"
  else
    echo "[ERROR] No optimized library to be linked."
    exit
  fi

  
}
