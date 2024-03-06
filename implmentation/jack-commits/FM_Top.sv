module top_level #(
    parameter DATA_WIDTH = 32
) (
    input logic clock,                    
    input logic reset,                  
    input logic start,                    
    input logic [DATA_WIDTH - 1 : 0] data_in,  
    input logic [DATA_WIDTH - 1 : 0] volume,    
    output logic [DATA_WIDTH - 1 : 0] left_audio, 
    output logic [DATA_WIDTH - 1 : 0] right_audio 
);
    //TAP COEFFICIENTS

    localparam logic[0:31][31:0] BP_PILOT_TONE_TAPS = `{
	(32'h0000000e), (32'h0000001f), (32'h00000034), (32'h00000048), (32'h0000004e), (32'h00000036), (32'hfffffff8), (32'hffffff98), 
	(32'hffffff2d), (32'hfffffeda), (32'hfffffec3), (32'hfffffefe), (32'hffffff8a), (32'h0000004a), (32'h0000010f), (32'h000001a1), 
	(32'h000001a1), (32'h0000010f), (32'h0000004a), (32'hffffff8a), (32'hfffffefe), (32'hfffffec3), (32'hfffffeda), (32'hffffff2d), 
	(32'hffffff98), (32'hfffffff8), (32'h00000036), (32'h0000004e), (32'h00000048), (32'h00000034), (32'h0000001f), (32'h0000000e)
    };
    localparam logic[0:31][31:0] BP_PILOT_TONE_POST_SQUARE_TAPS = `{
	(32'hffffffff), (32'h00000000), (32'h00000000), (32'h00000002), (32'h00000004), (32'h00000008), (32'h0000000b), (32'h0000000c), 
	(32'h00000008), (32'hffffffff), (32'hffffffee), (32'hffffffd7), (32'hffffffbb), (32'hffffff9f), (32'hffffff87), (32'hffffff76), 
	(32'hffffff76), (32'hffffff87), (32'hffffff9f), (32'hffffffbb), (32'hffffffd7), (32'hffffffee), (32'hffffffff), (32'h00000008), 
	(32'h0000000c), (32'h0000000b), (32'h00000008), (32'h00000004), (32'h00000002), (32'h00000000), (32'h00000000), (32'hffffffff)
    };
    localparam logic[0:31][31:0] LMR_MERGE_TAPS = `{
	(32'h00000000), (32'h00000000), (32'hfffffffc), (32'hfffffff9), (32'hfffffffe), (32'h00000008), (32'h0000000c), (32'h00000002), 
	(32'h00000003), (32'h0000001e), (32'h00000030), (32'hfffffffc), (32'hffffff8c), (32'hffffff58), (32'hffffffc3), (32'h0000008a), 
	(32'h0000008a), (32'hffffffc3), (32'hffffff58), (32'hffffff8c), (32'hfffffffc), (32'h00000030), (32'h0000001e), (32'h00000003), 
	(32'h00000002), (32'h0000000c), (32'h00000008), (32'hfffffffe), (32'hfffffff9), (32'hfffffffc), (32'h00000000), (32'h00000000)
};
    localparam logic[0:31][31:0] LXR_FIR_TAPS = `{
	(32'hfffffffd), (32'hfffffffa), (32'hfffffff4), (32'hffffffed), (32'hffffffe5), (32'hffffffdf), (32'hffffffe2), (32'hfffffff3), 
	(32'h00000015), (32'h0000004e), (32'h0000009b), (32'h000000f9), (32'h0000015d), (32'h000001be), (32'h0000020e), (32'h00000243), 
	(32'h00000243), (32'h0000020e), (32'h000001be), (32'h0000015d), (32'h000000f9), (32'h0000009b), (32'h0000004e), (32'h00000015), 
	(32'hfffffff3), (32'hffffffe2), (32'hffffffdf), (32'hffffffe5), (32'hffffffed), (32'hfffffff4), (32'hfffffffa), (32'hfffffffd)
};
 //   localparam logic [0:31][31:0] 
    //END TAP COEFFICIENTS



    logic [DATA_WIDTH - 1 : 0] gain;
    logic [DATA_WIDTH - 1 : 0] fir_cmplx_out, fir_demod_out, fir_mult_out, fir_add_out, fir_sub_out;
    logic [DATA_WIDTH - 1 : 0] demod, add_out, sub_out;
    logic [DATA_WIDTH - 1 : 0] gain_left_out, gain_right_out;
    logic fir_cmplx_done, fir_demod_done, fir_mult_done, fir_add_done, fir_sub_done;
    logic demod_done, add_done, sub_done, gain_left_done, gain_right_done;
    logic FIFO_In_wr_en, FIFO_In_Full, FIFO_In_rd_en, FIFO_In_DOut, FIFO_In_Empty;
    logic FIFO_Demod_wr_en, FIFO_Demod_Full, FIFO_Demod_rd_en, FIFO_Demod_DOut, FIFO_Demod_Empty;
    logic FIFO_Multiply_wr_en, FIFO_Multiply_Full, FIFO_Multiply_rd_en, FIFO_Multiply_DOut, FIFO_Multiply_Empty;
    logic FIFO_Add_wr_en, FIFO_Add_Full, FIFO_Add_rd_en, FIFO_Add_DOut, FIFO_Add_Empty;
    logic FIFO_Sub_wr_en, FIFO_Sub_Full, FIFO_Sub_rd_en, FIFO_Sub_DOut, FIFO_Sub_Empty;
    logic FIFO_Left_wr_en, FIFO_Left_Full, FIFO_Left_rd_en, FIFO_Left_DOut, FIFO_Left_Empty;
    logic FIFO_Right_wr_en, FIFO_Right_Full, FIFO_Right_rd_en, FIFO_Right_DOut, FIFO_Right_Empty;

    // FIFO In, outputs to Read IQ
fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) fifo_in_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(FIFO_In_wr_en),
    .din(data_in),
    .full(FIFO_In_Full),
    .rd_clk(clock),
    .rd_en(FIFO_In_rd_en),
    .dout(FIFO_In_Dout),
    .empty(FIFO_In_Empty)
);    

    //IQ Signals

    logic [DATA_WIDTH - 1: 0] parsedQuantizedQ, parsedQuantizedI;
    logic iq_data_ready;
    //Parse data - Only operate when allowed to by past modules
iq_read #(
    .DATA_WIDTH(32),
    .QUANTIZE_WIDTH(10)
) iq_read_inst (
    .clock(clock),
    .reset(reset),
    .dataAvailible(~FIFO_In_Empty),
    .out_rd_en(iq_read_rd_en),
    .iq_data_in(FIFO_In_Dout),
    .i_data_out(parsedQuantizedI),
    .q_data_out(parsedQuantizedQ),
    .outputAvailible(iq_data_ready),
    .in_rd_en(FIFO_In_rd_en)
);

//Signals for FIR COMPLEX
logic iq_read_rd_en, FIR_CMPLX_DATA_AVAIL;
logic [DATA_WIDTH-1:0] FIR_CMPLX_Q, FIR_CMPLX_I;

fir_cmplx #(
    .DATA_WIDTH(DATA_WIDTH),
    .TAP_COUNT(20),
    .MULT_PER_CYCLE(1),
    .DECIMATION_FACTOR(1)
    ) fir_cmplx_inst (
    .Iin(parsedQuantizedI),
    .Qin(parsedQuantizedQ)
    .clock(clock),
    .reset(reset),
    .newDataAvailible(iq_data_ready),
    .out_rd_en(fir_cmplx_rd_en),
    .in_rd_en(iq_read_rd_en),
    .Iout(FIR_CMPLX_I),
    .Qout(FIR_CMPLX_Q),
    .Done(FIR_CMPLX_DATA_AVAIL)
);

//Signals for demodulator
logic fir_cmplx_rd_en;

demodulator #(
    .DATA_WIDTH(DATA_WIDTH)
    ) demod_inst (
    .clock(clock),
    .reset(reset),
    .start(FIR_CMPLX_DATA_AVAIL), //READY TO RUN NEXT
    .x(FIR_CMPLX_Q),
    .y(FIR_CMPLX_I),
    .gain(gain),
    .done(demod_done),
    .fir_cmplx_rd_en(fir_cmplx_rd_en)
    .demod(demod)
);
// FIFO Demod
fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) fifo_demod_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(demod_done),
    .din(demod), // the out signal from FIR Demod
    .full(FIFO_Demod_Full),
    .rd_clk(clock),
    .rd_en(FIFO_Demod_rd_en/*MAKE THIS AND OF ALL READ IN FIRS*/),
    .dout(FIFO_Demod_Out),
    .empty(FIFO_Demod_Empty)
);
//BOTTOM LEFT FIR-> FIR MULT FIR PIPELINE
logic [DATA_WIDTH - 1:0] PILOT_BP_FIR_OUT;
logic FIR_PILOT_BP_DONE, FIR_PILOT_BP_RE;

FIR #(
    .TAP_COUNT(32),
    .DECIMATION_FACTOR(1),
    .MULT_PER_CYCLE(1),
    .DATA_WIDTH(32),
    .TAPS(BP_PILOT_TONE_TAPS)
) FIR_DEMOD_PILOT_BP (
    .clock(clock),
    .reset(reset),
    .newData(FIFO_Demod_Out),
    .newDataAvailible(~FIFO_Demod_Empty),
    .rd_en(~SQUARE_PILOT_BP_done),
    .dotProd(PILOT_BP_FIR_OUT),
    .done(FIR_PILOT_BP_DONE),
    .in_rd_en(FIR_PILOT_BP_RE)
);

logic [DATA_WIDTH - 1:0] SQUARE_PILOT_PROD;
logic SQUARE_PILOT_BP_done, FIR_POST_SQUARE_RD_EN;

multiplier #(
    .DATA_WIDTH(DATA_WIDTH)
) PILOT_SQUARER (
    .clock(clock),
    .reset(reset),
    .dataAvailible(FIR_PILOT_BP_DONE),
    .out_rd_en(FIR_POST_SQUARE_RD_EN),
    .multiplicand(FIR_BP_FIR_OUT),
    .multiplier(FIR_BP_FIR_OUT),
    .product(SQUARE_PILOT_PROD),
    .complete(SQUARE_PILOT_BP_done)
);

logic [DATA_WIDTH-1:0]PILOT_PIPELINE_RESULT;
logic PILOT_PIPELINE_DONE, 
FIR #(
    .TAP_COUNT(32),
    .DECIMATION_FACTOR(1),
    .MULT_PER_CYCLE(1),
    .DATA_WIDTH(32),
    .TAPS(BP_PILOT_TONE_POST_SQUARE_TAPS)
) POST_PILOT_SQUARE_FIR (
    .clock(clock),
    .reset(reset),
    .newData(SQUARE_PILOT_PROD),
    .rd_en(/*COME BACK MULT READY*/),
    .newDataAvailible(SQUARE_PILOT_BP_done),
    .dotProd(PILOT_PIPELINE_RESULT),
    .done(PILOT_PIPELINE_DONE),
    .in_rd_en(FIR_POST_SQUARE_RD_EN)
);

logic [31:0] LMR_DOT_PROD;
logic LMR_RD_EN, LMR_DONE;

FIR #(
    .TAP_COUNT(32),
    .DECIMATION_FACTOR(1),
    .MULT_PER_CYCLE(1),
    .DATA_WIDTH(32),
    .TAPS(LMR_MERGE_TAPS)
) LMR_MERGE_FIR (
    .clock(clock),
    .reset(reset),
    .newData(FIFO_Demod_DOut),
    .rd_en(~FIFO_Mult_Full),
    .newDataAvailible(~FIFO_Demod_Empty),
    .dotProd(LMR_DOT_PROD),
    .done(LMR_DONE),
    .in_rd_en(LMR_RD_EN)
);

    // FIFO Multiply
fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) fifo_mult_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(LMR_DONE),
    .din(LMR_DOT_PROD),// the out signal from FIR multiply
    .full(FIFO_Mult_Full),
    .rd_clk(clock),
    .rd_en(~MERGE_MULT_EMPTY && PILOT_PIPELINE_DONE), //only put out value when previous is ready, and write avail
    .dout(FIFO_Mult_Out),
    .empty(FIFO_Mult_Empty)
);

logic [31:0] MergeProduct;
logic MergeMultDone, TOP_DEC_rd_en;

multiplier #(
    .DATA_WIDTH(32)
) mergeMult (
    .clock(clock),
    .reset(reset),
    .out_rd_en(TOP_DEC_rd_en),
    .dataAvailible(PILOT_PIPELINE_DONE && ~FIFO_Mult_Empty),
    .multiplicand(FIFO_Mult_Out),
    .multiplier(PILOT_PIPELINE_RESULT),
    .product(MergeProduct),
    .complete(MergeMultDone)
);

logic [DATA_WIDTH - 1:0] TOP_DEC_FIR_RES;
logic FIR_TOP_DEC_DONE;
FIR #(
    .DATA_WIDTH(DATA_WIDTH),
    .DECIMATION_FACTOR(10),
    .MULT_PER_CYCLE(1),
    .TAP_COUNT(32),
    .TAPS(LXR_FIR_TAPS)
) TOP_DECIMATE_FIR (
    .clock(clock),
    .reset(reset),
    .newData(MergeProduct),
    .newDataAvailible(MergeMultDone),
    .rd_en(~FIFO_Add_Full),
    .dotProd(TOP_DEC_FIR_RES),
    .done(FIR_TOP_DEC_DONE),
    .in_rd_en(TOP_DEC_rd_en)
);

logic [DATA_WIDTH - 1:0] BOTTOM_DEC_FIR_RES;
logic BOTTOM_DEC_FIR_DONE, BOTTOM_DEC_RD_EN;

FIR #(
    .DATA_WIDTH(DATA_WIDTH),
    .DECIMATION_FACTOR(10),
    .MULT_PER_CYCLE(1),
    .TAP_COUNT(32),
    .TAPS(LXR_FIR_TAPS)
) BOTTOM_DECIMATE_FIR(
    .clock(clock),
    .reset(reset),
    .newData(FIFO_Demod_Out),
    .newDataAvailible(~FIFO_Demod_Empty),
    .rd_en(~FIFO_Sub_Full),
    .dotProd(BOTTOM_DEC_FIR_RES),
    .done(BOTTOM_DEC_FIR_DONE),
    .in_rd_en(BOTTOM_DEC_RD_EN)
);
    // FIFO Add
fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) fifo_add_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(FIR_TOP_DEC_DONE),
    .din(TOP_DEC_FIR_RES), // the out signal from FIR Add
    .full(FIFO_Add_Full),
    .rd_clk(clock),
    .rd_en(FIFO_Add_rd_en),
    .dout(FIFO_Add_Out),
    .empty(FIFO_Add_Empty)
); 
    // FIFO Sub
fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(32)
) fifo_sub_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(BOTTOM_DEC_FIR_DONE),
    .din(BOTTOM_DEC_FIR_RES), // the out signal from FIR Sub
    .full(FIFO_Sub_Full),
    .rd_clk(clock),
    .rd_en(FIFO_Sub_rd_en),
    .dout(FIFO_Sub_DOut),
    .empty(FIFO_Sub_Empty)
); 
logic [DATA_WIDTH-1:0]AddSum, SubDiff;
logic Adddone, Subdone;
adder #(
    .DATA_WIDTH(DATA_WIDTH)
    ) add_inst (
        .clock(clock),
        .reset(reset),
        .out_rd_en(FIFO_Add_rd_en),
        .dataAvailible(~FIFO_Add_Empty),
        .addend1(FIFO_Sub_DOut),
        .addend2(FIFO_Add_DOut), // Placeholder for actual second addend
        .sum(AddSum),
        .complete(Adddone)
    );

subtractor #(
    .DATA_WIDTH(DATA_WIDTH)
    ) sub_inst (
        .clock(clock),
        .reset(reset),
        .out_rd_en(FIFO_Sub_rd_en),
        .dataAvailible(~FIFO_Sub_Empty),
        .op1(FIFO_Add_DOut)// Placeholder for actual second subtrahend
        .op2(FIFO_Sub_DOut),
        .difference(SubDiff),
        .complete(Subdone)
    );
    // FIFO Out Left

logic [DATA_WIDTH-1:0] Top_deemph_out, bottom_deemp_out;
logic Top_deemph_done, Bottom_deemph_done;

IIR #(
    .TAP_COUNT(2),
    .FB_TAP_COUNT(3),
    .DECIMATION_FACTOR(1),
    .MULT_PER_CYCLE(1),
    .DATA_WIDTH(32)
) TOP_DEEMPH (
    .clock(clock),
    .reset(reset),
    .newData(Addsum),
    .newDataAvailable(Adddone),
    .filteredData(Top_deemph_out),
    .done(Top_deemph_done)
);

IIR #(
    .TAP_COUNT(2),
    .FB_TAP_COUNT(3),
    .DECIMATION_FACTOR(1),
    .MULT_PER_CYCLE(1),
    .DATA_WIDTH(32)
) BOTTOM_DEEMPH (
    .clock(clock),
    .reset(reset),
    .newData(SubDiff),
    .newDataAvailable(Subdone),
    .filteredData(bottom_deemp_out),
    .done(Bottom_deemph_done)
);

logic [DATA_WIDTH - 1:0] LeftGainOut, RightGainOut;
logic RightGainDone, LeftGainDone;
multiplier #(
    .DATA_WIDTH(32)
) topGain (
    .clock(clock),
    .reset(reset),
    .out_rd_en(~FIFO_Left_Full),
    .dataAvailible(Top_deemph_done),
    .multiplicand(volume),
    .multiplier(Top_deemph_out),
    .product(LeftGainOut),
    .complete(LeftGainDone)
);
multiplier #(
    .DATA_WIDTH(32)
) mergeMult (
    .clock(clock),
    .reset(reset),
    .out_rd_en(~FIFO_Right_Full),
    .dataAvailible(Bottom_deemph_done),
    .multiplicand(volume),
    .multiplier(Bottom_deemph_out),
    .product(RightGainOut),
    .complete(RightGainDone)
);


fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) fifo_left_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(LeftGainDone),
    .din(LeftGainOut), // the out signal from IIR Add
    .full(FIFO_Left_Full),
    .rd_clk(clock),
    .rd_en(FIFO_Left_rd_en),
    .dout(FIFO_Left_DOut),
    .empty(FIFO_Left_Empty)
); 
    // Fifo Out Right
fifo #(
    .FIFO_BUFFER_SIZE(128),
    .FIFO_DATA_WIDTH(DATA_WIDTH)
) fifo_right_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(RightGainDone),
    .din(RightGainOut), // the out signal from IIR Sub
    .full(FIFO_Right_Full),
    .rd_clk(clock),
    .rd_en(FIFO_Right_rd_en),
    .dout(FIFO_Right_DOut),
    .empty(FIFO_Right_Empty)
); 

   
    // Output assignment for left and right audio channels
  

endmodule
