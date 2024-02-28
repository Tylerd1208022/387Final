module arctan#(
    parameter DATA_WIDTH = 32
)(
    input logic                              clock,
    input logic                              reset,
    input logic [DATA_WIDTH - 1 : 0]         x,
    input logic [DATA_WIDTH - 1 : 0]         y,
    output logic [DATA_WIDTH - 1: 0]         angle,
    output logic                             done
)

endmodule