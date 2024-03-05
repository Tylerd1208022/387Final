#define BITS            10
#define QUANT_VAL       (1 << BITS)
#define QUANTIZE_F(f)   (int)(((float)(f) * (float)QUANT_VAL))
#define QUANTIZE_I(i)   (int)((int)(i) * (int)QUANT_VAL)
#define DEQUANTIZE(i)   (int)((int)(i) / (int)QUANT_VAL)
#define PI              3.1415926535897932384626433832795f
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{

}