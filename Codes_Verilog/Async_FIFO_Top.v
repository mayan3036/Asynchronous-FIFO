//--------------DESCRIPTION-----------------
// This module implements a top-level asynchronous FIFO with configurable data and address sizes.
// It integrates memory, pointer handlers, and clock domain synchronization logic.
//-------------------------------------------

// -------------PARAMETERS------------
// DATA_WIDTH: Width of the data bus
// ADDR_WIDTH: Width of the address bus
// -----------------------------------

module Async_FIFO_Top #(parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4)(
    output [DATA_WIDTH-1:0] read_data,       // Output data - data to be read
    output write_full,                       // Write full signal
    output read_empty,                       // Read empty signal
    input [DATA_WIDTH-1:0] write_data,       // Input data - data to be written
    input write_enable, write_clock, write_reset_n,  // Write control signals
    input read_enable, read_clock, read_reset_n      // Read control signals
    );

    wire [ADDR_WIDTH-1:0] write_addr, read_addr;
    wire [ADDR_WIDTH:0] write_ptr, read_ptr, sync_write_ptr, sync_read_ptr;

    Clock_Domain_Synchronizer #(ADDR_WIDTH+1) sync_read_to_write (  // Synchronize read pointer to write clock domain
        .sync_out(sync_write_ptr), 
        .sync_in(read_ptr),
        .sync_clock(write_clock), 
        .sync_reset_n(write_reset_n)
    );

    Clock_Domain_Synchronizer #(ADDR_WIDTH+1) sync_write_to_read (  // Synchronize write pointer to read clock domain
        .sync_out(sync_read_ptr), 
        .sync_in(write_ptr),
        .sync_clock(read_clock), 
        .sync_reset_n(read_reset_n)
    );

    FIFO_Buffer #(DATA_WIDTH, ADDR_WIDTH) fifo_memory (  // FIFO memory module
        .read_data(read_data), 
        .write_data(write_data),
        .write_addr(write_addr), 
        .read_addr(read_addr),
        .write_enable(write_enable), 
        .write_full(write_full),
        .write_clock(write_clock)
    );

    Read_Pointer_Handler #(ADDR_WIDTH) read_handler (  // Read pointer and empty flag logic
        .read_empty(read_empty),
        .read_addr(read_addr),
        .read_ptr(read_ptr), 
        .sync_write_ptr(sync_read_ptr),
        .read_enable(read_enable), 
        .read_clock(read_clock),
        .read_reset_n(read_reset_n)
    );

    Write_Pointer_Handler #(ADDR_WIDTH) write_handler (  // Write pointer and full flag logic
        .write_full(write_full), 
        .write_addr(write_addr),
        .write_ptr(write_ptr), 
        .sync_read_ptr(sync_write_ptr),
        .write_enable(write_enable), 
        .write_clock(write_clock),
        .write_reset_n(write_reset_n)
    );

endmodule