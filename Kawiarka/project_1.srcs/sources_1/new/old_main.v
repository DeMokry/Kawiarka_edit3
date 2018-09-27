

`include "defines.v"


//////////////////////////////////////////////////////////////////////////////////
// Company: WSIZ Copernicus
// Engineer: Rafa³ B., Szymon S., Darek B.
// 
// Create Date: 25.04.2017 18:46:49
// Design Name:  
// Module Name: mdk
// Project Name: Maszyna do kawy 
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


module mdk_main(
    //input wire clk,                         // zegar
    input wire clk_div,                     // zegar z dzielnika czêstotliwoœci
    // sygna³ z przycisków
    input wire [2:0]panel_przyciskow_in,    // przyciski - wybór kawy 
    // czujnik sprawnoœci maszyny 
    input wire sprawnosc_in,                // czujnikami zajmie siê inny modu³ - tu wystarczy sygna³: 0-sprawny, 1-niesprawny
    // licznik
    input wire licz_in,                     // 0 - stoi, 1 - liczy
    input wire [6:0] count_secs,            // potrzebne do wyœwietlacza - iloœæ pozosta³ych sekund                    
    output reg [3:0] licz_out,              // wyjœcie do licznika        
    // sterowanie modu³em monet
   input wire[1:0]cmd_in,                  // odpowiedz na komende z modu³u wyboru
    input wire[4:0]stan_mm,                 // potrzebne do obs³ugi wyœwietlacza
   output reg [2:0]cmd_out,                // komenda do modu³u wyboru
    // wyœwietlacz
    output reg [4:0] L_1,                // segment 1
    output reg [4:0] L_2,                // segment 2
    output reg [4:0] L_3,                // segment 3
    output reg [4:0] L_4,                // segment 4
    // sterowanie poszczególnymi etapami parzenia kawy - do zmiany na [2:0]
    output reg [2:0]urzadzenia              // sterowanie urz¹dzeniami
                                            // 000 - nic nie pracuje
    //output reg kubek,                     // 001 - podstawienie kubka
    //output reg woda,                      // 010 - w³¹czanie dozowania wody
    //output reg kawa,                      // 011 - w³¹czanie m³ynka do kawy
    //output reg mleko                      // 100 - w³¹czanie dozowania mleka (spieniacz)
    );
    
    
    parameter KAWA_1 = `k1;				// cena opcji 1 (3.00z³ - expresso)
    parameter KAWA_2 = `k2;				// cena opcji 2 (5.00z³ - expresso grande :P )
    parameter KAWA_3 = `k3;				// cena opcji 3 (7.50z³ - cappucino :P )
    
    parameter tick_every = 20;              // pozwoli dostosowaæ czasy do zegaru (oraz przyspieszyæ symulacjê ;] )

    // ³¹czymy modu³y
    // pod³¹czamy modu³ monet
    //^ modul_monet #(.CENA_OP1(CENA_OP1), .CENA_OP2(CENA_OP2), .CENA_OP3(CENA_OP3)) wrzut_zwrot(.clk(clk_div), .cmd_in(cmd_out), .cmd_out(cmd_in), .stan_mm(stan_mm));
    // pod³¹czamy modu³ sprawnosci
    //^ sprawnosc spr_test(.signal_s(sprawnosc_in));
    // pod³¹czamy modu³ licznika
    //^ counter #(.tick_every(tick_every)) licznik(.clk(clk_div), .count_out(licz_in), .count_in(licz_out), .count_secs(count_secs));
    // pod³¹czamy modu³ wyœwietlacza
    //^ wyswietlacz_4x7seg wys_pan(.clk(clk), .L_1(L_1), .L_2(L_2), .L_3(L_3), .L_4(L_4));
    // pod³¹czamy dzielnik czêstotliwoœci
    //^ divider #(1) div(.clk(clk), .clk_div(clk_div));

    reg [4:0]stan_main, stan_n;              // stan i nastêpny stan modu³u g³ównego
    
    function [9:0]licznikNaLiczby;
        input reg [6:0] count_secs;
        integer a,b;
        begin
            b = count_secs / 10;
            a = count_secs - (b*10);
            licznikNaLiczby = {b[4:0],a[4:0]};
            $strobe("strobe  count_secs:%b(%0d) a:%b(%0d) b:%b(%0d) @ %0t", count_secs, count_secs, b[4:0], b[4:0], a[4:0], a[4:0], $time);
        end
    endfunction 
    
    
    always @(panel_przyciskow_in)
        #1 begin
            if (panel_przyciskow_in == `CMD_RESET && cmd_in === 2'bXX) // automat nic nie robi - reset pocz¹tkowy
                begin
                    // ustawienia poczatkowe
                    stan_main = 0;
                    stan_n = 0;
                    urzadzenia = `NIC;
                    
                    licz_out = `LICZNIK_RESET;  // resetujemy licznik
                    // reset wyswietlacza
                    L_1 = 5'b00000;
                    L_2 = 5'b00000;
                    L_3 = 5'b00000;
                    L_4 = 5'b00000;
                end
            if (sprawnosc_in == 1'b0) begin     // sterowanie dostêpne tylko w przypadku sprawnej maszyny
                case (panel_przyciskow_in)
                    `CMD_K1: // wciœniêto przycisk wyboru opcji 1
                        if(cmd_in == `R_NO)   // jeœli modu³ nic nie robi
                            begin
                                cmd_out = `CMD_K1; // rozpoczynamy pobór monet
                                stan_n = `wybieranie;
                            end
                    `CMD_K2: // wciœniêto przycisk wyboru opcji 2
                        if(cmd_in == `R_NO)   // jeœli modu³ nic nie robi
                            begin
                                cmd_out = `CMD_K2; // rozpoczynamy pobór monet
                                stan_n = `wybieranie;
                            end
                    `CMD_K3: // wciœniêto przycisk wyboru opcji 3
                        if(cmd_in == `R_NO)   // jeœli modu³ nic nie robi
                            begin
                                cmd_out = `CMD_K3; // rozpoczynamy pobór monet
                                stan_n = `wybieranie;
                            end
                    `CMD_RESET:
                        begin
                                cmd_out = `CMD_RESET;
                                stan_n = `czekam;
                            end
                            
                        
                endcase
            end
            stan_main <= stan_n;
        end
        always @(licz_in)
            begin
                if (licz_in == `SKONCZYLEM_ODLICZAC)
                    begin
                        case (stan_main)  
                        `napelnij:
                            begin
                            stan_n = `mielenie;
                            case(cmd_out)
                                `CMD_K1: begin licz_out <= `ODLICZ_K1; end
                                `CMD_K2: begin licz_out <= `ODLICZ_K2; end
                                `CMD_K3: begin licz_out <= `ODLICZ_K3; end
                            endcase
                            urzadzenia <= `CMD_GRIND_CAFFE;
                            end
                        `mielenie:
                             begin 
                             stan_n = `podgrzewanie;
                             licz_out <= `ODLICZ_GRZANIE;
                             urzadzenia <= `CMD_WATER_BOIL;
                            end
                           `podgrzewanie:
                             begin
                             stan_n = `sypanie;
                             licz_out <= `ODLICZ_WSYP;
                             urzadzenia <= `CMD_CAFFE_POUR;
                            end
                         `sypanie:
                             begin
                             stan_n = `zalewanie;
                             case(cmd_out)
                               `CMD_K1: begin licz_out <= `ODLICZ_WODA_OP1; end
                               `CMD_K2: begin licz_out <= `ODLICZ_WODA_OP2; end
                               `CMD_K3: begin licz_out <= `ODLICZ_WODA_OP3; end
                              endcase
                             urzadzenia <= `CMD_WATER_POUR;
                            end
                         `zalewanie:
                             begin
                             stan_n = `czyszczenie;
                             licz_out <= `ODLICZ_CZYSZ;
                             urzadzenia <= `CMD_WATER_POUR;
                            end
                          `czyszczenie:
                            begin
                            stan_n = `czekam;
                            licz_out <= `LICZNIK_NULL;
                            urzadzenia <= `CMD_ZERO;
                           end
                   endcase
               end
         stan_main <= stan_n;
    end
                           
                     
                            
            
        always @(cmd_in) // odpowiedŸ z modu³u wyboru
            begin
                stan_n = stan_main;
                case (stan_main)
                    `wybieranie:
                        begin
                            if ( cmd_in == `R_OK) // zkoñczono pobór op³aty gdy brak resetu
                                begin 
                                    stan_n <= `napelnij;
                                    licz_out <= `ODLICZ_NAPELNIJ;
                                    urzadzenia <= `CMD_FILL;
                                end
                        end
                endcase
            end
            
            
            
        always @(posedge clk_div)  // g³owna czêœæ
            begin
                stan_n <= stan_main;
                case (stan_main)
                    `czekam:    
                        begin // NIC SIE NIE DZIEJE - PUSTY WYSWIETLACZ
                            {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b0,`W_NULL,1'b0,`W_NULL,1'b0,`W_NULL};
                    
                        end
            /*
                   `napelnij:     // wype³nianie przewodów wod¹
                        begin
                           {L_1,L_2,L_3,L_4} <= {1'b0,`W_MM,1'b0,`W_MM,licznikNaLiczby(count_secs)};
                        end         
                    `mielenie:            // mielenie kawy
                        begin
                           {L_1,L_2,L_3,L_4} <= {1'b0,`W_2,1'b0,`W_MM,licznikNaLiczby(count_secs)};
                       end
                    `podgrzewanie:            // podgrzewanie wody
                        begin
                            {L_1,L_2,L_3,L_4} <= {1'b0,`W_3,1'b0,`W_MM,licznikNaLiczby(count_secs)};
                        end
                    `sypanie:        // sypanie kawy
                        begin
                            {L_1,L_2,L_3,L_4} <= {1'b0,`W_4,1'b0,`W_MM,licznikNaLiczby(count_secs)};
                        end
                    `zalewanie:         // zalewanie gor¹c¹ wod¹
                        begin
                            {L_1,L_2,L_3,L_4} <= {1'b0,`W_MM,1'b0,`W_MM,licznikNaLiczby(count_secs)};
                        end
                    `czyszczenie:  // czyszczenie
                        begin
                            {L_1,L_2,L_3,L_4} <= {1'b0,`W_4,1'b0,`W_MM,licznikNaLiczby(count_secs)};
                        end
             */           
                    `wybieranie:
                        begin
                        case(stan_mm)
                        `k1:
                           begin // kawa E
                              {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_NULL,1'b0,`W_NULL,1'b0,`W_E};
                           end
                         `k2:
                            begin // kawa 2E
                              {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_NULL,1'b0,`W_2,1'b0,`W_E};
                            end
                         `k3:
                            begin // kawa A
                               {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_NULL,1'b0,`W_NULL,1'b0,`W_A};
                            end
                        endcase  
                        end
                    endcase
               end
           
        always @(negedge clk_div)
            begin
                if (cmd_out == `CMD_RESET && cmd_in == `R_NO) 
                    begin
                        cmd_out <= `CMD_NO;        // zerowanie linii komend po wstêpnym resecie
                        licz_out <= `LICZNIK_NULL;  // zerowanie linii komend licznika po wstepnym resecie
                        stan_n = `czekam;          // zerowanie stanu maszyny
                    end
              if (cmd_out == `CMD_NO && stan_main != `czekam) 
                                        stan_n = `czekam; 
                                    stan_main <= stan_n;
            end
            
endmodule
