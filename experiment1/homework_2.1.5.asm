SSTACK SEGMENT STACK ; �����ջ��
	DW 32 DUP(?)
SSTACK ENDS

CODE SEGMENT
	ASSUME CS:CODE, SS:SSTACK
START:
	PUSH DS
	XOR AX, AX
	MOV DS, AX
	MOV SI, 3500H
	MOV DI, 3600H ; 
	MOV CX, 8	; ѭ������8��
AA1:
	MOV AL, [SI]
	MOV [DI], AL
	INC SI
	INC DI
	INC AL	; �����Լ�1
	LOOP AA1
	MOV AX, 4C00H
	INT 21H ; EXIT
CODE ENDS
	END START