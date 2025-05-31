#include <iostream>
#include <cstdlib>
#include <cmath>

int foo(int a, int b);
int bar(int a, int b);
double baz(double x);

void print_array(const double data[], const int size);

int main()
{
  int a=0, b=-1;
  std::cout << "Digite el valor de a (Valor por defecto 0)\n";
  std::cin >> a;
  std::cout << "Digite el valor de b (Valor por defecto -1)\n";
  std::cin >> b;

  std::cout  << "Resultado 1 : " << foo(a, b) << "\n";
  std::cout << "Resultado 2 : " << foo(b, a) << "\n";

  baz(25.9);

  const int NX = 2, NY = 3, NZ = 4;
  double x[NX] = {}, y[NY] = {}, z[NZ] = {};

  print_array(x, NX);
  print_array(y, NY);
  print_array(z, NZ);
  std::cout << std::endl;

  for (int ii = 0; ii < NX; ++ii) {
    x[ii] = ii;
  }
  for (int jj = 0; jj < NY; ++jj) {
    y[jj] = jj;
  }

  print_array(x, NX);
  print_array(y, NY);
  print_array(z, NZ);
  std::cout << std::endl;

  return EXIT_SUCCESS;
}

int foo(int a, int b)
{
  if(a!=0 && bar(a,b)!=0 && b!=0){
    return a/b + b/bar(a, b) + b/a;
  } else{
    std::cout << "Expresión indeterminada (División por cero) \n";
    return -1;   //Se puede mejorar para prevenir confusiones
  }  
}

int bar(int a, int b)
{
  int result = (2*a) - b;
  return result;
}

double baz(double x)
{
  if (x >= 0){
    return std::sqrt(x);
  } else{
    std::cout << "Valor no existente en los reales\n";
    return -1;    // Se puede mejorar para prevenir confusiones
  }
}

void print_array(const double data[], const int size)
{
  std::cout << std::endl;
  for (int ii = 0; ii < size; ++ii) {
    std::cout << data[ii] << "  " ;
  }
}