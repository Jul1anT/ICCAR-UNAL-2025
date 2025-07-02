#!/bin/bash

# Script para ejecutar todos los experimentos de métricas paralelas
# Uso: ./run_exp.sh <tamaño_vector>

if [ $# -ne 1 ]; then
    echo "Uso: $0 <tamaño_vector>"
    echo "Ejemplo: $0 200000000"
    exit 1
fi

VECTOR_SIZE=$1
MAX_THREADS=13  # 12 cores + 1 para sobresubscripción
EXECUTABLE="./parallel_metrics"

# Verificar que el ejecutable existe
if [ ! -f "$EXECUTABLE" ]; then
    echo "Error: $EXECUTABLE no encontrado. Ejecute 'make' primero."
    exit 1
fi

# Crear directorio de datos
mkdir -p data

echo "========================================="
echo "  EXPERIMENTOS DE MÉTRICAS PARALELAS"
echo "========================================="
echo "Vector size: $VECTOR_SIZE elementos"
echo "Threads: 1 a $MAX_THREADS"
echo "Políticas: seq, par, par_unseq"
echo "========================================="

# Función para mostrar barra de progreso
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    
    printf "\rProgreso: ["
    for ((i=0; i<filled; i++)); do printf ""; done
    for ((i=filled; i<width; i++)); do printf ""; done
    printf "] %d%% (%d/%d)" $percentage $current $total
}

# Archivos de salida
SEQ_FILE="data/sequential.txt"
PAR_FILE="data/parallel.txt"
UNSEQ_FILE="data/parallel_unseq.txt"

# Limpiar archivos anteriores
> "$SEQ_FILE"
> "$PAR_FILE"
> "$UNSEQ_FILE"

# Agregar headers
echo "# threads time_ms" >> "$SEQ_FILE"
echo "# threads time_ms" >> "$PAR_FILE"
echo "# threads time_ms" >> "$UNSEQ_FILE"

# Calcular total de experimentos
TOTAL_EXPERIMENTS=$((MAX_THREADS * 3))
CURRENT_EXPERIMENT=0

echo "Iniciando experimentos..."
echo

# Ejecutar experimentos
for threads in $(seq 1 $MAX_THREADS); do
    echo "--- Threads: $threads ---"
    
    # Política secuencial
    echo -n "  Secuencial: "
    result=$($EXECUTABLE $VECTOR_SIZE $threads 0 2>/dev/null | tail -n 1)
    echo "$result" >> "$SEQ_FILE"
    echo "✓"
    CURRENT_EXPERIMENT=$((CURRENT_EXPERIMENT + 1))
    show_progress $CURRENT_EXPERIMENT $TOTAL_EXPERIMENTS
    
    # Política paralela
    echo -n "  Paralela: "
    result=$($EXECUTABLE $VECTOR_SIZE $threads 1 2>/dev/null | tail -n 1)
    echo "$result" >> "$PAR_FILE"
    echo "✓"
    CURRENT_EXPERIMENT=$((CURRENT_EXPERIMENT + 1))
    show_progress $CURRENT_EXPERIMENT $TOTAL_EXPERIMENTS
    
    # Política paralela no secuenciada
    echo -n "  Paralela unseq: "
    result=$($EXECUTABLE $VECTOR_SIZE $threads 2 2>/dev/null | tail -n 1)
    echo "$result" >> "$UNSEQ_FILE"
    echo "✓"
    CURRENT_EXPERIMENT=$((CURRENT_EXPERIMENT + 1))
    show_progress $CURRENT_EXPERIMENT $TOTAL_EXPERIMENTS
    
    echo
done

echo
echo "========================================="
echo "✓ Todos los experimentos completados"
echo "========================================="

# Generar archivo de datos combinados para análisis
COMBINED_FILE="data/combined_results.txt"
echo "# threads seq_time par_time unseq_time speedup_par speedup_unseq efficiency_par efficiency_unseq" > "$COMBINED_FILE"

# Leer tiempo secuencial de referencia (1 thread)
seq_time_1=$(grep "^1" "$SEQ_FILE" | awk '{print $2}')

echo "Calculando métricas de rendimiento..."

for threads in $(seq 1 $MAX_THREADS); do
    seq_time=$(grep "^$threads" "$SEQ_FILE" | awk '{print $2}')
    par_time=$(grep "^$threads" "$PAR_FILE" | awk '{print $2}')
    unseq_time=$(grep "^$threads" "$UNSEQ_FILE" | awk '{print $2}')
    
    # Calcular speedup y eficiencia
    if [ -n "$seq_time_1" ] && [ -n "$par_time" ] && [ -n "$unseq_time" ]; then
        speedup_par=$(echo "scale=4; $seq_time_1 / $par_time" | bc)
        speedup_unseq=$(echo "scale=4; $seq_time_1 / $unseq_time" | bc)
        efficiency_par=$(echo "scale=4; $speedup_par / $threads" | bc)
        efficiency_unseq=$(echo "scale=4; $speedup_unseq / $threads" | bc)
        
        echo "$threads $seq_time $par_time $unseq_time $speedup_par $speedup_unseq $efficiency_par $efficiency_unseq" >> "$COMBINED_FILE"
    fi
done

echo "✓ Métricas calculadas y guardadas en $COMBINED_FILE"

# Generar gráficas
echo "Generando gráficas..."
if command -v gnuplot &> /dev/null; then
    gnuplot plots.gp
    echo "✓ Gráficas generadas en data/"
    echo "  - data/speedup.pdf"
    echo "  - data/efficiency.pdf"
else
    echo "⚠️  gnuplot no encontrado. Instale con: sudo apt install gnuplot"
    echo "   Las gráficas se pueden generar después con: make plots"
fi

echo
echo "========================================="
echo "  RESUMEN DE RESULTADOS"
echo "========================================="

# Mostrar algunos resultados clave
echo "Tiempo secuencial (1 thread): ${seq_time_1} ms"

# Mejor speedup
max_speedup_par=$(awk 'NR>1 {if($5>max) max=$5; if($5>max_threads) {max_threads=$1}} END {print max}' "$COMBINED_FILE")
max_threads_par=$(awk -v max="$max_speedup_par" 'NR>1 && $5==max {print $1}' "$COMBINED_FILE")

echo "Mejor speedup paralelo: ${max_speedup_par}x con ${max_threads_par} threads"

echo "========================================="
echo "Experimentos completados exitosamente!"
echo "Los resultados están en la carpeta 'data/'"
echo "========================================"