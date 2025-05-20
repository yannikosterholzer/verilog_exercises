module bitwise_2compl(
                        input  wire clk,
                        input  wire areset,
                        input  wire x,
                        output wire z
                    );

  parameter a = 0, b = 1;  // Zustände: a = Vor erstem '1'; b = Ab erstem '1' (invertieren)
  reg state, next_state;
    
    // Zustandsübergangslogik:
    // Zustand 'a': Suche erstes gesetztes Bit (erste '1')
    // Zustand 'b': Ab erstem '1' bleiben wir in 'b' (invertieren alle weiteren Bits)
    always @(*)
        case(state)
            a: next_state = (x) ? b : a;
            b: next_state = b;
        endcase
	
    // Zustandsregister mit asynchronem Reset
    always @(posedge clk or posedge areset)
        if (areset)
            state <= a;
        else
            state <= next_state;
    
    // Ausgangslogik:
    // Zustand 'a': Bits unverändert durchreichen (z = x)
    // Zustand 'b': Bits invertieren (z = ~x)
    assign z = (state == a) ? x : ~x;
endmodule
