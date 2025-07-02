#include <iostream>
#include <vector>
#include <numeric>
#include <chrono>
#include <execution>
#include <random>
#include <iomanip>
#include <omp.h>

using namespace std;
using namespace std::chrono;

// Función para generar datos aleatorios
vector<double> generate_data(size_t size) {
    vector<double> data(size);
    random_device rd;
    mt19937 gen(rd());
    uniform_real_distribution<double> dis(1.0, 100.0);
    
    for (size_t i = 0; i < size; ++i) {
        data[i] = dis(gen);
    }
    return data;
}

// Función para medir tiempo de ejecución
template<typename Policy>
double measure_time(const vector<double>& data, Policy&& policy) {
    auto start = high_resolution_clock::now();
    
    double result = std::reduce(policy, data.begin(), data.end(), 0.0);
    
    auto end = high_resolution_clock::now();
    auto duration = duration_cast<microseconds>(end - start);
    
    // Prevenir optimización del compilador
    volatile double dummy = result;
    (void)dummy;
    
    return duration.count() / 1000.0; // Convertir a milisegundos
}

int main(int argc, char* argv[]) {
    if (argc != 4) {
        cerr << "Uso: " << argv[0] << " <tamaño_vector> <num_threads> <policy>" << endl;
        cerr << "Policy: 0=seq, 1=par, 2=par_unseq" << endl;
        return 1;
    }
    
    size_t vector_size = stoull(argv[1]);
    int num_threads = stoi(argv[2]);
    int policy_type = stoi(argv[3]);
    
    // Configurar OpenMP
    omp_set_num_threads(num_threads);
    
    cout << "Generando vector de " << vector_size << " elementos..." << flush;
    vector<double> data = generate_data(vector_size);
    cout << " ✓" << endl;
    
    cout << "Ejecutando con " << num_threads << " threads, política ";
    
    double exec_time = 0.0;
    const int num_runs = 5; // Promedio de 5 ejecuciones para mayor precisión
    
    switch (policy_type) {
        case 0: {
            cout << "secuencial..." << flush;
            for (int i = 0; i < num_runs; ++i) {
                exec_time += measure_time(data, std::execution::seq);
            }
            break;
        }
        case 1: {
            cout << "paralela..." << flush;
            for (int i = 0; i < num_runs; ++i) {
                exec_time += measure_time(data, std::execution::par);
            }
            break;
        }
        case 2: {
            cout << "paralela no secuenciada..." << flush;
            for (int i = 0; i < num_runs; ++i) {
                exec_time += measure_time(data, std::execution::par_unseq);
            }
            break;
        }
        default:
            cerr << "Política inválida. Use 0, 1 o 2." << endl;
            return 1;
    }
    
    exec_time /= num_runs; // Promedio
    cout << " ✓" << endl;
    
    // Información del sistema
    cout << "Cores físicos: " << omp_get_num_procs() << endl;
    cout << "Threads usados: " << num_threads << endl;
    cout << "Tiempo promedio: " << fixed << setprecision(3) << exec_time << " ms" << endl;
    
    // Salida para el archivo de datos (formato: threads tiempo_ms)
    cout << num_threads << "\t" << fixed << setprecision(6) << exec_time << endl;
    
    return 0;
}