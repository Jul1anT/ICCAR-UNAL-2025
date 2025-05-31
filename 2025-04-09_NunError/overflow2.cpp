#include <cstdio>
#include <iostream>

int main(void)
{
    int a = 2;

    while(a>0){
        std::printf("%10d\n", a);
        a *= 2 ;
    }

    return 0;
}