extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_using_c
global alternate_sum_4_using_c_alternative
global alternate_sum_8
global product_2_f
global product_9_f

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4:
  sub EDI, ESI
  add EDI, EDX
  sub EDI, ECX

  mov EAX, EDI
  ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4_using_c:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  push R12
  push R13	; preservo no volatiles, al ser 2 la pila queda alineada

  mov R12D, EDX ; guardo los parámetros x3 y x4 ya que están en registros volátiles
  mov R13D, ECX ; y tienen que sobrevivir al llamado a función

  call restar_c 
  ;recibe los parámetros por EDI y ESI, de acuerdo a la convención, y resulta que ya tenemos los valores en esos registros
  
  mov EDI, EAX ;tomamos el resultado del llamado anterior y lo pasamos como primer parámetro
  mov ESI, R12D
  call sumar_c

  mov EDI, EAX
  mov ESI, R13D
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  pop R13 ;restauramos los registros no volátiles
  pop R12
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


alternate_sum_4_using_c_alternative:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  sub RSP, 16 ; muevo el tope de la pila 8 bytes para guardar x4, y 8 bytes para que quede alineada

  mov [RBP-8], RCX ; guardo x4 en la pila

  push RDX  ;preservo x3 en la pila, desalineandola
  sub RSP, 8 ;alineo
  call restar_c 
  add RSP, 8 ;restauro tope
  pop RDX ;recupero x3
  
  mov EDI, EAX
  mov ESI, EDX
  call sumar_c

  mov EDI, EAX
  mov ESI, [RBP - 8] ;leo x4 de la pila
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  add RSP, 16 ;restauro tope de pila
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[?], x2[?], x3[?], x4[?], x5[?], x6[?], x7[?], x8[?]
alternate_sum_8:
	;x1 --> EDI
  ;x2 --> ESI
  ;x3 --> EDX
  ;x4 --> ECX
  ;x5 --> R8D
  ;x6 --> R9D
  ;x7 --> 
  ;x8 -->

	;prologo
  push RBP ;pila alineada
  mov RBP, RSP

  push R9
  push R8
  push RCX
  push RDX

  call restar_c ; EAX <- x1 - x2

  mov EDI, EAX
  pop RDX
  mov ESI, EDX

  ; No tengo alineado el stack, primero hago:
  sub RSP, 8

  call sumar_c ; EAX <- x1 - x2 + x3
  add RSP, 8

  mov EDI, EAX
  pop RCX
  mov ESI, ECX

  call restar_c ; EAX <- x1 - x2 + x3 - x4

  mov EDI, EAX
  pop R8
  mov ESI, R8D

  ; no tengo alineado el stack, primero hago:
  sub RSP, 8

  call sumar_c ; EAX <- x1 - x2 + x3 - x4 + x5
  add RSP, 8

  mov EDI, EAX
  pop R9
  mov ESI, R9D

  call restar_c ; EAX <- x1 - x2 + x3 - x4 + x5 - x6

  mov EDI, EAX
  mov ESI, [RBP + 16] ; Los parámetros se pasan fuera del stack frame, ver Manejo de Pila para más detalles

  call sumar_c ; EAX <- x1 - x2 + x3 - x4 + x5 - x6 + x7

  mov EDI, EAX
  mov ESI, [RBP + 24]

  call restar_c ; EAX <- x1 - x2 + x3 - x4 + x5 - x6 + x7 - x8

	;epilogo
  pop RBP
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[?], x1[?], f1[?]
product_2_f:
  ; destination -> RDI
  ; x1 -> ESI
  ; f1 -> XMM0

  cvtsi2sd XMM1, RSI
  cvtss2sd XMM0, XMM0

  mulsd XMM0, XMM1

  cvttsd2si EAX, XMM0

  mov dword [RDI], EAX   

	ret


;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[esi], f1[xmm0], x2[edx], f2[xmm1], x3[ecx], f3[xmm2], x4[r8], f4[xmm3]
;	, x5[r9], f5[xmm4], x6[RBP + 16], f6[xmm5], x7[RBP + 24], f7[xmm6], x8[RBP + 32], f8[xmm7],
;	, x9[RBP + 40], f9[RBP + 48]
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp

	;convertimos los flotantes de cada registro xmm en doubles
	cvtss2sd XMM0, XMM0
  cvtss2sd XMM1, XMM1
  cvtss2sd XMM2, XMM2
  cvtss2sd XMM3, XMM3
  cvtss2sd XMM4, XMM4
  cvtss2sd XMM5, XMM5
  cvtss2sd XMM6, XMM6
  cvtss2sd XMM7, XMM7

  movss XMM8, [RBP + 48]
  cvtss2sd XMM8, XMM8

	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	mulsd XMM0, XMM1
  mulsd XMM0, XMM2
  mulsd XMM0, XMM3
  mulsd XMM0, XMM4
  mulsd XMM0, XMM5
  mulsd XMM0, XMM6
  mulsd XMM0, XMM7
  mulsd XMM0, XMM8

	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	cvtsi2sd XMM1, RSI
  mulsd XMM0, XMM1

  cvtsi2sd XMM2, RDX
  mulsd XMM0, XMM2

  cvtsi2sd XMM3, RCX
  mulsd XMM0, XMM3

  cvtsi2sd XMM4, R8
  mulsd XMM0, XMM4

  cvtsi2sd XMM5, R9
  mulsd XMM0, XMM5

  mov RSI, [RBP + 16]
  cvtsi2sd XMM6, RSI
  mulsd XMM0, XMM6

  mov RDX, [RBP + 24]
  cvtsi2sd XMM7, RDX
  mulsd XMM0, XMM7

  mov R8, [RBP + 32]
  cvtsi2sd XMM8, R8
  mulsd XMM0, XMM8

  mov R9, [RBP + 40]
  cvtsi2sd XMM9, R9
  mulsd XMM0, XMM9

  movsd [RDI], XMM0 ; destination <- resultado
	; epilogo
	pop rbp
	ret

