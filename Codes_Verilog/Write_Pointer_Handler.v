//-------------DESCRIPTION---------------------------
// This module handles the write pointer and full flag logic for the FIFO.
//--------------------------------------------------

//-------------PARAMETERS---------------------------
// ADDR_WIDTH: Width of the address bus
//--------------------------------------------------

module Write_Pointer_Handler #(parameter ADDR_WIDTH = 4)(
    output reg write_full,                   // Full flag
    output [ADDR_WIDTH-1:0] write_addr,      // Write address
    output reg [ADDR_WIDTH :0] write_ptr,    // Write pointer
    input [ADDR_WIDTH :0] sync_read_ptr,     // Synchronized read pointer
    input write_enable, write_clock, write_reset_n  // Write control signals
    );

    reg [ADDR_WIDTH:0] write_bin;                     // Binary write pointer
    wire [ADDR_WIDTH:0] write_gray_next, write_bin_next; // Next pointers
    wire write_full_val;                             // Full flag value

    // Synchronous write pointer update
    always @(posedge write_clock or negedge write_reset_n) begin
        if (!write_reset_n)            // Reset the FIFO
            {write_bin, write_ptr} <= 0;
        else 
            {write_bin, write_ptr} <= {write_bin_next, write_gray_next}; // Update pointers
    end

    assign write_addr = write_bin[ADDR_WIDTH-1:0];     // Calculate write address
    assign write_bin_next = write_bin + (write_enable & ~write_full); // Increment pointer
    assign write_gray_next = (write_bin_next >> 1) ^ write_bin_next; // Convert to gray code

    // Check if FIFO is full
    assign write_full_val = (write_gray_next == {~sync_read_ptr[ADDR_WIDTH:ADDR_WIDTH-1], sync_read_ptr[ADDR_WIDTH-2:0]}); // Full flag logic

    always @(posedge write_clock or negedge write_reset_n) begin
        if (!write_reset_n)            // Reset full flag
            write_full <= 1'b0;
        else 
            write_full <= write_full_val; // Update full flag
    end
endmodule