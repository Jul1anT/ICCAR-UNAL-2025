CXX = g++
CXXFLAGS = -std=c++17 -O3 -fsanitize=undefined,leak,address
TARGET = parallel-metrics
SOURCE = parallel-metrics.cpp
VECTOR_SIZE = 200000000

all: $(TARGET)

# Compilar el programa
$(TARGET): $(SOURCE)
	@echo "= Compilando $(TARGET)..."
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SOURCE)

experiments: $(TARGET)
	@echo "= Iniciando experimentos completos..."
	@chmod +x run-exp.sh
	./run-exp.sh $(VECTOR_SIZE)

plots:
	@echo "= Generando gráficas..."
	gnuplot plots.gnu

test: $(TARGET)
	@echo "Ejecutando prueba rápida..."
	@mkdir -p data
	./$(TARGET) 10000000 1 0
	./$(TARGET) 10000000 2 1

clean:
	@echo "= Limpiando archivos..."
	rm -f $(TARGET)
	rm -rf data/

.PHONY: all experiments plots test clean info deps
