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

		POSyE			db	7	; posicao escrita de y
		POSxE			db	4	; posicao escrita de x
		SimbE			db	1	; simbolo escrito

		Jogador1 		db  "- Pedro",'$' ; aqui vai ser a string inserida pelo utilizador
		Jogador2 		db  "- Tomas",'$'	; aqui vai ser a string inserida pelo utilizador
		JogadorAtual    db 	1
		auxJogadorAtual db 	1 

		auxSalta		db	1
		auxSimbolo		db	1
		bool1Simbolo 	db 	0

		array    		db  81 dup(?)   ; Array de 81 elementos
		
		;testes
		teste2    		db  81 dup('-')
		teste db 'ABCDEFGHI', '$'

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

	;MOSTRA O ARRAY PARA VER SE ESTÁ A GUARDAR BEM
    mov si, offset array
    mov cx, 81
	goto_xy	1,19

    mostrar_array:
	
        mov dl, [si]
        inc si

        ; Exibir o caractere no Ecrã
        mov ah, 02h
        int 21h

        dec cx
        jnz mostrar_array

	;MOSTRA O ARRAY PARA VER SE ESTÁ A GUARDAR BEM

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

	;guardar as posicoes de escrita
	mov al, POSx
	mov POSxE, al

	mov al, POSy   
	mov POSyE, al

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
    ;jmp CICLO
	jmp ATUALIZA_ARRAY

ATUALIZAR_JOGADOR_O:
    mov JogadorAtual, 'O'
	;jmp CICLO
	jmp ATUALIZA_ARRAY

PRIMEIRA_EXIBICAO:
    ; Exibe o caractere inicial no ecrã
    mov ah, 02h
    mov dl, JogadorAtual
    int 21H

    ; Atualizar flag de exibição
    mov bool1Simbolo, 1

    ;jmp CICLO
	jmp ATUALIZA_ARRAY

ATUALIZA_ARRAY:
    call COORDS	

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

;########################################################################
;COORDS

COORDS:
    cmp POSxE, 4
    jne check_next
    cmp POSyE, 7
    jne check_next

    mov al, jogadorAtual
    mov si, offset array
    add si, 0   ; Acesso ao elemento 0 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 0 do array
    jmp end_coord

check_next:
    ; Código para a combinação (1, 0) aqui
    cmp POSxE, 6
    jne check_next2
    cmp POSyE, 7
    jne check_next2

    mov al, jogadorAtual
    mov si, offset array
    add si, 1   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next2:
    ; Código para a combinação (0, 1) aqui
    cmp POSxE, 8
    jne check_next3
    cmp POSyE, 7
    jne check_next3

    mov al, jogadorAtual
    mov si, offset array
    add si, 2   ; Acesso ao elemento 2 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 2 do array
    jmp end_coord

check_next3:
	; Código para a combinação (3, 0) aqui
    cmp POSxE, 4
    jne check_next4
    cmp POSyE, 8
    jne check_next4

    mov al, jogadorAtual
    mov si, offset array
    add si, 3   ; Acesso ao elemento 2 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 2 do array
    jmp end_coord

check_next4:
	; Código para a combinação (4, 0) aqui
    cmp POSxE, 6
    jne check_next5
    cmp POSyE, 8
    jne check_next5

    mov al, jogadorAtual
    mov si, offset array
    add si, 4   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next5:
	; Código para a combinação (5, 0) aqui
    cmp POSxE, 8
    jne check_next6
    cmp POSyE, 8
    jne check_next6

    mov al, jogadorAtual
    mov si, offset array
    add si, 5   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next6:
	; Código para a combinação (6, 0) aqui
    cmp POSxE, 4
    jne check_next7
    cmp POSyE, 9
    jne check_next7

    mov al, jogadorAtual
    mov si, offset array
    add si, 6   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next7:
	; Código para a combinação (7, 0) aqui
    cmp POSxE, 6
    jne check_next8
    cmp POSyE, 9
    jne check_next8

    mov al, jogadorAtual
    mov si, offset array
    add si, 7   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next8:
	; Código para a combinação (8, 0) aqui
    cmp POSxE, 8
    jne check_next9
    cmp POSyE, 9
    jne check_next9

    mov al, jogadorAtual
    mov si, offset array
    add si, 8   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
;FIM TABULEIRO 1

check_next9:
	; Código para a combinação (0, 1) aqui
    cmp POSxE, 12
    jne check_next10
    cmp POSyE, 7
    jne check_next10

    mov al, jogadorAtual
    mov si, offset array
    add si, 9   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next10:
	; Código para a combinação (1, 1) aqui
    cmp POSxE, 14
    jne check_next11
    cmp POSyE, 7
    jne check_next11

    mov al, jogadorAtual
    mov si, offset array
    add si, 10   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next11:
	; Código para a combinação (2, 1) aqui
    cmp POSxE, 16
    jne check_next12
    cmp POSyE, 7
    jne check_next12

    mov al, jogadorAtual
    mov si, offset array
    add si, 11   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord


check_next12:
	; Código para a combinação (3, 1) aqui
    cmp POSxE, 12
    jne check_next13
    cmp POSyE, 8
    jne check_next13

    mov al, jogadorAtual
    mov si, offset array
    add si, 12   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next13:
	; Código para a combinação (4, 1) aqui
    cmp POSxE, 14
    jne check_next14
    cmp POSyE, 8
    jne check_next14

    mov al, jogadorAtual
    mov si, offset array
    add si, 13   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next14:
	; Código para a combinação (5, 1) aqui
    cmp POSxE, 16
    jne check_next15
    cmp POSyE, 8
    jne check_next15

    mov al, jogadorAtual
    mov si, offset array
    add si, 14   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next15:
	; Código para a combinação (7, 1) aqui
    cmp POSxE, 12
    jne check_next16
    cmp POSyE, 9
    jne check_next16

    mov al, jogadorAtual
    mov si, offset array
    add si, 15   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next16:
	; Código para a combinação (8, 1) aqui
    cmp POSxE, 14
    jne check_next17
    cmp POSyE, 9
    jne check_next17

    mov al, jogadorAtual
    mov si, offset array
    add si, 16   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next17:
	; Código para a combinação (8, 1) aqui
    cmp POSxE, 16
    jne check_next18
    cmp POSyE, 9
    jne check_next18

    mov al, jogadorAtual
    mov si, offset array
    add si, 17   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
; FIM TABULEIRO 2

check_next18:
	; Código para a combinação (0, 2) aqui
    cmp POSxE, 20
    jne check_next19
    cmp POSyE, 7
    jne check_next19

    mov al, jogadorAtual
    mov si, offset array
    add si, 18   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next19:
	; Código para a combinação (1, 2) aqui
    cmp POSxE, 22
    jne check_next20
    cmp POSyE, 7
    jne check_next20

    mov al, jogadorAtual
    mov si, offset array
    add si, 19   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next20:
	; Código para a combinação (2, 2) aqui
    cmp POSxE, 24
    jne check_next21
    cmp POSyE, 7
    jne check_next21

    mov al, jogadorAtual
    mov si, offset array
    add si, 20   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next21:
	; Código para a combinação (3, 2) aqui
    cmp POSxE, 20
    jne check_next22
    cmp POSyE, 8
    jne check_next22

    mov al, jogadorAtual
    mov si, offset array
    add si, 21   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next22:
	; Código para a combinação (4, 2) aqui
    cmp POSxE, 22
    jne check_next23
    cmp POSyE, 8
    jne check_next23

    mov al, jogadorAtual
    mov si, offset array
    add si, 22   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next23:
	; Código para a combinação (5, 2) aqui
    cmp POSxE, 24
    jne check_next24
    cmp POSyE, 8
    jne check_next24

    mov al, jogadorAtual
    mov si, offset array
    add si, 23   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next24:
	; Código para a combinação (6, 2) aqui
    cmp POSxE, 20
    jne check_next25
    cmp POSyE, 9
    jne check_next25

    mov al, jogadorAtual
    mov si, offset array
    add si, 24   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next25:
	; Código para a combinação (7, 2) aqui
    cmp POSxE, 22
    jne check_next26
    cmp POSyE, 9
    jne check_next26

    mov al, jogadorAtual
    mov si, offset array
    add si, 25   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next26:
	; Código para a combinação (8, 2) aqui
    cmp POSxE, 24
    jne check_next27
    cmp POSyE, 9
    jne check_next27

    mov al, jogadorAtual
    mov si, offset array
    add si, 26   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
; FIM TABULEIRO 3

check_next27:
	; Código para a combinação (0, 3) aqui
    cmp POSxE, 4
    jne check_next28
    cmp POSyE, 11
    jne check_next28

    mov al, jogadorAtual
    mov si, offset array
    add si, 27   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next28:
	; Código para a combinação (1, 3) aqui
    cmp POSxE, 6
    jne check_next29
    cmp POSyE, 11
    jne check_next29

    mov al, jogadorAtual
    mov si, offset array
    add si, 28   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next29:
	; Código para a combinação (2, 3) aqui
    cmp POSxE, 8
    jne check_next30
    cmp POSyE, 11
    jne check_next30

    mov al, jogadorAtual
    mov si, offset array
    add si, 29   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next30:
	; Código para a combinação (3, 3) aqui
    cmp POSxE, 4
    jne check_next31
    cmp POSyE, 12
    jne check_next31

    mov al, jogadorAtual
    mov si, offset array
    add si, 30   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next31:
	; Código para a combinação (4, 3) aqui
    cmp POSxE, 6
    jne check_next32
    cmp POSyE, 12
    jne check_next32

    mov al, jogadorAtual
    mov si, offset array
    add si, 31   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next32:
	; Código para a combinação (5, 3) aqui
    cmp POSxE, 8
    jne check_next33
    cmp POSyE, 12
    jne check_next33

    mov al, jogadorAtual
    mov si, offset array
    add si, 32   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next33:
	; Código para a combinação (6, 3) aqui
    cmp POSxE, 4
    jne check_next34
    cmp POSyE, 13
    jne check_next34

    mov al, jogadorAtual
    mov si, offset array
    add si, 33   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next34:
	; Código para a combinação (7, 3) aqui
    cmp POSxE, 6
    jne check_next35
    cmp POSyE, 13
    jne check_next35

    mov al, jogadorAtual
    mov si, offset array
    add si, 34   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next35:
	; Código para a combinação (8, 3) aqui
    cmp POSxE, 8
    jne check_next36
    cmp POSyE, 13
    jne check_next36

    mov al, jogadorAtual
    mov si, offset array
    add si, 35   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
; FIM TABULEIRO 4

check_next36:
	; Código para a combinação (0, 4) aqui
    cmp POSxE, 12
    jne check_next37
    cmp POSyE, 11
    jne check_next37

    mov al, jogadorAtual
    mov si, offset array
    add si, 36   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next37:
	; Código para a combinação (1, 4) aqui
    cmp POSxE, 14
    jne check_next38
    cmp POSyE, 11
    jne check_next38

    mov al, jogadorAtual
    mov si, offset array
    add si, 37   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next38:
	; Código para a combinação (2, 4) aqui
    cmp POSxE, 16
    jne check_next39
    cmp POSyE, 11
    jne check_next39

    mov al, jogadorAtual
    mov si, offset array
    add si, 38   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next39:
	; Código para a combinação (3, 4) aqui
    cmp POSxE, 12
    jne check_next40
    cmp POSyE, 12
    jne check_next40

    mov al, jogadorAtual
    mov si, offset array
    add si, 39   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord


check_next40:
	; Código para a combinação (4, 4) aqui
    cmp POSxE, 14
    jne check_next41
    cmp POSyE, 12
    jne check_next41

    mov al, jogadorAtual
    mov si, offset array
    add si, 40   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next41:
	; Código para a combinação (5, 4) aqui
    cmp POSxE, 16
    jne check_next42
    cmp POSyE, 12
    jne check_next42

    mov al, jogadorAtual
    mov si, offset array
    add si, 41   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next42:
	; Código para a combinação (6, 4) aqui
    cmp POSxE, 12
    jne check_next43
    cmp POSyE, 13
    jne check_next43

    mov al, jogadorAtual
    mov si, offset array
    add si, 42   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next43:
	; Código para a combinação (7, 4) aqui
    cmp POSxE, 14
    jne check_next44
    cmp POSyE, 13
    jne check_next44

    mov al, jogadorAtual
    mov si, offset array
    add si, 43   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next44:
	; Código para a combinação (8, 4) aqui
    cmp POSxE, 16
    jne check_next45
    cmp POSyE, 13
    jne check_next45

    mov al, jogadorAtual
    mov si, offset array
    add si, 44   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
; FIM TABULEIRO 5

check_next45:
	; Código para a combinação (0, 5) aqui
    cmp POSxE, 20
    jne check_next46
    cmp POSyE, 11
    jne check_next46

    mov al, jogadorAtual
    mov si, offset array
    add si, 45   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next46:
	; Código para a combinação (1, 5) aqui
    cmp POSxE, 22
    jne check_next47
    cmp POSyE, 11
    jne check_next47

    mov al, jogadorAtual
    mov si, offset array
    add si, 46   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next47:
	; Código para a combinação (2, 5) aqui
    cmp POSxE, 24
    jne check_next48
    cmp POSyE, 11
    jne check_next48

    mov al, jogadorAtual
    mov si, offset array
    add si, 47   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next48:
	; Código para a combinação (3, 5) aqui
    cmp POSxE, 20
    jne check_next49
    cmp POSyE, 12
    jne check_next49

    mov al, jogadorAtual
    mov si, offset array
    add si, 48   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
check_next49:
	; Código para a combinação (4, 5) aqui
    cmp POSxE, 22
    jne check_next50
    cmp POSyE, 12
    jne check_next50

    mov al, jogadorAtual
    mov si, offset array
    add si, 49   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next50:
	; Código para a combinação (5, 5) aqui
    cmp POSxE, 24
    jne check_next51
    cmp POSyE, 12
    jne check_next51

    mov al, jogadorAtual
    mov si, offset array
    add si, 50   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next51:
	; Código para a combinação (6, 5) aqui
    cmp POSxE, 20
    jne check_next52
    cmp POSyE, 13
    jne check_next52

    mov al, jogadorAtual
    mov si, offset array
    add si, 51   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next52:
	; Código para a combinação (7, 5) aqui
    cmp POSxE, 22
    jne check_next53
    cmp POSyE, 13
    jne check_next53

    mov al, jogadorAtual
    mov si, offset array
    add si, 52   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next53:
	; Código para a combinação (8, 5) aqui
    cmp POSxE, 24
    jne check_next54
    cmp POSyE, 13
    jne check_next54

    mov al, jogadorAtual
    mov si, offset array
    add si, 53   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
; FIM TABULEIRO 6

check_next54:
	; Código para a combinação (0, 6) aqui
    cmp POSxE, 4
    jne check_next55
    cmp POSyE, 15
    jne check_next55

    mov al, jogadorAtual
    mov si, offset array
    add si, 54   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next55:
	; Código para a combinação (1, 6) aqui
    cmp POSxE, 6
    jne check_next56
    cmp POSyE, 15
    jne check_next56

    mov al, jogadorAtual
    mov si, offset array
    add si, 55   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next56:
	; Código para a combinação (2, 6) aqui
    cmp POSxE, 8
    jne check_next57
    cmp POSyE, 15
    jne check_next57

    mov al, jogadorAtual
    mov si, offset array
    add si, 56   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next57:   
	; Código para a combinação (3, 6) aqui
    cmp POSxE, 4
    jne check_next58
    cmp POSyE, 16
    jne check_next58

    mov al, jogadorAtual
    mov si, offset array
    add si, 57   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next58:
	; Código para a combinação (4, 6) aqui
    cmp POSxE, 6
    jne check_next59
    cmp POSyE, 16
    jne check_next59

    mov al, jogadorAtual
    mov si, offset array
    add si, 58   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next59:
	; Código para a combinação (5, 6) aqui
    cmp POSxE, 8
    jne check_next60
    cmp POSyE, 16
    jne check_next60

    mov al, jogadorAtual
    mov si, offset array
    add si, 59   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next60:
	; Código para a combinação (6, 6) aqui
    cmp POSxE, 4
    jne check_next61
    cmp POSyE, 17
    jne check_next61

    mov al, jogadorAtual
    mov si, offset array
    add si, 60   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next61:
	; Código para a combinação (7, 6) aqui
    cmp POSxE, 6
    jne check_next62
    cmp POSyE, 17
    jne check_next62

    mov al, jogadorAtual
    mov si, offset array
    add si, 61   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next62:
	; Código para a combinação (8, 6) aqui
    cmp POSxE, 8
    jne check_next63
    cmp POSyE, 17
    jne check_next63

    mov al, jogadorAtual
    mov si, offset array
    add si, 62   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
;;  FIM TABULEIRO 7

check_next63:
	; Código para a combinação (0, 7) aqui
    cmp POSxE, 12
    jne check_next64
    cmp POSyE, 15
    jne check_next64

    mov al, jogadorAtual
    mov si, offset array
    add si, 63   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next64:
	; Código para a combinação (1, 7) aqui
    cmp POSxE, 14
    jne check_next65
    cmp POSyE, 15
    jne check_next65

    mov al, jogadorAtual
    mov si, offset array
    add si, 64   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next65:
	; Código para a combinação (2, 7) aqui
    cmp POSxE, 16
    jne check_next66
    cmp POSyE, 15
    jne check_next66

    mov al, jogadorAtual
    mov si, offset array
    add si, 65   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next66:
	; Código para a combinação (3, 7) aqui
    cmp POSxE, 12
    jne check_next67
    cmp POSyE, 16
    jne check_next67

    mov al, jogadorAtual
    mov si, offset array
    add si, 66   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next67:
	; Código para a combinação (4, 7) aqui
    cmp POSxE, 14
    jne check_next68
    cmp POSyE, 16
    jne check_next68

    mov al, jogadorAtual
    mov si, offset array
    add si, 67   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next68:
	; Código para a combinação (5, 7) aqui
    cmp POSxE, 16
    jne check_next69
    cmp POSyE, 16
    jne check_next69

    mov al, jogadorAtual
    mov si, offset array
    add si, 68   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next69:
	; Código para a combinação (6, 7) aqui
    cmp POSxE, 12
    jne check_next70
    cmp POSyE, 17
    jne check_next70

    mov al, jogadorAtual
    mov si, offset array
    add si, 69   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next70:
	; Código para a combinação (7, 7) aqui
    cmp POSxE, 14
    jne check_next71
    cmp POSyE, 17
    jne check_next71

    mov al, jogadorAtual
    mov si, offset array
    add si, 70   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next71:
	; Código para a combinação (8, 7) aqui
    cmp POSxE, 16
    jne check_next72
    cmp POSyE, 17
    jne check_next72

    mov al, jogadorAtual
    mov si, offset array
    add si, 71   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord
; FIM TABULEIRO 8

check_next72:
	; Código para a combinação (0, 8) aqui
    cmp POSxE, 20
    jne check_next73
    cmp POSyE, 15
    jne check_next73

    mov al, jogadorAtual
    mov si, offset array
    add si, 72   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next73:
	; Código para a combinação (1, 8) aqui
    cmp POSxE, 22
    jne check_next74
    cmp POSyE, 15
    jne check_next74

    mov al, jogadorAtual
    mov si, offset array
    add si, 73   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next74:
	; Código para a combinação (2, 8) aqui
    cmp POSxE, 24
    jne check_next75
    cmp POSyE, 15
    jne check_next75

    mov al, jogadorAtual
    mov si, offset array
    add si, 74   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next75:
	; Código para a combinação (3, 8) aqui
    cmp POSxE, 20
    jne check_next76
    cmp POSyE, 16
    jne check_next76

    mov al, jogadorAtual
    mov si, offset array
    add si, 75   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next76:
	; Código para a combinação (4, 8) aqui
    cmp POSxE, 22
    jne check_next77
    cmp POSyE, 16
    jne check_next77

    mov al, jogadorAtual
    mov si, offset array
    add si, 76   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next77:
	; Código para a combinação (5, 8) aqui
    cmp POSxE, 24
    jne check_next78
    cmp POSyE, 16
    jne check_next78

    mov al, jogadorAtual
    mov si, offset array
    add si, 77   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next78:
	; Código para a combinação (6, 8) aqui
    cmp POSxE, 20
    jne check_next79
    cmp POSyE, 17
    jne check_next79

    mov al, jogadorAtual
    mov si, offset array
    add si, 78   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next79:
	; Código para a combinação (7, 8) aqui
    cmp POSxE, 22
    jne check_next80
    cmp POSyE, 17
    jne check_next80

    mov al, jogadorAtual
    mov si, offset array
    add si, 79   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

check_next80:
	; Código para a combinação (8, 8) aqui
    cmp POSxE, 24
    jne end_coord
    cmp POSyE, 17
    jne end_coord

    mov al, jogadorAtual
    mov si, offset array
    add si, 80   ; Acesso ao elemento 1 do array
    mov [si], al  ; Armazena jogadorAtual no elemento 1 do array
    jmp end_coord

; FIM TABULEIRO 9

end_coord:
    jmp CICLO
	;jmp WINNER

;########################################################################
;VERIFICA WINNER

WINNER:

	BOARD_1:
	;LINHAS
	cmp 

	;COLUNAS


	;DIAGONAIS


;########################################################################

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


		
