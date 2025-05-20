/*
Extrahiert 3-Byte-Pakete aus einem kontinuierlichen PS/2-Datenstrom und gibt das 24-Bit-Paket aus, sobald es vollständig empfangen wurde
*/

module ps2pars(
                input         wire  clk,
                input [7:0]         in,                // Eingehendes PS/2-Datenbyte
                input         wire  reset,             // synchroner Reset
                output [23:0] wire  out_bytes,         // Ausgaberegister für 3 empfangene Bytes
                output        wire  done               // Signalisiert, dass ein vollständiges Paket vorliegt
              ); 
          	
    reg [23:0] out_data;                               // Zwischenspeicher für die 3 Bytes
    reg [1:0] state, next_state;

  
    always @(*)
        case(state)
            2'b00: next_state = (in[3])? 2'b01 : 2'b00;
            2'b01: next_state = 2'b10;
            2'b10: next_state = 2'b11;
            2'b11: next_state = (in[3])? 2'b01 : 2'b00;
        endcase
    
    always @(posedge clk)
        if(reset)
            state <= 2'b00;
        else
            state <= next_state;
  
    // Schiebe neues Byte in das Ausgaberegister
    always @(posedge clk)
        out_data <= {out_data[15:0], in};
    
    // Paket vollständig, wenn im Endzustand
    assign done = (state == 2'b11);
   // Ausgabe nur aktiv, wenn Paket komplett – sonst 0
  assign out_bytes = (done)? out_data: 0;

endmodule
