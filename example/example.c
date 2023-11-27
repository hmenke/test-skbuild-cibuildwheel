#include "example.h"

#include <gsl/gsl_vector_float.h>

float square(float x) {
    gsl_vector_float * v = gsl_vector_float_alloc(1);
    gsl_vector_float_set(v, 0, x);
    gsl_vector_float_mul(v, v);
    return gsl_vector_float_get(v, 0);
}
