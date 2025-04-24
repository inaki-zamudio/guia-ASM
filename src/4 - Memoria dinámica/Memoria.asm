extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
; a -> rdi 
; b -> rsi

strCmp:
	.loop:
	; *a == *b == 0 -> .eq
	mov al, [rdi]
	mov bl, [rsi]
	cmp al, bl
	jg .greater
	jl .smaller
	cmp al, 0
	je .eq
	jmp .loop
	
	.smaller:
	mov rax, -1
	jmp .fin

	.greater:
	mov rax, 1
	jmp .fin

	.eq:
	xor rax, rax
	
	.fin:
	ret

; char* strClone(char* a)
strClone:
	ret

; void strDelete(char* a)
strDelete:
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	ret

; uint32_t strLen(char* a)
strLen:
	ret


