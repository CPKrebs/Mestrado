#!/usr/bin/gnuplot

OUTPUT_FILE = 'ccr.pdf'
set terminal pdf enhanced size 3,5
set output OUTPUT_FILE

set multiplot layout 1,1

unset key
set key top right
unset border
set border 12 lw 2

set xtics font ", 14"
set ytics font ", 14"
set ylabel font ",20"
set key font ",14"

set grid ytics
set yrange [0.5:3.5]

set bars fullwidth
set boxwidth 0.8 absolute
set style fill solid 1 border -1

set ylabel "IPC"
#set xtics ("Executado" 0, "Paper" 1)
set xtics ("Executado" 0)

set style histogram
set style data histogram

#Trivial
$data1 <<EOD
#   531.deepsjeng_r     548.exchange2_r     538.imagick_r            
0   1.737               2.729               2.666      
#1  1.7               2.6               2.7   
EOD

set obj 1 rect from graph 0,0 to graph 1,1 fc rgb 0xf0f0f0 behind
plot $data1 \
    u ($2) t "531.deepsjeng\\_r" lc rgb '#2166AC', \
""  u ($3) t "548.exchange2\\_r" lc rgb '#D6604D', \
""  u ($4) t "538.imagick\\_r" lc rgb '#41AB5D'

unset ylabel
unset title

unset multiplot
