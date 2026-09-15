/*
Compile as win x86-64 static library with:
mkdir ./Build
gcc -m64 -c lib_relu.c -o ./Build/lib_relu.o 
ar rcs ./Build/lib_relu.lib ./Build/lib_relu.o
*/

#include "lib_relu.h"

double computeReLu(double x) {
    double y;
    if (x < 0) {
        y = 0.0;
    } else {
        y = x;
    }
    return y;
}
