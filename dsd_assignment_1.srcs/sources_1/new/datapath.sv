`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2026 11:01:52 AM
// Design Name: 
// Module Name: datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module datapath(
    input  logic [15:0] AB,
    output logic  [15:0] C,
    input  logic   ABorALU,
    input  logic       LDA,
    input  logic       LDB,
    output logic         N,
    output logic         Z,
    input  logic  [1:0] FN,
    input  logic       clk
    );
    wire [15:0] A, B, Y;
    
    c_alu alu(
        .A (A),
        .B (B),
        .fn (FN),
        .C (Y),
        .Z(Z),
        .N(N)
    );
    
    c_reg reg_a(
        .clk (clk),
        .en (LDA),
        .data_in (C),
        .data_out (A)
    );
    c_reg reg_b(
        .clk (clk),
        .en (LDB),
        .data_in (C),
        .data_out (B)
    );
    
    c_mux mux(
        .data_in1(AB),
        .data_in2(Y),
        .s(ABorALU),
        .data_out(C)
    );
    
endmodule
