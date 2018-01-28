// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//
// Description: Top level Apple 1 module for Terasic DE0 board
//
// Author.....: Niels A. Moseley
// Date.......: 26-1-2018
// 


module apple1_de0_top(
    input   CLOCK_50,       // the 50 MHz DE0 master clock

    // UART I/O signals
    output  UART_TXD,       // UART transmit pin on DE0 board
    input   UART_RXD,       // UART receive pin on DE0 board
    output  UART_CTS,       // UART clear-to-send pin on DE0 board
    
    output  [7:0] LEDG,     // monitoring for lower 8 address bits
    input   [2:0] BUTTON,   // BUTTON[0] for reset
    output  [6:0] HEX0_D,
    output  [6:0] HEX1_D,
    output  [6:0] HEX2_D,
    output  [6:0] HEX3_D,
    input   PS2_KBCLK,
    input   PS2_KBDAT
);

    //////////////////////////////////////////////////////////////////////////    
    // Registers and Wires
    reg clk25;
    wire [15:0] pc_monitor;

    // generate 25MHz clock from 50MHz master clock
    always @(posedge CLOCK_50)
    begin
        clk25 <= ~clk25;
    end
    
    //////////////////////////////////////////////////////////////////////////    
    // Core of system
    apple1 apple1_top(
        .clk25(clk25),
        .rst_n(BUTTON[0]),       // we don't have any reset pulse..
        .uart_rx(UART_RXD),
        .uart_tx(UART_TXD),
        .uart_cts(UART_CTS),
        .ps2_clk(PS2_KBCLK),
        .ps2_din(PS2_KBDAT),
        .pc_monitor(pc_monitor)
    );

    //////////////////////////////////////////////////////////////////////////    
    // Display 6502 address on 7-segment displays
    
    segmentdisplay seg1(
        .clk(clk25),
        .latch(1'b1),
        .hexdigit_in(pc_monitor[3:0]),
        .display_out(HEX0_D)
    );

    segmentdisplay seg2(
        .clk(clk25),
        .latch(1'b1),
        .hexdigit_in(pc_monitor[7:4]),
        .display_out(HEX1_D)
    );
    
    segmentdisplay seg3(
        .clk(clk25),
        .latch(1'b1),
        .hexdigit_in(pc_monitor[11:8]),
        .display_out(HEX2_D)
    );

    segmentdisplay seg4(
        .clk(clk25),
        .latch(1'b1),
        .hexdigit_in(pc_monitor[15:12]),
        .display_out(HEX3_D)
    );

endmodule
