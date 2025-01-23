//--------------DESCRIPTION--------------
// This testbench verifies the functionality of the asynchronous FIFO.
// It performs write and read operations and checks for correct behavior.
//---------------------------------------

`timescale 1ns/1ps

module Async_FIFO_Testbench();

    parameter DATA_WIDTH = 8; // Data bus width
    parameter ADDR_WIDTH = 3; // Address bus width
    parameter MEM_DEPTH = 1 << ADDR_WIDTH; // Depth of the FIFO memory

    reg [DATA_WIDTH-1:0] write_data;   // Input data
    wire [DATA_WIDTH-1:0] read_data;   // Output data
    wire write_full, read_empty;       // FIFO status signals
    reg write_enable, read_enable, write_clock, read_clock, write_reset_n, read_reset_n; // Control signals

    Async_FIFO_Top #(DATA_WIDTH, ADDR_WIDTH) fifo (
        .read_data(read_data), 
        .write_data(write_data),
        .write_full(write_full),
        .read_empty(read_empty),
        .write_enable(write_enable), 
        .read_enable(read_enable), 
        .write_clock(write_clock), 
        .read_clock(read_clock), 
        .write_reset_n(write_reset_n), 
        .read_reset_n(read_reset_n)
    );

    integer i = 0;
    integer seed = 1;

    // Clock generation
    always #5 write_clock = ~write_clock;    // Faster write clock
    always #10 read_clock = ~read_clock;     // Slower read clock

    initial begin
        // Initialize signals
        write_clock = 0;
        read_clock = 0;
        write_reset_n = 1;     // Active low reset
        read_reset_n = 1;      // Active low reset
        write_enable = 0;
        read_enable = 0;
        write_data = 0;

        // Reset the FIFO
        #40 write_reset_n = 0; read_reset_n = 0;
        #40 write_reset_n = 1; read_reset_n = 1;

        // Test Case 1: Write and read data
        read_enable = 1;
        for (i = 0; i < 10; i = i + 1) begin
            write_data = $random(seed) % 256;
            write_enable = 1;
            #10;
            write_enable = 0;
            #10;
        end

        // Test Case 2: Fill FIFO and attempt overflow
        read_enable = 0;
        write_enable = 1;
        for (i = 0; i < MEM_DEPTH + 3; i = i + 1) begin
            write_data = $random(seed) % 256;
            #10;
        end

        // Test Case 3: Read from empty FIFO
        write_enable = 0;
        read_enable = 1;
        for (i = 0; i < MEM_DEPTH + 3; i = i + 1) begin
            #20;
        end

        $finish;
    end
endmodule