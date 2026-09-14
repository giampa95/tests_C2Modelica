#include "lib_relu_ptr.h"

void computeReLu_ptr(double x, double *y) {
    if (x < 0) {
        *y = 0.0;
    } else {
        *y = x;
    }
}