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
    int prevX = 102;
    int prevY = 204;
    int x = 409;
    int y = 512;


    int r = DEQUANTIZE(x * prevX) - DEQUANTIZE(-y * prevY);
    int i = DEQUANTIZE(prevX * y) + DEQUANTIZE(-prevY * x);
    
    printf("Arctan args: X=%0x, Y=%0x\n",r,i);

    int arctanRes = -289;
    int gain = 2;

    int demodRes = DEQUANTIZE(gain * arctanRes);

    printf("Demod result:%0x\n",demodRes);

    return 0;
}