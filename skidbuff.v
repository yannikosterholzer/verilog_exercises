// Skid-Buffer-Logik zur Handhabung temporärer Stausituationen in synchronen Pipelines
// Verhindert Datenverlust, wenn `downstream_ready` temporär deasserted ist

module skidbuff #(parameter DWIDTH = 8)(
                        input                clk,
                        input                rstn,
                    
                        // Eingänge von der vorgelagerten Pipeline-Stufe (Stage N-1)
                        input  [DWIDTH-1:0] upstream_data,       // Dateninput
                        input               upstream_valid,                   // Gültigkeitssignal von Stage N-1
                        output          reg upstream_ready,               // "bereit"-Signal an Stage N-1
                    
                        // Ausgänge zur nachfolgenden Pipeline-Stufe (Stage N+1)
                        input                downstream_ready,                 // "bereit"-Signal von Stage N+1
                        output           reg downstream_valid,             // Gültigkeitssignal an Stage N+1
                        output           reg [DWIDTH-1:0] downstream_data  // Datenoutput
                    );

    reg [DWIDTH-1:0] data_buffer;     // Zwischenspeicher für 1 Datenelement
    reg valid_buffer;                 // Puffer für das valid-Signal

    // Hauptlogik zur Datenverwaltung
    always @(posedge clk) begin
        if (!rstn) begin
            downstream_valid <= 0;
            data_buffer      <= 0;
            valid_buffer     <= 0;

        end else begin
            // Fall: Downstream ist bereit, Daten zu übernehmen
            if (downstream_ready) begin

                if (!upstream_ready) begin
                    // Zustand: Daten aus dem Puffer ausgeben
                    downstream_data  <= data_buffer;
                    downstream_valid <= valid_buffer;

                    // Puffer als geleert markieren
                    valid_buffer     <= 0;

                end else begin
                    // Zustand: Direkte Datenweitergabe von oben nach unten
                    downstream_data  <= upstream_data;
                    downstream_valid <= upstream_valid;
                end

            end else begin
                // Fall: Downstream blockiert – Daten puffern, wenn noch nicht gepuffert
                if (!valid_buffer && upstream_valid) begin
                    data_buffer  <= upstream_data;
                    valid_buffer <= 1;
                end
            end
        end
    end

    // Steuerung des Ready-Signals zur vorgelagerten Stufe:
    // Nur dann "bereit", wenn kein Rückstau besteht
    always @(posedge clk)
        if (!rstn)
            upstream_ready <= 1;
        else
            upstream_ready    <= downstream_ready; 

endmodule
            upstream_ready <= downstream_ready || !valid_buffer;

endmodule
