# Configuración común
set encoding utf8
set termoption enhanced
set grid xtics ytics
set font "Arial,12"
cores = 6
max_threads = 13
vector_size = "200M elementos"
cpu_model = "Intel i5-10500 (6 cores)"

# Estilos comunes
set style line 1 lc rgb "blue" lw 2 pt 7 ps 1.2
set style line 2 lc rgb "dark-green" lw 2 pt 9 ps 1.2 
set style line 3 lc rgb "red" lw 2 dt 2
set style line 4 lc rgb "gray" lw 1 dt 3
set style line 5 lc rgb "orange" lw 2 pt 5 ps 1.2

# Función para títulos
system_title(t) = sprintf("%s\n{/*0.8 %s - %s}", t, vector_size, cpu_model)

# Speedup
set terminal pdf enhanced size 10,7
set output "data/speedup.pdf"
set title system_title("Speedup vs Número de Threads")
set xlabel "Número de Threads"; set ylabel "Speedup (T₁/Tₚ)"
set xrange [0.5:13.5]; set yrange [0:14]
set xtics 1; set ytics 1

set arrow from 1,1 to cores,cores nohead ls 3
set label "Ideal" at cores-1, cores+0.5 tc rgb "red"
set arrow from cores,0 to cores,14 nohead ls 4
set label sprintf("%d cores", cores) at cores+0.1, 12 rotate by 90

plot 'data/combined_results.txt' u 1:5 w lp ls 1 t "Paralela (par)", \
     '' u 1:6 w lp ls 2 t "Paralela no secuenciada (par_unseq)", \
     x w l ls 3 t "Ideal"

# Eficiencia
set output "data/efficiency.pdf"
set title system_title("Eficiencia Paralela")
set ylabel "Eficiencia (Speedup/Threads)"
set yrange [0:1.1]; set ytics 0.1

set arrow from 0.5,1 to 13.5,1 nohead ls 3
set label "100%" at 7, 1.05 tc rgb "red"
set arrow from cores,0 to cores,1.1 nohead ls 4

plot 'data/combined_results.txt' u 1:7 w lp ls 1, \
     '' u 1:8 w lp ls 2, \
     1 w l ls 3 t "Ideal"

# Tiempos de ejecución
set output "data/execution_time.pdf"
set title system_title("Tiempo de Ejecución")
set ylabel "Tiempo (ms)"; unset yrange
set logscale y; set format y "%.0f"

stats 'data/combined_results.txt' u 2 nooutput
set arrow from cores,STATS_min to cores,STATS_max nohead ls 4

plot 'data/combined_results.txt' u 1:2 w lp ls 5 t "Secuencial", \
     '' u 1:3 w lp ls 1 t "Paralela", \
     '' u 1:4 w lp ls 2 t "Paralela no secuenciada"

unset logscale

# Comparación de políticas
set output "data/policies_comparison.pdf"
set title system_title("Comparación de Políticas")
set xlabel "Speedup"; set ylabel "Tiempo (ms)"
set logscale y; set xrange [0:*]

plot 'data/combined_results.txt' u 5:3 w p ls 1, \
     '' u 6:4 w p ls 2

# Resumen estadístico
set print "data/summary_stats.txt"
print "# Resumen de Métricas Paralelas"
print "# Mejores valores obtenidos:"
stats 'data/combined_results.txt' u 5 nooutput
print sprintf(" - Speedup paralela: %.2fx con %d threads", STATS_max, STATS_index_max)
stats 'data/combined_results.txt' u 6 nooutput
print sprintf(" - Speedup paralela unseq: %.2fx con %d threads", STATS_max, STATS_index_max)
unset print