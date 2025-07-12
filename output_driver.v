module output_driver (
    input wire clk, reset,
    input wire [2:0] estado_atual,
	 input wire [2:0] estado_anterior,
    output reg [6:0] display0, // HEX0
    output reg [6:0] display1, // HEX1
    output reg [6:0] display2, // HEX2
    output reg [6:0] display3, // HEX3
    output reg [6:0] display4, // HEX4
    output reg [6:0] display5, // HEX5
    output reg dp0,        // Ponto decimal de HEX0
    output reg dp1,        // Ponto decimal de HEX1
    output reg dp2,        // Ponto decimal de HEX2
    output reg dp3,        // Ponto decimal de HEX3
    output reg dp4,        // Ponto decimal de HEX4
    output reg dp5,        // Ponto decimal de HEX5
    output reg CLOSE,      // LEDR0 (Atuador de fechamento)
    output reg abertura    // LEDR1 (Sinal de abertura)
);

    // Códigos de 7 segmentos (ativo baixo, [0]=a, [1]=b, [2]=c, [3]=d, [4]=e, [5]=f, [6]=g)
    parameter A = 7'b0001000;   // 'A'
    parameter B = 7'b0000011;   // 'B'
    parameter E = 7'b0000110;   // 'E'
    parameter F = 7'b0001110;   // 'F'
    parameter P = 7'b0001100;   // 'P'
    parameter L = 7'b1000111;   // 'L'
    parameter M = 7'b0101010;   // 'M' (aproximação: a, b, d, g)
    parameter ONE = 7'b1111001; // '1'
    parameter TWO = 7'b0100100; // '2'
    parameter OFF = 7'b1111111; // Apagado

    always @(posedge clk) begin
        if (reset) begin
            display0 <= OFF;
            display1 <= OFF;
            display2 <= OFF;
            display3 <= OFF;
            display4 <= OFF;
            display5 <= OFF;
            dp0 <= 1'b1;  // DP desativado
            dp1 <= 1'b1;  // DP desativado
            dp2 <= 1'b1;  // DP desativado
            dp3 <= 1'b1;  // DP desativado
            dp4 <= 1'b1;  // DP desativado
            dp5 <= 1'b1;  // DP desativado
            CLOSE <= 1'b0;
            abertura <= 1'b0;
        end else begin
            case (estado_atual)
                3'b000: begin // AB (Aberto)
                    display0 <= B;      // B
                    display1 <= A;      // A
                    display2 <= OFF;
                    display3 <= OFF;
                    display4 <= OFF;
                    display5 <= OFF;
                    CLOSE <= 1'b0;
                    abertura <= 1'b1;
                end
                3'b001: begin // AL (Abertura Local)
                    display0 <= E;
                    display1 <= F;
                    display2 <= OFF;
                    display3 <= OFF;
                    display4 <= L;      // L
                    display5 <= A;      // A
                    CLOSE <= 1'b1;
                    abertura <= 1'b0;
                end
                3'b010: begin // PF (Programação Remota)
                    display0 <= E;
                    display1 <= F;
                    display2 <= OFF;
                    display3 <= OFF;
                    display4 <= F;      // F
                    display5 <= P;      // P
                    CLOSE <= 1'b1;
                    abertura <= 1'b0;
                end
                3'b011: begin // FE (Fechado)
						  if (estado_anterior == 3'b001) begin // Veio de AL
							display0 <= E;
							display1 <= F;
							display2 <= OFF;
							display3 <= OFF;
							display4 <= OFF;
							display5 <= OFF;
							end else if (estado_anterior == 3'b010) begin // Veio de PF
							display0 <= E;
							display1 <= F;
							display2 <= OFF;
							display3 <= OFF;
							display4 <= F;
							display5 <= P;
							end else begin // Caso padrão (se estado_anterior for inválido)
							display0 <= E;
							display1 <= F;
							display2 <= OFF;
							display3 <= OFF;
							display4 <= OFF;
							display5 <= OFF;
							end
							CLOSE <= 1'b1;
							abertura <= 1'b0;
                end
                3'b100: begin // E1 (Erro 1)
                    display0 <= E;
                    display1 <= F;
                    display2 <= ONE;    // 1
                    display3 <= E;      // E
                    display4 <= OFF;
                    display5 <= OFF;
                    CLOSE <= 1'b1;
                    abertura <= 1'b0;
                end
                3'b101: begin // E2 (Erro 2)
                    display0 <= E;
                    display1 <= F;
                    display2 <= TWO;    // 2
                    display3 <= E;      // E
                    display4 <= OFF;
                    display5 <= OFF;
                    CLOSE <= 1'b1;
                    abertura <= 1'b0;
                end
                3'b110: begin // BL (Senha Bloqueada)
                    display0 <= E;
                    display1 <= F;
                    display2 <= L;      // L
                    display3 <= B;      // B
                    display4 <= OFF;
                    display5 <= OFF;
                    CLOSE <= 1'b1;
                    abertura <= 1'b0;
                end
                3'b111: begin // EM (Emergência)
                    display0 <= B;
                    display1 <= A;
                    display2 <= M;      // M
                    display3 <= E;      // E
                    display4 <= OFF;
                    display5 <= OFF;
                    CLOSE <= 1'b0;
                    abertura <= 1'b1;
                end
                default: begin
                    display0 <= OFF;
                    display1 <= OFF;
                    display2 <= OFF;
                    display3 <= OFF;
                    display4 <= OFF;
                    display5 <= OFF;
                    CLOSE <= 1'b0;
                    abertura <= 1'b0;
                end
            endcase
            dp0 <= 1'b1;  // DP desativado
            dp1 <= 1'b1;  // DP desativado
            dp2 <= 1'b1;  // DP desativado
            dp3 <= 1'b1;  // DP desativado
            dp4 <= 1'b1;  // DP desativado
            dp5 <= 1'b1;  // DP desativado
        end
    end
endmodule