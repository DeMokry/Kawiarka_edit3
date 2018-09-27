   //////////////////////////////////////////////////////////////////////////////////
//
// Wirtualny komponent bloku odczytu danych dla obs³ugi magistrali 1-wire
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


module OW_READ(input CLK,RST,RX_ACT,Z,BUS_IN,CRC_RST,CRC_EN,
               output reg DONE,LD,
               output BUS_OUT,
               output reg [7:0] CRC,DATA,
               output [6:0] TIME_C);

reg  wire1_out,bus_in_sync;
reg [2:0] st;
reg [6:0] tc;
reg [2:0] cntr;

always @(posedge CLK) bus_in_sync<=BUS_IN;
assign in_CRC=bus_in_sync^CRC[0];

always@(posedge CLK)
begin
  if(~RST)  st<=0; else
  begin
   case(st) 
	3'd0: begin  DONE<=0; tc<=7'd0; LD<=1'b0;
	  cntr<=0; wire1_out<=1'b1;
	   if(RX_ACT) st<=3'd1;
	   if(CRC_RST) CRC<=8'd0; end
	3'd1: begin  wire1_out<=1'b0;
	   tc<=7'd0; LD<=1'b1;
	   if(Z) st<=3'd2; end
	3'd2: begin wire1_out<=1'b1;
	   st<=3'd3; LD<=1'b0;	 end
	3'd3: begin tc<=7'd0; LD<=1'b1;	  
	  if(Z) st<=3'd5; end
	3'd5: begin  LD<=1'b0; st<=3'd6; 
	  DATA<={bus_in_sync,DATA[7:1]}; 
	  if(CRC_EN) //(1)
          CRC<={in_CRC,CRC[7],CRC[6],CRC[5],
          CRC[4]^in_CRC,CRC[3]^in_CRC,CRC[2],CRC[1]};  end
	3'd6: begin tc<=7'd17; LD<=1'b1; if(Z) st<=3'd7; end
	3'd7: begin  LD<=1'b0; 
          if(cntr!=3'd7)  begin cntr<=cntr+1; st<=3'd1; end
	   else begin DONE<=1'b1; st<=3'd0; end
	end
   endcase
   end
end
 assign TIME_C=tc;
 assign BUS_OUT=wire1_out;
endmodule
