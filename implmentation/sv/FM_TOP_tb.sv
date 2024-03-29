`timescale 1ns/1ns

module FM_TOP_tb();

    logic [31:0] data_in, volume, Lout, Rout;
    logic clock, reset,wr_en;
    localparam logic[0:255][7:0]inputdata = {8'h9B, 8'hC3, 8'h0F, 8'h25, 8'hA7, 8'hD6, 8'h81, 8'h14, 8'h6F, 8'h30, 8'h47, 8'h5A, 8'h70, 8'hF7, 8'h5D, 8'hE2,
8'h4F, 8'h9D, 8'h8A, 8'hBE, 8'h3C, 8'hE5, 8'hA4, 8'h02, 8'h76, 8'h9E, 8'hB5, 8'hF6, 8'hC7, 8'h18, 8'h3E, 8'h61,
8'h9C, 8'h80, 8'h5E, 8'h91, 8'h27, 8'h7D, 8'h53, 8'hF8, 8'h4E, 8'hA9, 8'h6C, 8'h4D, 8'hB9, 8'h12, 8'h6A, 8'h59,
8'h7B, 8'h43, 8'hE3, 8'h8C, 8'hA2, 8'h34, 8'h6D, 8'h82, 8'h50, 8'hA5, 8'h63, 8'h8D, 8'h92, 8'h40, 8'h2F, 8'h46,
8'hF2, 8'hD4, 8'h68, 8'h3B, 8'h37, 8'h71, 8'h22, 8'h49, 8'h26, 8'h1D, 8'h97, 8'h20, 8'h8F, 8'hAC, 8'hBA, 8'hB2,
8'h41, 8'h98, 8'h28, 8'h19, 8'h16, 8'h55, 8'hAF, 8'h9A, 8'h7E, 8'hE4, 8'hCD, 8'h31, 8'hFD, 8'hE8, 8'hCC, 8'h72,
8'h3F, 8'h87, 8'hDD, 8'hEB, 8'h0D, 8'h10, 8'hB8, 8'hAB, 8'hBF, 8'h85, 8'hDE, 8'hFC, 8'hF5, 8'h44, 8'hDA, 8'h57,
8'h96, 8'h54, 8'hF4, 8'h4A, 8'hC9, 8'hC4, 8'h74, 8'hCE, 8'h7C, 8'hB0, 8'hEA, 8'hA3, 8'hB7, 8'h6B, 8'h32, 8'h83,
8'hA0, 8'hEF, 8'h6E, 8'hA1, 8'h9F, 8'h79, 8'hE9, 8'h0A, 8'h5B, 8'h3A, 8'h38, 8'hA6, 8'hB6, 8'h99, 8'hC6, 8'hD9,
8'h7A, 8'h84, 8'h8E, 8'h4B, 8'h58, 8'hC2, 8'h4C, 8'hCA, 8'h6F, 8'h05, 8'hC5, 8'hD1, 8'h23, 8'hF1, 8'hC8, 8'hE6,
8'h89, 8'hF3, 8'hD5, 8'h2A, 8'h8B, 8'hFF, 8'hE7, 8'h0E, 8'h9B, 8'h75, 8'h2D, 8'h1A, 8'h7F, 8'h33, 8'h24, 8'h4D,
8'h45, 8'hC1, 8'hB3, 8'hFC, 8'hF0, 8'h95, 8'hE0, 8'hFB, 8'h1E, 8'h64, 8'h52, 8'hA8, 8'hCF, 8'h69, 8'h5F, 8'h03,
8'hB4, 8'h7A, 8'h77, 8'h6B, 8'h13, 8'h0A, 8'hED, 8'h2B, 8'hA6, 8'h1C, 8'h08, 8'h81, 8'h07, 8'hDF, 8'h3C, 8'h67,
8'hBC, 8'h50, 8'h8D, 8'h82, 8'h8C, 8'h1E, 8'h69, 8'h6D, 8'h3D, 8'h99, 8'h4C, 8'h7D, 8'h55, 8'h6E, 8'h4E, 8'hD7,
8'hD6, 8'hF3, 8'h76, 8'h5D, 8'hD9, 8'h92, 8'hDD, 8'h87, 8'hAA, 8'h3A, 8'h61, 8'h97, 8'h14, 8'hE8, 8'h58, 8'h56,
8'h4A, 8'hB1, 8'h96, 8'hE2, 8'hA1, 8'h70, 8'h1F, 8'hA9, 8'hC8, 8'h62, 8'h6C, 8'h26, 8'h9F, 8'h5C, 8'hB8, 8'hFA
};
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
     int i;
     always #10 clock = ~clock;

     initial begin
         clock = 1;
         reset = 1;
         wr_en = 1;
         volume = 10;
         #10 reset = 0;
         #10;
         for(i = 0; i < 256; i = i + 4) begin
            data_in = {inputdata[i+3],inputdata[i+2],inputdata[i+1],inputdata[i]};
            #20;
         end
         wr_en = 0;
         #100000;
         $finish;
     end


endmodule
