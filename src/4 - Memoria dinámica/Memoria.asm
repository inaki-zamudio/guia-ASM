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
	mov byte al, [rdi] ; guardamos en registro de 1 byte
	mov byte cl, [rsi]
	cmp al, cl 
	jg .greater
	jl .smaller
	cmp al, 0 
	je .eq 	; *a == *b == 0 -> .eq
	inc rdi
	inc rsi
	jmp .loop
	
	.smaller:
	mov eax, 1
	jmp .fin

	.greater:
	mov eax, -1
	jmp .fin

	.eq:
	xor eax, eax

	.fin:
	ret

; GUARDA: NO ROMPER REGISTROS NO VOLÁTILES (ej: no podríamos haber usado el registro bl)
; nos deberíamos asegurar de preservarlos (push bla bla)

; char* strClone(char* a)
strClone:
	push rbp
	mov rbp, rsp

	; quiero conservar r12
	push r12
	mov r12, rdi

	call strLen
	mov rdi, rax
	inc rdi
	call malloc ; rax = puntero al inicio de la mem reservada

	mov rdx, rax

	.loop:
	mov cl, [r12]
	mov [rdx], cl ; escribo el primer byte
	cmp cl, 0
	je .fin
	
	inc rdx
	inc r12
	jmp .loop

	.fin:
	pop r12
	pop rbp
	ret

; void strDelete(char* a)
strDelete:
	push rbp
	mov rbp, rsp

	call free

	pop rbp
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	
	ret

; uint32_t strLen(char* a)
strLen:
	xor rax, rax
	.loop:
	mov byte cl, [rdi]
	cmp cl, 0
	je .fin
	inc eax
	inc rdi
	jmp .loop

	.fin:
	ret