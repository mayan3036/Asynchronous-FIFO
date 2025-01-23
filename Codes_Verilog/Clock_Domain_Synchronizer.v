// -----------------DESCRIPTION------------------
// This module synchronizes signals across clock domains using a 2-stage flip-flop.
// ----------------------------------------------

// -------------PARAMETERS------------
// DATA_WIDTH: Width of the input data bus
// -----------------------------------

module Clock_Domain_Synchronizer #(parameter DATA_WIDTH = 4)( 
    output reg [DATA_WIDTH-1:0] sync_out,   // Synchronized output
    input [DATA_WIDTH-1:0] sync_in,         // Input data
    input sync_clock, sync_reset_n          // Clock and reset
    );

    reg [DATA_WIDTH-1:0] sync_stage1; // First stage flip-flop

    always @(posedge sync_clock or negedge sync_reset_n) begin
        if (!sync_reset_n) 
            {sync_out, sync_stage1} <= 0;          // Reset the synchronizer
        else 
            {sync_out, sync_stage1} <= {sync_stage1, sync_in};  // Shift the data
    end 
endmodule