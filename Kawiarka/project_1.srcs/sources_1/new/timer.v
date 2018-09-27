   //////////////////////////////////////////////////////////////////////////////////
//
// Kod modu³u czasowego dla obs³ugi magistrali 1-wire
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


module TIMER(input [6:0] DATA,
             input LD,CLK,
             output reg Z);
reg mLD,done;
reg[6:0] cntr;
reg [2:0] div;
wire cntr0;

assign cntr0=|cntr;

always @(posedge CLK)
begin
 mLD<=LD;
 if(LD&&~mLD) //(1)
 begin cntr<=DATA; Z<=1'b0; div<=1'b0; done<=0; end
 else
 begin
   div<=div+1;
   if(div==3'd5) //(2)
   begin  
    div<=0;
    if(cntr0) cntr<=cntr-1; 
    else if(~done) begin Z<=1'b1; done<=1'b1; end
   end
 end
  if(done) Z<=1'b0; //(3)
end
endmodule
