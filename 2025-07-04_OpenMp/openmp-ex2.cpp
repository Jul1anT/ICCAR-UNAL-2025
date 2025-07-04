#include <cstdio>
#include <omp.h>

int main(void)
{
  double x = 9.0; // "public" var, seen and shared by all threads 

  int nth = omp_get_num_threads();
  int thid = omp_get_thread_num();
  std::printf("Hello world from thid: %d, out of %d .\n",
              thid, nth);

//#pragma omp parallel num_threads(4) // set the num_threads instead of relying on OMP_NUM_THREADS
#pragma omp parallel private(thid, nth) // makes thid and nth private, not problem with overwriting
  {// se generan los threads
    thid = omp_get_thread_num(); // privada, aunque tenga el mismo nombre, tipo, y no haya sido redeclarada
    nth = omp_get_num_threads(); // privada, aunque tenga el mismo nombre, tipo, y no haya sido redeclarada
    std::printf("Hello world from thid: %d, out of %d .\n",
                thid, nth);
  } // mueren los threads

  return 0;
}