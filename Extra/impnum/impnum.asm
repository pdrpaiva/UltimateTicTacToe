;------------------------------------------------------------------------
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2020/2021
;--------------------------------------------------------------
; Demostração duma rotina de calculo de números aleatórios 
;
;--------------------------------------------------------------

.8086
.MODEL SMALL
.STACK 2048

DADOS	SEGMENT PARA 'DATA'
	num_16 dw	123

	str_num db 	6 dup(?),'$'
DADOS	ENDS

CODIGO	SEGMENT PARA 'CODE'
	ASSUME CS:CODIGO, DS:DADOS

;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da página
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

;########################################################################
; MOSTRA - Faz o display de uma string terminada em $

MOSTRA MACRO STR 
MOV AH,09H
LEA DX,STR 
INT 21H
ENDM

;########################################################################
; FIM DAS MACROS


;------------------------------------------------------
;impnum - imprime um numero de 16 bits na posicao do cursor
;Parametros passados por registo
;entrada:
;AX - numero a imprimir
;saida:
;não tem parametros de saída
;notas adicionais:
; deve estar definida uma variavel => str_num db 5 dup(?),'$'
; assume-se que DS esta a apontar para o segmento onde esta armazenada str_num

impnum proc near

	push	bx
	push	cx
	push	dx
	push	di
	
	lea		di,[str_num+5]
	mov		cx,5
	
prox_dig:
	xor		dx,dx
	mov		bx,10
	div		bx
	add		dl,'0' ; dh e' sempre 0
	dec		di
	mov		[di],dl
	loop	prox_dig

	MOSTRA str_num

	pop		di
	pop		dx
	pop		cx
	pop		bx

	ret		
impnum endp



;########################################################################

PRINC PROC
	MOV	AX, DADOS
	MOV	DS, AX


	goto_xy	60, 10
	mov		ax, num_16
	call	impnum

	MOV	AH,4Ch
	INT	21h
PRINC ENDP


CODIGO	ENDS
END	PRINC

