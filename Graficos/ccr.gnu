#!/usr/bin/gnuplot

OUTPUT_FILE = 'ccr.pdf'
set terminal pdf enhanced size 13,3
set output OUTPUT_FILE

set multiplot layout 1,4

unset key
set key top right
unset border
set border 15 lw 2

set xtics font ", 14"
set ytics font ", 14"
set ylabel font ",20"
set key font ",14"

set grid ytics
set yrange [0:12]

set bars fullwidth
set boxwidth 0.75 absolute
set style fill solid 1.0 border -1

set title font ",24"
set title "(a) Trivial"

set xlabel "CCR"
set ylabel "Execution Time (s)"
set xtics ("0.5" 0, "1.0" 1, "2.0" 2)
set style histogram
set style data histogram

#Trivial
$data1 <<EOD
#   ompc        Charm++     starpu      mpi  
0   8.819       4.974       7.881       5.627      #CCR 0.5
1   6.849       4.229       5.893       4.670      #CCR 1.0
2   5.890       3.857       4.770       4.206      #CCR 2.0
EOD

set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data1 \
    u ($2) t "OMPC" lc rgb '#2166AC', \
""  u ($3) t "Charm++" lc rgb '#9400D3', \
""  u ($4) t "StarPU" lc rgb '#41AB5D', \
""  u ($5) t "MPI" lc rgb '#D6604D'

unset ylabel
unset title

#Tree
$data2 <<EOD
#   ompc        Charm++     starpu      mpi   
0   16.819      32.450      10.679      11.357   
1   10.869      17.833      7.529       7.477    
2   8.819       10.694      5.505       5.534    
EOD

set title font ",24"
set title "(b) Tree"
set yrange[0:35]

set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data2 \
    u ($2) t "OMPC" lc rgb '#2166AC', \
""  u ($3) t "Charm++" lc rgb '#9400D3', \
""  u ($4) t "StarPU" lc rgb '#41AB5D', \
""  u ($5) t "MPI" lc rgb '#D6604D'

unset title

#Stencil-1D periodic
$data3 <<EOD
#   ompc        Charm++     starpu      mpi
0   45.709      63.401      19.971      16.271   
1   28.280      33.588      12.363      9.575   
2   13.230      18.260      7.732       6.772    
EOD

set title font ",24"
set title "(c) Stencil-1D Periodic"
set yrange[0:65]

set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data3 \
    u ($2) t "OMPC" lc rgb '#2166AC', \
""  u ($3) t "Charm++" lc rgb '#9400D3', \
""  u ($4) t "StarPU" lc rgb '#41AB5D', \
""  u ($5) t "MPI" lc rgb '#D6604D'

unset title

#FFT
$data4 <<EOD
#   ompc        Charm++     starpu      mpi   
0   30.809      59.099      19.258      15.426   
1   18.700      31.423      11.923      9.675    
2   12.050      17.301      7.584       6.616    
EOD

set title font ",24"
set title "(d) FFT"
set yrange[0:62]

set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data4 \
    u ($2) t "OMPC" lc rgb '#2166AC', \
""  u ($3) t "Charm++" lc rgb '#9400D3', \
""  u ($4) t "StarPU" lc rgb '#41AB5D', \
""  u ($5) t "MPI" lc rgb '#D6604D'

unset multiplot
