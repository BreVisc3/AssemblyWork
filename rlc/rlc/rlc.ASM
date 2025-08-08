;---------------------------------------------------------------------
;  Program:      Run Length Coding
;
;  Function:     Decompresses 1 dimensional run lengths
;                This subroutine links with a C main program
;
;                Add your additional functional comments
;
;  Owner:		 Brendan Viscount
;
;  Changes:
;  Date          Reason
;  ----          ------
;  05/16/2017    Original version ... coded to spec design
;---------------------------------------------------------------------
         .model    small
         .8086
         public    _rlc
;---------------------------------------
         .data                         ;start the data segment
;---------------------------------------

	white db 20h    					;white character
	black db 0DBh   					;black character
	linelength dw 50h                   ;line Length
	fillflag db 0Fh

;---------------------------------------
         .code                         ;start the code segnment
;---------------------------------------
; Save the registers ... 'C' requires (bp,si,di)
; Access the input and output lists
;---------------------------------------
_rlc:                                  ;
         push      bp                  ;save 'C' register
         mov       bp,sp               ;set bp to point to stack
         push      si                  ;save 'C' register
         push      di                  ;save 'C' register
		 push      dx           	   ;save 'C' register
		 push      cx                  ;save 'C' register
		 push      bx                  ;save 'C' register
		 push      ax				   ;save 'C' register
         mov       si,[bp+4]           ;si points to the input compressed data
         mov       di,[bp+6]           ;di points to the empty output buffer
;---------------------------------------
;     PREPARE DATA FOR PROCCESSING
;---------------------------------------

		 mov       ax, ds              ; Set Data segment address to extra
		 mov       es, ax				
		 cld                           ; set direction flag for lodsb and stosb to increment
		 
newline: 
		 mov       dx, [linelength]    ; reset remaining spaces
		 mov       bx, 0DB20h          ; Color data storage [black][white]
;---------------------------------------
;     LOAD DATA FOR 2 RUNS INTO AL
;---------------------------------------
process_next:
		 lodsb                         ; Load from si to al
		 
		 cmp       al, 00h             ; Compare to end of input marker
		 je        exit                ; Jump to end
		 
;---------------------------------------
;     READING FIRST RUN FOR BYTE
;---------------------------------------
		 mov       cx, 4               ; load into shiftable reg
		 mov       ah, al              ; Preserve byte data in AH
		 shr       al, cl              ; Shift the upper four bits of al to get the first run length
		 
		 mov       cl, al              ; Set first length to loop counter register 
		 mov       al, bl             ; Move current color char into reg used by stosb
		 
		 cmp        cl, 00Fh           ; compare to fill byte
		 je         fill_first         ; jump to fill line   <- IF I'M USING 2 LABELS
		 
		 sub       dx, cx              ; Adjust remaining spaces
		 
		 rep stosb                     ; store AL to DI 
		 xchg       bl, bh             ; Toggle color (switch between 20h and DBh)
		 
;---------------------------------------
;     READING SECOND RUN FOR BYTE
;---------------------------------------		 
read_second:
		 mov        al, ah              ; Load preserved byte into AL
		 and        al, 0Fh             ; Mask to preserve lower 4 bits (second run)
		 
		 mov        cl, al              ; Set counter for second
		 mov        al, bl              ; Set current color to
		 
		 cmp        cl, 00Fh            ; compare to fill byte
		 je         fill_remaining      ; jump to fill line 
		 
		 sub        dx, cx              ; Adjust remaining spaces
		 
		 rep stosb                     ; store Al to DI, CX times
		 xchg       bl, bh             ; Toggle color
		 jmp        process_next       ; Repeat for next byte
		 

;---------------------------------------
;     FILL THE REST OF LINE 
;---------------------------------------
fill_first:
		 ;;;MAYBE USE EXTRA LABEL TO DETERMINE WHERE TO JUMP AFTER
		 mov       cx, dx              ; set remaining spaces into cx
         rep stosb                     ; Fill the remaining space with the current color
		 mov       bx, 0DB20h          ; Color data storage [black][white]
		 mov       dx, [linelength]    ; reset remaining spaces
		 jmp       read_second         ; go to processing the lower 4 bits
fill_remaining:

         mov       cx, dx              ; set remaining spaces into cx
         rep stosb                     ; Fill the remaining space with the current color
		 jmp       newline             ; 
		 
		 ;;;FIGURE OUT IF FIRST OR SECOND BYTE WAS FILL
		 
		; and       ah, 0Fh             ; Mask to preserve lower 4 bits (second run)
		; cmp       ah, 
		; je        read_second         ; jump to read second byte if fill was the high 4 bits
		; jmp       process_next		 ; if fill character was in higher 4 bits jmp read_second

;---------------------------------------
;     RESTORE REGISTERS AND RETURN
;---------------------------------------
exit:
         pop       ax                  ; Restore registers
		 pop	   bx
		 pop       cx
         pop       dx
         pop       di
         pop       si
         pop       bp
         ret                           ; Return
;---------------------------------------
         end