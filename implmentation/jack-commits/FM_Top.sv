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
    .rd_en(FIFO_Demod_rd_en),
    .dout(FIFO_Demod_Out),
    .empty(FIFO_Demod_Empty)
);
//BOTTOM LEFT FIR-> FIR MULT FIR PIPELINE

fir #(
    .TAP_COUNT(32),
    .DECIMATION_FACTOR(1),
    .MULT_PER_CYCLE(1),
    .DATA_WIDTH(32),
    .TAPS(BP_PILOT_TONE_TAPS)
) FIR_DEMOD_PILOT_BP (
    .clock(clock),
    .reset(reset),
    .newData(FIFO_Demod_Out)
    .newDataAvailible(~FIFO_Demod_Empty),
    
);

    // FIFO Multiply
fifo #(
    .FIFO_BUFFER_SIZE(),
    .FIFO_DATA_WIDTH()
) fifo_mult_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(FIFO_Mult_wr_en),
    .din(),// the out signal from FIR multiply
    .full(FIFO_Mult_Full),
    .rd_clk(clock),
    .rd_en(FIFO_Mult_rd_en),
    .dout(FIFO_Mult_Out),
    .empty(FIFO_Mult_Empty)
); 
    // FIFO Add
fifo #(
    .FIFO_BUFFER_SIZE(),
    .FIFO_DATA_WIDTH()
) fifo_add_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(FIFO_Add_wr_en),
    .din(), // the out signal from FIR Add
    .full(FIFO_Add_Full),
    .rd_clk(clock),
    .rd_en(FIFO_Add_rd_en),
    .dout(FIFO_Add_Out),
    .empty(FIFO_Add_Empty)
); 
    // FIFO Sub
fifo #(
    .FIFO_BUFFER_SIZE(),
    .FIFO_DATA_WIDTH()
) fifo_sub_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(FIFO_Sub_wr_en),
    .din(), // the out signal from FIR Sub
    .full(FIFO_Sub_Full),
    .rd_clk(clock),
    .rd_en(FIFO_Sub_rd_en),
    .dout(FIFO_Sub_DOut),
    .empty(FIFO_Sub_Empty)
); 
    // FIFO Out Left
fifo #(
    .FIFO_BUFFER_SIZE(),
    .FIFO_DATA_WIDTH()
) fifo_left_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(FIFO_Left_wr_en),
    .din(), // the out signal from IIR Add
    .full(FIFO_Left_Full),
    .rd_clk(clock),
    .rd_en(FIFO_Left_rd_en),
    .dout(FIFO_Left_DOut),
    .empty(FIFO_Left_Empty)
); 
    // Fifo Out Right
fifo #(
    .FIFO_BUFFER_SIZE(),
    .FIFO_DATA_WIDTH()
) fifo_right_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(FIFO_Right_wr_en),
    .din(), // the out signal from IIR Sub
    .full(FIFO_Right_Full),
    .rd_clk(clock),
    .rd_en(FIFO_Right_rd_en),
    .dout(FIFO_Right_DOut),
    .empty(FIFO_Right_Empty)
); 

    // Read IQ module placeholder

    // FIR CMPLX placeholder module


    // Demodulator module


    // FIR after demodulation placeholder module
    fir #(.DATA_WIDTH(DATA_WIDTH)) fir_demod_inst (
        .clock(clock),
        .reset(reset),
        .start(demod_done),
        .data_in(demod_out),
        .data_out(fir_demod_out),
        .done(fir_demod_done)
    );


    // Adder module
    adder #(.DATA_WIDTH(DATA_WIDTH)) add_inst (
        .clock(clock),
        .reset(reset),
        .start(fir_demod_done),
        .addend1(fir_demod_out),
        .addend2(fir_demod_out), // Placeholder for actual second addend
        .sum(add_out),
        .complete(add_done)
    );

    // FIR after addition placeholder module
    fir #(.DATA_WIDTH(DATA_WIDTH)) fir_add_inst (
        .clock(clock),
        .reset(reset),
        .start(add_done),
        .data_in(add_out),
        .data_out(fir_add_out),
        .done(fir_add_done)
    );

    // Subtractor module
    subtractor #(.DATA_WIDTH(DATA_WIDTH)) sub_inst (
        .clock(clock),
        .reset(reset),
        .start(fir_demod_done),
        .minuend(fir_demod_out),
        .subtrahend(fir_demod_out), // Placeholder for actual second subtrahend
        .difference(sub_out),
        .complete(sub_done)
    );

    // FIR after subtraction placeholder module
    fir #(.DATA_WIDTH(DATA_WIDTH)) fir_sub_inst (
        .clock(clock),
        .reset(reset),
        .start(sub_done),
        .data_in(sub_out),
        .data_out(fir_sub_out),
        .done(fir_sub_done)
    );

    // Gain (multiplier) module for left audio
    multiplier #(.DATA_WIDTH(DATA_WIDTH)) gain_left_inst (
        .clock(clock),
        .reset(reset),
        .start(fir_add_done),
        .multiplicand(fir_add_out),
        .multiplier(volume),
        .product(gain_left_out),
        .complete(gain_left_done)
    );

    // Gain (multiplier) module for right audio
    multiplier #(.DATA_WIDTH(DATA_WIDTH)) gain_right_inst (
        .clock(clock),
        .reset(reset),
        .start(fir_sub_done),
        .multiplicand(fir_sub_out),
        .multiplier(volume),
        .product(gain_right_out),
        .complete(gain_right_done)
    );

    // Output assignment for left and right audio channels
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            left_audio <= 0;
            right_audio <= 0;
        end else if (gain_left_done && gain_right_done) begin
            left_audio <= gain_left_out;
            right_audio <= gain_right_out;
        end
    end

endmodule
