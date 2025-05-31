#include <cstdio>
#include <cstdlib>
#include <chrono>
#include <iostream>

/*
  Tests cache misses.
*/

void option1(long * data, int m, int n);
void option2(long * data, int m, int n);
void option3(long * data, int m, int n);

int main(int argc, char **argv)
{
  if (argc < 3){
    printf("Usage: cacheTest sizeI sizeJ\nIn first input.\n");
    return 1;
  }
  long sI = atoi(argv[1]);
  long sJ = atoi(argv[2]);

  printf("Operating on matrix of size %ld by %ld\n", sI, sJ);

  std::chrono::duration<double> diff;
  
  auto start = std::chrono::steady_clock::now();
  long *arr = new long[sI*sJ]; // double array.
  auto end = std::chrono::steady_clock::now();
  diff = end-start;
  std::cout << diff.count() << "\n"; 
  
  // option 1
  start = std::chrono::steady_clock::now();
  option1(arr, sI, sJ);
  end = std::chrono::steady_clock::now();
  diff = end-start;
  std::cout << diff.count() << "\n"; 
      
  // option 2
  start = std::chrono::steady_clock::now();
  option2(arr, sI, sJ);
  end = std::chrono::steady_clock::now();
  diff = end-start;
  std::cout << diff.count() << "\n"; 

  // option 3
  start = std::chrono::steady_clock::now();
  option3(arr, sI, sJ);
  end = std::chrono::steady_clock::now();
  diff = end-start;
  std::cout << diff.count() << "\n"; 

  // why this?
  printf("%ld\n", arr[0]);

  // free memory
  start = std::chrono::steady_clock::now();
  delete [] arr; 
  end = std::chrono::steady_clock::now();
  diff = end-start;
  std::cout << diff.count() << "\n"; 

  return 0;
}

void option1(long * data, int m, int n)
{
  for (long i=0; i < m; ++i)
    for (long j=0; j < n; ++j)
      data[(i * (n)) + j ] = i;
}

void option2(long * data, int m, int n)
{
  for (long i=0; i < m; ++i)
    for (long j=0; j < n; ++j)
      data[(j * (m)) + i ] = i;
}

void option3(long * data, int m, int n)
{
  for (int i=0; i < m*n; ++i) data[i] = i;
}
