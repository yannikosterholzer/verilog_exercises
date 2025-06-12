        /*
          Dieses Modul implementiert eine CRC-32-Berechnung im Ethernet-Format (LSB-first, reflektiert),
          basierend auf dem Generatorpolynom 0xEDB88320.
  
          Die verwendete 256-Werte-Tabelle (CRC-ROM) wurde wie folgt in Python erzeugt:
            def generate_crc_table():
                table = []
                for i in range(256):
                    crc = i
                    for _ in range(8):
                        crc = (crc >> 1) ^ POLY if (crc & 1) else (crc >> 1)
                    table.append(crc)
                return table
    
            crc_table = generate_crc_table()
  
          Zur Laufzeit wird jeder eingehende Daten-Byte in einem Schritt verarbeitet:
  
            def crc32_step(current_crc: int, data_byte: int) -> int:
                index = (current_crc ^ data_byte) & 0xFF
                return (current_crc >> 8) ^ crc_table[index]
  
          Dieses Verhalten wird in Verilog 1:1 nachgebildet mit anschließendem finalem XOR-Out mit 0xFFFFFFFF.
  
        */


module crc32  #( parameter INIT_CRC = 32'hFFFF_FFFF)
        (
            input           clk,
            input           rst,                    // globaler Reset
            input           crc_clear,              // manueller Soft-Reset fürs CRC
            input  [7:0]    data_in,     
            input           data_valid,
            output [31:0]   crc_out
        );
          
        localparam POLY     = 32'hEDB88320,         // Reflektiertes Ethernet-CRC32-Polynom (LSB-first)
                   XOR_OUT  = 32'hFFFFFFFF;
  
        reg  [31:0] crc_reg, next_crc, value; 
        reg  [7:0]  index;                          //Table-Index

        
        assign crc_out = crc_reg ^ XORVAL;          // Final-Xor

            
        always @(posedge clk) begin
            if(rst || crc_clear)
                crc_reg <= INIT_CRC;
            else
                if(data_valid)
                    crc_reg <= next_crc;
        end
        
        always @(*) begin
            index = crc_reg[7:0] ^ data_in;  
            next_crc = (crc_reg >> 8) ^ value ;
        end            
             
         // CRC-Tabelle mit 256 CRC32-Werten (LSB-first),
         // jeweils für ein einzelnes Byte (0x00-0xFF), das 8-mal durch den CRC-Schritt geschoben wird.
         always @(*)
                     case(index)
                0  : value = 32'h00000000;
                1  : value = 32'h77073096;
                2  : value = 32'hEE0E612C;
                3  : value = 32'h990951BA;
                4  : value = 32'h076DC419;
                5  : value = 32'h706AF48F;
                6  : value = 32'hE963A535;
                7  : value = 32'h9E6495A3;
                8  : value = 32'h0EDB8832;
                9  : value = 32'h79DCB8A4;
                10 : value = 32'hE0D5E91E;
                11 : value = 32'h97D2D988;
                12 : value = 32'h09B64C2B;
                13 : value = 32'h7EB17CBD;
                14 : value = 32'hE7B82D07;
                15 : value = 32'h90BF1D91;
                16 : value = 32'h1DB71064;
                17 : value = 32'h6AB020F2;
                18 : value = 32'hF3B97148;
                19 : value = 32'h84BE41DE;
                20 : value = 32'h1ADAD47D;
                21 : value = 32'h6DDDE4EB;
                22 : value = 32'hF4D4B551;
                23 : value = 32'h83D385C7;
                24 : value = 32'h136C9856;
                25 : value = 32'h646BA8C0;
                26 : value = 32'hFD62F97A;
                27 : value = 32'h8A65C9EC;
                28 : value = 32'h14015C4F;
                29 : value = 32'h63066CD9;
                30 : value = 32'hFA0F3D63;
                31 : value = 32'h8D080DF5;
                32 : value = 32'h3B6E20C8;
                33 : value = 32'h4C69105E;
                34 : value = 32'hD56041E4;
                35 : value = 32'hA2677172;
                36 : value = 32'h3C03E4D1;
                37 : value = 32'h4B04D447;
                38 : value = 32'hD20D85FD;
                39 : value = 32'hA50AB56B;
                40 : value = 32'h35B5A8FA;
                41 : value = 32'h42B2986C;
                42 : value = 32'hDBBBC9D6;
                43 : value = 32'hACBCF940;
                44 : value = 32'h32D86CE3;
                45 : value = 32'h45DF5C75;
                46 : value = 32'hDCD60DCF;
                47 : value = 32'hABD13D59;
                48 : value = 32'h26D930AC;
                49 : value = 32'h51DE003A;
                50 : value = 32'hC8D75180;
                51 : value = 32'hBFD06116;
                52 : value = 32'h21B4F4B5;
                53 : value = 32'h56B3C423;
                54 : value = 32'hCFBA9599;
                55 : value = 32'hB8BDA50F;
                56 : value = 32'h2802B89E;
                57 : value = 32'h5F058808;
                58 : value = 32'hC60CD9B2;
                59 : value = 32'hB10BE924;
                60 : value = 32'h2F6F7C87;
                61 : value = 32'h58684C11;
                62 : value = 32'hC1611DAB;
                63 : value = 32'hB6662D3D;
                64 : value = 32'h76DC4190;
                65 : value = 32'h01DB7106;
                66 : value = 32'h98D220BC;
                67 : value = 32'hEFD5102A;
                68 : value = 32'h71B18589;
                69 : value = 32'h06B6B51F;
                70 : value = 32'h9FBFE4A5;
                71 : value = 32'hE8B8D433;
                72 : value = 32'h7807C9A2;
                73 : value = 32'h0F00F934;
                74 : value = 32'h9609A88E;
                75 : value = 32'hE10E9818;
                76 : value = 32'h7F6A0DBB;
                77 : value = 32'h086D3D2D;
                78 : value = 32'h91646C97;
                79 : value = 32'hE6635C01;
                80 : value = 32'h6B6B51F4;
                81 : value = 32'h1C6C6162;
                82 : value = 32'h856530D8;
                83 : value = 32'hF262004E;
                84 : value = 32'h6C0695ED;
                85 : value = 32'h1B01A57B;
                86 : value = 32'h8208F4C1;
                87 : value = 32'hF50FC457;
                88 : value = 32'h65B0D9C6;
                89 : value = 32'h12B7E950;
                90 : value = 32'h8BBEB8EA;
                91 : value = 32'hFCB9887C;
                92 : value = 32'h62DD1DDF;
                93 : value = 32'h15DA2D49;
                94 : value = 32'h8CD37CF3;
                95 : value = 32'hFBD44C65;
                96 : value = 32'h4DB26158;
                97 : value = 32'h3AB551CE;
                98 : value = 32'hA3BC0074;
                99 : value = 32'hD4BB30E2;
                100: value = 32'h4ADFA541;
                101: value = 32'h3DD895D7;
                102: value = 32'hA4D1C46D;
                103: value = 32'hD3D6F4FB;
                104: value = 32'h4369E96A;
                105: value = 32'h346ED9FC;
                106: value = 32'hAD678846;
                107: value = 32'hDA60B8D0;
                108: value = 32'h44042D73;
                109: value = 32'h33031DE5;
                110: value = 32'hAA0A4C5F;
                111: value = 32'hDD0D7CC9;
                112: value = 32'h5005713C;
                113: value = 32'h270241AA;
                114: value = 32'hBE0B1010;
                115: value = 32'hC90C2086;
                116: value = 32'h5768B525;
                117: value = 32'h206F85B3;
                118: value = 32'hB966D409;
                119: value = 32'hCE61E49F;
                120: value = 32'h5EDEF90E;
                121: value = 32'h29D9C998;
                122: value = 32'hB0D09822;
                123: value = 32'hC7D7A8B4;
                124: value = 32'h59B33D17;
                125: value = 32'h2EB40D81;
                126: value = 32'hB7BD5C3B;
                127: value = 32'hC0BA6CAD;
                128: value = 32'hEDB88320;
                129: value = 32'h9ABFB3B6;
                130: value = 32'h03B6E20C;
                131: value = 32'h74B1D29A;
                132: value = 32'hEAD54739;
                133: value = 32'h9DD277AF;
                134: value = 32'h04DB2615;
                135: value = 32'h73DC1683;
                136: value = 32'hE3630B12;
                137: value = 32'h94643B84;
                138: value = 32'h0D6D6A3E;
                139: value = 32'h7A6A5AA8;
                140: value = 32'hE40ECF0B;
                141: value = 32'h9309FF9D;
                142: value = 32'h0A00AE27;
                143: value = 32'h7D079EB1;
                144: value = 32'hF00F9344;
                145: value = 32'h8708A3D2;
                146: value = 32'h1E01F268;
                147: value = 32'h6906C2FE;
                148: value = 32'hF762575D;
                149: value = 32'h806567CB;
                150: value = 32'h196C3671;
                151: value = 32'h6E6B06E7;
                152: value = 32'hFED41B76;
                153: value = 32'h89D32BE0;
                154: value = 32'h10DA7A5A;
                155: value = 32'h67DD4ACC;
                156: value = 32'hF9B9DF6F;
                157: value = 32'h8EBEEFF9;
                158: value = 32'h17B7BE43;
                159: value = 32'h60B08ED5;
                160: value = 32'hD6D6A3E8;
                161: value = 32'hA1D1937E;
                162: value = 32'h38D8C2C4;
                163: value = 32'h4FDFF252;
                164: value = 32'hD1BB67F1;
                165: value = 32'hA6BC5767;
                166: value = 32'h3FB506DD;
                167: value = 32'h48B2364B;
                168: value = 32'hD80D2BDA;
                169: value = 32'hAF0A1B4C;
                170: value = 32'h36034AF6;
                171: value = 32'h41047A60;
                172: value = 32'hDF60EFC3;
                173: value = 32'hA867DF55;
                174: value = 32'h316E8EEF;
                175: value = 32'h4669BE79;
                176: value = 32'hCB61B38C;
                177: value = 32'hBC66831A;
                178: value = 32'h256FD2A0;
                179: value = 32'h5268E236;
                180: value = 32'hCC0C7795;
                181: value = 32'hBB0B4703;
                182: value = 32'h220216B9;
                183: value = 32'h5505262F;
                184: value = 32'hC5BA3BBE;
                185: value = 32'hB2BD0B28;
                186: value = 32'h2BB45A92;
                187: value = 32'h5CB36A04;
                188: value = 32'hC2D7FFA7;
                189: value = 32'hB5D0CF31;
                190: value = 32'h2CD99E8B;
                191: value = 32'h5BDEAE1D;
                192: value = 32'h9B64C2B0;
                193: value = 32'hEC63F226;
                194: value = 32'h756AA39C;
                195: value = 32'h026D930A;
                196: value = 32'h9C0906A9;
                197: value = 32'hEB0E363F;
                198: value = 32'h72076785;
                199: value = 32'h05005713;
                200: value = 32'h95BF4A82;
                201: value = 32'hE2B87A14;
                202: value = 32'h7BB12BAE;
                203: value = 32'h0CB61B38;
                204: value = 32'h92D28E9B;
                205: value = 32'hE5D5BE0D;
                206: value = 32'h7CDCEFB7;
                207: value = 32'h0BDBDF21;
                208: value = 32'h86D3D2D4;
                209: value = 32'hF1D4E242;
                210: value = 32'h68DDB3F8;
                211: value = 32'h1FDA836E;
                212: value = 32'h81BE16CD;
                213: value = 32'hF6B9265B;
                214: value = 32'h6FB077E1;
                215: value = 32'h18B74777;
                216: value = 32'h88085AE6;
                217: value = 32'hFF0F6A70;
                218: value = 32'h66063BCA;
                219: value = 32'h11010B5C;
                220: value = 32'h8F659EFF;
                221: value = 32'hF862AE69;
                222: value = 32'h616BFFD3;
                223: value = 32'h166CCF45;
                224: value = 32'hA00AE278;
                225: value = 32'hD70DD2EE;
                226: value = 32'h4E048354;
                227: value = 32'h3903B3C2;
                228: value = 32'hA7672661;
                229: value = 32'hD06016F7;
                230: value = 32'h4969474D;
                231: value = 32'h3E6E77DB;
                232: value = 32'hAED16A4A;
                233: value = 32'hD9D65ADC;
                234: value = 32'h40DF0B66;
                235: value = 32'h37D83BF0;
                236: value = 32'hA9BCAE53;
                237: value = 32'hDEBB9EC5;
                238: value = 32'h47B2CF7F;
                239: value = 32'h30B5FFE9;
                240: value = 32'hBDBDF21C;
                241: value = 32'hCABAC28A;
                242: value = 32'h53B39330;
                243: value = 32'h24B4A3A6;
                244: value = 32'hBAD03605;
                245: value = 32'hCDD70693;
                246: value = 32'h54DE5729;
                247: value = 32'h23D967BF;
                248: value = 32'hB3667A2E;
                249: value = 32'hC4614AB8;
                250: value = 32'h5D681B02;
                251: value = 32'h2A6F2B94;
                252: value = 32'hB40BBE37;
                253: value = 32'hC30C8EA1;
                254: value = 32'h5A05DF1B;
                255: value = 32'h2D02EF8D;
                endcase  
endmodule
