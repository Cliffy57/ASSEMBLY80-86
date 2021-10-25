PILE SEGMENT PARA STACK 'PILE' ;On defini la pile
        DW 512 DUP(00) ; define one word 512
PILE  ENDS
;10 = retour a la ligne

DONNEE SEGMENT
	_TITLE_1		DB	' _____________________________________',10,'$'
	_TITLE_2		DB	'|   DI PAOLO Hugo x DI TULLIO Louis   |',10,'$'
	_TITLE_3		DB	'|         \\\ Calculatrice ///        |',10,'$'
	_TITLE_4		DB	'|                                     |',10,'$'
	_TITLE_5		DB	'|_____________________________________|',10,'$'
	_MENU			DB	' 1:(+) ',10,' Choisissez votre operation: $'
	
	_QS				DB	'   $'
	_R_ADD			DB	10,' + $'
	_R_SUB			DB	10,' - $'
	_R_MUL			DB	10,' * $'
	_R_DIV			DB	10,' / $'
	_QE				DB 10,' = $'
	_QUIT			DB	'  Voulez vous quitter le programme ? $',10 ;Define Byte. 8 bits
	_CHOIX    DB  '	 - Oui ou Non (o/n)? $'
	OK		DB 	13 ;carriage return no line feed
	DEL		DB	8 ;On assigne 8 a delete (Backspace pour supprimer lors de la saisie des operandes)
	DELETE	DB	8,' ',8,'$'
DONNEE ENDS


CODE SEGMENT 
WRLN PROC NEAR ;retour a la ligne
		PUSH AX ;stores 16 bit value in the stack.
		PUSH DX ;PUSH and POP work with 16 bit values only!
		MOV DL,10
		MOV AH,2
		INT 21H
		POP DX
		POP AX ;gets 16 bit value from the stack.
		RET ; transfers control to the return address located on the stack
    
WRLN ENDP
SCANINT	PROC NEAR
	;OUTPUT DI
	ASSUME CS:CODE,DS:DONNEE ;directive tells the assembler to assume, that a certain register contains the base of some structure(in your case: segments). In your case, CS and DS point to the code segment and the data segment respectively, both the one and only of their respective kind. So CS is already assumed as a pointer to the code segment, because the code segment is the only one. So is DS
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		MOV DI,0
		MOV CX,4
		SIREAD_CHAR:
			MOV AH,8; On assigne 8 a AH donc on DELETE
			INT 21H
			
			CMP AL,DEL ;Compare AL a DEL
			JE SIACTION_DEL   ;JE = Zéro (Egal)
			CMP AL,OK ;Compare AL a OK
			JE SIACTION_OK ;JE = Zéro (Egal)
			CMP CX,0 
			JE SIREAD_CHAR		;Interruption en cas de caracteres non autorise
			CMP AL,'0' ;Compare AL a la valeur 0
			JB SIREAD_CHAR		;JB = Inférieur -> jump
			CMP AL,'9' ;Compare AL a la valeur 9
			JA SIREAD_CHAR		;JA = Supérieur -> jump
			MOV DL,AL
			MOV AH,2
			INT 21H
			SUB AL,'0' ;Passe du DEC au CHAR
			;DI=NUMBER  AL=DIGIT
			MOV BL,AL	;BL=DIGIT
			MOV AX,10	
			MUL DI		;DX:AX=DI X 10
			ADD AL,BL	;AX = AX + DIGIT
			MOV DI,AX
			;DI=NUMBER
			DEC CX
			
		JMP SIREAD_CHAR
		
	SIACTION_DEL:
		CMP CX,4
		JNB SIREAD_CHAR			; JNB = Pas inférieur
		LEA DX, DELETE
		MOV AH,9
		INT 21H
		;DI=NUMBER
		MOV DX,0
		MOV AX,DI
		MOV BX,10
		DIV BX		;DX:AX DIV BX => AX (MOD => DX)
		MOV DI,AX	;DI <= DI DIV 10
		;
		INC CX
		JMP SIREAD_CHAR
	
	SIACTION_OK:
		CMP CX,4
		JNE SIFIN
		MOV DL,'0'
		MOV AH,2
		INT 21H		
		
	SIFIN:
		POP DX ;Pop Word off Stack
		POP CX ;Désempile du sommet de la pile une valeur et la met dans un emplacement mémoire ou registre
		POP BX ;Cette instruction permet de désempiler de la pile un mot, un double mot ou un quadruple mot et la met dans une opérande.
		POP AX
		RET
SCANINT	ENDP

PRINTINT16	PROC NEAR
	;INPUT DI
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		
		MOV CX,0
		MOV AX,DI
		MOV BX,10
		
	PI16CALC_DIGITS: ;convertit en  16 digits
		MOV DX,0
		DIV BX
		PUSH DX
		INC CX
		CMP AX,0
		JNE PI16CALC_DIGITS
	
	PI16AFF_DIGITS: ;affiche en 16 digits
		POP DX
		ADD DL,'0'
		MOV AH,2
		INT 21H
		LOOP PI16AFF_DIGITS
		
		POP DX 
		POP CX
		POP BX
		POP AX
		RET
PRINTINT16 ENDP



PROG_ADDITION PROC NEAR
		PUSH AX
		PUSH DX
		PUSH SI ;Source Index points to a source in stream operations
		PUSH DI ;points to a destination in stream operations
	;'   ' espace
		LEA DX,_QS ;Load effective adress dans DX
		MOV AH,9
		INT 21H
	;NBR 1 DANS SI
		CALL SCANINT
		MOV SI,DI
	;' + '
		LEA DX,_R_ADD
		MOV AH,9 
		INT 21H
	;NBR 2 DANS DI
		CALL SCANINT
	;' = '
		LEA DX,_QE
		MOV AH,9
		INT 21H		
	;RESULT	  
		ADD DI,SI
		CALL PRINTINT16
		CALL WRLN
		
		POP DI
		POP SI
		POP DX
		POP AX
		RET
PROG_ADDITION ENDP


PROG    PROC NEAR
        ASSUME CS:CODE;DS:DONNEE;SS:PILE;ES:NOTHING
        MOV AX,DONNEE
        MOV DS,AX
		
		;AFFICHAGE DE L'ENTETE
				MOV AH,9
				LEA DX,_TITLE_1
				INT 21H
				LEA DX,_TITLE_2
				INT 21H
				LEA DX,_TITLE_3
				INT 21H
				LEA DX,_TITLE_4
				INT 21H
				LEA DX,_TITLE_5
				INT 21H
			
		_P_MENU:;AFFICHAGE DU MENU			
				MOV AH,9
				LEA DX,_MENU
				INT 21H
			;CHOIX
				MOV AH,1
				INT 21H
				CALL WRLN
			;TEST SELECTION
		_P_ADDITION:
				CMP AL,'1'
				CALL PROG_ADDITION
				JMP _P_REPEAT
				
		_P_REPEAT:
			MOV AH,9
			LEA DX, _QUIT
			INT 21H
			CALL WRLN
			LEA DX, _CHOIX	
			INT 21H
			;SAISIE DE LA REPONSE
			MOV AH,1
			INT 21H
			CALL WRLN
			;TRAITEMENT DE LA REPONSE
			CMP AL,'n'
			JE _P_MENU
			CMP AL,'o'
			JNE _P_REPEAT
		
		_P_END:
			MOV	AX,4C00H ;RETOUR AU DOS
			INT	21H
		
PROG  ENDP
CODE ENDS
        END  PROG