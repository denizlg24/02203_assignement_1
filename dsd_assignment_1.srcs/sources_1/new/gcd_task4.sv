`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2026 11:01:52 AM
// Design Name: 
// Module Name: gcd_task4
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


module gcd_task4(
    input logic             clk,
    input logic             reset,
    input logic             req,
    input logic  [15 : 0]    AB,
    output logic            ack,
    output logic [15 : 0]   C
    );
    
    // shared signals between FSM and Datapath
    logic        ABorALU;
    logic        LDA;
    logic        LDB;
    logic [1:0]  FN;
    logic        Z;
    logic        N;

    // FSM
    fsm u_fsm (
        // exterior
        .clk(clk),
        .reset(reset),
        .req(req),
        .ack(ack),
        // from datapath
        .Z(Z),
        .N(N),
        // to datapath
        .ABorALU(ABorALU),
        .LDA(LDA),
        .LDB(LDB),
        .FN(FN)
    );

    // Datapath
    datapath u_datapath (
        // from exterior
        .clk(clk),
        .AB(AB),
        // to exterior (leds)
        .C(C),
        // from FSM
        .ABorALU(ABorALU),
        .LDA(LDA),
        .LDB(LDB),
        .FN(FN),
        // to FSM (flags)
        .Z(Z),
        .N(N)
     );
     
endmodule
