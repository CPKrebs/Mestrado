#!/usr/bin/gnuplot

OUTPUT_FILE = 'SGEMM_SGEMV_cache_suja.pdf'
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
set title "(a) SGEMM"
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


unset title
unset yrange
unset style

# Overhead Analysis
set title font ",24"
set title "(b) SGEMV"
set style fill solid 1 border -1

$data2 << EOD
#   ACC 	CBLAS   
0   58955	591915
1   971091	2492778
2   2695103	5970890
3   4563817	10862820
EOD

set yrange [0:6]
set ylabel "Speedup"
set xlabel "Matrix size"
set xrange [-0.2:7.2]
set xtics ("256" 0, "512" 1, "768" 2, "1024" 3, "1280" 4, "1536" 5, "1792" 6, "2048" 7)
set style data linespoints


$data3 << EOD
#   ACC 		CBLAS   
0   111958		591333
1   1096568		2675759
2 	2697474		6196467
3 	4956812		11252467
4 	7784327	 	16957163
5 	11179696 	24579541
6 	15385979 	33073309
7 	19649581 	44491300
EOD


set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data3 u ($3/$2) t "" ls 2



unset multiplot
