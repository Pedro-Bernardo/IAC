
; Programa projeto.as

; 	Zona I: Definição das constantes

				ORIG	8000h
WindowControl	EQU		FFFCh
WindowWrite		EQU		FFFEh
Temporizador_I	EQU     FFF7h
Temporizador_V	EQU     FFF6h
SP_INIT			EQU		FDFFh
INT_MASK_ADDR	EQU		FFFAh
INT_MASK 		EQU		1100000000011111b
RandomMask     	EQU     1000000000010110b
LOWER_EDGE		EQU     1700h
RIGHT_EDGE 		EQU 	78
END_Vetor		EQU 	'@'
Max_Lasers		EQU		50
Asteroide       EQU 	'*'
Black 			EQU     'O'
Laser 			EQU     '-'
L_VarTexto1		EQU     10
L_VarTexto2		EQU     16
L_VarTexto3		EQU     11
L_VarTexto4		EQU     11
LCDControl		EQU 	FFF4h
LCDWrite 		EQU 	FFF5h
Display			EQU 	FFF0h



; 	ZONA II: definicao de variaveis
; Posicao da nave
POS 			WORD		0503h 

; Posicao dos asteroides
POS_Ast			TAB 	14

; Posicao dos buracos negros
POS_Black		TAB 	7

;Posicao dos lasers
Num_Lasers		WORD	0
POS_L			TAB 	77

T_Cria 			WORD	1
T_Cria_Black	WORD	31
T_Ast 			WORD	1

Velocidade		WORD	0001h
F_Baixo			WORD	0001h
F_Cima			WORD	0001h
F_Esquerda		WORD	0001h
F_Direita		WORD	0001h
F_Dispara		WORD	0001h
F_Tempo			WORD 	0001h
F_Asteroide		WORD 	0001h
F_Laser_C		WORD	0001h
F_Inicio		WORD	0001h
F_Over			WORD	0001h
Ni_Random      	WORD    000Ch
Feed_Random 	WORD	0000h
Res 			TAB 	4
Pont 			WORD 	0000h
Ordem			WORD	0000h
VarTexto1 		STR		'Prepare se', END_Vetor
VarTexto2		STR	 	'Prima o botao IE', END_Vetor
VarTexto3		STR 	'Fim do jogo', END_Vetor
VarTexto4 		STR 	'Pontuacao: ', END_Vetor


; Atribuicao das Rotinas de tratamento
; das interrupçoes as respetivas

				ORIG 	FE00h
INT0			WORD	INT_Baixo
INT1			WORD	INT_Cima
INT2			WORD	INT_Esquerda
INT3			WORD	INT_Direita
INT4			WORD	INT_Dispara
INT5			WORD	INT_OVER
INT6			WORD	INT_OVER
INT7			WORD	INT_OVER
INT8			WORD	INT_OVER
INT9			WORD	INT_OVER
INT10			WORD	INT_OVER
INT11			WORD	INT_OVER
INT12			WORD	INT_OVER
INT13			WORD	INT_OVER
INT_E 			WORD	INT_Inicio
TEMP			WORD	INT_Tempo

				
; 	ZONA III: codigo

				ORIG	0000h
				JMP Inicio

;	ZONA III - 1: Rotinas de desenho

; Desenha o ecrã de jogo
;				Entradas: ---		
;				Saidas: -----
;				Efeito: -----
;				Descricao: Desenha a nave e desenha as bordas

DrawGame:		CALL DrawShip
				CALL DrawEdges
				RET


; DrawCharacter: Rotina que efectua a escrita de um caracter para o ecra.
;      			 O caracter pode ser visualizado na janela de texto.
;               Entradas: pilha - caracter a escrever e posicao
;               Saidas: ---
;               Efeitos: alteracao da posicao de memoria M[WindowControl] e M[WindowWrite]


DrawCharacter:	PUSH R1

				MOV R1, M[SP + 3]
				MOV M[WindowControl], R1		
				MOV R1, M[SP + 4]
				MOV M[WindowWrite], R1	

				POP R1
				RETN 2


; Desenha a nave
;				Entradas: ---
;				Saidas: -----
;				Efeito: -----
;				Descricao: Percorre os enderecos de memoria de POS ate POS + 3
;   					   (onde estao as coordenadas dos caracteres da nave)
;						   e desenha os caracteres nas respetivas 
DrawShip:		PUSH R1
				PUSH R2
				PUSH R3

				MOV R1, M[POS]
				MOV R3, 0100h

				MOV M[WindowControl], R1		;Coloca o cursor na posicao onde se vai desenhar o caractere '>'
				MOV R2, 003Eh
				MOV M[WindowWrite], R2			;Desenha o caractere '>'
				DEC R1
				MOV M[WindowControl], R1		;Coloca o cursor na posicao onde se vai desenhar o caractere '|'
				MOV R2, 0029h
				MOV M[WindowWrite], R2			;Desenha o caractere ')'
				ADD R1, R3
				MOV M[WindowControl], R1		;Coloca o cursor na posicao onde se vai desenhar o caractere '/'
				MOV R2, 002Fh
				MOV M[WindowWrite], R2			;Desenha o caractere '/'
				SUB R1, R3
				SUB R1, R3
				MOV M[WindowControl], R1		;Coloca o cursor na posicao onde se vai desenhar o caractere '\'
				MOV R2, 005Ch
				MOV M[WindowWrite], R2 			;Desenha o caractere '\'

				POP R3
				POP R2
				POP R1

				RET

; Desenha as bordas
;				Entradas: ---
;				Saidas: -----
;				Efeito: -----
;				Descricao: Coloca o caracter '#' na primeira e na ultima linha.
;						   Coloca um '#' na linha 0 e depois na linha 23, depois aumenta
;						   a coluna, e repete enquanto esta dentro dos limites da janela de
;						   texto (80 colunas).

DrawEdges:		PUSH R1
				PUSH R2
				PUSH R3

				MOV  R1, LOWER_EDGE	
				MOV  R3, R0
				MOV  R2, 0023h

DrawCicle:		MOV  M[WindowControl], R3		;Coloca o cursor na primeira posicao(0,0) da janela de texto, primeira linha e primeira colun
				MOV  M[WindowWrite], R2
				MOV  M[WindowControl], R1		;Coloca o cursor na posicao (24,0) da janela de texto, ultima linha e primeira coluna
				MOV  M[WindowWrite], R2
				INC  R1							;Incrementa a coluna
				MVBL R3, R1						;Copia os dois bits menos significativos de R1, que correspondem a coluna
				CMP  R3, RIGHT_EDGE				;Testa se ja chegou a ultima coluna
				BR.NZ DrawCicle					;Se nao e a ultima coluna, repete

				POP R3
				POP R2
				POP R1
				RET

; Desenha caracteres nas posicoes de uma tabela
;				Entradas: Stack
;				Saidas: -----
;				Efeito: -----
;				Descricao: Percorre os todos enderecos de memoria da tabela passada
;						   como parametro pelo stack e desenha o caracter tambem passado pelo stack
;						   na posicao corresponente ao que se encontra nesse endereco de memoria
Draw_ALL:		PUSH R1
				PUSH R2
				PUSH R3

				MOV R1, M[SP + 5]
				MOV R2, M[SP + 6]
				MOV R3, END_Vetor

				CMP M[R1], R3
				BR.NZ  Draw_ALL_Cic

				POP R3
				POP R2
				POP R1

				RETN 2

Draw_ALL_Cic:	PUSH R2
				PUSH M[R1]
				CALL DrawCharacter

				INC R1
				CMP M[R1], R3
				BR.NZ  Draw_ALL_Cic

				POP R3
				POP R2
				POP R1

				RETN 2

;	ZONA III - 2: Rotinas de apagar

; Apaga a nave 
;				Entradas: ---
;				Saidas: -----
;				Efeito: -----
;				Descricao: Substitui os caracteres da nave por ' '

ClearShip:		PUSH R1
				PUSH R2
				PUSH R3

				MOV R3, 0100h     				;Coloca a posicao anterior da nave em R3
				MOV R1, M[POS]
				MOV M[WindowControl], R1		;Substitui o caractere '>' por um ' '
				MOV R2, 0020h
				MOV M[WindowWrite], R2			;Desenha o ' ' 
				DEC R1
				MOV M[WindowControl], R1		;Substitui o caractere '|' por um ' '
				MOV M[WindowWrite], R2			;Desenha o ' ' 
				ADD R1, R3
				MOV M[WindowControl], R1		;Substitui o caractere '/' por um ' '
				MOV M[WindowWrite], R2			;Desenha o ' ' 
				SUB R1, R3
				SUB R1, R3
				MOV M[WindowControl], R1		;Substitui o caractere '\' por um ' '
				MOV M[WindowWrite], R2 			;Desenha o ' ' 

				POP R3
				POP R2
				POP R1
				RET

; Apaga o laser 
;				Entradas: ---
;				Saidas: -----
;				Efeito: -----
;				Descricao: Substitui os caracteres da nave por ' '

ClearObjeto:	PUSH R1
				PUSH R2
				
				MOV  R1, M[SP + 4]
				MOV  M[WindowControl], R1		;Substitui o caractere '-' por um ' '
				MOV  R2, 0020h
				MOV  M[WindowWrite], R2	

				POP  R2
				POP  R1	
				RETN 1

; Clear_All: Apaga todos os elementos de um vetor (da janela de texto)
;				Entradas: Stack
;				Saidas: -----
;				Efeito: -----
;				Descricao: Substitui os caracteres nas posicoes descritas na tabela,
;						   acedida atraves do stack, por ' '
Clear_All:		PUSH R1
				PUSH R2

				MOV R1, M[SP + 4]
				MOV R2, END_Vetor

				CMP M[R1], R2
				BR.NZ	Clear__Ciclo

				POP R2
				POP R1
				RETN 1

Clear__Ciclo: 	PUSH M[R1]
				CALL ClearObjeto

				INC R1
				CMP M[R1], R2
				BR.NZ	Clear__Ciclo

				POP R2
				POP R1

				RETN 1

; ClearEdges: Apaga as fronteiras de jogo
;				Entradas: Stack
;				Saidas: -----
;				Efeito: -----
;				Descricao: Substitui todos os # nas fronteiras do jogo por ' '

ClearEdges:		PUSH R1
				PUSH R2
				PUSH R3

				MOV  R1, LOWER_EDGE	
				MOV  R3, R0
				MOV  R2, ' '

ClearECicle:	MOV  M[WindowControl], R3		;Coloca o cursor na primeira posicao(0,0) da janela de texto, primeira linha e primeira colun
				MOV  M[WindowWrite], R2
				MOV  M[WindowControl], R1		;Coloca o cursor na posicao (24,0) da janela de texto, ultima linha e primeira coluna
				MOV  M[WindowWrite], R2
				INC  R1							;Incrementa a coluna
				MVBL R3, R1						;Copia os dois bits menos significativos de R1, que correspondem a coluna
				CMP  R3, RIGHT_EDGE				;Testa se ja chegou a ultima coluna
				BR.NZ ClearECicle					;Se nao e a ultima coluna, repete

				POP R3
				POP R2
				POP R1
				RET


; ApagaObjeto: Apaga um objeto (asteroide, laser ou buraco negro)
;			Entradas: Stack	
;			Saidas: ------
;			Efeito: Move os valoros guardados nos enderecos de memoria a seguir ao parametro 										
;					fornecido (stack), para tras, escrevendo por cima dele, ate chegar ao END_Vetor ('@')
;			


ApagaObjeto:	PUSH R1
				PUSH R2
				PUSH R3
				
				MOV R1, M[SP + 5]
				MOV R3, END_Vetor
				
ApagaCiclo:		MOV R2, M[R1 + 1]
				MOV M[R1], R2
				INC R1
				CMP M[R1], R3
				BR.NZ	ApagaCiclo

				MOV M[R1], R0
				
				POP R3
				POP R2
				POP R1

				RETN 1
				
;	ZONA III - 2: Rotinas de Strings

; EscString: Rotina que efectua a escrita de uma cadeia de caracter, terminada
;          pelo caracter END_Vetor
;               Entradas: Stack
;               Saidas: ---
;               Efeitos: ---

EscString:      PUSH    R1
                PUSH    R2
                PUSH 	R3
                PUSH 	R4

                MOV R3, RIGHT_EDGE
                MOV R4, M[SP + 7]
                MOV R2, M[SP + 6]
                
                SHR R3, 1
                SHR R4, 1

                SUB R3, R4
                ADD R3, M[SP + 8]

CicloA:         MOV     R1, M[R2]
                CMP     R1, END_Vetor
                BR.Z    FimEsc
                
                PUSH    R1
                PUSH 	R3
                CALL    DrawCharacter
                INC 	R3
                INC     R2
                BR      CicloA

FimEsc:         POP 	R4
				POP 	R3
				POP     R2
                POP     R1
                RETN 3

; ApagaString: Rotina que apaga de uma cadeia de caracteres, terminada
;          pelo caracter END_Vetor
;               Entradas: Stack
;               Saidas: ---
;               Efeitos: ---
;				Descricao: A escrita da string e feita na linha fornecida como parametro (stack)
;						   no centro do ecra

ApagaString:    PUSH    R1
                PUSH    R2
                PUSH 	R3
                PUSH 	R4

                MOV R3, RIGHT_EDGE
                MOV R4, M[SP + 7]
                MOV R2, M[SP + 6]
                
                SHR R3, 1
                SHR R4, 1

                SUB R3, R4
                ADD R3, M[SP + 8]

CicloApaga:     MOV     R1, M[R2]
                CMP     R1, END_Vetor
                BR.Z    FimApaga
                
                PUSH    ' '
                PUSH 	R3
                CALL    DrawCharacter
                INC 	R3
                INC     R2
                BR      CicloApaga

FimApaga:       POP 	R4
				POP 	R3
				POP     R2
                POP     R1
                RETN 3




; EscPontos: Rotina que escreve o valor dos pontos (Guardado em M[Pont])
;               Entradas: Stack
;               Saidas: ---
;               Efeitos: ---
;				Descricao: Converte os pontos para decimal escreve os na posicao fornecida
;							como parametro (stack)

EscPontos:		PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4


				MOV R1, M[Pont]
				MOV R3, Res

EscPontosCiclo:	MOV R2, 10
				DIV R1, R2
				MOV M[R3], R2
				INC R3
				INC M[Ordem]

				CMP R1, R0
				BR.NZ	EscPontosCiclo

				MOV R1, Res
				DEC R1
				MOV R2, M[SP + 6]

PontosCiclo:	MOV R4, M[R3]
				ADD R4, '0'

				PUSH R4
				PUSH R2
				CALL DrawCharacter

				INC R2
				DEC R3
				INC M[Ordem]

				CMP R3, R1
				BR.NZ PontosCiclo
				

				POP R4
				POP R3
				POP R2
				POP R1
				RETN 1



; ApagaPontos: Rotina que com o proposito de apagar o escrito pela rotina EscPontos
;               Entradas: Stack
;               Saidas: ---
;               Efeitos: ---
;				Descricao: Escreve ' 's na posicao fornecida ate percorrer as posicoes
;						   no ecra correspondentes ao numero guardado em M[Ordem]
;						   Comeca o processo na posicao fornecida como parametro (stack)


ApagaPontos:	PUSH R1
				PUSH R2

				MOV R1, M[SP + 4]
				MOV R2, M[Ordem]

			
ApagaPontosCic:	PUSH R1
				CALL ClearObjeto

				INC R1
				DEC R2

				CMP R2, R0
				BR.NZ 	ApagaPontosCic

				POP R2
				POP R1

				RETN 1


; 	Zona IV - Rotinas de movimentacao


; Trata da movimentacao da nave para baixo
;				Entradas: Stack
;				Saidas: -----
;				Efeito: Diminuicao (- 0001h) dos valores guardados na tabela especificada pelo parametro (stack)
;				Descricao: Atualiza as coordenadas (- 0001h) de cada um dos elementos presentes
;						   na tabela especificada como parametro (stack). Faz os testes de colisao com a nave 

Move_All:		PUSH R1
				PUSH R2
				PUSH R3


				MOV R1, M[SP + 5]
				MOV R2, END_Vetor
				MOV R3, R0


				CMP M[R1], R2
				BR.NZ	Move_Ciclo

				POP R3
				POP R2
				POP R1
				RETN 1

Move_Ciclo: 	PUSH M[R1]
				CALL ColisoesNave
				DEC  M[R1]
				PUSH M[R1]
				CALL ColisoesNave
				MVBL R3, M[R1]
				CMP R3, R0
				BR.Z Apaga_

Iter_Move:		CMP  M[R1], R2
				BR.NZ Continua_

				POP R3
				POP R2
				POP R1
				RETN 1

Continua_:		INC R1
				CMP M[R1], R2
				BR.NZ	Move_Ciclo

				POP R3
				POP R2
				POP R1
				RETN 1

Apaga_:			PUSH R1
				CALL ApagaObjeto

				JMP  Iter_Move

; Trata do disparo do laser
;				Entradas: ---
;				Saidas: -----
;				Efeito: Aumento das coordenadas dos elementos da tabela POS_L
;				Descricao: Percorre todos os elementos da tabela POS_L e aumenta incrementa os
;						   

Move_All_L:		PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4

				MOV R1, POS_L
				MOV R2, END_Vetor
				MOV R3, RIGHT_EDGE
				MOV R4, R0

				CMP M[R1], R2
				BR.NZ	Move_L_Ciclo

				POP R4
				POP R3
				POP R2
				POP R1
				RET

Move_L_Ciclo: 	INC  M[R1]
				MVBL R4, M[R1]
				CMP R4, R3
				BR.NN  Apaga

IterMove:		CMP  M[R1], R2
				BR.NZ Continua	

				POP R4
				POP R3
				POP R2
				POP R1
				RET	
				
Continua:		INC R1
				CMP M[R1], R2
				BR.NZ	Move_L_Ciclo

				POP R4
				POP R3
				POP R2
				POP R1
				RET

Apaga:			PUSH R1
				CALL ApagaObjeto
				DEC M[Num_Lasers]

				JMP  IterMove

; Trata da movimentacao da nave para baixo
;				Entradas: ---
;				Saidas: -----
;				Efeito: Atualiza o que esta em POS -> POS + 3
;				Descricao: Apaga a Nave, atualiza as suas coordenadas (+ 1 linha), testa 
;						   se a nave está nos limites de jogo, se nao estiver, nao a desenha

TrataBaixo:		DSI
				PUSH R1
				PUSH R2
				PUSh R3

 				MOV R1, POS
 				MOV R2, R0
 				MOV R3, M[POS]

 				ADD R3, 0100h
				MVBH R2, R3
				
				CMP  R2, LOWER_EDGE
				BR.NZ	NextBaixo				;Verifica se a posicao a baixo e o limite de jogo, se for nao modifica as coordenadas da nave
				
				MOV R3, 0100h	
				SUB M[R1], R3

				POP R3
				POP R2
				POP R1
				ENI
				RET
				
NextBaixo:		MOV R2, 0100h
				SUB  M[R1], R2
				CALL ClearShip
				ADD  M[R1], R2					;Modifica as coordenadas da nave colocando todos os caraceres uma linha a baixo

				PUSH M[R1]
				PUSH POS_Ast
				CALL Colisoes_MOVE

				PUSH M[R1]
				PUSH POS_Black
				CALL Colisoes_MOVE

				CALL DrawShip
				
				POP R3
				POP R2				
				POP R1
				ENI
				RET

; Trata da movimentacao da nave para cima
;				Entradas: ---
;				Saidas: -----
;				Efeito: Atualiza o que esta em POS -> POS + 3
;				Descricao: Apaga a Nave, atualiza as suas coordenadas (- 1 linha), testa 
;						   se a nave está nos limites de jogo, se nao estiver, nao a desenha

TrataCima:		DSI
				PUSH R1
				PUSH R2
				PUSH R3

				MOV R1, POS
				MOV R2, R0
				MOV R3, M[R1]

				SUB R3, 0100h

				MVBH R2, R3
				CMP R2, R0

				BR.NZ 	NextCima				;Verifica se a posicao a cima e o limite de jogo, se for nao modifica as coordenadas da nave
				
				MOV R3, 0100h
				ADD M[R1], R3
				
				POP R3
				POP R2
				POP R1
				ENI
				RET
				
NextCima:		MOV R3, 0100h
				ADD M[R1], R3
				CALL ClearShip
				SUB  M[R1], R3					;Modifica as coordenadas da nave colocando todos os caraceres uma linha a cima

				PUSH M[R1]
				PUSH POS_Ast
				CALL Colisoes_MOVE

				PUSH M[R1]
				PUSH POS_Black
				CALL Colisoes_MOVE

				CALL DrawShip
				
				POP R3
				POP R2
				POP R1
				ENI
				RET

; Trata da movimentacao da nave para a esquerda
;				Entradas: ---
;				Saidas: -----
;				Efeito: Atualiza o que esta em POS -> POS + 3
;				Descricao: Apaga a Nave, atualiza as suas coordenadas (- 1 coluna), testa 
;						   se a nave está nos limites de jogo, se nao estiver, nao a desenha

TrataEsquerda:	DSI
				PUSH R1
				PUSH R2
				
				MOV R1, POS
				MOV R2, R0

				MVBL R2, M[R1]
				DEC R2
				CMP R2, R0
				BR.NN 	NextEsquerda				;Verifica se a posicao a cima e o limite de jogo, se for nao modifica as coordenadas da nave
				
				INC M[R1]

				POP R2
				POP R1
				ENI
				RET

NextEsquerda:	INC M[R1]
				CALL ClearShip
				
				DEC M[R1]	

				PUSH M[R1]
				PUSH POS_Ast
				CALL Colisoes_MOVE

				PUSH M[R1]
				PUSH POS_Black
				CALL Colisoes_MOVE
			
				CALL DrawShip

				POP R2
				POP R1
				ENI
				RET

; Trata da movimentacao da nave para a direita
;				Entradas: ---
;				Saidas: -----
;				Efeito: Atualiza o que esta em POS -> POS + 3
;				Descricao: Apaga a Nave, atualiza as suas coordenadas (+ 1 coluna), testa 
;						   se a nave está nos limites de jogo, se nao estiver, nao a desenha

TrataDireita:	DSI
				PUSH R1
				PUSH R2
				PUSH R3
				

 				MOV R1, POS
 				MOV R2, RIGHT_EDGE
 				MOV R3, R0

				MVBL R3, M[R1]
				CMP  R2, R3
				BR.P	NextDireita
				
				
			 	MOV R2, 0001h
				SUB  M[R1], R2					;Modifica as coordenadas da nave colocando todos os caraceres uma coluna para a direita

				POP R3
				POP R2
				POP R1
				ENI
				RET
				
NextDireita:	DEC  M[R1]						;Modifica as coordenadas da nave colocando todos os caraceres uma coluna para a direita
				CALL ClearShip

				INC M[R1]					;Modifica as coordenadas da nave colocando todos os caraceres uma coluna para a direita	

				PUSH M[R1]
				PUSH POS_Ast
				CALL Colisoes_MOVE

				PUSH M[R1]
				PUSH POS_Black
				CALL Colisoes_MOVE

				CALL DrawShip


				POP R3
				POP R2
				POP R1
				ENI
				RET


; Trata do disparo do laser
;				Entradas: ---
;				Saidas: -----
;				Efeito: Atualiza o que esta guardad em POS_I_L
;				Descricao: Desenha o Laser, permite a interrupcao pelo temporizador e inicializa o
	

TrataDispara: 	DSI
				PUSH R1
				PUSH R2
				PUSH R3
				
				MOV R2, Max_Lasers
				INC M[Num_Lasers]
				CMP M[Num_Lasers], R2
				BR.NZ	Shoot

				PUSH M[Velocidade]
				CALL InitTempo
				
				POP R3
				POP R2
				POP R1
				RET

Shoot:			MOV R1, POS
				MOV R3, M[R1]
				INC R3
				
				PUSH R3
				PUSH POS_L
				CALL Cria_Objeto

				PUSH Laser
				PUSH R3
				CALL DrawCharacter
			
				PUSH M[Velocidade]
				CALL InitTempo
				
				POP R3
				POP R2
				POP R1
				ENI
				RET


; TrataTempo: Rotina que trata dos acontecimentos aquando da interurpcao do temporizador
;				Entradas: ---
;				Saidas: -----
;				Efeito: Atualiza Flags, Movimenta e testa colisoes dos objetos no ecra de jogo 
;						(nave, lasers, asteroides, buracos negros)
;				Descricao: Testa se e tempo de mover os asteroides/buracos negros, se for, move-os 
;							(repoe a flag que controla este acontecimento) e testa se e tempo de criar
;							um buraco negro, se for, e procede para movimetar os lasers, fazendo tambem os
;							testes das colisoes. Se nao for tempo de criar um buraco negro, teste se o e para os
;							asteroides. Se for, cria um asteroide e procede para desenhar e testar as colisoes dos lasers 

TrataTempo:		PUSH R1
				INC M[Feed_Random]
				DEC M[T_Cria]
				DEC M[T_Cria_Black]
				DEC M[T_Ast]

				CMP M[T_Ast], R0
				JMP.NZ  CicloTempo


				PUSH POS_Ast
				CALL Clear_All			;apaga os asteroides
				PUSH POS_Ast
				CALL Move_All  			;move os asteroides
				PUSH Asteroide
				PUSH POS_Ast
				CALL Draw_ALL 			;desenha os asteroides

				PUSH POS_Black
				CALL Clear_All  		;apaga os buracos negros
				PUSH POS_Black
				CALL Move_All 			;move os buracos negros
				PUSH Black
				PUSH POS_Black
				CALL Draw_ALL 			;desenha os buracos negros
				
				MOV R1, 2
				MOV M[T_Ast], R1

				CMP M[T_Cria_Black], R0
				JMP.NZ	Testa_Ast
				
				CALL RandomGen
				MOV R1, M[Ni_Random]

				ADD  R1, RIGHT_EDGE
				PUSH R1 
				PUSH POS_Black
				CALL Cria_Objeto


				MOV R1, 40
				MOV M[T_Cria_Black], R1

				MOV R1, 10
				MOV M[T_Cria], R1
				JMP CicloTempo
				
Testa_Ast:		CMP M[T_Cria], R0
				BR.NZ CicloTempo
				
				CALL RandomGen
				MOV R1, M[Ni_Random]

				ADD R1, RIGHT_EDGE
				PUSH R1 
				PUSH POS_Ast
				CALL Cria_Objeto
				
				MOV R1, 10
				MOV M[T_Cria], R1

				

CicloTempo:		PUSH POS_L
				CALL Clear_All
				CALL Colisao_Laser
				CALL Colisao_LaserB
				
				CALL Move_All_L
				CALL Colisao_Laser
				CALL Colisao_LaserB

				PUSH Laser
				PUSH POS_L
				CALL Draw_ALL

				PUSH M[Velocidade]
				CALL InitTempo

				POP R1
				RET




; 		ZONA V - Tratamento das interrupcoes

; Tratamento da interrupcao 0
;				Entradas: ---
;				Saidas: -----
;				Efeito: Modifica M[F_Baixo] para 0
;				Descricao: 

INT_Baixo:		PUSH R1

				MOV M[F_Baixo], R0
				MOV R1, 0100h
				ADD M[POS], R1 

				POP R1
				RTI


; Tratamento da interrupcao 1
;				Entradas: ---
;				Saidas: -----
;				Efeito: Modifica M[F_Cima] para 0
;				Descricao: 

INT_Cima:		PUSH R1

				MOV M[F_Cima], R0
				MOV R1, 0100h
				SUB M[POS], R1 

				POP R1
				RTI


; Tratamento da interrupcao 2
;				Entradas: ---
;				Saidas: -----
;				Efeito: Modifica M[F_Esquerda] para 0
;				Descricao: 

INT_Esquerda:	MOV M[F_Esquerda], R0
				DEC M[POS]
				
				RTI

; Tratamento da interrupcao 3
;				Entradas: ---
;				Saidas: -----
;				Efeito: Modifica M[F_Direita] para 0
;				Descricao:

INT_Direita:	MOV M[F_Direita], R0
				INC M[POS] 

				RTI


; Tratamento da interrupcao 4
;				Entradas: ---
;				Saidas: -----
;				Efeito: Modifica M[F_Dispara] para 0
;				Descricao: 


INT_Dispara:	MOV M[F_Dispara], R0
				RTI

;Tratamento da interrupcao testada na rotina GameOver
;				Entradas: ---
;				Saidas: -----
;				Efeito: Altera a flag F_Over para 0
;				Descricao:  

INT_OVER:		MOV M[F_Over],R0
				RTI	

;Tratamento da interrupcao IE
;				Entradas: ---
;				Saidas: -----
;				Efeito: Altera a flag F_Inicio para 0
;				Descricao: (Re)Inicia o jogo  

INT_Inicio:		MOV M[F_Inicio],R0
				RTI	


; Tratamento da interrupcao do Temporizador
;				Entradas: ---
;				Saidas: -----
;				Efeito: Altera a flag F_Tempo para 0
;				Descricao: 

INT_Tempo:		MOV M[F_Tempo], R0
				RTI

; 		Zona VI - Utilidades

; Gera um numero aleatorio
;			Entradas: ----	
;			Saidas: ------
;			Efeito: Coloca um numero aleatorio entre 0 e 23 na variavel Ni_Random
;			Descricao: Utiliza o program counter para alimentar um algoritmo de geracao
;					   aleatoria de numeros

RandomGen:      PUSH R1
                PUSH R2
                PUSH R3

                MOV R1, M[Feed_Random]
                MOV R3, Ni_Random
                MOV R2, M[Ni_Random]

                SHR R1, 1
                BR.NC   e_zero

                XOR R2, RandomMask
                ROR R2, 1
                MOV R4, 22
                DIV R2, R4
                INC R4
                SHL R4, 8
                MOV M[R3], R4

                POP R3
                POP R2
                POP R1

                RET

e_zero:         ROR R2, 1
                MOV R4, 22
                DIV R2, R4
                INC R4
                SHL R4, 8
                MOV M[R3], R4

                POP R3
                POP R2
                POP R1

                RET

; Gera um numero aleatorio
;			Entradas: ----	
;			Saidas: ------
;			Efeito: Coloca um numero aleatorio entre 0 e 23 na variavel Ni_Random
;			Descricao: Utiliza o program counter para alimentar um algoritmo de geracao
;					   aleatoria de numeros
GameOver:		PUSH POS_Ast
				CALL Clear_All
				PUSH POS_Black
				CALL Clear_All
				PUSH POS_L
				CALL Clear_All
				CALL ClearShip
				CALL ClearEdges
				;Reposicao das Flags
				INC M[F_Over]
				INC M[F_Baixo]
				INC M[F_Cima]
				INC M[F_Esquerda]
				INC M[F_Direita]
				INC M[F_Dispara]
				INC M[F_Inicio]
				;Reposicao dos Registos alterados e nao repostos
				MOV R1, R0
				MOV R2, R0
				MOV R3, R0
				MOV R4, R0

				PUSH 0111111111111111b
				CALL InitMask

				PUSH 0C00h
				PUSH L_VarTexto3
				PUSH VarTexto3
				CALL EscString

				PUSH 0E00h
				PUSH L_VarTexto4
				PUSH VarTexto4
				CALL EscString

				PUSH 0E2Dh
				CALL EscPontos

				ENI

CicloOver:		CMP M[F_Baixo], R0
				JMP.Z  TrataOver
				
				CMP M[F_Cima], R0
				JMP.Z  TrataOver
				
				CMP M[F_Esquerda], R0
				JMP.Z  TrataOver
				
				CMP M[F_Direita], R0
				JMP.Z  TrataOver
				
				CMP M[F_Dispara], R0
				JMP.Z  TrataOver

				CMP M[F_Over], R0
				JMP.Z  TrataOver

				CMP M[F_Inicio],R0
				JMP.Z TrataOver

				JMP CicloOver 

TrataOver:		DSI 
				INC M[F_Baixo]
				INC M[F_Cima]
				INC M[F_Esquerda]
				INC M[F_Direita]
				INC M[F_Inicio]
				INC M[F_Over]


				PUSH 0C00h
				PUSH L_VarTexto3
				PUSH VarTexto3
				CALL ApagaString
				
				PUSH 0E00h
				PUSH L_VarTexto4
				PUSH VarTexto4
				CALL ApagaString

				PUSH 0E2Ch
				CALL ApagaPontos
			
				JMP Inicia


; Cria um objeto (asteroide, laser ou buraco negro)
;			Entradas: Stack	
;			Saidas: ------
;			Efeito: Acrescenta ao parametro de entrada (TAB) uma posicao 
;			Descricao: Move para o fim do (TAB) uma posicao, shiftando o caracter de fim de tabela
;					   um endereco de memoria para o lado. Retira a tabela e a posicao a nela inserir 


Cria_Objeto:	PUSH R1
				PUSH R2
				PUSH R3
	
				MOV R1, M[SP + 5]
				MOV R2, M[R1]
				CMP R2, END_Vetor
				BR.NZ	Cria_Cicle
				
				MOV R3, M[SP + 6]
				MOV M[R1], R3
				MOV R2, END_Vetor
				MOV M[R1 + 1], R2

				POP R3
				POP R2
				POP R1
				RETN 2
	

Cria_Cicle:		INC  R1							;Incrementa a coluna
				MOV R2, M[R1]
				CMP R2, END_Vetor
				BR.NZ Cria_Cicle
				
				MOV R3, M[SP + 6]
				MOV M[R1], R3
				MOV R3, END_Vetor
				MOV M[R1 + 1], R3

				POP R3
				POP R2
				POP R1
				RETN 2


; Escreve no Display de 7 segmentos
;			Entradas: ----
;			Saidas: ------
;			Efeito: Escreve a Pontuacao(em decimal) no display de 7 segmentos 
;			Descricao: Converte o numero de pontos em decimal e desenha-o no display de 7 segmentos digito
;						a digito (maximo 4 digitos) 

EscreveDisplay:			PUSH R1
						PUSH R2
						PUSH R3
						PUSH R4
			            MOV     R4, Display
			            MOV     R1, M[Pont]               		  
			            MOV     R2, 10
			            DIV     R1,R2
			            MOV     M[R4],R2
			            MOV     R3, 10
			            DIV     R1,R3			            
			            MOV     M[R4 + 1],R3
			            MOV     R3, 10
			            DIV     R1,R3
			            MOV     M[R4 + 2],R3
			            MOV     R3, 10
			            DIV     R1,R3
			            MOV     M[R4 + 3],R3			      	
			      		POP R4
			            POP R3
			            POP R2
			            POP R1
			            RET


; Escreve no LCD
;			Entradas: ----
;			Saidas: ------
;			Efeito: Escreve a Posicao da nave (linha coluna) no LCD 
;			Descricao: Converte para decimal os 2 bytes correspondentes a linha e a coluna e 
;					   escreve os no LCD, separados de um espaco em branco

EscreveLCD:		PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4

				MOV  R1, M[POS]
				MOV  R2, R0
				MVBL R2, R1					;linha
				MVBH R3, R1				
				SHR  R3, 8					;coluna

				MOV R1, 10
				DIV R2, R1
				

				MOV R4, 1000000000000000b
				MOV M[LCDControl], R4
				
				ADD R2, '0'					;converte o numero para o seu codigo ASCII
				MOV M[LCDWrite], R2
				
				INC R4						;aumenta a posicao uma coluna
				MOV M[LCDControl], R4
				ADD R1, '0'
				MOV M[LCDWrite], R1

				MOV R1, 10
				DIV R3, R1

				ADD R4, 2					;aumenta a posicao duas colunas, de modo a dar um espaco
				MOV M[LCDControl], R4
				ADD R3, '0'
				MOV M[LCDWrite], R3

				INC R4						;aumenta a posicao uma coluna
				MOV M[LCDControl], R4
				ADD R1, '0'
				MOV M[LCDWrite], R1
				
				POP R4
				POP R3
				POP R2
				POP R1

				RET

;		Inicializa - Repõe os valores iniciais de todas as variaveis 
;					 necessarias para o funcionamento do jogo
;					 e para que o comportamento seja o esperado quando este
;					 é reiniciado por meio de GameOver ou pela interrupçoes respetiva (IE)

Inicializa: 	DSI
				PUSH R1 
				MOV  R1, 0503h
				MOV  M[POS], R1
				MOV  M[Pont], R0
				MOV  R1, END_Vetor
				MOV  M[POS_Ast], R1
				MOV  M[POS_Black], R1
				MOV  M[POS_L], R1
				MOV  M[Pont], R0
				MOV  M[Ordem], R0
				MOV  R1, 1
				MOV  M[T_Cria], R1
				MOV  M[T_Ast], R1
				MOV  R1, 31
				MOV  M[T_Cria_Black], R1
				MOV  R1, Res 
				MOV  M[R1], R0
				MOV  M[R1 + 1], R0
				MOV  M[R1 + 2], R0
				MOV  M[R1 + 3], R0
				INC M[F_Over]
				INC M[F_Baixo]
				INC M[F_Cima]
				INC M[F_Esquerda]
				INC M[F_Direita]
				INC M[F_Dispara]
				INC M[F_Inicio]
				POP	 R1
				ENI
				RET


; Atribuicao da mascara de interrupcoes
;				
;
;

InitMask:		PUSH R7
				
				MOV R7, M[SP + 3]
				MOV M[INT_MASK_ADDR], R7		;Define as interrupcoes que vamos perimitr

				POP R7
				RETN 1

; Inicializa Temporizador
;				Entradas: Stack
;				Saidas: ----
;				Efeito: Inicia o temporizador
;				Descricao: Inicializa o temporizador para o tempo dado pelo parametro (que se encontra em SP + 3)	

InitTempo:		PUSH R7
				
				;Velocidade de jogo				
				MOV R7, M[SP + 3]
				MOV M[Temporizador_V], R7

				MOV R7, 1
				MOV M[Temporizador_I], R7	

				POP R7

				RETN 1

; 		ZONA VII - Colisoes

; Trata das colisoes dos lasers com os buracos negros
;			Entradas: ----
;			Saidas: ------
;			Efeito: Apaga os Lasers que se encontram na mesma posicao que os buracos negros, caso existam
;			Descricao: Testa a posicao de todos os laser, para cada buraco negro, acerca da sua posicao e elimina
;					   os lasers que se encontram na mesma posicao que os buracos negros

Colisao_LaserB:		PUSH R1
					PUSH R2
					PUSH R3
					PUSH R4

					MOV R1, POS_Black
					MOV R2, POS_L
					MOV R4, END_Vetor

Teste_FIMB:			CMP M[R1], R4
					JMP.Z AcabaColisaoB

Colision_CicloB:	MOV R3, M[R1]
					CMP R3, M[R2]
					BR.Z 	ApagaB

					INC R2
					CMP M[R2], R4
					BR.Z 	Update_Black
					JMP Colision_CicloB

AcabaColisaoB:		POP R4
					POP R3
					POP R2
					POP R1

					RET

ApagaB:				PUSH R2
					CALL ApagaObjeto


					MOV R2, POS_L
					INC R1


					JMP Teste_FIMB

Update_Black:		INC R1
					MOV R2, POS_L
					JMP Teste_FIMB

; Trata das colisoes dos lasers com os asteroides
;			Entradas: ----
;			Saidas: ------
;			Efeito: Remove da respetiva tabela os lasers e os asteroides que colidem
;			Descricao: Testa a posicao de todos os asteroides, para cada laser, acerca da sua posicao e elimina
;					   os lasers e os asteroides que se encontram na mesma posicao
Colisao_Laser:		PUSH R1
					PUSH R2
					PUSH R3
					PUSH R4

					MOV R1, POS_L
					MOV R2, POS_Ast
					MOV R4, END_Vetor

Teste_FIM:			CMP M[R1], R4
					JMP.Z AcabaColisao
					
Colision_Ciclo:		MOV R3, M[R1]
					CMP R3, M[R2]
					BR.Z 	ApagaBoth

					INC R2
					CMP M[R2], R4
					BR.Z 	Update_Laser
					JMP Colision_Ciclo

AcabaColisao:		POP R4
					POP R3
					POP R2
					POP R1

					RET

ApagaBoth:			INC M[Pont]
					CALL EscreveDisplay
					PUSH R1
					CALL ApagaObjeto

					PUSH M[R2]
					CALL ClearObjeto
					PUSH R2
					CALL ApagaObjeto
					
					MOV R3, FFFFh		;LED ACENDE
					MOV M[FFF8h], R3


					MOV R2, POS_Ast

					JMP Teste_FIM

Update_Laser:		INC R1
					MOV R2, POS_Ast
					JMP Teste_FIM

; ColisoesNave: Trata de a colisao de qualquer objeto com a nave
;			Entradas: ----
;			Saidas: ------
;			Efeito: Faz o CALL da rotina GameOver caso haja uma colisao
;			Descricao: Compara uma posicao com as de todos os componentes da nave.
;					   Invoca a rotina GameOver se alguma destas posicoes for igual

ColisoesNave:	PUSH R1
				PUSH R2

				MOV R1, M[SP + 4]
				MOV R2, M[POS]

				CMP R2, R1
				JMP.Z GameOver
				
				DEC R2
				ADD R2, 0100h

				CMP R2, R1
				JMP.Z GameOver

				SUB R2, 0200h

				CMP R2, R1
				JMP.Z GameOver

				POP R2
				POP R1
				RETN 1

; Colisoes_MOVE: Trata de a colisao da nave com qualquer objeto
;			Entradas: Stack
;			Saidas: ------
;			Efeito: Faz o CALL da rotina GameOver caso haja uma colisao
;			Descricao: Compara uma posicao com as de todos os componentes de uma tabela passada como
;					   parametro pelo stack.
;					   Invoca a rotina GameOver se alguma destas posicoes for igual

Colisoes_MOVE:	PUSH R1
				PUSH R2
				PUSH R3

				MOV R1, M[SP + 6]
				MOV R2, M[SP + 5]
				MOV R3, END_Vetor

				CMP M[R2], R3
				BR.Z ReturnCol

Col_Ciclo:		CMP R1, M[R2]
				JMP.Z GameOver
				
				DEC R1
				CMP R1, M[R2]
				JMP.Z GameOver
				
				ADD R1, 0100h
				CMP R1, M[R2]
				JMP.Z GameOver
				
				SUB R1, 0200h
				CMP R1, M[R2]
				JMP.Z GameOver

				INC R2
				CMP M[R2], R3
				BR.NZ 	Col_Ciclo

ReturnCol:		POP R3
				POP R2
				POP R1
				RETN 2





; 		ZONA VIII - Programa Principal

Inicio:			MOV R1, FFFFh					
				MOV M[WindowControl], R1		;Inicializa o porto de controlo para a janela de texto

				MOV R1, R0
;		Inicializa todas as variaveis necessarias para o funcionamento do jogo. Serve como 
;		reposicao de valores quando o jogo e reiniciado

Inicia:		    MOV R7, SP_INIT					
				MOV SP, R7						;Inicializacao do Stack Pointer

				PUSH 0100000000000000b
				CALL InitMask

				CALL Inicializa

				PUSH 0C00h
				PUSH L_VarTexto1
				PUSH VarTexto1
				CALL EscString

				PUSH 0E00h
				PUSH L_VarTexto2
				PUSH VarTexto2
				CALL EscString	

Ciclo_Inicia:	CMP M[F_Inicio],R0
				BR.NZ Ciclo_Inicia



				PUSH INT_MASK
				CALL InitMask
				
				DSI
				PUSH 0E00h
				PUSH L_VarTexto2
				PUSH VarTexto2
				CALL ApagaString

				PUSH 0C00h
				PUSH L_VarTexto1
				PUSH VarTexto1
				CALL ApagaString
				
				INC M[F_Over]
				INC M[F_Baixo]
				INC M[F_Cima]
				INC M[F_Esquerda]
				INC M[F_Direita]
				INC M[F_Dispara]
				INC M[F_Inicio]

				CALL DrawGame
				CALL EscreveLCD
				CALL EscreveDisplay
				ENI

				PUSH M[Velocidade]
				CALL InitTempo

;		|Ciclo Principal de Jogo|

Ciclo:			MOV M[FFF8h], R0	;LED APAGA
				CMP M[F_Baixo], R0
				JMP.Z  Baixo
				
				CMP M[F_Cima], R0
				JMP.Z  Cima
				
				CMP M[F_Esquerda], R0
				JMP.Z  Esquerda
				
				CMP M[F_Direita], R0
				JMP.Z  Direita
				
				CMP M[F_Dispara], R0
				JMP.Z  Dispara

				INC M[Feed_Random]

				CMP M[F_Tempo], R0
				JMP.Z  Tempo

				CMP M[F_Inicio],R0
				JMP.Z Reinicia

				JMP Ciclo

Baixo: 			DEC M[Feed_Random]
				DSI
				CALL 	TrataBaixo
				CALL EscreveLCD
				INC 	M[F_Baixo]
				ENI
				JMP Ciclo

Cima:			INC M[Feed_Random]
				DSI
				CALL 	TrataCima
				CALL    EscreveLCD
				INC 	M[F_Cima]
				ENI
				JMP Ciclo

Esquerda:		INC M[Feed_Random]
				DSI
				CALL 	TrataEsquerda
				CALL 	EscreveLCD
				INC 	M[F_Esquerda]
				ENI
				JMP Ciclo

Direita:		DEC M[Feed_Random]
				DSI
				CALL 	TrataDireita
				CALL EscreveLCD
				INC 	M[F_Direita]
				ENI
				JMP Ciclo

Dispara:		INC M[Feed_Random]
				DSI
				CALL 	TrataDispara
				INC 	M[F_Dispara]
				ENI
				JMP Ciclo

Tempo:			DSI
				CALL TrataTempo
				INC M[F_Tempo]
				ENI
				JMP Ciclo

Reinicia:		DSI
				INC M[F_Inicio]
				PUSH POS_Ast
				CALL Clear_All
				PUSH POS_Black
				CALL Clear_All
				PUSH POS_L
				CALL Clear_All
				CALL ClearShip
				CALL ClearEdges
				ENI
				JMP Inicia
