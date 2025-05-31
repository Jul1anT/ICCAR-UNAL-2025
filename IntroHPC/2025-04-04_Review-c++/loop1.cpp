// imprima los numeros del 1 al 10 usando while
#include <iostream> 

int main(void) 
{
  // int n;
  // std::cout << "\n Nums(1-10)\n";
  // n = 1;
  // while (n <= 10) {
  //   std::cout << n << std::endl;
  //   ++n;  
  // }
  
  std::cout << "\n Nums(10-1)\n";
  for(int i=10; i >= 0; i = --i){
    std::cout << i << "\n";
  }

  for(int i=0; i <= 10; i = --i){
    std::cout << i << "\n";
  }

  return 0;
}