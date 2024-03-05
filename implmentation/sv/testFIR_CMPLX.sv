`timescale 1ns/1ns

module FIR_CMPLX_tb();

    logic [31:0] Iin, Qin, Iout, Qout;
    logic clock, reset, newDataAvailible, Done;
    
    FIR_COMPLEX #(
        .TAP_COUNT(8),
        .DATA_WIDTH(32),
        .MULT_PER_CYCLE(2),
        .DECIMATION_FACTOR(8)
    ) inst (
        .Iin(Iin),
        .Qin(Qin),
        .clock(clock),
        .reset(reset),
        .newDataAvailible(newDataAvailible),
        .Iout(Iout),
        .Qout(Qout),
        .Done(done)
    );

    always #10 clock = ~clock;
//    int x_real[] = {10400,20300,13000,40050,50020,6100,70040,80100};
//    int x_imag[] = {11100, 12100, 32100, 41300, 51400 ,61010, 71005, 81100};
    initial begin
        Iin = 11100;
        Qin = 10400;
        clock = 1;
        reset = 1;
        newDataAvailible = 0;
        #20;
        reset = 0;
        newDataAvailible = 1;
        #20;
        Iin = 12100;
        Qin = 20300;
        #20;
        Iin = 32100;
        Qin = 13000;
        #20;
        Iin = 41300;
        Qin = 40050;
        #20;
        Iin = 51400;
        Qin = 50020;
        #20;
        Iin = 61010;
        Qin = 6100;
        #20;
        Iin = 71005;
        Qin = 70040;
        #20;
        Iin = 81100;
        Qin = 80100;
        #3000;
        $finish;
    end


endmodule