//---------------DESCRIPTION-----------------------
// This module handles the read pointer and empty flag logic for the FIFO.
//--------------------------------------------------

//-------------PARAMETERS---------------------------
// ADDR_WIDTH: Width of the address bus
//--------------------------------------------------

module Read_Pointer_Handler #(parameter ADDR_WIDTH = 4)(
    output reg read_empty,                  // Empty flag
    output [ADDR_WIDTH-1:0] read_addr,      // Read address
    output reg [ADDR_WIDTH :0] read_ptr,    // Read pointer
    input [ADDR_WIDTH :0] sync_write_ptr,   // Synchronized write pointer
    input read_enable, read_clock, read_reset_n  // Read control signals
    );

    reg [ADDR_WIDTH:0] read_bin;                     // Binary read pointer
    wire [ADDR_WIDTH:0] read_gray_next, read_bin_next; // Next pointers
    wire read_empty_val;                             // Empty flag value

    // Synchronous read pointer update
    always @(posedge read_clock or negedge read_reset_n) begin
        if (!read_reset_n)                // Reset the FIFO
            {read_bin, read_ptr} <= 0;
        else 
            {read_bin, read_ptr} <= {read_bin_next, read_gray_next};  // Update pointers
    end

    assign read_addr = read_bin[ADDR_WIDTH-1:0];     // Calculate read address
    assign read_bin_next = read_bin + (read_enable & ~read_empty); // Increment pointer
    assign read_gray_next = (read_bin_next >> 1) ^ read_bin_next; // Convert to gray code

    // Check if FIFO is empty
    assign read_empty_val = (read_gray_next == sync_write_ptr); // Empty flag logic

    always @(posedge read_clock or negedge read_reset_n) begin
        if (!read_reset_n)                // Reset empty flag
            read_empty <= 1'b1;
        else 
            read_empty <= read_empty_val; // Update empty flag
    end
endmodule