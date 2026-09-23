# Design of Digital Systems - Assignment 1

## Whiteboard for registering thoughts and answers

### Whiteboard

### Answers

#### Task 0

##### 0.b)

A register of 16 bits is made up of 16 Flip Flops, thus since we are using 2, 16 bit registers, we expect to use 32 Flip Flops. In terms of LUTs for the 16-bit multiplexer we need approximately 16 LUTs, for the ALU result we also need approximately 16 LUTs, since the result of bit i is a function of f(A_i,B_i,borrow_i,FN_1,FN_0) which fits in one LUT but the subtraction also needs to calculate the borrow/carry passed to the next bit, which is a function of f(A_i,B_i,borrow_i,FN_1,FN_0), that's another LUT. Since we need the borrow/carry chain calculated up to the last bit, we add 16 bits for output and 15 bits for the borrow/carry chain, which adds up to around 31 LUTs for the ALU. Then for the Z flag, which needs to reduce all the 16 bits into one bit, indicating if they are all 0 or not, needs around 3 LUTs since $16/6\approx3$. Our guess for LUTs is, thus, around 50.

Great breakdown on task 0 b), I totally agree with your logic. Just a minor detail I was thinking about for the Z flag, since we need to reduce 16 bits to 1, grouping 16/6 gives us 3 LUTs for the first layer, but I think we'd actually need a 4th LUT to combine the outputs of those first 3 LUTs into the final single bit. It doesn't change the overall estimate much, but thought it was worth mentioning.

#### Task 2

##### 2.b)

Our proposed drawing for the FSMD

![fsm_diagram](./task2_b.png)

Your initial drawing was a great foundation and the logic flow was spot on. I just made a slightly updated version to make it 100% hardware-accurate based on the physical datapath we have in Figure 2.
The main adjustments are:

1. **State 2 & 3 (Loading RegB):**

Separated the waiting state (`Req=0`) from the loading state. This ensures we don't save switch bounce or garbage data into `RegB` while the user is still flipping the switches.
2. **The "Comparator" (States 4, 5, 6):** Since we only have one ALU and no dedicated comparator, the FSM can't directly check `RegA > RegB`. Instead, we have to command the ALU to subtract (`FN=00`) and then look at the physical output flags (`Z` and `N`) to decide our next state.
*(Note: I also removed `C <= RegA` from the final state because in Fig 2, C is permanently buffered to RegA, so the FSM doesn't need a control signal for it).*

Here is the revised diagram:

<img width="1200" height="1600" alt="State Machine" src="https://github.com/user-attachments/assets/aa0226b1-74d2-4224-a262-efcb46ab5bf6" />

Our final FSM diagram:

![fsm_diagram](./fsmd.png)

We also drew up a ASM:

![asm_diagram](./task2_asm.png)

#### Task 3

##### 3.a)

We decided to implement the operand sharing. Instead of having three subtractions one on each state, we first choose which operands are going to be used, based on state, and then do the arithmetic with the chosen operands.

##### 3.c)

We ran the utilization report on the naive GCD implementation - [Naive Utilization Report](./utilization_reports/gcd_naive_utilization.txt) - and recorded a usage of 60 LUTs and 40 FFs. The LUTs were considerably above what we expected, and we attribute that to the synthesis tool generating subtractor circuits for all the operations we had (3). FFs also were considerably higher and we didn't understand why in the beginning. After digging down, we found out that even declaring 3 bits for the state encoding, the synthesis tool overwrote the encoding and used one-hot encoding.

After implementing the first optimization - operator sharing - where instead of running subtractions in three places, we first decide which are the operands and then run the subtraction, as well as forcing the sequential encoding with the flag `(* fsm_encoding = "sequential" *)` we reran the implementation and generated another utilization report - [Operand Sharing Utilization Report](./utilization_reports/gcd_op_sharing_utilization.txt) - and recorded a usage of 47 LUTs and 35 FFs, which now aligns much better with what we expected. The synthesis tool now uses one subtractor circuit only and uses only 3 FFs for encoding state. The other 32 FFs are for the two 16 bit registers we have.

For the second optimization we tried computing both subtractions in parallel and committing only the correct one. The operand-sharing version needs two clock cycles per iteration of the algorithm: one in `compare` to subtract and read the flags, and one in `a_greater`/`b_greater` to subtract again and write the result back. In the parallel version we compute `A - B` and `B - A` every cycle with two subtractors, and `compare` uses the sign of `A - B` to decide which result to write back in that same cycle: if $A > B$, `RegA` takes `A - B`; if $A < B$, `RegB` takes `B - A`; if the result is zero we move to the output state. This removes the `a_greater` and `b_greater` states, so the FSM goes from 8 to 6 states and each iteration takes one clock cycle instead of two.

The utilization report for this version is [Parallel Utilization Report](./utilization_reports/gcd_parallel.txt).

| | Shared version | Parallel version |
|---|---|---|
| LUTs (`gcd` module) | 47 | TBD |
| LUTs (whole design, incl. debouncer) | 88 | TBD |
| CARRY4 | 15 | TBD |
| FFs (`gcd` module) | 35 | TBD |
| WNS @ 100 MHz | TBD | TBD |
| Critical path in `gcd` (data path delay) | TBD | TBD |
| Clock cycles per iteration | 2 | 1 |
