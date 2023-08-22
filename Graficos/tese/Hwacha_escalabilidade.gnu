#!/usr/bin/gnuplot

OUTPUT_FILE = 'Hwacha_escalabilidade.pdf'
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
set xrange [-0.2:4.2]
set xtics ("256" 0, "512" 1, "768" 2, "1024" 3, "1280" 4)
set style data linespoints


$data1 << EOD
#   lane   	1_lane		2_lane		4_lane
0 	256 	331556		327513		323221
1 	512 	1588681		1510289		1501928
2 	768 	3574448		3215171		2982327
3 	1024 	6677143		5794905		5441067
4 	1280 	10108079	8867615		8038582
EOD

set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data1 \
	u (($2*$2)/$3) t "1 lane" ls 2, \
""  u (($2*$2)/$4) t "2 lane" ls 3, \
""  u (($2*$2)/$5) t "4 lane" ls 4


unset title
unset yrange
unset style

# Overhead Analysis
set title font ",24"
set title "(b) SGEMM"
set style fill solid 1 border -1

$data2 << EOD
#   lane   	1_lane		2_lane		4_lane
0 	128 	1072148		774686		647630
1 	256 	6512965		4685541		4098496
2 	384 	21025585	14109998	13988300
3 	512 	50765643	36154500	35202175
EOD

set yrange [0:5.5]
set ylabel "GFLOPS"
set xlabel "Dimensão da matriz"
set xrange [-0.2:3.2]
set xtics ("128" 0, "256" 1, "384" 2, "512" 3)
set style data linespoints



set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data2 \
	u (($2*$2*$2)/$3) t "1 lane" ls 2, \
""  u (($2*$2*$2)/$4) t "2 lane" ls 3, \
""  u (($2*$2*$2)/$5) t "4 lane" ls 4



unset multiplot
