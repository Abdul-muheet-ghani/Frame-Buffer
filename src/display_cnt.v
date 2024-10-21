module display_cnt#(
    parameter RES = 0,
    parameter H_PIXELS = 799,
    parameter V_PIXELS = 525,
    parameter RTRN_HSYNC = 96,
    parameter RTRN_VSYNC = 2,
    parameter H_BACK_PORCH = 48,
    parameter V_BACK_PORCH = 33,
    parameter POS_DIV = $clog2(H_PIXELS/(RES))
)(
    input  wire           clk,

    output [POS_DIV-1:0]  pos_x_div,
    output [POS_DIV-1:0]  pos_y_div,

    output                active,
    output                o_hsync,
    output                o_vsync
);

    localparam HS_ACTIVE = RTRN_HSYNC + H_BACK_PORCH; // Horizontal start active region
    localparam HE_ACTIVE = RTRN_HSYNC + H_BACK_PORCH + 640; // Horizontal end active region

    localparam VS_ACTIVE = RTRN_VSYNC + V_BACK_PORCH; // Horizontal start active region
    localparam VE_ACTIVE = RTRN_VSYNC + V_BACK_PORCH + 480; // Horizontal end active region

    // Horizontal and vertical counters to track pixel positions
    reg [9:0] counter_x = 0;  // Horizontal pixel counter (X axis)
    reg [9:0] counter_y = 0;  // Vertical pixel counter (Y axis)

    reg [9:0] pos_x = 0;
    reg [9:0] pos_y = 0;

    // Horizontal pixel counter logic
    always @(posedge clk)  
    begin 
        // Increment horizontal counter until it reaches (H_PIXELS-1)
        counter_x <= (counter_x < (H_PIXELS-1)) ? counter_x + 1 : counter_x <= 0;  
        pos_x <= (counter_x > HS_ACTIVE && counter_x <= (HE_ACTIVE-1)) ? pos_x + 1 : pos_x <= 'b0;
              
        if (counter_x == (H_PIXELS-1)) 
        begin
            counter_y <= (counter_y < V_PIXELS) ? counter_y + 1 : counter_y <= 0;  // Increment vertical counter
            pos_y <= (counter_y > VS_ACTIVE && counter_y <= (VE_ACTIVE-1)) ? pos_y + 1 : pos_y <= 'b0;
        end
    end 

    // Horizontal sync signal (active for first 96 counts of horizontal line)
    assign o_hsync = counter_x < RTRN_HSYNC;  
    // Vertical sync signal (active for first 2 counts of vertical frame)
    assign o_vsync = counter_y < RTRN_VSYNC; 

    // Output color signals only within the visible area (defined by pixel ranges)
    assign active =   (counter_x > HS_ACTIVE && counter_x <= (HE_ACTIVE-1) && counter_y > VS_ACTIVE && counter_y <= (VE_ACTIVE-1));  

    assign pos_x_div = pos_x[9:(RES-1)];
    assign pos_y_div = pos_y[9:(RES-1)];

endmodule