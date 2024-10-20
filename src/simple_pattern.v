`timescale 1ns / 1ps
// Module to generate simple VGA pattern
module Simple_pattern(
    input wire clk25MHz,           // 25 MHz input clock signal
    output o_hsync,                // Horizontal sync signal for VGA
    output o_vsync,                // Vertical sync signal for VGA
    output o_red,                  // Red color signal for VGA
    output o_blue,                 // Blue color signal for VGA
    output o_green                 // Green color signal for VGA
);

    
    // Registers for the color signals (red, blue, green)
    reg r_red = 0;
    reg r_blue = 0;
    reg r_green = 0;
    
    // Reset signal for the PLL (not used in this code, but initialized to 0)
    reg reset = 0;
    wire active;
    // Horizontal and vertical counters to track pixel positions
    wire [9:0] pos_x;  // Horizontal pixel counter (X axis)
    wire [9:0] pos_y;  // Vertical pixel counter (Y axis)

    display_cnt u_display_cnt(
        .clk        (clk25MHz),
        .pos_x      (pos_x),
        .pos_y      (pos_y),
        .active     (active),
        .o_hsync    (o_hsync),
        .o_vsync    (o_vsync)
    ); 

    // Color generation logic: determine pixel color based on the current position
    always @ (posedge clk25MHz)
    begin
        // Generate a black square (no color) in the center of the screen
        if (pos_y > 0 && pos_y < 100)
        begin              
            r_red <= 1'b1;    
            r_blue <= 1'b0;
            r_green <= 1'b0;
        end  
        // Generate blue color in a strip from Y=135 to Y=235
        else if (pos_y >= 100 && pos_y < 200)
        begin 
            r_red <= 1'b0;    
            r_blue <= 1'b1;
            r_green <= 1'b0;
        end 
        // Generate magenta (red+blue) color in a strip from Y=235 to Y=335
        else if (pos_y >= 200 && pos_y < 300)
        begin 
            r_red <= 1'b1;    
            r_blue <= 1'b1;
            r_green <= 1'b0;
        end  
        // Generate green color in a strip from Y=335 to Y=435
        else if (pos_y >= 300 && pos_y < 400)
        begin
            r_red <= 1'b0;    
            r_blue <= 1'b0;
            r_green <= 1'b1;
        end  
        // Generate yellow (red+green) color in a strip from Y=435 to Y=535
        else if (pos_y >= 400 && pos_y < 500)
        begin
            r_red <= 1'b1;    
            r_blue <= 1'b0;
            r_green <= 1'b1;    
        end 
        // Default to black (no color) outside specified areas
        else
        begin
            r_red <= 1'b0; 
            r_blue <= 1'b0;
            r_green <= 1'b0;
        end 
    end 

    // Output color signals only within the visible area (defined by pixel ranges)
    assign o_red =   (active) ? r_red : 1'b0;
    assign o_blue =  (active) ? r_blue : 1'b0;
    assign o_green = (active) ? r_green : 1'b0;

endmodule  // End of Simple_pattern module
