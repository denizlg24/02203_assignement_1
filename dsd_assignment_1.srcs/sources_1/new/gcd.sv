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


module gcd (
    input  logic          clk,    // The clock signal.
    input  logic          reset,  // Reset the module.
    input  logic          req,    // Start computation.
    input  logic [15 : 0] AB,     // The two operands. One at a time.
    output logic          ack,    // Input received / Computation is complete.
    output logic [15 : 0] C       // The result.
);
    typedef enum logic [2 : 0] { in_a, load_a, in_b, load_b, compare, b_greater, a_greater, print } state_t; // Input your own state names here
    logic [1:0] FN;
    logic Z, N;
    shortint unsigned reg_a, next_reg_a, reg_b, next_reg_b;
    
    state_t state, next_state;
    
    // Combinatorial logic
    always_comb begin
        case (state)
            in_a: begin
                if(req == 1)
                    next_state = load_a;
                else
                    next_state = in_a;
            end
            load_a: begin
                next_reg_a = unsigned'(AB);
                if (req == 0)
                    next_state = in_b;
                else
                    next_state = load_a;
            end
            in_b: begin
                if(req == 1)
                    next_state = load_b;
                else
                    next_state = in_b;
            end
            load_b: begin
                next_reg_b = unsigned'(AB);
                next_state = compare;
            end
            compare: begin
                if(Z == 1)
                    next_state = print;
                else begin
                    if(N == 1)
                        next_state = b_greater;
                    else
                        next_state = a_greater;
                end   
            end
            print: begin
                if(req == 0)
                    next_state = in_a;
                else
                    next_state = print;
            end
        endcase
    end

        // Register
    always_ff @(posedge clk or posedge reset) begin
        // <REGISTER BODY>
    end

endmodule