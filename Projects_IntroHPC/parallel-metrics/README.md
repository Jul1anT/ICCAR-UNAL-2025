# Parallel Metrics

Proyecto para medir el rendimiento de diferentes políticas de ejecución paralela en C++.

## Descripción

Este programa compara el rendimiento de tres políticas de ejecución:
- Secuencial (`std::execution::seq`)
- Paralela (`std::execution::par`) 
- Paralela no secuenciada (`std::execution::par_unseq`)

## Compilación

```bash
make
```

## Uso

### Ejecutar experimentos completos
```bash
make experiments
```

### Ejecutar manualmente
```bash
./parallel-metrics <tamaño_vector> <num_threads> <política>
```

Donde:
- `tamaño_vector`: número de elementos (ej: 200000000)
- `num_threads`: número de threads (1-13)
- `política`: 0=secuencial, 1=paralela, 2=paralela_no_secuenciada

## Archivos generados

- `data/sequential.txt` - Resultados secuenciales
- `data/parallel.txt` - Resultados paralelos
- `data/parallel_unseq.txt` - Resultados paralelos no secuenciados
- `data/combined.txt` - Métricas combinadas con speedup y eficiencia
- `data/*.pdf` - Gráficas de rendimiento

## Limpiar

```bash
make clean
```

## Requisitos

- g++ con soporte C++17
- OpenMP
- gnuplot (para generar gráficas)