`timescale 1ns / 1ps
// Module to generate simple VGA pattern
module vga_ctrl(
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
    wire [8:0] pos_x;  // Horizontal pixel counter (X axis)
    wire [8:0] pos_y;  // Vertical pixel counter (Y axis)

    display_cnt u_display_cnt(
        .clk        (clk25MHz),
        .pos_x_div  (pos_x),
        .pos_y_div  (pos_y),
        .active     (active),
        .o_hsync    (o_hsync),
        .o_vsync    (o_vsync)
    ); 

    draw_pattern u_draw_pattern(
        .clk25MHz   (clk25MHz),
        .pos_x      (pos_x),
        .pos_y      (pos_y),
        .active     (active),
        .o_red      (o_red),
        .o_blue     (o_blue),
        .o_green    (o_green)
    );


endmodule  // End of Simple_pattern module
