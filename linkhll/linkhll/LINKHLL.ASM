;-----------------------------------------------------------
;
; Program: Linkhll
;
; Function: Multiply two largest numbers out of four
;		INPUT: 4 unsigned word-sized numbers 
;			stored on the stack
;
;		OUTPUT: The product of multiplying the
;			two largest numbers in dx:ax
;
; Owner: Brendan Viscount
;
; Date: 10/23/2024
; 11/21/2016   Original Version
;
;
;---------------------------------------
         .model    small               ;
         .8086                         ;
         public    _linkhll            ;
;---------------------------------------
         .data
;---------------------------------------
;
; Data Segment
;
;---------------------------------------
         .code
;---------------------------------------
;
; Code Segment
;
;---------------------------------------
_linkhll: 

	;---------------------------------------
	; Load in parameters from the stack
	;---------------------------------------
	push bp				   ; Save base pointer location
	mov bp, sp             ; Move stack point to base pointer               
    mov ax, [bp + 4]       ; Load v1
    mov bx, [bp + 6]       ; Load v2
    mov cx, [bp + 8]       ; Load v3
    mov dx, [bp + 10]      ; Load v4

;---------------------------------------
;
; SORTING TO GET 2 LARGEST IN AX AND BX
;
;---------------------------------------

	;---------------------------------------
	; Compare ax and cx
	;---------------------------------------
	cmp ax, cx			   ; If cx is above, ax then swap
	ja  skip2			   ; Skip if not
	xchg ax, cx			   ; Swap bx and dx
	;---------------------------------------
	; Compare ax and dx
	;---------------------------------------
skip2:
	cmp ax, dx			   ; If dx is above, ax then swap
	ja skip3			   ; Skip if not
	xchg ax, dx			   ; Swap bx and dx
	;---------------------------------------
	; Compare bx and cx
	;---------------------------------------
skip3:
	cmp bx, cx			   ; If cx is above, bx then swap
	ja skip4			   ; Skip if not
	xchg bx, cx			   ; Swap bx and dx
	;---------------------------------------
	; Compare bx and dx
	;---------------------------------------
skip4:
	cmp bx, dx			   ; If dx is above, bx then swap
	ja mult			   	   ; No more swaps time to multiply
	xchg bx, dx			   ; Swap bx and dx

;---------------------------------------
;
; MULTIPLY
;
;---------------------------------------
mult:
	mul bx				   ; Multiply bx and ax (Largest 2 values now)

;---------------------------------------
;
; RESTORE
;
;---------------------------------------		
	pop bp				   			   ; Restore base pointer
	
	;-----------------------------------
	; Return
	;-----------------------------------
         ret                           ; return
                                       ;
         end                           ; end source code
;---------------------------------------

