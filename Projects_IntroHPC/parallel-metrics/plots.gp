# Script de gnuplot para generar gráficas de métricas paralelas
# Generar PDFs con las métricas de speedup y eficiencia

# Configuración general
set encoding utf8
set termoption enhanced

# Información del sistema (ajustar según sea necesario)
cores_fisicos = 6
max_threads = 13

#===============================================
# GRÁFICA 1: SPEEDUP
#===============================================

set terminal pdf enhanced color font "Arial,12" size 10,7
set output "data/speedup.pdf"

set title "Speedup vs Número de Threads\n{/*0.8 Vector de 200M elementos - Intel i5-10500 (6 cores físicos)}" font "Arial,14"
set xlabel "Número de Threads" font "Arial,12"
set ylabel "Speedup (T₁/Tₚ)" font "Arial,12"

# Configurar grid y escalas
set grid xtics ytics
set xrange [0.5:13.5]
set yrange [0:14]

# Configurar tics
set xtics 1
set ytics 1

# Línea teórica ideal (speedup = threads)
set arrow from 1,1 to cores_fisicos,cores_fisicos nohead lc rgb "red" lw 2 dt 2
set label "Speedup Ideal" at cores_fisicos-1, cores_fisicos+0.5 textcolor rgb "red" font "Arial,10"

# Línea vertical indicando cores físicos
set arrow from cores_fisicos,0 to cores_fisicos,14 nohead lc rgb "gray" lw 1 dt 3
set label sprintf("Cores físicos (%d)", cores_fisicos) at cores_fisicos+0.1, 12 rotate by 90 font "Arial,9"

# Plotear datos
plot 'data/combined_results.txt' u 1:5 w linespoints lw 2 pt 7 ps 1.2 lc rgb "blue" title "Paralela (par)", \
     'data/combined_results.txt' u 1:6 w linespoints lw 2 pt 9 ps 1.2 lc rgb "dark-green" title "Paralela no secuenciada (par_unseq)", \
     x w lines lw 2 lc rgb "red" dt 2 title "Speedup ideal"

unset output

#===============================================
# GRÁFICA 2: EFICIENCIA PARALELA
#===============================================

set output "data/efficiency.pdf"

set title "Eficiencia Paralela vs Número de Threads\n{/*0.8 Vector de 200M elementos - Intel i5-10500 (6 cores físicos)}" font "Arial,14"
set xlabel "Número de Threads" font "Arial,12"
set ylabel "Eficiencia (Speedup/Threads)" font "Arial,12"

# Configurar escalas para eficiencia
set yrange [0:1.1]
set ytics 0.1

# Línea de eficiencia ideal (100%)
set arrow from 0.5,1 to 13.5,1 nohead lc rgb "red" lw 2 dt 2
set label "Eficiencia Ideal (100%)" at 7, 1.05 textcolor rgb "red" font "Arial,10"

# Línea vertical indicando cores físicos
set arrow from cores_fisicos,0 to cores_fisicos,1.1 nohead lc rgb "gray" lw 1 dt 3
set label sprintf("Cores físicos (%d)", cores_fisicos) at cores_fisicos+0.1, 0.9 rotate by 90 font "Arial,9"

# Plotear eficiencia
plot 'data/combined_results.txt' u 1:7 w linespoints lw 2 pt 7 ps 1.2 lc rgb "blue" title "Paralela (par)", \
     'data/combined_results.txt' u 1:8 w linespoints lw 2 pt 9 ps 1.2 lc rgb "dark-green" title "Paralela no secuenciada (par_unseq)", \
     1 w lines lw 2 lc rgb "red" dt 2 title "Eficiencia ideal (100%)"

unset output

#===============================================
# GRÁFICA 3: TIEMPO DE EJECUCIÓN
#===============================================

set output "data/execution_time.pdf"

set title "Tiempo de Ejecución vs Número de Threads\n{/*0.8 Vector de 200M elementos - Intel i5-10500 (6 cores físicos)}" font "Arial,14"
set xlabel "Número de Threads" font "Arial,12"
set ylabel "Tiempo de Ejecución (ms)" font "Arial,12"

# Usar escala logarítmica en Y para mejor visualización
set logscale y
set yrange [*:*]
set format y "%.0f"

# Línea vertical indicando cores físicos
stats 'data/combined_results.txt' u 2 nooutput
max_time = STATS_max
set arrow from cores_fisicos,STATS_min to cores_fisicos,max_time nohead lc rgb "gray" lw 1 dt 3
set label sprintf("Cores físicos (%d)", cores_fisicos) at cores_fisicos+0.1, max_time/2 rotate by 90 font "Arial,9"

# Plotear tiempos
plot 'data/combined_results.txt' u 1:2 w linespoints lw 2 pt 5 ps 1.2 lc rgb "orange" title "Secuencial", \
     'data/combined_results.txt' u 1:3 w linespoints lw 2 pt 7 ps 1.2 lc rgb "blue" title "Paralela (par)", \
     'data/combined_results.txt' u 1:4 w linespoints lw 2 pt 9 ps 1.2 lc rgb "dark-green" title "Paralela no secuenciada (par_unseq)"

unset logscale y
unset output

#===============================================
# GRÁFICA 4: COMPARACIÓN DIRECTA DE POLÍTICAS
#===============================================

set output "data/policies_comparison.pdf"

set title "Comparación de Políticas de Ejecución\n{/*0.8 Tiempo vs Speedup - Vector de 200M elementos}" font "Arial,14"
set xlabel "Speedup (T₁/Tₚ)" font "Arial,12"
set ylabel "Tiempo de Ejecución (ms)" font "Arial,12"

set logscale y
set xrange [0:*]

# Plotear relación speedup vs tiempo
plot 'data/combined_results.txt' u 5:3 w points pt 7 ps 1.5 lc rgb "blue" title "Paralela (par)", \
     'data/combined_results.txt' u 6:4 w points pt 9 ps 1.5 lc rgb "dark-green" title "Paralela no secuenciada (par_unseq)"

unset logscale y
unset output

#===============================================
# RESUMEN EN ARCHIVO DE TEXTO
#===============================================

# Crear un archivo de resumen con estadísticas
set print "data/summary_stats.txt"
print "# RESUMEN DE MÉTRICAS PARALELAS"
print "# ================================"
print ""
print "# Sistema: Intel i5-10500 (6 cores físicos, 12 threads)"
print "# Vector: 200,000,000 elementos"
print "# Operación: std::reduce (suma)"
print ""
print "# Formato: threads speedup_par speedup_unseq efficiency_par efficiency_unseq"

# Calcular y mostrar estadísticas clave
stats 'data/combined_results.txt' u 1:5 nooutput
max_speedup_par_value = STATS_max_y
pos_max_speedup_par = STATS_pos_max_y

stats 'data/combined_results.txt' u 1:6 nooutput  
max_speedup_unseq_value = STATS_max_y
pos_max_speedup_unseq = STATS_pos_max_y

print sprintf("# Mejor speedup paralela: %.2f con %d threads", max_speedup_par_value, pos_max_speedup_par)
print sprintf("# Mejor speedup paralela unseq: %.2f con %d threads", max_speedup_unseq_value, pos_max_speedup_unseq)

unset print

# Mensaje final
print "✓ Gráficas generadas exitosamente:"
print "  - data/speedup.pdf"
print "  - data/efficiency.pdf" 
print "  - data/execution_time.pdf"
print "  - data/policies_comparison.pdf"
print "  - data/summary_stats.txt"