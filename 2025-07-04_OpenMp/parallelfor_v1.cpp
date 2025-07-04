#include <omp.h>
#include <iostream>
#include <cmath>
#include <vector>
#include <cstdlib>

void fill(std::vector<double> & array);
double suma(const std::vector<double> & array);

int main(int argc, char *argv[])
{
  if (argc != 2) {
    std::cerr << "Uso: " << argv[0] << " <N>\n";
    return 1;
  }

  const int N = std::atoi(argv[1]);
  std::vector<double> data(N);

  double t1 = omp_get_wtime();
  fill(data);
  double t2 = omp_get_wtime();

  double t3 = omp_get_wtime();
  double total = suma(data);
  double t4 = omp_get_wtime();

  std::cout << "Promedio: " << total / data.size() << "\n";
  std::cout << "Tiempo llenado: " << (t2 - t1) << " s\n";
  std::cout << "Tiempo suma: " << (t4 - t3) << " s\n";

  return 0;
}

void fill(std::vector<double> & array)
{
  const int N = array.size();
#pragma omp parallel for
  for(int ii = 0; ii < N; ii++) {
      array[ii] = 2*ii*std::sin(std::sqrt(ii/56.7)) +
                  std::cos(std::pow(1.0*ii*ii/N, 0.3));
  }
}

double suma(const std::vector<double> & array)
{
  int N = array.size();
  double suma = 0.0;
#pragma omp parallel for reduction(+:suma)
  for(int ii = 0; ii < N; ii++) {
    suma += array[ii];
  }
  return suma;
}
