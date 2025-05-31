// Mi primer programa

#include <iostream>

int main(void)
{
    std::string name;

    std::cout << "Hello, what is your name?" << std::endl;
    std::getline(std::cin, name);
    std::cout << "Hello " << name << "!" << std::endl;

    std::cout << "No sabia " + name + "\n";

    return 0;
}