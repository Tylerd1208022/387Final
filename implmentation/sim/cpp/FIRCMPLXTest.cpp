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
    int i = 0;
    int j = 0;
    int y_real = 0;
    int y_imag = 0;

    int x_real[] = {10400,20300,13000,40050,50020,6100,70040,80100};
    int x_imag[] = {11100, 12100, 32100, 41300, 51400 ,61010, 71005, 81100};

    int h_real[] = {1,2,3,4,5,6,7,8};
    int h_imag[] = {10,11,12,13,14,15,16,17};

    // compute new real & imag values
    for ( i = 0; i < 8; i++ )
    {
        int op1 = (h_real[i] * x_real[i]);
        int op2 = (h_imag[i] * x_imag[i]);
        int op3 = (h_real[i] * x_imag[i]);
        int op4 = (h_imag[i] * x_real[i]);
        y_real += DEQUANTIZE(op1 - op2);
        y_imag += DEQUANTIZE(op3 - op4);
        printf("Iter %d: Q: %0x, I: %0x\n",i,y_real,y_imag);
        printf("Ops: 1:%d, 2:%d, 3:%d 4:%d \n",op1,op2,op3,op4);
    }

    printf("Q VALUE: %0x\n",y_real);
    printf("I VALUE: %0x\n",y_imag);
    return 0;
}