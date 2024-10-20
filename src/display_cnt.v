module display_cnt(
    input  wire         clk,

    output reg   [9:0]  pos_x,
    output reg   [9:0]  pos_y,

    output              active,
    output              o_hsync,
    output              o_vsync
);

    parameter RTRN_HSYNC = 96;  // HSYNC for next row
    parameter RTRN_VSYNC = 2;   // VSYNC for next frame

    // Horizontal and vertical counters to track pixel positions
    reg [9:0] counter_x = 0;  // Horizontal pixel counter (X axis)
    reg [9:0] counter_y = 0;  // Vertical pixel counter (Y axis)

    // Horizontal pixel counter logic
    always @(posedge clk)  
    begin 
        // Increment horizontal counter until it reaches 799
        if (counter_x < 799) begin
            counter_x <= counter_x + 1;  
                if(counter_x > 10'd144 && counter_x <= 10'd783)
				begin
				    pos_x <= pos_x + 1;
				end
				else
				begin
				    pos_x <= 'b0;
				end
        end
        else
            // Reset the horizontal counter after reaching 799 (end of line)
            counter_x <= 0;              
    end 

    // Vertical pixel counter logic (increments only when horizontal counter resets)
    always @ (posedge clk)  
    begin 
        // Increment vertical counter when horizontal counter reaches its max value (799)
        if (counter_x == 799) 
        begin
            if (counter_y < 525)  begin
                counter_y <= counter_y + 1;  // Increment vertical counter
                if(counter_y > 10'd35 && counter_y <= 10'd514)
					begin
					  pos_y <= pos_y + 1;
					end
					else 
					begin
					  pos_y <= 'b0;
					end
            end
            else
                counter_y <= 0;  // Reset vertical counter after reaching 525 (end of frame)
        end
    end  

    // Horizontal sync signal (active for first 96 counts of horizontal line)
    assign o_hsync = counter_x < RTRN_HSYNC;  
    // Vertical sync signal (active for first 2 counts of vertical frame)
    assign o_vsync = counter_y < RTRN_VSYNC; 


    // Output color signals only within the visible area (defined by pixel ranges)
    assign active =   (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514);  

endmodule