`include "defines.v"

module sprawnosc(i_w,i_k,signal_s);


// i_w - ilosc wody
// i_k - ilo�� kawy
// i_m - ilo�� mleka
// m_k - mielenie kawy
// g_w - grzanie_wody

// signal_s - wyj�ciowy sygna�

// deklaracja port�w
output signal_s;
input i_w, i_k;

assign signal_s = i_w | i_k ;

endmodule
