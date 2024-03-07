#define BITS            10
#define ADC_RATE        64000000 // 64 MS/s
#define QUANT_VAL       (1 << BITS)
#define QUANTIZE_F(f)   (int)(((float)(f) * (float)QUANT_VAL))
#define MAX_DEV         55000.0f
#define QUANTIZE_I(i)   (int)((int)(i) * (int)QUANT_VAL)
#define DEQUANTIZE(i)   (int)((int)(i) / (int)QUANT_VAL)
#define USRP_DECIM      250
#define QUAD_RATE       (int)(ADC_RATE / USRP_DECIM) // 256 kS/s
#define PI              3.1415926535897932384626433832795f
#define FM_DEMOD_GAIN   QUANTIZE_F( (float)QUAD_RATE / (2.0f * PI * MAX_DEV) )
#include <math.h>
#include <stdio.h>
#include <stdlib.h>


int main(int argc, char **argv)
{

    unsigned char char1 = 0x12;
    unsigned char char2 = 0x34;
    unsigned char char3 = 0x56;
    unsigned char char4 = 0x78;

    printf("Out 1I:%0x\n",QUANTIZE_I((short)(char3 << 8) | (short)char4));
    printf("Out 1Q:%0x\n",QUANTIZE_I((short)(char1 << 8) | (short)char2));

    char1 = 0x21;
    char2 = 0x43;
    char3 = 0x65;
    char4 = 0x87;

    printf("Out 2I:%0x\n",QUANTIZE_I((short)(char3 << 8) | (short)char4));
    printf("Out 2Q:%0x\n",QUANTIZE_I((short)(char1 << 8) | (short)char2));

    char1 = 0x34;
    char2 = 0x56;
    char3 = 0x78;
    char4 = 0x12;

    printf("Out 3I:%0x\n",QUANTIZE_I((short)(char3 << 8) | (short)char4));
    printf("Out 3Q:%0x\n",QUANTIZE_I((short)(char1 << 8) | (short)char2));

    char1 = 0x43;
    char2 = 0x65;
    char3 = 0x87;
    char4 = 0x21;

    printf("Out 4I:%0x\n",QUANTIZE_I((short)(char3 << 8) | (short)char4));
    printf("Out 4Q:%0x\n",QUANTIZE_I((short)(char1 << 8) | (short)char2));

    char1 = 0x56;
    char2 = 0x78;
    char3 = 0x12;
    char4 = 0x34;

    printf("Out 5I:%0x\n",QUANTIZE_I((short)(char3 << 8) | (short)char4));
    printf("Out 5Q:%0x\n",QUANTIZE_I((short)(char1 << 8) | (short)char2));

    char1 = 0x65;
    char2 = 0x87;
    char3 = 0x21;
    char4 = 0x43;

    printf("Out 6I:%0x\n",QUANTIZE_I((short)(char3 << 8) | (short)char4));
    printf("Out 6Q:%0x\n",QUANTIZE_I((short)(char1 << 8) | (short)char2));

    char1 = 0x78;
    char2 = 0x56;
    char3 = 0x34;
    char4 = 0x12;

    printf("Out 7I:%0x\n",QUANTIZE_I((short)(char3 << 8) | (short)char4));
    printf("Out 7Q:%0x\n",QUANTIZE_I((short)(char1 << 8) | (short)char2));

    char1 = 0x87;
    char2 = 0x65;
    char3 = 0x43;
    char4 = 0x21;

    printf("Out 8I:%0x\n",QUANTIZE_I((short)(char3 << 8) | (short)char4));
    printf("Out 8Q:%0x\n",QUANTIZE_I((short)(char1 << 8) | (short)char2));

    char1 = 0x11;
    char2 = 0x33;
    char3 = 0x55;
    char4 = 0x77;

    printf("Out 9I:%0x\n",QUANTIZE_I((short)(char3 << 8) | (short)char4));
    printf("Out 9Q:%0x\n",QUANTIZE_I((short)(char1 << 8) | (short)char2));

    char1 = 0x22;
    char2 = 0x44;
    char3 = 0x66;
    char4 = 0x88;

    printf("Out 10I:%0x\n",QUANTIZE_I((short)(char3 << 8) | (short)char4));
    printf("Out 10Q:%0x\n",QUANTIZE_I((short)(char1 << 8) | (short)char2));
    printf("%0x\n",FM_DEMOD_GAIN);
        
}