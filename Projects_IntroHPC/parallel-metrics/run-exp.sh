#!/bin/bash

VECTOR_SIZE=$1
MAX_THREADS=13
EXECUTABLE="./parallel-metrics"
DATADIR="data"

# Crear directorio y archivos
mkdir -p "$DATADIR"
OUTFILES=("$DATADIR/sequential.txt" "$DATADIR/parallel.txt" "$DATADIR/parallel_unseq.txt")

# Inicializar archivos de salida
for file in "${OUTFILES[@]}"; do
    echo "# threads time_ms" > "$file"
done

# Ejecutar experimentos
for ((t=1; t<=MAX_THREADS; t++)); do
    echo "Threads: $t"
    for policy in 0 1 2; do
        result=$($EXECUTABLE $VECTOR_SIZE $t $policy 2>/dev/null | tail -n1)
        if [[ -n "$result" ]]; then
            echo "$result" >> "${OUTFILES[$policy]}"
        else
            echo "ERROR: No se obtuvo resultado para threads=$t, policy=$policy"
        fi
    done
done

# Obtener tiempo de referencia secuencial
seq_ref=$(awk 'NR==2 {print $2}' "${OUTFILES[0]}")

# Verificar que seq_ref tiene un valor válido
if [[ -z "$seq_ref" || "$seq_ref" == "0" ]]; then
    echo "ERROR: No se pudo obtener tiempo de referencia secuencial"
    exit 1
fi

echo "DEBUG: Tiempo de referencia secuencial: $seq_ref ms"

# Crear archivo combinado con métricas
echo "# threads seq par unseq speedup_par speedup_unseq eff_par eff_unseq" > "$DATADIR/combined.txt"

for ((t=1; t<=MAX_THREADS; t++)); do
    # Leer tiempos usando awk (más robusto que grep)
    seq=$(awk -v thread="$t" '$1==thread {print $2; exit}' "${OUTFILES[0]}")
    par=$(awk -v thread="$t" '$1==thread {print $2; exit}' "${OUTFILES[1]}")
    unseq=$(awk -v thread="$t" '$1==thread {print $2; exit}' "${OUTFILES[2]}")
    
    # Verificar que todas las variables tienen valores
    if [[ -n "$seq" && -n "$par" && -n "$unseq" ]]; then
        # Calcular métricas
        sp_par=$(echo "scale=4; $seq_ref/$par" | bc -l)
        sp_unseq=$(echo "scale=4; $seq_ref/$unseq" | bc -l)
        eff_par=$(echo "scale=4; $sp_par/$t" | bc -l)
        eff_unseq=$(echo "scale=4; $sp_unseq/$t" | bc -l)
        
        echo "$t $seq $par $unseq $sp_par $sp_unseq $eff_par $eff_unseq" >> "$DATADIR/combined.txt"
    else
        echo "WARNING: Datos faltantes para threads=$t (seq='$seq', par='$par', unseq='$unseq')"
    fi
done

echo "Datos generados en $DATADIR/combined.txt"

gnuplot plots.gnu && echo "Gráficas generadas en data/"

# Mostrar mejor resultado
if [[ -f "$DATADIR/combined.txt" ]]; then
    best=$(tail -n +2 "$DATADIR/combined.txt" | sort -k5nr | head -1)
    if [[ -n "$best" ]]; then
        speedup_par=$(echo "$best" | awk '{print $5}')
        threads_par=$(echo "$best" | awk '{print $1}')
        
        best_unseq=$(tail -n +2 "$DATADIR/combined.txt" | sort -k6nr | head -1)
        speedup_unseq=$(echo "$best_unseq" | awk '{print $6}')
        threads_unseq=$(echo "$best_unseq" | awk '{print $1}')
        
        echo "Mejor speedup paralelo: ${speedup_par}x con $threads_par threads"
        echo "Mejor speedup no secuenciado: ${speedup_unseq}x con $threads_unseq threads"
    fi
fi