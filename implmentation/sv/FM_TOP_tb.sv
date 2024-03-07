`timescale 1ns/1ns

module FM_TOP_tb();

    logic [31:0] data_in, volume, Lout, Rout;
    logic clock, reset,wr_en;
    
    top_level #(
        .DATA_WIDTH(32)
    ) inst (
        .clock(clock),
        .reset(reset),
        .data_in(data_in),
        .wr_en(wr_en),
        .out_rd_en(0),
        .volume(volume),
        .left_audio(Lout),
        .right_audio(Rout)

    );

     always #10 clock = ~clock;

     initial begin
         clock = 1;
         reset = 1;
         wr_en = 1;
         volume = 10;
         data_in = 32'h12345678;
         #10;
         reset = 0;
         #10;
         #20;
         data_in = 32'h21436587;
         #20;
         data_in = 32'h34567812;
         #20;
         data_in = 32'h43658721;
         #20;
         data_in = 32'h56781234;
         #20;
         data_in = 32'h65872143;
         #20;
         data_in = 32'h78123456;
         #20;
         data_in = 32'h87214365;
         #20;
         data_in = 32'h11335577;
         #20;
         data_in = 32'h22446688;
         #20;
         #18000;
         $finish;
     end


endmodule
