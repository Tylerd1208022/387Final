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
    int x = 142;
    int y = -30;

    const int quad1 = QUANTIZE_F(PI / 4.0);
    const int quad3 = QUANTIZE_F(3.0 * PI / 4.0);

    int abs_y = abs(y) + 1;
    int angle = 0; 
    int r = 0;

    if ( x >= 0 ) 
    {
        r = QUANTIZE_I(x - abs_y) / (x + abs_y);
        angle = quad1 - DEQUANTIZE(quad1 * r);
        printf("%0x\n",r);
        printf("%0x\n", quad1 * r);
        printf("%0x\n", DEQUANTIZE(quad1 * r));
        printf("%0x\n",quad1);
        printf("%0x\n",quad1 - DEQUANTIZE(quad3 * r));
    } 
    else 
    {
        r = QUANTIZE_I(x + abs_y) / (abs_y - x);
        angle = quad3 - DEQUANTIZE(quad1 * r);
    }

    printf("%0x\n",(y < 0) ? -angle : angle);
    return 0;
}