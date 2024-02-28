module divider#(
    parameter DATA_WIDTH = 32,
) (
    input logic                         clock,
    input logic                         reset,
    input logic [DATA_WIDTH-1:0]        divisor,
    input logic [DATA_WIDTH-1:0]        dividend,
    output logic [DATA_WIDTH-1:0]       quotient,
    output logic                        done
)

endmodule