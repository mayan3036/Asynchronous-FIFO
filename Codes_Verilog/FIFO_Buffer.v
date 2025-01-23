//----------------DISCRIPTION-----------------
// This module implements the memory buffer for the FIFO.
// It supports dual-port read/write operations with configurable data and address sizes.
//-------------------------------------------

// -------------PARAMETERS------------
// DATA_WIDTH: Width of the data bus
// ADDR_WIDTH: Width of the address bus
// -----------------------------------

module FIFO_Buffer #(parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4)(
    output [DATA_WIDTH-1:0] read_data,        // Output data - data to be read
    input [DATA_WIDTH-1:0] write_data,        // Input data - data to be written
    input [ADDR_WIDTH-1:0] write_addr, read_addr,  // Write and read addresses
    input write_enable, write_full, write_clock  // Write control signals
    );

    localparam MEM_DEPTH = 1 << ADDR_WIDTH;     // Depth of the FIFO memory
    reg [DATA_WIDTH-1:0] memory [0:MEM_DEPTH-1]; // Memory array

    assign read_data = memory[read_addr];       // Read data from memory

    always @(posedge write_clock)
        if (write_enable && !write_full) memory[write_addr] <= write_data; // Write data to memory
endmodule