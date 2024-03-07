module iq_read #(
    parameter DATA_WIDTH = 32, 
    parameter QUANTIZE_WIDTH = 10
)(
    input logic clock, 
    input logic reset, 
    input logic dataAvailible,
    input logic out_rd_en,
    input logic [DATA_WIDTH-1:0] iq_data_in, 
    output logic [DATA_WIDTH-1:0] i_data_out, 
    output logic [DATA_WIDTH-1:0] q_data_out,
    output logic outputAvailible,
    output logic in_rd_en
);
    typedef enum logic {read, write} readIQstate;
    readIQstate state_c, state_s;
    logic [DATA_WIDTH-1:0] i_data_out_c, q_data_out_c;
    logic [15:0] op1, op2;
    logic [31:0] SEop1, SEop2;
    always_comb begin
        state_c = state_s;
        outputAvailible = 0;
        i_data_out_c = i_data_out;
        q_data_out_c = q_data_out;
        in_rd_en = 0;
        op1 = 0;
        op2 = 0;
        case(state_s)
        read: begin
            in_rd_en = 1;
            if (dataAvailible == 1'b1) begin
                state_c = write;
                op1 = {iq_data_in[DATA_WIDTH-17:DATA_WIDTH-24],iq_data_in[DATA_WIDTH-25:0]};
                op2 = {iq_data_in[DATA_WIDTH-1:DATA_WIDTH-8],iq_data_in[DATA_WIDTH-9:DATA_WIDTH-16]};
                SEop1 = $signed(op1);
                SEop2 = $signed(op2);
                i_data_out_c = $signed(SEop1 * $signed(32'h00000400));
                q_data_out_c = $signed(SEop2 * $signed(32'h00000400));
                in_rd_en = 0;
            end
        end
        write: begin
            outputAvailible = 1;
            if (out_rd_en == 1'b1) begin
                state_c = read;
                in_rd_en = 1;
            end
        end
        default: begin
            outputAvailible = 0;
            state_c = read;
        end
        endcase

    end



    always_ff @(posedge clock or negedge reset) begin
        if (reset) begin
                i_data_out <= 0;
                q_data_out <= 0;
                state_s <= read;
        end else begin
                state_s <= state_c;
                i_data_out <= i_data_out_c;
                q_data_out <= q_data_out_c;
        end
    end
endmodule
