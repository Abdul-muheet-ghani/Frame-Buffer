module mem_inline #(
    parameter CORDW=16,   // signed coordinate width (bits)
    parameter H_RES=640,  // horizontal screen resolution (pixels)
    parameter SX_OFFS=2   // horizontal screen offset (pixels)
    ) (
    input  wire  clk,                            // clock
    input  wire  rst,                            // reset
    input  wire  line,                           // start of active screen line
    input  wire  signed [CORDW-1:0] sx, sy,      // screen position
    input  wire  signed [CORDW-1:0] sprx, spry,  // sprite position
    output       pix,                            // pixel colour index
    output       drawing                         // drawing at position (sx,sy)
    );

    // sprite bitmap
    localparam SPR_WIDTH  = 8;
    localparam SPR_HEIGHT = 8;
    reg [0:SPR_WIDTH-1] bmap [SPR_HEIGHT];
    initial begin  // MSB first, so we can write initial block left to right
        bmap[0]  = 8'b1111_1100;
        bmap[1]  = 8'b1100_0000;
        bmap[2]  = 8'b1100_0000;
        bmap[3]  = 8'b1111_1000;
        bmap[4]  = 8'b1100_0000;
        bmap[5]  = 8'b1100_0000;
        bmap[6]  = 8'b1100_0011;
        bmap[7]  = 8'b0000_0011;
    end

    // coordinates within sprite bitmap
    reg [$clog2(SPR_WIDTH)-1:0]  bmap_x;
    reg [$clog2(SPR_HEIGHT)-1:0] bmap_y;

    // for registering sprite position
    reg signed [CORDW-1:0] sprx_r, spry_r;

    // status flags: used to change state
    reg spr_active;  // sprite active on this line
    reg spr_begin;   // begin sprite drawing
    reg spr_end;     // end of sprite on this line
    reg line_end;    // end of screen line, corrected for sx offset
    always_comb begin
        spr_active = (sy - spry_r >= 0) && (sy - spry_r < SPR_HEIGHT);
        spr_begin  = (sx >= sprx_r - SX_OFFS);
        spr_end    = (bmap_x == SPR_WIDTH-1);
        line_end   = (sx == H_RES - SX_OFFS);
    end

    // sprite state machine
    enum {
        IDLE,      // awaiting line signal
        REG_POS,   // register sprite position
        ACTIVE,    // check if sprite is active on this line
        WAIT_POS,  // wait for horizontal sprite position
        SPR_LINE,  // iterate over sprite pixels
        WAIT_DATA  // account for data latency
    } state;

    always_ff @(posedge clk) begin
        if (line) begin  // prepare for new line
            state <= REG_POS;
            pix <= 0;
            drawing <= 0;
        end else begin
            case (state)
                REG_POS: begin
                    state <= ACTIVE;
                    sprx_r <= sprx;
                    spry_r <= spry;
                end
                ACTIVE: state <= spr_active ? WAIT_POS : IDLE;
                WAIT_POS: begin
                    if (spr_begin) begin
                        state <= SPR_LINE;
                        bmap_x <= sx - sprx_r + SX_OFFS;  // account for start offset
                        bmap_y <= sy - spry_r;
                    end
                end
                SPR_LINE: begin
                    if (spr_end || line_end) state <= WAIT_DATA;
                    bmap_x <= bmap_x + 1;
                    pix <= bmap[bmap_y][bmap_x];
                    drawing <= 1;
                end
                WAIT_DATA: begin
                    state <= IDLE;  // 1 cycle between address set and data receipt
                    pix <= 0;  // default colour
                    drawing <= 0;
                end
                default: state <= IDLE;
            endcase
        end

        if (rst) begin
            state <= IDLE;
            bmap_x <= 0;
            bmap_y <= 0;
            pix <= 0;
            drawing <= 0;
        end
    end
endmodule