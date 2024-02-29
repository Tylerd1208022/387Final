module divider_tb();


    logic clock, reset, done, overflow,start;
    logic [31:0] dividend, divisor, quotient;

    divider #(
        .DATA_WIDTH(32)
    ) inst (
        .clock(clock),
        .reset(reset),
        .start(start),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .complete(done),
        .overflow(overflow)
    );

    always #10 clock = ~clock;

    initial begin
        start = 0;
        reset = 1;
        clock = 1;
        dividend = 8;
        divisor = 3;
        #10;
        reset = 0;
        #20;
        start = 1;
        #20 start = 0;
        #680;
        start = 1;
        dividend = 3;
        #20 start = 0;
        #1000;
        start = 1;
        dividend = -1024;
        divisor = 3;
        #20;
        start = 0;
        #1000;
    
        $finish;
    end

endmodule