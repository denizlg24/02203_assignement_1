// -----------------------------------------------------------------------------
//
//  Title      :  System Verilog FSMD implementation template for GCD
//             :
//  Developers :  Otto Westy Rasmussen
//             :
//  Purpose    :  This is a template for the FSMD (finite state machine with datapath) 
//             :  implementation of the GCD circuit
//             :
//  Revision   :  02203 fall 2025 v.1.0
//
// -----------------------------------------------------------------------------


module gcd_opt_share (
    input  logic          clk,    // The clock signal.
    input  logic          reset,  // Reset the module.
    input  logic          req,    // Start computation.
    input  logic [15 : 0] AB,     // The two operands. One at a time.
    output logic          ack,    // Input received / Computation is complete.
    output logic [15 : 0] C       // The result.
);
    typedef enum logic [2 : 0] { in_a, load_a, in_b, load_b, compare, b_greater, a_greater, print } state_t;
    logic Z, N;
    logic [16:0] temp;
    logic [15:0] X,Y;
    shortint unsigned reg_a, next_reg_a, reg_b, next_reg_b;
    
    state_t state, next_state;
    
    // Combinatorial logic
    always_comb begin
        next_state = state;
        next_reg_a = reg_a;
        next_reg_b = reg_b;
        ack = 1'b0;
        C   = reg_a;
        temp = 17'b0;
        Z    = 1'b0;
        N    = 1'b0;
        X = reg_a;
        Y = reg_b;
        
        case(state)
            b_greater: begin
                Y = reg_b;
                X = reg_a;
            end
        endcase
        
        temp = {1'b0, X} - {1'b0, Y};
        
        case (state)
            in_a: begin
                ack = 1'b0;
                if(req == 1'b1)
                    next_state = load_a;
            end
            load_a: begin
                next_reg_a = AB;
                ack = 1'b1;

                if (req == 1'b1)
                    next_state = in_b;
            end
            in_b: begin
                ack = 1'b0;
                if(req == 1'b1)
                    next_state = load_b;
            end
            load_b: begin
                next_reg_b = AB;
                next_state = compare;
            end
            compare: begin
                Z = (temp[15:0] == 16'b0);
                N = temp[16];
                if(Z == 1'b1)
                    next_state = print;
                else begin
                    if(N == 1'b1)
                        next_state = b_greater;
                    else
                        next_state = a_greater;
                end   
            end
            a_greater: begin
                next_reg_a = temp[15:0];
                next_state = compare;
            end
            b_greater: begin
                next_reg_b = temp[15:0];
                next_state = compare;
            end
            print: begin
                ack = 1'b1;
                C = reg_a;
                if(req == 1'b0)
                    next_state = in_a;
            end
        endcase
    end

        // Register
    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= in_a;
            reg_a <= 16'b0;
            reg_b <= 16'b0;
        end
        else begin
            state <= next_state;
            reg_a <= next_reg_a;
            reg_b <= next_reg_b;
        end
    end

endmodule