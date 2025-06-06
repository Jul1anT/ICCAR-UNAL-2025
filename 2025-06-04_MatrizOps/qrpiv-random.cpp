#include <iostream>
#include <eigen3/Eigen/Dense>

int main(int argc, char **argv)
{
    const int SEED = std::atoi(argv[1]);
    const int N = std::atoi(argv[2]);
    srand(SEED); // control seed
    Eigen::MatrixXd A = Eigen::MatrixXd::Random(N,N);
    Eigen::MatrixXd b = Eigen::MatrixXd::Random(N,1);

    // std::cout << "Here is the matrix A:\n" << A << std::endl;
    // std::cout << "Here is the vector b:\n" << b << std::endl;
    Eigen::VectorXd x = A.colPivHouseholderQr().solve(b);
    // std::cout << "The solution is:\n" << x << std::endl;
    std::cout << "Verification:\n" << (A*x - b).norm() << std::endl;
}