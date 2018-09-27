   //////////////////////////////////////////////////////////////////////////////////
//
// Przyk³adowa aplikacja z modu³ami obs³ugi magistrali 1-wire
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

module ow_test(input CLK_50MHZ,
               input BTN_SOUTH,BTN_WEST,BTN_EAST,BTN_NORTH,
               output LCD_E,LCD_RS,LCD_RW,
               inout [7:0] LCD_DB,
               output [7:0] LED,
               inout [4:0] J18_IO);

reg [3:0] ss;
reg clk_1MHz,WR_EN;
reg [4:0] ct;
wire [7:0] LCD_BUS;
reg [8:0] DATA_IN;
reg ds_ack;
wire ds_rdy;
wire [7:0] byte0,byte1;
wire rst_status,bus_in;
wire [7:0] b2b_data_in,b2b_data_out;
reg b2b_start;
wire b2b_done;
reg [3:0] frac;

bufif0 (J18_IO[4],1'b0,bo);
assign bus_in=J18_IO[4];

debouncer d1(.clk(CLK_50MHZ),
             .PB({BTN_SOUTH,BTN_WEST,BTN_EAST,BTN_NORTH}),
             .BUTTONS({sw1,sw2,sw3,sw4}));

lcd_putchar d2(.CLK_1MHZ(clk_1MHz),.CLK_WR(CLK_50MHZ),
               .WR_EN(WR_EN),.RST(~sw1),.BF(BUSY_FLAG),
               .DATA_IN(DATA_IN),.LCD_E(LCD_E),.LCD_RS(LCD_RS),
               .LCD_RW(LCD_RW),.LCD_DB(LCD_BUS));
				 		 
DS18B20 rtemp(.CLK(CLK_50MHZ),.CLK_1MHZ(clk_1MHz),.RST(reset),
              .BUS_IN(bus_in),.ACK(ds_ack),.BUS_OUT(bo),
              .OW_RST_STAT(rst_status),.RDY(ds_rdy),
              .BYTE0(byte0),.BYTE1(byte1));

bin2bcd #(.NO_BITS_IN(8),.NO_BCD_DIGITS(2),.BIT_CNT_WIDTH(3))
         cr(.clk(CLK_50MHZ),.start(b2b_start),.done(b2b_done),
            .data_in(b2b_data_in),.data_bcd(b2b_data_out));

assign reset=~sw1;
assign LCD_DB=LCD_RW?8'hzz:LCD_BUS;
assign BUSY_FLAG=LCD_DB[7];
assign b2b_data_in={1'b0,byte1[2:0],byte0[7:4]};

always @(*) //(1)
 case(byte0[3:0])
  0,1: frac=0;
  2:   frac=1;
  3,4: frac=2;
  5:   frac=3;
  6,7: frac=4;
  8,9: frac=5;
  10:  frac=6;
  11,12: frac=7;
  13:    frac=8;
  14,15: frac=9;
 endcase

always @(posedge CLK_50MHZ)
if(sw1) ss<=0;
else
 case(ss) //(2)
   0: begin WR_EN<=0; ds_ack<=0; DATA_IN<=9'h001; ss<=1; end
   1: begin WR_EN<=1; ss<=2;end
   2: begin WR_EN<=0; if(ds_rdy) ss<=3;end 
   3: begin b2b_start<=1; ss<=4; DATA_IN<=9'h080; end
   4: begin b2b_start<=0; ss<=5; end
   5: begin  if(b2b_done) ss<=6; end
   6: begin WR_EN<=1; ss<=7; end
   7: begin WR_EN<=0; DATA_IN<={5'b10011,b2b_data_out[7:4]}; ss<=8; end
   8: begin WR_EN<=1; ss<=9; end
   9: begin WR_EN<=0; DATA_IN<={5'b10011,b2b_data_out[3:0]}; ss<=10; end
  10: begin WR_EN<=1; ss<=11; end
  11: begin WR_EN<=0; ss<=12; DATA_IN<=9'h12e; end
  12: begin WR_EN<=1; ss<=13; end
  13: begin WR_EN<=0; ss<=14; DATA_IN<={5'b10011,frac}; end
  14: begin WR_EN<=1; ss<=15; ds_ack<=1; end
  15: begin WR_EN<=0; ss<=2; ds_ack<=0; end  
 endcase

assign LED=byte0;

always @(posedge CLK_50MHZ) 
 if (ct<24) ct<=ct+1;
 else begin ct<=0; clk_1MHz<=~clk_1MHz; end

endmodule
