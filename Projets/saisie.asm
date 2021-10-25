			TITLE			DISPLAY - programme prototype
			
			ASSUME CS:CSEG, DS:CSEG, ES:CSEG
			.286
;==================================================			
SSEG 		SEGMENT			STACK
			DB 32 DUP("STACK---")
SSEG		ENDS
;========Segment de donnée==============================
DSEG 		SEGMENT
MESSAGE		DB "bonjour, voici un message",0DH,0AH
L_MESSAGE	EQU $-MESSAGE
CHAINE 		DB "Veuillez saisir une chaine de caracteres:", 24H
TAMPON		DB 80,?,80 DUP("$")
nomfich 	db"FICHIER.TXT",0
numfich 	DW ?

DSEG 		ENDS
;=================================================
;=======Zone de Macros============
CRLF MACRO
			MOV AH,02
			MOV DL,0DH
			INT 21H
			MOV DL,0AH
			INT 21H
	ENDM
;=====================================
CSEG 		SEGMENT 'CODE'
			ASSUME		CS:CSEG, SS:SSEG, DS:DSEG
MAIN 		PROC FAR
			PUSH DS
			PUSH 0
			MOV AX,DSEG
			MOV DS,AX 
;===============================================

;********************Affichage INT 21-09
			MOV AH,09H
			LEA DX,CHAINE
			INT 21H
			CRLF
			
;*********************Saisie INT 21-0A
			MOV AH,0AH
			LEA DX,TAMPON
			INT 21H
			CRLF;****************Affichage INT 21:40
			MOV BX,0001H
			LEA DX,MESSAGE
			MOV CX,L_MESSAGE
			MOV AH,40H
			INT 21H
			CRLF
;********************Affichage INT 21-09
			MOV AH,09H
			LEA DX,TAMPON+2
			INT 21H
			CRLF
			
;*******************Création fichier INT 21-3C
		MOV AH,3CH
		LEA DX,nomfich
		MOV CX,0
		INT 21H
		MOV numfich,AX
		
;*******************ouverture fichier INT 21-3D
		MOV AH,3DH
		MOV AL,02H
		LEA DX,nomfich
		INT 21H
		MOV numfich,AX

;****************ecriture fichier INT 21:40
			MOV BX,numfich
			LEA DX,Tampon
			MOV CX,80
			MOV AH,40H
			INT 21H
			CRLF
			
;****************fermeture fichier INT 21:3E
			MOV AH,3EH
			MOV BX,numfich
			INT 21H						

;=============================================
			RET
			MAIN ENDP
CSEG		ENDS
			END MAIN
