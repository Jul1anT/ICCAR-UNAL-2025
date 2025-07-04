#include <omp.h>
#include <iostream>
#include <cmath>
#include <vector>
#include <cstdlib>
#include <numeric>

void fill(std::vector<double> & array);
double suma(const std::vector<double> & array);

int main(int argc, char *argv[])
{
  const int N = std::atoi(argv[1]);
  std::vector<double> data(N);

  // llenar el arreglo
  fill(data);
  //std::cout << data[0] << "\n";

  // calcular la suma y el promedio
  double total = suma(data);
  std::cout << total/data.size() << "\n";

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