`ifndef MY_DEFINES_SV
`define MY_DEFINES_SV
    `timescale 1us / 1ns
    
   
     // stany choose module - wyboru
          `define NIC          5'b00000 
         
          
    
    // Modu³ wyboru kawy
    
    `define k0  3'b000        // brak wyboru
    `define k1  3'b001        // kawa 1 esspresso
    `define k2  3'b010        // kawa 2 dubleesspresso
    `define k3  3'b011        // kawa 3 americana
    
   // MODU£ G£ÓWNY STANY
        `define czekam       4'b0000 
        `define wybieranie   4'b0001 // pobieranie wyboru
        `define mielenie     4'b0010    // mielenie kawy  
        `define podgrzewanie 4'b0011     // podgrzewanie wody
        `define sypanie      4'b0100      // sypanie kawy    
        `define zalewanie    4'b0101      //zalewanie gor¹c¹ wod¹
        `define czyszczenie  4'b0110    // czyszczenie
        `define napelnij     4'b0111 // nape³nij przewody
  
    
        
        
    // Sterowanie urz¹dzeniami
        `define CMD_ZERO                3'b000
        `define CMD_START               3'b001  // rozpocznij pracê
        `define CMD_GRIND_CAFFE         3'b010  // zmiel kawê
        `define CMD_CAFFE_POUR          3'b011  // syp kaw 
        `define CMD_WATER_BOIL          3'b100  // grzanie wody
        `define CMD_WATER_POUR          3'b101  // zalej gor¹c¹ wod¹
        `define CMD_FILL                3'b110  // nape³nij przewody
        `define CMD_CLEANING            3'b111  // czyœæ
        
       
    // MODU£U WYBORU - BUTTONY / KOMENDY
            `define CMD_NO       3'b000  //brak wyboru  
            `define CMD_K1       3'b001  //esspresso   
            `define CMD_K2       3'b010  //double esspresso   
            `define CMD_K3       3'b011  //amerykanska 
            `define CMD_RESET    3'b100 
    // konieczne
   //`define  CMD_RESET1   3'b101
  //  `define  CMD_RESET2   3'b110
  // `define  CMD_RESET3   3'b111
        
    // MODU£ WYBORU - odpowiedzi (return)
        `define  R_NO        2'b00
        `define  R_WORKING   2'b01
        
        `define  R_ERROR     2'b10
        `define  R_OK        2'b11
        //`define  ODP_RESET   2'b11
    
 
	
	// KOMENDY LICZNIKA
    `define LICZNIK_NULL        4'b0000
   // `define ODLICZ_KUBEK        4'b0001
    `define ODLICZ_K1     4'b0001
    `define ODLICZ_K2     4'b0010
    `define ODLICZ_K3    4'b0011
    `define ODLICZ_WODA_OP1     4'b0100
    `define ODLICZ_WODA_OP2     4'b0101
    `define ODLICZ_WODA_OP3     4'b0110
    `define ODLICZ_GRZANIE        4'b0111
    `define ODLICZ_NAPELNIJ     4'b1000
    `define ODLICZ_WSYP     4'b1001
    `define ODLICZ_CZYSZ     4'b1010
    `define LICZNIK_RESET       4'b1011
    
    // ODPOWIEDZI LICZNIKA
    `define NIC_NIE_ODLICZAM    1'b0
    `define SKONCZYLEM_ODLICZAC 1'b0
    `define ODLICZAM            1'b1
    
    // CZASY DLA POSZCZEGÓLNYCH OPCJI (w sekundach)
    // MODU£ PRZELICZY TO NA ODPOWIEDNI¥ LICZBÊ
    // UWZGLÊDNIAJ¥C CZÊSTOTLIWOŒÆ ZEGARA
    //`define CZAS_KUBEK          2
    `define CZAS_K1    4
    `define CZAS_K2    6
    `define CZAS_K3    4
    `define CZAS_WODA_OPCJA1    15
    `define CZAS_WODA_OPCJA2    30
    `define CZAS_WODA_OPCJA3    20
   // `define CZAS_MLEKO          30
    `define CZAS_GRZANIE    30
    `define CZAS_WSYP 5
    `define CZAS_NAPELNIJ         3
    `define CZAS_CZYSZ          5
    
    // wyœwietlacz - liczby i znaki
    `define W_0             4'b0000 // 0
    `define W_1             4'b0001 // 1
    `define W_2             4'b0010 // 2
    `define W_3             4'b0011 // 3
    `define W_4             4'b0100 // 4
    `define W_5             4'b0101 // 5
    `define W_6             4'b0110 // 6
    `define W_7             4'b0111 // 7
    `define W_8             4'b1000 // 8
    `define W_9             4'b1001 // 9
                    
    
    `define W_NULL          4'b1111 // nic
    
    
    `define W_MM           4'b1010 // middle
    `define W_A             4'b1011 // a
    `define W_E             4'b1100 // e
`endif