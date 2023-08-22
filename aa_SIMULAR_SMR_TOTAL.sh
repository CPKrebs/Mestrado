export RISCV=/opt/RISC-V/riscv_linux
export PATH=$PATH:$RISCV/bin


echo '____________________________________________________________'
echo 'gemm'
echo ' '
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/hwacha/gemm
#time ./TESE/simulator-chipyard-GemminiFPMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/gemmini/gemm
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/openblas/gemm

echo '____________________________________________________________'
echo '2mm'
echo ' '
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/hwacha/2mm
#time ./TESE/simulator-chipyard-GemminiFPMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/gemmini/2mm
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/openblas/2mm

echo '____________________________________________________________'
echo '3mm'
echo ' '
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/hwacha/3mm
#time ./TESE/simulator-chipyard-GemminiFPMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/gemmini/3mm
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/openblas/3mm

echo '____________________________________________________________'
echo 'syrk'
echo ' '
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/hwacha/syrk
#time ./TESE/simulator-chipyard-GemminiFPMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/gemmini/syrk
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/openblas/syrk

echo '____________________________________________________________'
echo 'atax'
echo ' '
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/hwacha/atax
#time ./TESE/simulator-chipyard-GemminiFPMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/gemmini/atax
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/openblas/atax

echo '____________________________________________________________'
echo 'bicg'
echo ' '
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/hwacha/bicg
#time ./TESE/simulator-chipyard-GemminiFPMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/gemmini/bicg
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/openblas/bicg

echo '____________________________________________________________'
echo 'mvt'
echo ' '
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/hwacha/mvt
#time ./TESE/simulator-chipyard-GemminiFPMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/gemmini/mvt
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/openblas/mvt






#time ./TESE/simulator-chipyard-GemminiFPMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/gemmini/SGEMM
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/openblas/SGEMM
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/hwacha/SGEMM

#time ./TESE/simulator-chipyard-GemminiFPMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/gemmini/SGEMV
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/openblas/SGEMV
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/hwacha/SGEMV





#time ./TESE/simulator-chipyard-GemminiFPMegaBoom_0 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/openblas/SGEMM
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/hwacha/SGEMV


#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/hwacha/SGEMV
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60_2lane -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/hwacha/SGEMV
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60_4lane -c EXPERIMENTOS/pk /opt/SRM/smr-gemmini/bin/validate/hwacha/SGEMV


#time ./TESE/simulator-chipyard-HwachaMegaBoom_0 -c EXPERIMENTOS/pk /opt/BOOM/chipyard/sims/verilator/EXPERIMENTOS/hwacha/SGEMM512
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60 -c EXPERIMENTOS/pk /opt/BOOM/chipyard/sims/verilator/EXPERIMENTOS/hwacha/SGEMM512
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60_2lane -c EXPERIMENTOS/pk /opt/BOOM/chipyard/sims/verilator/EXPERIMENTOS/hwacha/SGEMM512
#time ./TESE/simulator-chipyard-HwachaMegaBoom_60_4lane -c EXPERIMENTOS/pk /opt/BOOM/chipyard/sims/verilator/EXPERIMENTOS/hwacha/SGEMM512



time ./simulator-chipyard-RocketConfig -c EXPERIMENTOS/pk Hello.riscv
