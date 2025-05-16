#include "factorial.h"
#include <iostream>

typedef float REAL; 

REAL sumdown(int nterms);

long factorial(long number)
{
    if (0 == number) return 1;
    if (number < 0) {
        std::cout << "Negative numbers not allowed. Returning -1\n";
        return -1;
    }
    return number < 0 ? number : factorial(number-1)*number;
}


int par_impar(long n) {
  std::cout << "Enter an integer: ";
  std::cin >> n;

  if ( n % 2 == 0)
    return true;
  else
    return false;
}