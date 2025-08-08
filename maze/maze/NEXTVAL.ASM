;---------------------------------------------------------------------
; Program:   nextval subroutine
;
; Function:  Find next mouse move in an array 15 by 30.
;            We can move into a position if its contents is blank ( 20h ).
;
; Input:     Calling sequence is:
;            x    pointer   si
;            y    pointer   di
;            dir  pointer   bx
;            maze pointer   bp
;
; Output:    x,y,dir modified in caller's data segment
;
; Owner:     Dana A. Lasher
;
; Date:      Update Reason
; --------------------------
; 11/06/2016 Original version
;
;
;---------------------------------------
         .model    small               ;64k code and 64k data
         .8086                         ;only allow 8086 instructions
         public    nextval             ;allow extrnal programs to call
;---------------------------------------


;---------------------------------------
         .data                         ;start the data segment
	
	
	column db 30					   ; Width of columns
		 
;---------------------------------------
         .code                         ;start the code segment
;---------------------------------------
; Save any modified registers
;---------------------------------------
nextval:                               ;
    ; Input: 
    ; bp -> maze address
    ; di -> pointer to current y (1-15)
    ; si -> pointer to current x (1-30)
    ; bx -> pointer to current direction (1-4)                                   ;
                                       ;
;---------------------------------------
; Code to make 1 move in the maze
;---------------------------------------
    ; Load Y and X from pointers into mouse_data
	; Push used registers to maintain for caller
	
;----------------------------------------------------
; SAVE REGISTERS TO RESTORE FOR CALLER
;----------------------------------------------------
	push ax 										 ; Preserve register ax
	push dx 										 ; Preserve register dx 
	push si 										 ; Preserve register si 
	push bx 										 ; Preserve register bx 
	
;----------------------------------------------------

; FIND OFFSET IN MEMORY BASED ON COORDINATES

;----------------------------------------------------
	mov dh, 0										 ; Clear dh for offset 
    mov dl, byte ptr [si]                       	 ; Get current X
;----------------------------------------------------	
; CHANGE COORDINATE TO 0-BASED FOR OFFSET CALCULATION
;----------------------------------------------------
	dec byte ptr [di]                  				 ; Convert Y to 0-based (Y - 1)
    dec dx                             				 ; Convert X to 0-based (X - 1)
;----------------------------------------------------	
; MULTIPLY (Y-1) BY COLUMN WIDTH TO MOVE TO CORRECT ROW
;----------------------------------------------------
	mov al, [di]                       				 ; Move Y to DL to use it for multiplication
	mov bl, [column]                   				 ; Load the column count (30) into BL
    mul bl       					   				 ; DL * BL -> AX = (Y - 1) * 30
;----------------------------------------------------	
; ADD (X-1) TO PRODUCT TO MOVE TO CORRECT COLUMN IN ROW
;----------------------------------------------------
	mov si, ax						   				 ; store in a register that can be used for offset
	add si, dx                         				 ; Final offset: (Y - 1) * 30 + (X - 1) stored in SI
	pop bx                             			     ; move bx back to original position to use for direction checking

;----------------------------------------------------	
; CHECK DIRECTION
;----------------------------------------------------
moves:											     ; cycle check directions
	cmp byte ptr [bx], 1 							 ; EAST
	je moveDown								 		 ; Right from east is Down (south)
	cmp byte ptr [bx], 2			       			 ; SOUTH
	je moveLeft						         		 ; Right from south is Left (west)
	cmp byte ptr [bx], 3 							 ; WEST
	je moveUp										 ; Right from west is Up (north)
	
;----------------------------------------------------	

; CHECK FOR OPEN SPACE

;----------------------------------------------------

;----------------------------------------------------	
; CHECK EAST
;----------------------------------------------------
moveRight:
	cmp byte ptr ds:[bp + si + 1], 20h			    ; Check the position to the right
	je moveR										; Equals? jmp to move
	jmp moveUp										; move to next direction
;----------------------------------------------------	
; CHECK SOUTH
;----------------------------------------------------
moveDown:
    cmp byte ptr ds:[bp + si + 30], 20h             ; Check the down position using BL
	je moveD										; Equals? jmp to move
	jmp moveRight									; move to next direction
;----------------------------------------------------	
; CHECK WEST
;----------------------------------------------------
moveLeft:
	cmp byte ptr ds:[bp + si - 1], 20h				; Check the position to the left
	je moveL										; move to next direction
	jmp moveDown
;----------------------------------------------------	
; CHECK NORTH
;----------------------------------------------------
moveUp:
	cmp byte ptr ds:[bp + si - 30], 20h		    	; Check the position above
	jne moveLeft								    ; If it's equal let if fall through

;---------------------------------------------------

; ALTER X and Y COORDINATES TO BE RETURNED	

;---------------------------------------------------

;----------------------------------------------------	
; MOVE NORTH
;----------------------------------------------------
moveU:
	pop si											; Restore register si
	dec byte ptr [di]  		                		; decrement y to move up
	mov byte ptr [bx], 4							; set direction moved
	jmp exit										; Jump to end of function call because move was made
;----------------------------------------------------	
; MOVE EAST
;----------------------------------------------------
moveR:												
    pop si											; Restore register si
	inc byte ptr [si]  		                		; increment x to move right
	mov byte ptr [bx], 1							; set direction moved
	jmp exit										; Jump to end of function call because move was made
;----------------------------------------------------	
; MOVE SOUTH
;----------------------------------------------------
moveD:
	pop si											; Restore register si
	inc byte ptr [di]  		                		; increment y to move down    
	mov byte ptr [bx], 2							; set direction moved
	jmp exit										; Jump to end of function call because move was made
;----------------------------------------------------	
; MOVE WEST
;----------------------------------------------------
moveL:
	pop si											; Restore register si
	dec byte ptr [si]  		                		; decrement x to move left
	mov byte ptr [bx], 3							; set direction moved
	
;---------------------------------------
; Restore registers and return
;---------------------------------------
exit:   
	pop dx											; Restore register dx
	pop ax											; Restore register ax 
	inc byte ptr [di]                     
                                       ;
         ret                           ;return
;---------------------------------------
         end
		 
