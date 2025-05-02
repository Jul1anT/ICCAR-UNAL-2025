#include <random>
#include <iostream>
#include <cstdlib>

double compute_pi(int seed, long nsamples);

int main(int argc, char **argv) 
{
  const int SEED = std::atoi(argv[1]);
  const long NSAMPLES = std::atol(argv[2]);
  std::cout.precision(16);
  std::cout.setf(std::ios::scientific);
  double mypi = compute_pi(SEED, NSAMPLES);
  std::cout << mypi << "\n"; 
    
  return 0;
}

double compute_pi(int seed, long nsamples) 
{
  // todo
}