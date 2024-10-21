`timescale 1ns / 1ps
// Module to generate simple VGA pattern
module vga_ctrl #(
    parameter RES = 0,
    parameter H_PIXELS = 799,
    parameter V_PIXELS = 525,
    parameter RTRN_HSYNC = 96,
    parameter RTRN_VSYNC = 2,
    parameter H_BACK_PORCH = 48,
    parameter V_BACK_PORCH = 33
)(
    input wire clk25MHz,           // 25 MHz input clock signal
    output o_hsync,                // Horizontal sync signal for VGA
    output o_vsync,                // Vertical sync signal for VGA
    output o_red,                  // Red color signal for VGA
    output o_blue,                 // Blue color signal for VGA
    output o_green                 // Green color signal for VGA
);

    
    localparam LOC_WIDTH = $clog2(640/RES);
    // Registers for the color signals (red, blue, green)
    reg r_red = 0;
    reg r_blue = 0;
    reg r_green = 0;
    
    // Reset signal for the PLL (not used in this code, but initialized to 0)
    reg reset = 0;
    wire active;
    // Horizontal and vertical counters to track pixel positions
    wire [LOC_WIDTH-1:0] pos_x;  // Horizontal pixel counter (X axis)
    wire [LOC_WIDTH-1:0] pos_y;  // Vertical pixel counter (Y axis)

    display_cnt #(
        .RES          (RES       ),
        .H_PIXELS     (H_PIXELS  ),
        .V_PIXELS     (V_PIXELS  ),
        .RTRN_HSYNC   (RTRN_HSYNC),
        .RTRN_VSYNC   (RTRN_VSYNC),
        .H_BACK_PORCH (H_BACK_PORCH),
        .V_BACK_PORCH (V_BACK_PORCH)
    ) u_display_cnt (
        .clk        (clk25MHz),
        .pos_x_div  (pos_x),
        .pos_y_div  (pos_y),
        .active     (active),
        .o_hsync    (o_hsync),
        .o_vsync    (o_vsync)
    ); 

    draw_pattern #(
        .LOC_WIDTH(LOC_WIDTH)
    ) u_draw_pattern(
        .clk25MHz   (clk25MHz),
        .pos_x      (pos_x),
        .pos_y      (pos_y),
        .active     (active),
        .o_red      (o_red),
        .o_blue     (o_blue),
        .o_green    (o_green)
    );


endmodule  // End of Simple_pattern module
