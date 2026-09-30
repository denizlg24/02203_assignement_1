`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2026 11:01:52 AM
// Design Name: 
// Module Name: fsm
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

module fsm (
    input  logic       clk,
    input  logic       reset,
    input  logic       req,

    input  logic       N,
    input  logic       Z,

    output logic       ack,
    output logic       ABorALU,
    output logic       LDA,
    output logic       LDB,
    output logic [1:0] FN
);

    typedef enum logic [2:0] {
        in_a,
        load_a,
        in_b,
        load_b,
        compare,
        b_greater,
        a_greater,
        print
    } state_t;

    state_t state, next_state;

    always_comb begin
        next_state = state;
        ack     = 1'b0;
        ABorALU = 1'b0;
        LDA     = 1'b0;
        LDB     = 1'b0;
        FN      = 2'b00;

        case (state)
            in_a: begin
                if (req == 1'b1)
                    next_state = load_a;
            end

            load_a: begin
                ack     = 1'b1;
                ABorALU = 1'b1;
                LDA     = req;
                if (req == 1'b0)
                    next_state = in_b;
            end

            in_b: begin  
                if (req == 1'b1)
                    next_state = load_b;
            end

            load_b: begin
                ABorALU = 1'b1;
                LDB     = 1'b1;
                next_state = compare;
            end

            compare: begin
                FN = 2'b00;
                if (Z == 1'b1)
                    next_state = print;
                else if (N == 1'b1)
                    next_state = b_greater;
                else
                    next_state = a_greater;
            end

            b_greater: begin
                FN      = 2'b01;
                ABorALU = 1'b0;
                LDB     = 1'b1;
                next_state = compare;
            end

            a_greater: begin
                FN      = 2'b00;
                ABorALU = 1'b0;
                LDA     = 1'b1;
                next_state = compare;
            end

            print: begin
                ABorALU = 1'b0;
                FN = 2'b10;
                ack = 1'b1;
                if (req == 1'b0)
                    next_state = in_a;
            end

            default: begin
                next_state = in_a;
            end

        endcase
    end

    
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= in_a;
        else
            state <= next_state;
    end

endmodule