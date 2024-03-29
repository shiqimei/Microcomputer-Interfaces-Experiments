IOY0         EQU   0600H          ;片选IOY0对应的端口始地址 
MY8255_A     EQU   IOY0+00H*2     ;8255的A口地址 
MY8255_B     EQU   IOY0+01H*2     ;8255的B口地址 
MY8255_C     EQU   IOY0+02H*2     ;8255的C口地址 
MY8255_CON   EQU   IOY0+03H*2     ;8255的控制寄存器地址 
 
SSTACK SEGMENT STACK   
	DW 16 DUP(?)
SSTACK ENDS

DATA   SEGMENT 
	DTABLE DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H   
	DB 7FH,6FH,77H,7CH,39H,5EH,79H,71H
DATA   ENDS 
 
CODE  SEGMENT        
	ASSUME CS:CODE,DS:DATA 
START: MOV AX,DATA   
	MOV DS,AX    
	MOV SI,3000H   
	MOV AL,00H   
	MOV [SI],AL     ;清显示缓冲 
	MOV [SI+1],AL   
	MOV [SI+2],AL   
	MOV [SI+3],AL   
	MOV [SI+4],AL   
	MOV [SI+5],AL   
	MOV DI,3005H
	; 3 steps
	MOV DX,MY8255_CON   ;写8255控制字   
	MOV AL,81H  ; 1 00(A) 0(A output)0(C high ouptput) 0(B) 0(B ouptput)1(c low input)
	OUT DX,AL
BEGIN: CALL DIS     ; display   
	CALL CLEAR     ;清屏   
	CALL CCSCAN     ;扫描   
	JNZ INK1       ; if one key is down  
	JMP BEGIN 
INK1: CALL DIS   ; display first key\'s position
	CALL DALLY   
	CALL DALLY   
	CALL CLEAR   ; clear screen
	CALL CCSCAN  ; the second key
	JNZ INK2     ;有键按下，转到INK2   
	JMP BEGIN ;确定按下键的位置 
INK2: MOV CH,0FEH   
	MOV CL,00H 
COLUM: MOV AL,CH   
	MOV DX,MY8255_B      ; X direction    
	OUT DX,AL   
	MOV DX,MY8255_C      ; Y direction
	IN AL,DX 
L1:  TEST AL,01H            ;is L1?   
	JNZ L2   
	MOV AL,00H             ;L1   
	JMP KCODE 
L2:  TEST AL,02H            ;is L2?   
	JNZ L3   
	MOV AL,04H             ;L2   
	JMP KCODE 
L3:  TEST AL,04H            ;is L3?   
	JNZ L4 
	MOV AL,08H             ;L3   
	JMP KCODE 
L4:  TEST AL,08H            ;is L4?   
	JNZ NEXT   
	MOV AL,0CH             ;L4 
KCODE: ADD AL,CL   
	CALL PUTBUF   
	PUSH AX 
KON:  CALL DIS   
	CALL CLEAR   
	CALL CCSCAN   
	JNZ KON   
	POP AX 
NEXT: INC CL   
	MOV AL,CH   
	TEST AL,08H   
	JZ KERR   
	ROL AL,1   
	MOV CH,AL   
	JMP COLUM 
KERR: JMP BEGIN 
 
CCSCAN: MOV AL,00H     ;键盘扫描子程序   
	MOV DX,MY8255_B  ;X direction     
	OUT DX,AL
	MOV DX,MY8255_C  ;Y direction    
	IN  AL,DX        ; c low input  
	NOT AL           ; has input
	AND AL,0FH       ; 0000 1111 (only check low 4 bits)
	RET 

CLEAR: MOV DX,MY8255_B    ;清屏子程序   
	MOV AL,00H   
	OUT DX,AL   
	RET 

DIS: PUSH AX      ;显示子程序   
	MOV SI,3000H   
	MOV DL,0DFH   
	MOV AL,DL 

AGAIN: PUSH DX 
	MOV DX,MY8255_B ; X direction    
	OUT DX,AL   
	MOV AL,[SI]   ; LED position
	MOV BX,OFFSET DTABLE   
	AND AX,00FFH  ; only get low 4 bits    
	ADD BX,AX  
	MOV AL,[BX]   
	MOV DX,MY8255_A ; display    
	OUT DX,AL   
	CALL DALLY   
	INC SI   ; the next LED 
	POP DX   ; -> the previous DX  
	MOV AL,DL   
	TEST AL,01H   
	JZ  OUT1   
	ROR AL,1 ; rotate right 
	MOV DL,AL   
	JMP AGAIN 
OUT1: POP AX   
RET 

DALLY: PUSH CX      ;延时子程序   
	MOV CX,0006H 
T1:  MOV AX,009FH 
T2:  DEC AX   
	JNZ T2   
	LOOP T1   
	POP CX   
	RET 

PUTBUF: MOV SI,DI     ;存键盘值到相应位的缓冲中   
	MOV [SI],AL   
	DEC DI   
	CMP DI,2FFFH   
	JNZ GOBACK   
	MOV DI,3005H 
GOBACK: RET 
 
CODE ENDS   
	END START