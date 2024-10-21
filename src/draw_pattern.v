module draw_pattern(
    input clk25MHz,

    input [8:0] pos_x,pos_y,

    input  active,

    output o_red,
    output o_blue,
    output o_green
);

    reg r_red   = 0;
    reg r_blue  = 0;
    reg r_green = 0;

    localparam SPR_WIDTH  = 8;
    localparam SPR_HEIGHT = 8;
    reg [0:SPR_WIDTH-1] bmap [SPR_HEIGHT:0];
    initial begin
        // Reversed bits for MSB first when accessing with bmap[0][0]
        bmap[0]  = 8'b0011_1111;  // Reverse of 1111_1100
        bmap[1]  = 8'b0000_0011;  // Reverse of 1100_0000
        bmap[2]  = 8'b0000_0011;  // Reverse of 1100_0000
        bmap[3]  = 8'b0001_1111;  // Reverse of 1111_1000
        bmap[4]  = 8'b0000_0011;  // Reverse of 1100_0000
        bmap[5]  = 8'b0000_0011;  // Reverse of 1100_0000
        bmap[6]  = 8'b1100_0011;  // Reverse of 1100_0011
        bmap[7]  = 8'b1100_0000;  // Reverse of 0000_0011
    end

    // Color generation logic: determine pixel color based on the current position
    always @ (posedge clk25MHz)
    begin
        r_red   <= (pos_x < 8 && pos_y < 8) ? bmap[pos_y][pos_x] : 1'b0;    
        r_blue  <= 1'b0;
        r_green <= 1'b0;
    end 

    // Output color signals only within the visible area (defined by pixel ranges)
    assign o_red =   (active) ? r_red : 1'b0;
    assign o_blue =  (active) ? r_blue : 1'b0;
    assign o_green = (active) ? r_green : 1'b0;
endmodule