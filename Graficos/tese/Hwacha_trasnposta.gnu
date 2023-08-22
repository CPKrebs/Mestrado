#!/usr/bin/gnuplot

OUTPUT_FILE = 'Hwacha_trasnposta.pdf'
set terminal pdf enhanced size 4,3
set output OUTPUT_FILE

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
set style fill solid 1.0 border -1

set yrange [0:0.25]
set ylabel "GFLOPS"
set xlabel "Dimensão da matriz"
set xrange [-0.2:4.2]
set xtics ("256" 0, "512" 1, "768" 2, "1024" 3, "1280" 4)
set style data linespoints


$data1 << EOD
#   lane   	Normal		Transposta		
0 	256 	331556		737423		
1 	512 	1588681		2893346		
2 	768 	3574448		5463062		
3 	1024 	6677143		10066007		
4 	1280 	10108079	15029687		
EOD

set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data1 \
	u (($2*$2)/$3) t "Normal" ls 2, \
""  u (($2*$2)/$4) t "Transposta" ls 3



unset multiplot
