#!/bin/bash

[ $# -ne 1 ] && { echo "Uso: $0 <tamaño_vector>"; exit 1; }

VECTOR_SIZE=$1
MAX_THREADS=13
EXECUTABLE="./parallel-metrics"
DATADIR="data"

[ -f "$EXECUTABLE" ] || { echo "Error: $EXECUTABLE no encontrado"; exit 1; }

mkdir -p "$DATADIR"
OUTFILES=("$DATADIR/sequential.txt" "$DATADIR/parallel.txt" "$DATADIR/parallel_unseq.txt")

for file in "${OUTFILES[@]}"; do
    echo "# threads time_ms" > "$file"
done

echo "Ejecutando experimentos para tamaño vector: $VECTOR_SIZE"

for ((t=1; t<=MAX_THREADS; t++)); do
    echo "Threads: $t"
    for policy in 0 1 2; do
        result=$($EXECUTABLE $VECTOR_SIZE $t $policy 2>/dev/null | tail -n1)
        echo "$result" >> "${OUTFILES[$policy]}"
    done
done

seq_ref=$(awk '/^1 /{print $2}' "${OUTFILES[0]}")

echo "# threads seq par unseq speedup_par speedup_unseq eff_par eff_unseq" > "$DATADIR/combined.txt"
for ((t=1; t<=MAX_THREADS; t++)); do
    read -r _ seq < <(grep "^$t " "${OUTFILES[0]}")
    read -r _ par < <(grep "^$t " "${OUTFILES[1]}")
    read -r _ unseq < <(grep "^$t " "${OUTFILES[2]}")
    
    sp_par=$(bc <<< "scale=4; $seq_ref/$par")
    sp_unseq=$(bc <<< "scale=4; $seq_ref/$unseq")
    eff_par=$(bc <<< "scale=4; $sp_par/$t")
    eff_unseq=$(bc <<< "scale=4; $sp_unseq/$t")
    
    echo "$t $seq $par $unseq $sp_par $sp_unseq $eff_par $eff_unseq" >> "$DATADIR/combined.txt"
done

command -v gnuplot >/dev/null && gnuplot plots.gnu && echo "Gráficas generadas"

best=$(sort -k5nr "$DATADIR/combined.txt" | head -1)
echo "Mejor speedup: ${best##* }x con $(cut -d' ' -f1 <<< "$best") threads"