#!/usr/bin/gnuplot

OUTPUT_FILE = 'Gemmini_fluxo.pdf'
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
set title "(a) SGEMV"
set style fill solid 1.0 border -1

set yrange [0:0.3]
set ylabel "GFLOPS"
set xlabel "Dimensão da matriz"
set xrange [-0.2:3.2]
set xtics ("256" 0, "512" 1, "768" 2, "1024" 3)

set style data linespoints


$data1 << EOD
#   ACC 	WS   		OS		
0 	256 	289392		301363		
1 	512 	1175020		1326083		
2 	768 	2633130		2941430		
3 	1024 	4640551		5334561		
EOD

set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data1 \
	u (($2*$2)/$3) t "WS" ls 2, \
""	u (($2*$2)/$4) t "OS" ls 3	

unset title
unset yrange
unset style

# Overhead Analysis
set title font ",24"
set title "(b) SGEMM"
set style fill solid 1 border -1

$data2 << EOD
#   ACC 	OS   		WS		   
0 	128 	318131		268044		
1 	256 	1934255		1558992		
2 	384 	5855549		5463169		
3 	512 	13958746	13068726	
EOD

set yrange [0:12]
set ylabel "GFLOPS"
set xlabel "Dimensão da matriz"
set xrange [-0.2:3.2]
set xtics ("128" 0, "256" 1, "384" 2, "512" 3)
set style data linespoints



set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data2 \
	u (($2*$2*$2)/$4) t "WS" ls 2, \
""	u (($2*$2*$2)/$3) t "OS" ls 3


unset multiplot
