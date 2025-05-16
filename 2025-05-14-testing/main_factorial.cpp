#include <iostream>
#include "factorial.h"

int main(void)
{
    std::cout << factorial(-1) << std::endl;
    std::cout << factorial(15) << std::endl;
    std::cout << factorial(8) << std::endl;
    std::cout << factorial(100) << std::endl;
    return 0;
}
