#include <cstdio>
#include <cstdlib>

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

  long *arr = new long[sI*sJ]; // double array.

  // option 1
  option1(arr, sI, sJ);
      
  // option 2
  option2(arr, sI, sJ);

  // option 3
  option3(arr, sI, sJ);

  // why this?
  printf("%ld\n", arr[0]);

  // free memory
  delete [] arr; 

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