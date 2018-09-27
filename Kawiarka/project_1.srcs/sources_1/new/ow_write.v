   //////////////////////////////////////////////////////////////////////////////////
//
// Wirtualny komponent bloku zapisu danych dla obs³ugi magistrali 1-wire
//
// (C) 2009 Zbigniew Hajduk
// http://zh.prz-rzeszow.pl
// 
//
// Ten kod Ÿród³owy mo¿e podlegaæ wolnej redystrybucji i/lub modyfikacjom 
// na ogólnych zasadach okreœlonych licencj¹ GNU General Public License.
//
// Autor wyra¿a nadziejê, ¿e kod wirtualnego komponentu bêdzie u¿yteczny
// jednak nie udziela ¯ADNEJ GWARANCJI dotycz¹cej jego sprawnoœci
// oraz przydatnoœci dla partykularnych zastosowañ.
//
//////////////////////////////////////////////////////////////////////////////////

module OW_WRITE(input CLK,RST,TX_ACT,Z,
                output reg DONE,LD,
                output BUS_OUT,
                input [7:0] DATA,
                output [6:0] TIME_C);

reg  wire1_out;
reg [2:0] st;
reg [6:0] tc;
reg [2:0] mux_addr;

function mux81(input [7:0] data, //(1)
               input [2:0] addr);
integer i;
begin
    for(i=0;i<8;i=i+1)
      if(i==addr) mux81=data[i];
end
endfunction
assign tx_bit=mux81(DATA,mux_addr);

always@(posedge CLK)
begin
   if(~RST) st<=0; else
   begin
    case(st) //(2)
	3'd0: begin 
              mux_addr<=0; DONE<=0; tc<=7'd0; LD<=1'b0;
	       wire1_out<=1'b1; if(TX_ACT) st<=3'd1;  end
	3'd1: begin wire1_out<=1'b0; tc<=7'd0; LD<=1'b1;
	      if(Z) st<=3'd2;	end
	3'd2: begin LD<=1'b0; st<=3'd3;
               if(tx_bit) wire1_out<=1'b1;	end
	3'd3: begin tc<=7'd17; LD<=1'b1; 
              if(Z) st<=3'd4; 	end
	3'd4: begin LD<=1'b0; wire1_out<=1'b1; st<=3'd5; end
	3'd5: begin tc<=7'd0; LD<=1'b1; if(Z) st<=3'd6; end
	3'd6: begin  LD<=1'b0;
             if(mux_addr==3'd7) st<=3'd7; else 
              begin mux_addr<=mux_addr+1; st<=3'd1; end end
	3'd7: begin DONE<=1'b1; st<=3'd0; end
   endcase
   end
end
 assign TIME_C=tc;
 assign BUS_OUT=wire1_out;
endmodule
