#!/bin/bash
##
## Script to generate a CSV with SMR's compilation time overhead.
##

source utils.sh


#
# GLOBALS
#
KERNELS=("2mm" "3mm" "atax" "bicg" "gemm" "mvt" "syrk")
DEF="-DSMALL_DATASET -DPOLYBENCH_TIME -DDATA_TYPE=real -DDATA_PRINTF_MODIFIER=\"(f0.2,1x)\",advance='no'"
SCRIPT_PATH="tmp/compile.sh"


#
# SCRIPT
#
function generateTempScript()
{
  # Generates a temporary script which calls timeExecution utilitary method
  #
  # $1 - Compilation path to be timed (flang or smr)
  # $2 - Kernel compilation to be timed

  # dump template into temporary file
  printf "#!/bin/bash \nsource utils.sh \ntimeExecution " > $SCRIPT_PATH

  # append parameters to timeExecution utilitary method
  echo "$1 $2;" >> $SCRIPT_PATH

  # fix permissions
  chmod 777 $SCRIPT_PATH
}

# prepare CSV output file
echo '"Kernel","Flang","Flang+SMR"' > csv/compilation_times.csv

# build utils library (uses utils.sh method)
buildPolybenchUtils

# time each kernel
for kernel in ${KERNELS[@]}; do
  logKernel "Timing Compilation for ${kernel^^} Kernel"
  TIMINGS="$kernel"

  logInfo "Timing FIR Compilation Only"
  generateTempScript "fir" "$kernel"
  polybenchTimeToCsv "$SCRIPT_PATH"

  echo $SUBDIVIDER
  logInfo "Timing FIR Compilation with SMR Rewrite Overhead"
  generateTempScript "smr" "$kernel"
  polybenchTimeToCsv "$SCRIPT_PATH"

  # append kernel time to CSV file
  echo "$TIMINGS" >> csv/compilation_times.csv

done

# plot results
gnuplot gnu-scripts/compilation_times.gnu

echo "$DIVIDER"
