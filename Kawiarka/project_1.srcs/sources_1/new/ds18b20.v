`timescale 1ns / 1ps

module DS18B20(input CLK,       //sygna³ taktuj¹cy
CLK_1MHZ,                       //sygna³ taktuj¹czy o czêstotliwoœci 1MHz
RST,                            //Wejœcie zeruj¹ce (aktywny poziom niski)
BUS_IN,                         //wejsæie danych magistrali 1-wire
ACK,                            //Sygna³ potwierdzenia odczytu temperatury.
                                // Narastaj¹ce zbocze na tym wejœciu powoduje wzerowanie wyjœcia RDY
                                // oraz rozpoczêcie nowego pomiaru temp
               output BUS_OUT,  //Wyjœcie danych magistrali 1-wire
               OW_RST_STAT,     //Wyjœcie sttusu bloku generowania sygna³u zeruj¹cego (mo¿e byæ ignorowany)
               output reg RDY,  //Poziom wysoki oznacza, ¿e na wyjœciach BYTE0 i BYTE1 jest dostêpna nowa wartoœæ temperatury
               output reg [7:0] BYTE0,BYTE1); //Dwa pierwsze bajty pamiêci notatnikowej termometru DS18B20 zwieraj¹ce informacjê o temperaturze
					
wire [7:0] crc,rd_data;
wire [6:0] tc,tc1,tc2,tc3;
wire ld1,ld2,ld3,rst_done;
reg [4:0] st;
reg [7:0] temp_data;
reg reset_crc,wire1_rst,rx_act,tx_act,crc_enable;
wire bus_out1,bus_out2,bus_out3,wr_done,rd_done,load,zero;
reg [2:0] wr_cnt;
reg ack_sync,temp_ack;
reg temp_rdy,temp_rdy_sync;

TIMER w1t(.DATA(tc),.LD(load),.Z(zero),.CLK(CLK_1MHZ));

OW_READ w1rd(.RST(RST),.CLK(CLK_1MHZ),.DATA(rd_data),
             .RX_ACT(rx_act),.Z(zero),.LD(ld3),.CRC_RST(reset_crc),
             .DONE(rd_done),.TIME_C(tc3),.BUS_OUT(bus_out3),.BUS_IN(BUS_IN),
             .CRC(crc),.CRC_EN(crc_enable));

OW_WRITE w1wr(.RST(RST),.CLK(CLK_1MHZ),.DATA(temp_data),
              .TX_ACT(tx_act),.Z(zero),.LD(ld2),
              .DONE(wr_done),.TIME_C(tc2),.BUS_OUT(bus_out2));

OW_RESET w1rst(.RST(RST),.CLK(CLK_1MHZ),.TIME_C(tc1),.LD(ld1),
               .RST_ACT(wire1_rst),.Z(zero),.DONE(rst_done),
               .BUS_IN(BUS_IN),.BUS_OUT(bus_out1),.STAT(OW_RST_STAT));

assign tc=tc1|tc2|tc3;
assign BUS_OUT=bus_out1&bus_out2&bus_out3;
assign load=ld1|ld2|ld3;

always @(posedge CLK_1MHZ)
if(~RST) st<=0; 
else
  begin
     case (st)	//(1)
       0: begin
	    wire1_rst<=1'b0; rx_act<=1'b0; tx_act<=1'b0;    
	    crc_enable<=1'b0; reset_crc<=1'b0; st<=1; temp_rdy<=1'b0; end
       1: begin wire1_rst<=1'b1; st<=2; end
       2: begin wire1_rst<=1'b0; if(rst_done) st<=3; end	
       3: begin temp_data<=8'hcc; tx_act<=1'b1; st<=4; end	 		
       4: begin tx_act<=1'b0; if(wr_done) st<=5; end	 		
       5: begin temp_data<=8'h44; tx_act<=1'b1; st<=6; end	 		 
       6: begin tx_act<=1'b0; if(wr_done) st<=7; end	 		
       7: begin rx_act<=1'b1; st<=8; end	 		
       8: begin rx_act<=1'b0; if(rd_done) st<=9; end	 		
       9: begin if(rd_data[7]==1'b0) st<=7; else st<=10; end	 		
      10: begin wire1_rst<=1'b1; st<=11; end	 		
      11: begin wire1_rst<=1'b0; if(rst_done) st<=12; end	 		
      12: begin temp_data<=8'hcc; tx_act<=1'b1; st<=13; end	 		
      13: begin tx_act<=1'b0; if(wr_done) st<=14; end	 		
      14: begin temp_data<=8'hbe; tx_act<=1'b1; st<=15; end	 		
      15: begin tx_act<=1'b0; reset_crc<=1'b1; if(wr_done) st<=16; end	 		
      16: begin reset_crc<=1'b0; crc_enable<=1'b1; wr_cnt<=3'd0; st<=17; end
      17: begin rx_act<=1'b1; st<=18; end	 		
      18: begin rx_act<=1'b0; if(rd_done) st<=19; end	 		
      19: begin st<=23;
	    if(wr_cnt==3'd0) BYTE0<=rd_data; else
           if(wr_cnt==3'd1) BYTE1<=rd_data;	end	
      20: begin  rx_act<=1'b1; crc_enable<=1'b0; st<=21;	end
      21: begin  rx_act<=1'b0; if(rd_done) st<=22; end	 		
      22: begin  if(crc==rd_data) st<=24; else st<=10; end
      23: begin
           if(wr_cnt!=3'd7) begin wr_cnt<=wr_cnt+1; st<=17; end
           else st<=20; end
      24: begin  temp_rdy<=1; if(ack_sync) st<=0; end	 		
    endcase		 
  end

always @(posedge CLK_1MHZ) //(2)
 if(~RST) ack_sync<=0; 
 else  ack_sync<=temp_ack;
    
always @(posedge CLK) //(3)
 if(~RST) begin RDY<=0; temp_ack<=0; end
 else
 begin
   temp_rdy_sync<=temp_rdy;
   if(temp_ack&~temp_rdy_sync) temp_ack<=0;
   if(temp_rdy_sync&~temp_ack) RDY<=1;
   if(ACK) begin temp_ack<=1; RDY<=0; end
 end
 

endmodule


