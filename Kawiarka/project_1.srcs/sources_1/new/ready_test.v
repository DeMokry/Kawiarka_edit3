`include "defines.v"

module sprawnosc(i_w,i_k,signal_s);


// i_w - ilosc wody
// i_k - iloœæ kawy
// i_m - iloœæ mleka
// m_k - mielenie kawy
// g_w - grzanie_wody

// signal_s - wyjœciowy sygna³

// deklaracja portów
output signal_s;
input i_w, i_k;

assign signal_s = i_w | i_k ;

endmodule
