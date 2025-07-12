module cofre_digital2 (
    input wire clk,         // CLOCK_50 (50 MHz, pino P11)
    input wire reset,       // KEY0 (pino B8, lógica negativa)
    input wire A,           // SW9 (pino F15, lógica positiva: 0=Remoto, 1=Normal)
    input wire B,           // KEY1 (pino A7, lógica negativa)
    input wire [3:0] senha, // SW3-SW0 (pinos C12, D12, C11, C10)
    input wire SAF,         // SW4 (pino A12, Abertura Remota)
    input wire H,           // SW5 (pino B12, Chave de Emergência)
    input wire reset_senha, // SW8 (Resetar senha)
    output wire [6:0] display0, // HEX0
    output wire [6:0] display1, // HEX1
    output wire [6:0] display2, // HEX2
    output wire [6:0] display3, // HEX3
    output wire [6:0] display4, // HEX4
    output wire [6:0] display5, // HEX5
    output wire dp0,        // Ponto decimal de HEX0
    output wire dp1,        // Ponto decimal de HEX1
    output wire dp2,        // Ponto decimal de HEX2
    output wire dp3,        // Ponto decimal de HEX3
    output wire dp4,        // Ponto decimal de HEX4
    output wire dp5,        // Ponto decimal de HEX5
    output wire CLOSE,      // LEDR0 (pino A8, Atuador de fechamento)
    output wire abertura,   // LEDR1 (pino A9, Sinal de abertura)
    output wire SPA,        // LEDR2 (pino A10, Indica porta fechada/aberta)
    output wire SPN,        // LEDR3 (pino B10, Indica pino de fechamento)
	 output wire LED_SAF, 	 // LEDR4 (pino D13, Indica SAF ativado)
	 output wire LED_RS, 	 // LEDR8 (pino A11, Indica reset_senha ativado)
    output wire LED_A,      // LEDR9 (pino B11, Indica SW9 ativado)
	 output wire [2:0] estado_dbg,
    output wire [2:0] off_leds // LED 5-7 (LEDS não utilizados)
);

    wire reset_clean, B_clean;
    wire [2:0] estado_atual;
    
    reg B_sync, rst_sync, B_sync_d1, rst_sync_d1;
    reg B_clean_reg, reset_clean_reg;

    always @(posedge clk) begin
        B_sync      <= B;
        B_sync_d1   <= B_sync;
        
        rst_sync    <= reset;
        rst_sync_d1 <= rst_sync;
    end

    assign B_clean = B_sync & ~B_sync_d1;
    assign reset_clean = rst_sync_d1 & ~rst_sync;

    // Atribuir o sinal A diretamente aos LED_A, LED_SAF, LED_RS
    assign LED_A = A;
	 assign LED_SAF = SAF;
	 assign LED_RS = reset_senha;

    state_machine sm (
        .clk(clk), .reset(reset_clean), .A(A), .B(B_clean), .senha(senha),
        .SAF(SAF), .H(H), .reset_senha(reset_senha), 
        .estado_atual(estado_atual), .SPA(SPA), .SPN(SPN)
    );

    output_driver od (
        .clk(clk), .reset(reset_clean), .estado_atual(estado_atual),
        .display0(display0), .display1(display1), .display2(display2),
        .display3(display3), .display4(display4), .display5(display5),
        .dp0(dp0), .dp1(dp1), .dp2(dp2), .dp3(dp3), .dp4(dp4), .dp5(dp5),
        .CLOSE(CLOSE), .abertura(abertura)
    );

    assign estado_dbg = estado_atual;
    assign off_leds = 5'b00000; // LEDR5-LEDR9 não utilizados
endmodule