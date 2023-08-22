#!/usr/bin/gnuplot

OUTPUT_FILE = 'SGEMM_SGEMV.pdf'
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

set yrange [0:2.9]
set ylabel "Speedup"
set xlabel "Dimensão da matriz"
set xrange [-0.2:7.2]
set xtics ("256" 0, "512" 1, "768" 2, "1024" 3, "1280" 4, "1536" 5, "1792" 6, "2048" 7)

set style data linespoints


$data1 << EOD
#   ACC 	hwacha   	Gemmini		OpenBLAS
0 	256 	331556		301363		728405
1 	512 	1588681		1326083		2768940
2 	768 	3574448		2941430		6149085
3 	1024 	6677143		5334561		11188601
4 	1280 	10108079	8298195		16888235
5 	1536	15024080	11976032	24515465
6 	1792	20332618	16397290	33019730
7 	2048	26551714	21070158	44446313
EOD

set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data1 \
	u ($5/$4) t "Gemmini" ls 2, \
"" 	u ($5/$3) t "Hwacha" ls 3

unset title
unset yrange
unset style

# Overhead Analysis
set title font ",24"
set title "(b) SGEMM"
set style fill solid 1 border -1

$data2 << EOD
#   ACC 	hwacha   	Gemmini		OpenBLAS   
0 	128 	1072148		268044		4296246
1 	256 	6512965		1558992		31916291
2 	384 	21025585	5463169		106854965
3 	512 	50765643	13068726	249270355
4 	640 	101012936	26643601	488333632
5 	768 	196500878 	44483610	839711234
EOD

set yrange [0:26]
set ylabel "Speedup"
set xlabel "Dimensão da matriz"
set xrange [-0.2:5.2]
set xtics ("128" 0, "256" 1, "384" 2, "512" 3, "640" 4, "768" 5)
set style data linespoints



set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data2 \
	u ($5/$4) t "Gemmini" ls 2, \
"" 	u ($5/$3) t "Hwacha" ls 3



unset multiplot
