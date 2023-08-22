#!/usr/bin/gnuplot

OUTPUT_FILE = 'analysis.pdf'
set terminal pdf enhanced size 7,3
set output OUTPUT_FILE

set multiplot layout 1,2

unset key
set key top left
unset border
set border 15 lw 2

set xtics font ", 14"
set ytics font ", 14"
set ylabel font ",20"
set key font ",14"
set grid ytics

set bars fullwidth
set boxwidth 0.95 absolute

# Overhead Analysis
set title font ",24"
set title "(a) Overhead Analysis"
set style fill solid 1.0 border -1

set yrange [0:100]
set ylabel "Wall Time %"
set xlabel "Workload"
set xtics ("1K" 0, "10K" 1, "100K" 2, "1M" 3, "10M" 4, "100M" 5)
set style histogram rowstacked
set style data histogram

$data1 << EOD
#   startup shutd   sched   Wall Time
0   8.440   5.306   0.250   25.812
1   8.691   4.249   0.259   25.923
2   8.455   3.945   0.260   33.847
3   8.509   4.229   0.266   123.562
4   8.885   5.113   0.265   972.668
5   8.309   5.556   0.255   9550.65
EOD

set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data1 u (100.*$4/$5) t "Schedule" lc rgb '#87CEEB', \
"" u (100.*$2/$5) t "Startup" lc rgb '#9400D3', \
"" u (100.*$3/$5) t "Shutdown"  lc rgb '#F4A460'

unset title
unset yrange
unset style

# Awave Analysis
set title font ",24"
set title "(b) Awave Scalability"
set style fill solid 1.0 border -1

set yrange [0.5:16.5]
set ylabel "Speedup"
set xtics ("1" 0, "2" 1, "4" 2, "8" 3, "16" 4 )
set xlabel "Worker Nodes"

set style histogram
set style data histogram

$data2 << EOD
#   Sigsbee Marmousi 
0   1.00    1.00
1   1.99    2.00
2   3.70    3.85
3   7.41    7.83
4   15.04   14.97
EOD

set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data2 u ($2) t "Sigsbee" lc rgb '#87CEEB', \
"" u ($3) t "Marmousi" lc rgb '#9400D3'

unset multiplot
