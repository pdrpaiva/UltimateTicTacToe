;------------------------------------------------------------------------
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2022/2023
;--------------------------------------------------------------
; Demostra��o da navega��o do cursor do Ecran 
;
;		arrow keys to move 
;		press ESC to exit
;
;--------------------------------------------------------------

.8086
.model small
.stack 2048

dseg	segment para public 'data'



        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'jogo.TXT',0
        HandleFich      dw      0
        car_fich        db      ?


		Car				db	32	; Guarda um caracter do Ecran 
		Cor				db	7	; Guarda os atributos de cor do caracter
		POSy			db	7	; a linha pode ir de [1 .. 25]
		POSx			db	4	; POSx pode ir [1..80]	
		POSya			db	4	; posicao anterior de y
		POSxa			db	4	; posicao anterior de x

		Jogador1 		db  "- Pedro",'$' ; aqui vai ser a string inserida pelo utilizador
		Jogador2 		db  "- Tomas",'$'	; aqui vai ser a string inserida pelo utilizador
		JogadorAtual    db 	1
		auxJogadorAtual db 	1 

		auxSalta		db	1
		auxSimbolo		db	1
		bool1Simbolo 	db 	0

		array    		db  81 dup(?)   ; Array de 81 elementos

dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg



;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da p�gina
		mov		dl,POSx
		mov		dh,POSy
		int		10h
		
endm


;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
			mov		ax,0B800h
			mov		es,ax
			xor		bx,bx
			mov		cx,25*80
		
apaga:		mov		byte ptr es:[bx],' '
			mov		byte ptr es:[bx+1],7
			inc		bx
			inc 	bx
			loop	apaga
			ret
apaga_ecran	endp


;########################################################################
; IMP_FICH

IMP_FICH	PROC

		;abre ficheiro
        mov     ah,3dh
        mov     al,0
        lea     dx,Fich
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0		
		je		fecha_ficheiro
        mov     ah,02h
		mov		dl,car_fich
		int		21h
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:	
		RET
		
IMP_FICH	endp		


;########################################################################
; LE UMA TECLA	

LE_TECLA	PROC
		
		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp



;########################################################################
; Avatar

AVATAR	PROC
			mov		ax,0B800h
			mov		es,ax
			
CICLO:	
		goto_xy	POSx,POSy		; Vai para nova possi��o
		mov 	ah, 08h
		mov		bh,0			; numero da p�gina
		int		10h		
		mov		Car, al			; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah			; Guarda a cor que est� na posi��o do Cursor
	
		goto_xy	78,0			; Mostra o caractr que estava na posi��o do AVATAR
		mov		ah, 02h			; IMPRIME caracter da posi��o no canto
		mov		dl, Car	
		int		21H		

		cmp		al, 177
		je		PAREDE

		cmp		al, 186
		je		SALTA_X

		cmp		al, 205
		je		SALTA_Y
		
		goto_xy	10, 4
		cmp	bool1Simbolo, 0
		jne	ALTERA_SIMBOLO ; Pula para a alteração de símbolo se bool1Simbolo for diferente de 0

	EXIBIR_JOGADOR_ATUAL:
		mov	dl, jogadorAtual
		jmp	MOSTRA_XO

	ALTERA_SIMBOLO:
		mov	ah, 02h
		mov	dl, jogadorAtual
		cmp	dl, 'X'
		je	ALTERA_PARA_O
		mov	dl, 'X'
		jmp	MOSTRA_XO

	ALTERA_PARA_O:
		mov	dl, 'O'

	MOSTRA_XO:
		int	21h ; Exibir caractere

		goto_xy	POSx,POSy	; Vai para posi��o do cursor		

LER_SETA:
		
		; Guarda a posicao antes de mudar de posicao
		mov 	al, POSx
		mov 	POSxa, al
		mov 	al, POSy
		mov 	POSya, al
		
		goto_xy POSx, POSy

		call 	LE_TECLA
		cmp 	ah, 1
		je 		ESTEND
		cmp 	al, 1Bh    ; ESCAPE (27 em hexadecimal)
		je 		FIM
		cmp 	al, 20h    ; ESPAÇO (32 em hexadecimal)
		je 		PODE_ESCREVER
		cmp 	al, 58h    ; X
		je 		PODE_ESCREVER
		cmp 	al, 4Fh    ; O 
		je 		PODE_ESCREVER
		cmp 	al, 0    ; Verifica as setas
		je 		VERIFICAR_SETA
		jmp 	LER_SETA

PODE_ESCREVER:

    goto_xy POSx, POSy  ; verifica se pode escrever o caractere no ecrã
    mov CL, Car
    cmp CL, 20h    ; Só escreve se for espaço em branco
    jne LER_SETA

    ; Verifica se a variável já foi exibida
    cmp bool1Simbolo, 0
    je PRIMEIRA_EXIBICAO

    ; Alternar entre 'X' e 'O'
    cmp JogadorAtual, 'X'
    je ESCREVER_O
    mov dl, 'X'
    jmp ESCREVER

ESCREVER_O:
    mov dl, 'O'

ESCREVER:
    mov ah, 02h    ; coloca o caractere lido no ecrã
    mov al, dl     ; caractere a ser exibido
    int 21H
	

    ; Atualizar flag de exibição
    mov bool1Simbolo, 1

    ; Alternar jogadorAtual
    cmp JogadorAtual, 'X'
    je ATUALIZAR_JOGADOR_O
    mov JogadorAtual, 'X'
    jmp CICLO

ATUALIZAR_JOGADOR_O:
    mov JogadorAtual, 'O'

    jmp CICLO

PRIMEIRA_EXIBICAO:
    ; Exibe o caractere inicial no ecrã
    mov ah, 02h
    mov dl, JogadorAtual
    int 21H

    ; Atualizar flag de exibição
    mov bool1Simbolo, 1

    jmp CICLO

VERIFICAR_SETA:
		cmp 	ah, 0    ; Verifica o segundo byte de ah para distinguir as setas
		je 		SETAS
		jmp 	LER_SETA

SETAS:
		cmp 	al, 4Bh    ; Setas: esquerda
		je 		PODE_ESCREVER
		cmp 	al, 4Dh    ; Setas: direita
		je 		PODE_ESCREVER
		cmp 	al, 48h    ; Setas: cima
		je 		PODE_ESCREVER
		cmp 	al, 50h    ; Setas: baixo
		je 		PODE_ESCREVER
		jmp 	LER_SETA
		
ESTEND:
		cmp 	al,48h
		jne		BAIXO
		dec		POSy		;cima
		mov 	auxSalta, al
		jmp		CICLO

BAIXO:
		cmp		al,50h
		jne		ESQUERDA
		inc 	POSy		;Baixo
		mov 	auxSalta, al
		jmp		CICLO

ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		sub		POSx, 2		;Esquerda
		mov 	auxSalta, al
		jmp		CICLO

DIREITA:
		cmp		al,4Dh
		jne		LER_SETA 
		add 	POSx, 2 	;Direita Mudei isto para andar 2 casas em vez de 1. troquei o inc por add
		mov 	auxSalta, al
		jmp		CICLO


;LIMITA O MOVIMENTO AO TABULEIRO ULTIMATE
PAREDE:
		; retorna o filho atrás, já que ele está a ir contra a parede
		mov		al, POSxa	   
		mov		POSx, al
		mov		al, POSya	 
		mov 	POSy, al
		jmp 	CICLO

SALTA_X:
        cmp     auxSalta,4Bh ;Esquerda
        jne     ADD_X
        sub     POSx, 2
        jmp     CICLO

ADD_X: ;Direita
        cmp     auxSalta,4Dh 
        add     POSx, 2
        jmp     CICLO

SALTA_Y:
		cmp     auxSalta,50h ;Baixo
        jne     SUB_Y
        inc     POSy
        jmp     CICLO

SUB_Y: ;Cima
        dec     POSy
        jmp     CICLO	

fim:				
			RET
AVATAR		endp

;########################################################################
;MOSTRA A STRING DOS JOGADORES
MOSTRA MACRO STR 

	MOV AH,09H
	LEA DX,STR 
	INT 21H

ENDM

;########################################################################
Main  proc
		mov			ax, dseg
		mov			ds,ax
		
		mov			ax,0B800h
		mov			es,ax

		call		apaga_ecran

		; Inicialização do gerador de números aleatórios
		MOV AH, 00H  ; Configurar função AH=00H para inicializar o gerador de números aleatórios
		INT 1AH      ; Chamar a interrupção para obter o contador de tempo atual em CX e DX

		; Gerar número aleatório entre 0 e 1
		MOV AX, CX   ; Mover o valor de CX para AX
		MOV BX, DX   ; Mover o valor de DX para BX
		XOR AX, BX   ; Executar a operação XOR entre AX e BX para obter um valor aleatório em AX

		; Atribuir símbolos aos jogadores com base no valor aleatório
		MOV BL, AL   ; Mover o valor aleatório para BL
		AND BL, 0001H ; Máscara para manter apenas o bit menos significativo

		GOTO_XY		3,1
		MOSTRA 		Jogador1
		GOTO_XY		3,2
		MOSTRA 		Jogador2

		;A JOGAR
		GOTO_XY		10,4
		MOV AX, 'X'  ; Armazenar 'X' em AX
		CMP BL, 0
		JE s_ajogar
		MOV AX, 'O'  ; Se BL for diferente de 0, armazenar 'O' em AX
		s_ajogar:
		MOV DL, AL   ; Mover o símbolo para DL
		MOV AH, 02H

		MOV JogadorAtual, AL ;guarda quem é que está a jogar
		
		;Jogador1
		GOTO_XY		1,1
		MOV AL, 'X'
		CMP BL, 0
		JE s_jogador1
		MOV AL, 'O'
		s_jogador1:
		MOV DL, AL
		MOV AH, 02H
		INT 21H

		;Jogador2
		GOTO_XY		1,2
		MOV AL, 'O'
		CMP BL, 0
		JE s_jogador2
		MOV AL, 'X'
		s_jogador2:
		MOV DL, AL
		MOV AH, 02H
		INT 21H

		goto_xy		0,0
		call		IMP_FICH

		call 		AVATAR
		goto_xy		0,22

		mov			ah,4CH
		INT			21H
Main	endp
Cseg	ends
end	Main


		
