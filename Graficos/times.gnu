#!/usr/bin/gnuplot

OUTPUT_FILE = 'times.pdf'
set terminal pdf enhanced size 13,3
set output OUTPUT_FILE

set multiplot layout 1,4

unset key
set key left top
set key font ",12"
unset border
set border 15 lw 2

set xtics font ", 14"
set ytics font ", 14"
set ylabel font ",20"

set grid xtics ytics

# line styles
set style line 1 lw 2 pt 7 ps 1 lc rgb '#2166AC' # OMPC
set style line 2 lw 2 pt 7 ps 1 lc rgb '#9400D3' # Charm++
set style line 3 lw 2 pt 7 ps 1 lc rgb '#41AB5D' # StarPU
set style line 4 lw 2 pt 7 ps 1 lc rgb '#D6604D' # MPI

set style data linespoints

#Trivial
set title font ",24"
set title "(a) Trivial"
set xlabel "Nodes"
set xrange [-0.2:5.2]
set xtics ("2" 0, "4" 1, "8" 2, "16" 3, "32" 4, "64" 5)
set ylabel "Execution Time (s)"
set yrange [0:5]

$data1 << EOD
#n   OmpC   Charm++ StarPU	MPI
0	 2.4884 1.7082  2.2778  1.7852
1	 2.4984 1.7179  2.2917  1.8006
2	 2.4910 1.7416  2.3205  1.8420
3	 2.6212 1.7599  2.3329  1.8587
4	 2.7254 1.7821  2.3483  1.8778
5	 3.5691 1.8236  2.3565  1.8978
EOD

set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data1 \
    u ($1):($2) t "OMPC" ls 1, \
""  u ($1):($3) t "Charm++" ls 2, \
""  u ($1):($4) t "StarPU" ls 3, \
""  u ($1):($5) t "MPI" ls 4

unset ylabel
unset title

#Tree
set title font ",24"
set title "(b) Tree"
set yrange [0:22]

$data2 << EOD
#n  OmpC    Charm++ StarPU	MPI
0   2.8207  8.5654  2.5380  2.8476
1   3.8026  11.129  2.5513  2.8649
2   4.2108  11.659  2.5417  2.8571
3   4.5585  11.691  2.5162  2.9307
4   5.3117  11.715  2.4991  2.8850
5   7.7797  11.842  2.4902  2.8944
EOD

set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data2 \
    u ($1):($2) t "OMPC" ls 1, \
""  u ($1):($3) t "Charm++" ls 2, \
""  u ($1):($4) t "StarPU" ls 3, \
""  u ($1):($5) t "MPI" ls 4

unset ylabel
unset title

#Stencil-1D periodic
set title font ",24"
set title "(c) Stencil-1D Periodic"
set yrange [0:22]

$data3 << EOD
#n   OmpC   Charm++	starPU	MPI
0	 3.7096 12.442  3.5716  4.1159
1	 6.4204 12.490  3.3929  4.0639
2	 8.3591 12.502  3.2863  4.0892
3	 9.3990 12.545  3.2350  4.1229
4	 11.730 12.587  3.2445  4.3135
5	 16.974 12.671  3.2388  4.3898
EOD

set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data3 \
    u ($1):($2) t "OMPC" ls 1, \
""  u ($1):($3) t "Charm++" ls 2, \
""  u ($1):($4) t "StarPU" ls 3, \
""  u ($1):($5) t "MPI" ls 4

unset ylabel
unset title

#FFT
set title font ",24"
set title "(d) FFT"
set yrange [0:22]

$data4 << EOD
#n   OmpCluster Charm++  	starPU	MPI
0	 3.5420  	9.7959  	2.9189	3.5621
1	 6.0118  	11.754  	3.0059	3.6863
2	 7.4294 	12.320  	3.0973	3.7858
3	 8.3559  	12.723  	3.1359	3.9221
4	 10.382  	12.914  	3.1768	3.9223
5	 15.706  	13.064  	3.2166	4.1865
EOD

set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data4 \
    u ($1):($2) t "OMPC" ls 1, \
""  u ($1):($3) t "Charm++" ls 2, \
""  u ($1):($4) t "StarPU" ls 3, \
""  u ($1):($5) t "MPI" ls 4

# unset obj
# set key left center
# set key font ",14"
# set border 0
# unset tics
# unset title
# unset xlabel
# unset ylabel
# set yrange [0:1]
# 
# plot \
#     2 t "OMPC"      w linespoints   ls 1, \
#     2 t "Charm++"   w linespoints   ls 2, \
#     2 t "StarPU"    w linespoints   ls 3, \
#     2 t "MPI"       w linespoints   ls 4

unset multiplot
