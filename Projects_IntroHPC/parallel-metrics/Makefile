CXX = g++
CXXFLAGS = -std=c++17 -O3 -fopenmp -fsanitize=undefined,leak,address
TARGET = parallel-metrics
SOURCE = parallel-metrics.cpp
VECTOR_SIZE = 200000000

all: $(TARGET)

# Compilar el programa
$(TARGET): $(SOURCE)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SOURCE)

experiments: $(TARGET)
	@echo "= Iniciando experimentos ..."
	@chmod +x run-exp.sh
	./run-exp.sh $(VECTOR_SIZE)

clean:
	@echo "= Limpiando archivos..."
	rm -f $(TARGET)
	rm -rf data/

.PHONY: all experiments plots test clean info deps
