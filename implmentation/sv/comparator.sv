module comparator #(
    parameter DATA_WIDTH = 32
) (
    input logic [DATA_WIDTH:0]     Din_L,
    input logic [DATA_WIDTH-1:0]     Din_R,
    output logic [DATA_WIDTH-1:0]    Dout,
    output logic                     isGreaterEqual
);

    logic [DATA_WIDTH:0] diff, extendedR;

    always_comb begin
        extendedR = {1'b0,Din_R};
        diff = $unsigned(Din_L - Din_R);
        if ($unsigned(Din_L) >= $unsigned(extendedR)) begin
            Dout = diff[DATA_WIDTH-1:0];
            isGreaterEqual = 1'b1;
        end else begin
            Dout = Din_L[DATA_WIDTH-1:0];
            isGreaterEqual = 1'b0;
        end
    end

endmodule