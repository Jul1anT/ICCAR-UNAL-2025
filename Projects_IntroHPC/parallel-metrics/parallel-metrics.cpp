#include <iostream>
#include <vector>
#include <numeric>
#include <chrono>
#include <execution>
#include <random>
#include <omp.h>

using namespace std;
using namespace chrono;

vector<double> generate_data(size_t size) {
    vector<double> data(size);
    mt19937 gen(random_device{}());
    uniform_real_distribution<double> dis(1.0, 100.0);
    
    generate(data.begin(), data.end(), [&]{ return dis(gen); });
    return data;
}

template<typename Policy>
double measure_time(const vector<double>& data, Policy&& policy) {
    auto start = high_resolution_clock::now();
    volatile double result = reduce(policy, data.begin(), data.end());
    return duration_cast<microseconds>(high_resolution_clock::now() - start).count() / 1000.0;
}

int main(int argc, char* argv[]) {
    if (argc != 4) {
        cerr << "Uso: " << argv[0] << " <tamaño> <threads> <0=seq|1=par|2=par_unseq>\n";
        return 1;
    }
    
    const auto data = generate_data(stoull(argv[1]));
    const int threads = stoi(argv[2]);
    omp_set_num_threads(threads);
    
    const char* policies[] = {"secuencial", "paralela", "paralela no secuenciada"};
    cout << "Ejecutando con " << threads << " threads (" << policies[stoi(argv[3])] << ")...";
    
    double time = 0;
    for (int i = 0; i < 5; i++) {
        time += [&]{
            switch(stoi(argv[3])) {
                case 0: return measure_time(data, execution::seq);
                case 1: return measure_time(data, execution::par);
                case 2: return measure_time(data, execution::par_unseq);
                default: throw invalid_argument("Política inválida");
            }
        }();
    }
    
    cout << " ✓\nTiempo: " << fixed << time/5 << " ms\n";
    cout << threads << "\t" << time/5 << endl;
}