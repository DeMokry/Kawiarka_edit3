`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2018 12:29:16
// Design Name: 
// Module Name: main
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


module main(
    //input wire [2:0]mon_in,
    input wire [2:0]panel_przyciskow_in,
    input wire i_k, i_w,
    input wire clk, 
    
   // output wire [2:0] mon_out,       // zwrot monet
    output wire [2:0] urzadzenia,
    output wire [3:0] segment_out,   // wskaŸnik wyœwietlanej liczby (0-wyœwietlany, 1-zgaszony)
    output wire seg_um,              // góra, œrodek
    output wire seg_ul,              // góra, lewo
    output wire seg_ur,              // góra, prawo
    output wire seg_mm,              // œrodek, œrodek
    output wire seg_dl,              // dó³, lewo
    output wire seg_dr,              // dó³, prawo
    output wire seg_dm,              // dól, œrodek
    output wire seg_dot              // kropka
    
    );
    // pod³¹czamy modu³ sprawnosci
    wire sprawnosc_out;
    sprawnosc ready_test(.i_k(i_k), .i_w(i_w), .signal_s(sprawnosc_out));
    
    //dzielnik czestotliwoœci
    wire clk_div;
    divider #(1) dzielnik(.clk(clk), .clk_div(clk_div));
    
    //modu³ wyboru
    parameter KAWA1 = `k1;				 //esspresso
    parameter KAWA2 = `k2;              // double esspresso
    parameter KAWA3 = `k3;              // amerykanska
    wire [2:0]cmd_out;
    wire [1:0]cmd_in;
    wire [4:0]stan_mm;
    choose_module #(.KAWA1(KAWA1), .KAWA2(KAWA2), .KAWA3(KAWA3)) wybor(.clk(clk_div), .cmd_in(cmd_out),
       .cmd_out(cmd_in), .stan_mm(stan_mm));
    
    // licznik
    parameter tick_every = 20;              // pozwoli dostosowaæ czasy do zegaru (oraz przyspieszyæ symulacjê ;] )
    wire licz_in;
    wire [3:0]licz_out;
    wire [6:0]count_secs;
    counter #(.tick_every(tick_every)) licznik(.clk(clk_div), .count_out(licz_in), .count_in(licz_out), .count_secs(count_secs));
    
    // wyswietlacz
    wire [4:0]L_1, L_2, L_3, L_4;
    wyswietlacz_4x7 wyswietlacz(.clk(clk), .L_1(L_1), .L_2(L_2), .L_3(L_3), .L_4(L_4),
            .seg_um(seg_um), .seg_ul(seg_ul), .seg_ur(seg_ur), .seg_mm(seg_mm),
            .seg_dm(seg_dm), .seg_dl(seg_dl), .seg_dr(seg_dr), .seg_dot(seg_dot), .segment_out(segment_out));
    
    // pod³¹czenie starego main
    wire [2:0]u;
    mdk_main old_main(.sprawnosc_in(sprawnosc_out), .panel_przyciskow_in(panel_przyciskow_in), .clk_div(clk_div), 
                    .cmd_out(cmd_out), .cmd_in(cmd_in), .stan_mm(stan_mm), .licz_in(licz_in), .licz_out(licz_out), .count_secs(count_secs),
                    .L_1(L_1), .L_2(L_2), .L_3(L_3), .L_4(L_4),
                    
                    .urzadzenia(urzadzenia) );

    
endmodule
