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
