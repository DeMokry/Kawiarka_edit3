`include "defines.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2018 11:30:03 PM
// Design Name: 
// Module Name: choose_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module choose_module(
    input wire clk, // zegar
    input wire [2:0] cmd_in, // komenda wyboru
    output reg[1:0] cmd_out, // odpowiedz na komende
    output wire [4:0] stan_mm // przekazanie stanu(wyswietlacz)
    );
    
    parameter KAWA1 = `k1; // kawa 1 esspresso
    parameter KAWA2 = `k2; // kawa 2 dubleesspresso
    parameter KAWA3 = `k3; // kawa 3 americana
    
    reg [3:0]stan;                         // aktualny stan    
   // reg [4:0]n_stan;                       // nastêpny stan
   // reg [4:0]tmp;                          // zmienna tymczasowa potrzebna do obliczeñ
    
    assign stan_mm = stan;
    
       always @(cmd_in) // otrzymaliœmy komendê
            begin
              // n_stan = stan;  // przepisujemy stan do n_stan - potrzebne w przypadku, gdyby stan nie uleg³ zmianie (pêtelka)
                case (cmd_in)
                    `CMD_K1:
                        begin
                            stan <= KAWA1;             // przycisk kawa 1(stan) E
                            cmd_out <= `R_OK;
                            
                        end
                    `CMD_K2:
                        begin
                            stan <= KAWA2;             // przycisk kawa 2(stan) 2E
                            cmd_out <= `R_OK;
                        end
                    `CMD_K3:
                        begin
                            stan <= KAWA3;             // przycisk kawa 3(stan) A
                            cmd_out <= `R_OK;
                        end
   
                     `CMD_RESET:                         // reset pocz¹tkowy
                        if (cmd_out === 2'bxx)          // jeœli automat nie zosta³ zresetowany wczeœniej
                            begin
                                
                                stan = `R_NO;
                                cmd_out = 2'b00;
                                
                               // tmp = `R_NO;
                            end
                            
                            
               endcase
           end
           
      /*  always @(posedge clk)
        begin
          //  n_stan = stan;
            case(n_stan)
            KAWA1:
                  begin
                  stan <= KAWA1;             // przycisk kawa 1(stan) E
                  cmd_out <= `R_OK;
                  end
            KAWA2:
                 begin
                  stan <= KAWA2;             // przycisk kawa 2(stan) 2E
                  cmd_out <= `R_OK;
                  end
            KAWA3:
                  begin
                  stan <= KAWA3;             // przycisk kawa 3(stan) A
                  cmd_out <= `R_OK;
                  end
            `R_NO:                         // reset pocz¹tkowy
                 if (cmd_out === 2'bxx)          // jeœli automat nie zosta³ zresetowany wczeœniej
                   begin
                     stan = `R_NO;
                 //    n_stan = `R_NO;
                     cmd_out = 2'b00;
                                                  
                    
                   end
             endcase
     end
     
     always @(*)
             #1 begin
                 stan = n_stan ;                                // ustawiamy nastêpny stan
             end
             */
    endmodule

