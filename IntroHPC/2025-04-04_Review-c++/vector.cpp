#include <vector>
#include <iostream>

// Declaraciones 
void print_v0(const std::vector<double> & mydata);
void print_v1(const std::vector<double> & mydata);

int main(void)
{
    std::vector<double> data = {0.1, 0.5, -0.6};
    print_v0(data);
    print_v1(data);

    return 0;
}

// Definiciones
void print_v0(const std::vector<double> & mydata)
{
    for(int ii = 0; ii < mydata.size(); ii++){
        std::cout << mydata[ii] << "  "; 
    }
    std::cout << "\n";
}

void print_v1(const std::vector<double> & mydata)
{
    for(auto x : mydata){
            std::cout << x << "  ";
        }
        std::cout << "\n";
}