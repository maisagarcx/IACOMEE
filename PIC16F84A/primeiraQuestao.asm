#include <p16f84a.inc>
; oscilador externo de 8MHz, sem watch dog timer, com power up timer e sem protecao de codigo
    __config _FOSC_XT & _WDT_OFF & _PWRTE_ON & _CP_OFF

VAR_A EQU 0x0C ; endereco onde sera salvo o A
VAR_B EQU 0x0D ; endereco onde sera salvo o B
VAR_C EQU 0x0E ; endereco onde sera salvo o C
VAR_D EQU 0x0F ; endereco onde sera salvo o D
VAR_E EQU 0x10 ; endereco onde sera salvo o E
VAR_F EQU 0x11 ; endereco onde sera salvo o F
VAR_X EQU 0x12 ; endereco onde sera salvo o X
MULTIPLICADOR EQU 0x13 ; endereco onde sera salvo o MULTIPLICADOR
PROCESSING EQU 0x14 
RESULT EQU 0x15
              
    ORG 0x00 ; inicio do programa principal em 0x00
    GOTO PRIN_START ; pula para o inicio do programa

; label instruction parameter comment
    ORG 0x04 ; inicio do programa de interrupcao em 0x04

; inicio do processo de configurar entradas e saidas
PRIN_START
    BCF STATUS, RP0 ; bank 0 (bit clear file)
    CLRF PORTA ; inicializa PORTA limpando-a (clear file)
    BSF STATUS, RP0 ; bank 1 (bit set file)
    BSF TRISA,RA1
    ; MOVLW 0x02 ; W = 0000 0010 (move literal to worker)
    ; MOVWF TRISA ; as portas A como saida e RA1 como entrada (move worker to file)
    
    BCF STATUS, RP0 ; bank 0 (bit clear file)
    CLRF PORTB ; inicializa PORTB limpando-a (clear file)
    BSF STATUS, RP0 ; bank 1 (bit set file)
    MOVLW 0x00 ; W = 0000 0000 (move literal to worker)
    MOVWF TRISB ; todas as portas B como saida (move worker to file)
    BCF STATUS, RP0 ; bank 0 (bit clear file)

    ; MOVLW 0x00 ; W = 0000 0000
    ; MOVWF PORTB ; todas as saidas iniciam em baixo
    ; MOVLW 0x00 ; W = 0000 0000
    ; MOVWF PORTA ; todas as saidas e entrada iniciam em baixo
; termino do processo de configurar entradas e saidas

; inicio do processo de carregar constantes
    MOVLW 0x02 ; W = 0000 0010
    MOVWF VAR_A ; VAR_A = 0x02 = 0000 0010 = 2
    MOVLW 0x03 ; W = 0000 0011
    MOVWF VAR_B ; VAR_B = 0x03 = 0000 0011 = 3
    MOVLW 0xFD ; W = 1111 1101
    MOVWF VAR_C ; VAR_C = 0xFD = 1111 1101 = -3
    MOVLW 0x08
    ADDWF VAR_A,W
    MOVWF VAR_E
    ; MOVF VAR_A,W ; W = VAR_A = 0x02 = 0000 0010 = 2
    ; ADDLW 0x08 ; W = VAR_A + 0x08
    ; MOVWF VAR_E ; VAR_E = W = VAR_A + 0x08 = 0x10   
    MOVLW 0x04
    MOVWF MULTIPLICADOR         
    MOVLW 0x00
    MOVWF PROCESSING
    GOTO LOOP
; termino do processo de carregar constantes
           
; inicio do loop de ler continuamente RA1, ou seja, VAR_D
LOOP
    BTFSC PORTA,RA1 ; pula próxima linha caso seja 0
    GOTO VAR_D_1
    GOTO VAR_D_0

VAR_D_1
    MOVF VAR_C,W
    ; MOVWF VAR_X
    CALL FUNCTION
    MOVF RESULT,W
    MOVWF VAR_F
    GOTO WRITING
    
VAR_D_0 
    MOVF VAR_E,W
    ; MOVWF VAR_X
    CALL FUNCTION
    MOVF RESULT,W
    MOVWF VAR_F
    GOTO WRITING

WRITING       
    ; MOVF VAR_F,W ; W = VAR_F
    MOVLW 0x00
    ADDWF VAR_F,1 ; SOMAR VAR_F COM 0 E GUARDO EM VAR_F
    ; MOVWF VAR_F

    BTFSC STATUS,Z ; pula próxima linha caso seja 0
    GOTO NEGATIVE_OR_ZERO
    GOTO LESS_OR_MORE_THEN

LESS_OR_MORE_THEN
    BTFSC VAR_F,7 ; pula próxima linha caso seja 0
    GOTO NEGATIVE_OR_ZERO
    GOTO POSITIVE

POSITIVE
    MOVLW 0x05 ; W = 0000 0101
    MOVWF PORTB
    GOTO LOOP ; fim do programa 

NEGATIVE_OR_ZERO
    MOVLW 0x04 ; W = 0000 0100
    MOVWF PORTB
    GOTO LOOP ; fim do programa 

; FATOR = VAX
; PARAMETRO = MULTIPLICADOR
; PRODUTO = PROCESSING
; RESULT

FUNCTION 
    MOVWF VAR_X ; VAR_X ESTA CARREGADA COM O VALOR DE VAR_E OU VAR_C
    MOVF VAR_X,W

M_LOOP
    ADDWF PROCESSING,1
    DECFSZ MULTIPLICADOR,1
    GOTO M_LOOP

    MOVWF PROCESSING
    MOVLW 0x03 
    SUBWF PROCESSING,W
    MOVWF RESULT
    RETURN
    END
