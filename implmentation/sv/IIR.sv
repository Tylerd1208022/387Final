module IIR #(
    parameter TAP_COUNT = 2,
    parameter FB_TAP_COUNT = 2,
    parameter DECIMATION_FACTOR = 1,
    parameter MULT_PER_CYCLE = 1,
    parameter DATA_WIDTH = 32
)(
    input logic                     clock,
    input logic                     reset,
    input logic [DATA_WIDTH - 1:0]  newData,
    input logic                     newDataAvailable,
    input logic                     rd_en,
    output logic [DATA_WIDTH - 1:0] filteredData,
    output logic                    done,
    output logic                    in_rd_en
);
    //Insert from fm_radio.h
    localparam [0:TAP_COUNT-1][DATA_WIDTH - 1:0]TAPS = {(32'h000000B2),(32'h000000B2)};
    localparam [0:FB_TAP_COUNT-1][DATA_WIDTH - 1:0] FB_TAPS= {(32'hFFFFFD66),(32'h00000000)};

    typedef enum logic[1:0] {shift, mult, doneCalc} FIRstate;
    FIRstate state_s, state_c;
    localparam MULT_CYCLE_COUNT = TAP_COUNT / MULT_PER_CYCLE;
    logic [TAP_COUNT-1:0] [DATA_WIDTH-1:0] shiftRegNow, shiftRegNext;
    logic [FB_TAP_COUNT-1:0][DATA_WIDTH-1:0]FBRegNow,FBRegNext;
    logic [7:0] shiftCounter_s, shiftCounter_c;
    logic [7:0] multCounter_s, multCounter_c;
    logic [DATA_WIDTH-1:0] FFdotProd_c,FFdotProd_s, FBdotProd_s, FBdotProd_c, dotProd_c;
    logic [MULT_PER_CYCLE-1:0] [31:0] dotProdSubOps, FBdotProdSubOps;
    int i;
    //FBRegs FF/FB dotprod
    always_comb begin
        shiftRegNext = shiftRegNow;
        FBRegNext = FBRegNow;
        FFdotProd_c = FFdotProd_s;
        FBdotProd_c = FBdotProd_s;
        state_c = state_s;
        shiftCounter_c = shiftCounter_s;
        multCounter_c = multCounter_s;
        dotProd_c = filteredData;
        in_rd_en = 0;
        done = 0;
        case (state_s)
        shift: begin
            in_rd_en = 1;
            FBdotProd_c = 0;
            FFdotProd_c = 0;
            if (newDataAvailable == 1'b1) begin
                dotProd_c = 0;
                shiftRegNext[TAP_COUNT-1:1] = shiftRegNow[TAP_COUNT-2:0];
                shiftRegNext[0] = newData;
                if (shiftCounter_s >= DECIMATION_FACTOR - 1) begin
                    shiftCounter_c = 0;
                    multCounter_c = 0;
                    if (rd_en == 1'b1) begin
                        state_c = mult;
                    end
                end else begin
            
                    shiftCounter_c = shiftCounter_s + 1;
                end
            end
        end
        mult: begin
            multCounter_c = multCounter_s + 1;
            for(i = 0; i < MULT_PER_CYCLE; i = i + 1) begin
               dotProdSubOps[i] = $signed($signed(TAPS[(multCounter_s * MULT_PER_CYCLE) + i]) * $signed(shiftRegNow[(multCounter_s * MULT_PER_CYCLE) + i]));
               FBdotProdSubOps[i] = $signed($signed(FB_TAPS[(multCounter_s * MULT_PER_CYCLE) + i])*$signed(FBRegNow[(multCounter_s * MULT_PER_CYCLE) + i]));
            end
            for(i = 0; i < MULT_PER_CYCLE; i = i + 1) begin
               FFdotProd_c += $signed($signed(dotProdSubOps[i]) / $signed(32'h00000400)); //DEQUANTIZE
               FBdotProd_c += $signed($signed(FBdotProdSubOps[i])/$signed(32'h00000400));
            end
            if (multCounter_s == MULT_CYCLE_COUNT - 1) begin
                state_c = doneCalc;
                multCounter_c = 0;
            end
        end
        doneCalc: begin
            done = 1;
            state_c = shift;
            FBRegNext[FB_TAP_COUNT-1:1] = FBRegNow[TAP_COUNT-2:0];
            dotProd_c = FFdotProd_s + FBdotProd_s;
            FBRegNext[0] = dotProd_c;
        end
        endcase
    end

    always_ff @(posedge clock or posedge reset) begin
        if (reset == 1'b1) begin
            state_s <= shift;
            shiftRegNow <= 0;
            shiftCounter_s <= 0;
            multCounter_s <= 0;
            filteredData <= 0;
            FBRegNow <= 0;
            FBdotProd_s <= 0;
            FFdotProd_s <= 0;
        end else begin
            FBRegNow <= FBRegNext;
            FFdotProd_s <= FFdotProd_c;
            FBdotProd_s <= FBdotProd_c;
            state_s <= state_c;
            shiftRegNow <= shiftRegNext;
            shiftCounter_s <= shiftCounter_c;
            multCounter_s <= multCounter_c;
            filteredData <= dotProd_c;
        end
    end

endmodule
