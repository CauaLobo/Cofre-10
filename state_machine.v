module state_machine (
    input wire clk, reset,
    input wire A, B,              // A (modo: 0=remoto, 1=normal), B (botão de envio)
    input wire [3:0] senha,       // Senha digitada (SW3-SW0)
    input wire SAF, H, reset_senha,// SAF (chave remota), H (chave de emergência), reset_senha (resetar senha)
    output reg [2:0] estado_atual,// Estado atual da máquina
	 output reg [2:0] estado_anterior, // Estado anterior da máquina
    output wire SPA, SPN,         // Sinais de status (porta fechada/aberta, pino de fechamento)
    output reg [3:0] senha_armazenada // Senha armazenada
);

    // Definição dos estados
    localparam AB = 3'b000,  // Porta aberta
               AL = 3'b001,  // Modo fechado normal
               PF = 3'b010,  // Modo fechado remoto
               FE = 3'b011,  // Verificação de senha
               E1 = 3'b100,  // Erro 1 (primeira tentativa incorreta)
               E2 = 3'b101,  // Erro 2 (segunda tentativa incorreta)
               BL = 3'b110,  // Bloqueado
               EM = 3'b111;  // Emergência

    reg [2:0] prox_estado;
    reg modo_remoto_ativado;

    // Detector de borda de descida para B (equivalente a "enviar")
    reg B_antigo;
    wire pulso;

    // Sincronização do sinal A
    reg A_sync, A_sync_d1;
    wire A_clean;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            B_antigo <= 1'b1;
            A_sync <= 1'b0;
            A_sync_d1 <= 1'b0;
        end else begin
            B_antigo <= B;
            A_sync <= A;
            A_sync_d1 <= A_sync;
        end
    end

    assign pulso = (B_antigo == 1'b1 && B == 1'b0);
    assign A_clean = A_sync; // Sinal A sincronizado

    // Lógica sequencial
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            estado_atual <= FE;
				estado_anterior <= AL;
            senha_armazenada <= 4'b0000;
        end else begin
            estado_atual <= prox_estado;
				
				// atualizaçao do estado anterior
				if (prox_estado == FE && estado_atual == AL)
						estado_anterior <= AL;
				else if (prox_estado == FE && estado_atual == PF)
						estado_anterior <= PF;
				else if (prox_estado == AB || prox_estado == EM || prox_estado == E1 || prox_estado == E2 || prox_estado == BL)
						estado_anterior <= AL; 


            // Atualização da senha
            if (estado_atual == AL && pulso && reset_senha && !A_clean)
                senha_armazenada <= senha;

            // Controle do modo remoto
            if (estado_atual == PF && pulso)
                modo_remoto_ativado <= SAF;
            else if (prox_estado == AB)
                modo_remoto_ativado <= 1'b0;
        end
    end

    // Lógica combinacional de próxima transição
    always @(*) begin
        prox_estado = estado_atual;

        case (estado_atual)
            AB: begin
                if (pulso) begin
                    if (!A_clean)
                        prox_estado = AL;
                    else
                        prox_estado = PF;
                end
            end

            AL: begin
                if (A_clean) // Chave mudou para modo normal
                    prox_estado = PF;
                else if (pulso) // Modo remoto: apenas pulso leva a FE
                    prox_estado = FE;
                else
                    prox_estado = AL; // Garante que permanece em AL se nenhuma condição for atendida
            end

            PF: begin
                if (!A_clean) // Chave mudou para modo remoto
                    prox_estado = AL;
                else if (pulso && SAF) // Modo remoto com SAF ativo
                    prox_estado = FE;
                else
                    prox_estado = PF; // Garante que permanece em PF se nenhuma condição for atendida
            end

            FE: begin
                if (pulso) begin
                    if (modo_remoto_ativado && SAF)
                        prox_estado = AB;  // Modo remoto com SAF ativado
                    else if (modo_remoto_ativado && !SAF)
                        prox_estado = FE;  // Modo remoto sem SAF
                    else if (!modo_remoto_ativado && senha == senha_armazenada)
                        prox_estado = AB;  // Modo normal com senha correta
                    else if (!modo_remoto_ativado)
                        prox_estado = E1;  // Modo normal com senha incorreta
                
                end else begin
                    prox_estado = FE;  // Nenhuma condição atendida, permanece em FE
                end
            end

            E1: begin // Primeira tentativa
                if (pulso) begin
                    if (senha == senha_armazenada)
                        prox_estado = AB;
                    else
                        prox_estado = E2; // Segunda tentativa
                end
            end

            E2: begin
                if (pulso) begin
                    if (senha == senha_armazenada)
                        prox_estado = AB;
                    else
                        prox_estado = BL; // Bloqueio do Cofre
                end
            end

            BL: begin
                if (H)
                    prox_estado = EM; // Abertura emergencial do Cofre
            end

            EM: begin
					 prox_estado = EM;
            end

            default: prox_estado = AB;
        endcase
    end

    // Sinais de status
    assign SPA = (estado_atual == AL || estado_atual == PF || estado_atual == FE || estado_atual == E1 || estado_atual == E2 || estado_atual == BL); // Saida da maquina de estados
    
	 assign SPN = SPA; // sinal informativo se o pino esta fechado nao afeta a maquina de estados

endmodule