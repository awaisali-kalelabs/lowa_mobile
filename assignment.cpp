#include <iostream>

class StudentProcessor {
public:
    static void doubleDigits(long long number) {
        std::cout << "Doubled digits in reverse order: ";
        while (number > 0) {
            int digit = number % 10;
            int doubledDigit = digit * 2;
            std::cout << doubledDigit << " ";
            number /= 10;
        }
        std::cout << std::endl;
    }

    static int sumOfDoubledDigits(long long number) {
        int sum = 0;
        while (number > 0) {
            int digit = number % 10;
            int doubledDigit = digit * 2;
            sum += doubledDigit;
            number /= 10;
        }
        return sum;
    }
};

int main() {
    // Student ID: BC123456789
    long long studentID = 123456789;

    // Save the numerical part of the given ID in a variable
    long long numericalPart = studentID;

    // Double each digit and print in reverse order
    StudentProcessor::doubleDigits(numericalPart);

    // Calculate the sum of doubled digits
    int sum = StudentProcessor::sumOfDoubledDigits(numericalPart);

    // Print the sum on the screen
    std::cout << "Sum of doubled digits: " << sum << std::endl;

    return 0;
}
