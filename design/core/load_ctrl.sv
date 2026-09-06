`timescale 1ns / 1ps
`include "../memory/memory.svh"
module load_ctrl #(
    DATA_BIT=16,
    STRB_BIT= 2
    )(
    input   wire                        i_unsigned,
    input   wire    [DATA_BIT - 1:0]    i_data,
    input   wire    [STRB_BIT - 1:0]    i_strb,
    output  wire    [DATA_BIT - 1:0]    o_data
    );

    wire [`BYTE_SIZE - 1:0] data_byte   [0:STRB_BIT - 1];

    genvar bytes;
    generate
        for (bytes = 0; bytes < STRB_BIT; bytes = bytes + 1) begin : DATA_BYTE
            assign data_byte[bytes]             = i_data[(`BYTE_SIZE * bytes)+:`BYTE_SIZE];
            if (bytes == 0) begin
                assign o_data[`BYTE_SIZE - 1:0]= data_byte[bytes];
            end
            else begin
                assign o_data[(`BYTE_SIZE * bytes)+:`BYTE_SIZE]= (i_strb[bytes] == 1'b1) ? 
                    data_byte[bytes]    : ((i_unsigned == 1'b1) ? 
                    {`BYTE_SIZE{1'b0}}  : 
                    {`BYTE_SIZE{o_data[(`BYTE_SIZE * bytes) - 1]}});
            end
        end
    endgenerate

endmodule
