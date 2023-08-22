#!/usr/bin/gnuplot

OUTPUT_FILE = 'SGEMM.pdf'
set terminal pdf enhanced size 3,3
set output OUTPUT_FILE


#set terminal png size 400,400 
#set output 'SGEMM_SGEMV.png'

set multiplot layout 1,1

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
set title "SGEMM"
set style fill solid 1.0 border -1

set yrange [0:50]
set ylabel "Speedup"
set xlabel "Matrix size"
set xrange [-0.2:5.2]
set xtics ("128" 0, "256" 1, "384" 2, "512" 3, "640" 4, "768" 5)
set style data linespoints


$data1 << EOD
#   ACC 		CBLAS   
0   94813		4291059
1   1226749		31815829
2   5228210		106459142
3   13030346	248414023
4   26513441	486823879
5   44445270	837763386
EOD

set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data1 u ($3/$2) t "" ls 2


unset multiplot
