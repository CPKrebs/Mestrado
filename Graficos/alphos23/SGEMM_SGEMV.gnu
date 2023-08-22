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
set title "(a) SGEMM"
set style fill solid 1.0 border -1

set yrange [0:30]
set ylabel "Speedup"
set xlabel "Matrix size"
set xrange [-0.2:5.2]
set xtics ("128" 0, "256" 1, "384" 2, "512" 3, "640" 4, "768" 5)
set style data linespoints


$data1 << EOD
#   ACC 		CBLAS   
0   268044		4296246
1   1558992		31916291
2   5463169		106854965
3   13068726	249270355
4   26643601	488333632
5   44483610	839711234
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

set yrange [0:4]
set ylabel "Speedup"
set xlabel "Matrix size"
set xrange [-0.2:7.2]
set xtics ("256" 0, "512" 1, "768" 2, "1024" 3, "1280" 4, "1536" 5, "1792" 6, "2048" 7)
set style data linespoints


$data3 << EOD
#   ACC 		CBLAS   
0   301363		728405
1   1326083		2768940
2 	2941430		6149085
3 	5334561		11188601
4 	8298195	 	16888235
5 	11976032 	24515465
6 	16397290 	33019730
7 	21070158 	44446313
EOD


set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data3 u ($3/$2) t "" ls 2



unset multiplot
