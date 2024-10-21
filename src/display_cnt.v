module display_cnt(
    input  wire         clk,

    output       [8:0]  pos_x_div,
    output       [8:0]  pos_y_div,

    output              active,
    output              o_hsync,
    output              o_vsync
);

    parameter RTRN_HSYNC = 96;  // HSYNC for next row
    parameter RTRN_VSYNC = 2;   // VSYNC for next frame

    // Horizontal and vertical counters to track pixel positions
    reg [9:0] counter_x = 0;  // Horizontal pixel counter (X axis)
    reg [9:0] counter_y = 0;  // Vertical pixel counter (Y axis)

    reg [9:0] pos_x = 0;
    reg [9:0] pos_y = 0;

    // Horizontal pixel counter logic
    always @(posedge clk)  
    begin 
        // Increment horizontal counter until it reaches 799
        counter_x <= (counter_x < 799) ? counter_x + 1 : counter_x <= 0;  
        pos_x <= (counter_x > 10'd144 && counter_x <= 10'd783) ? pos_x + 1 : pos_x <= 'b0;
              
        if (counter_x == 799) 
        begin
            counter_y <= (counter_y < 525) ? counter_y + 1 : counter_y <= 0;  // Increment vertical counter
            pos_y <= (counter_y > 10'd35 && counter_y <= 10'd514) ? pos_y + 1 : pos_y <= 'b0;
        end
    end 

    // Horizontal sync signal (active for first 96 counts of horizontal line)
    assign o_hsync = counter_x < RTRN_HSYNC;  
    // Vertical sync signal (active for first 2 counts of vertical frame)
    assign o_vsync = counter_y < RTRN_VSYNC; 

    // Output color signals only within the visible area (defined by pixel ranges)
    assign active =   (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514);  

    assign pos_x_div = pos_x[9:1];
    assign pos_y_div = pos_y[9:1];

endmodule