# Makefile para el proyecto de métricas paralelas
CXX = g++
CXXFLAGS = -std=c++17 -O3 -fopenmp -Wall -Wextra
TARGET = parallel_metrics
SOURCE = parallel_metrics.cpp
VECTOR_SIZE = 200000000

# Regla principal
all: $(TARGET)

# Compilar el programa
$(TARGET): $(SOURCE)
	@echo "Compilando $(TARGET)..."
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SOURCE)
	@echo "✓ Compilación completada"

# Ejecutar todos los experimentos
experiments: $(TARGET)
	@echo "Iniciando experimentos completos..."
	@chmod +x run-exp.sh
	./run_exp.sh $(VECTOR_SIZE)
	@echo "✓ Experimentos completados"

# Generar solo las gráficas (si ya tienes los datos)
plots:
	@echo "Generando gráficas..."
	gnuplot plots.gp
	@echo "✓ Gráficas generadas en data/"

# Ejecutar una prueba rápida
test: $(TARGET)
	@echo "Ejecutando prueba rápida..."
	@mkdir -p data
	./$(TARGET) 10000000 1 0
	./$(TARGET) 10000000 2 1
	./$(TARGET) 10000000 4 2
	@echo "✓ Prueba completada"

# Limpiar archivos generados
clean:
	@echo "Limpiando archivos..."
	rm -f $(TARGET)
	rm -rf data/
	@echo "✓ Archivos limpiados"

# Mostrar información del sistema
info:
	@echo "=== INFORMACIÓN DEL SISTEMA ==="
	@echo "Compilador: $(CXX)"
	@echo "Flags: $(CXXFLAGS)"
	@echo "Tamaño del vector: $(VECTOR_SIZE)"
	@echo "Cores disponibles:"
	@lscpu | grep -E "(CPU\(s\)|Core\(s\)|Thread\(s\))"
	@echo "OpenMP disponible:"
	@echo '#include <omp.h>' | $(CXX) -fopenmp -E -x c++ - > /dev/null 2>&1 && echo "✓ SÍ" || echo "✗ NO"


.PHONY: all experiments plots test clean info deps

# Ayuda
help:
	@echo "Uso del Makefile:"
	@echo "  make all         - Compilar el programa"
	@echo "  make experiments - Ejecutar todos los experimentos y generar gráficas"
	@echo "  make plots       - Generar solo las gráficas (requiere datos existentes)"
	@echo "  make test        - Ejecutar una prueba rápida"
	@echo "  make clean       - Limpiar archivos generados"
	@echo "  make info        - Mostrar información del sistema"
	@echo "  make help        - Mostrar esta ayuda"