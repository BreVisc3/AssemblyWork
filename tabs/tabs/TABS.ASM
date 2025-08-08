;--------------------------------------------------------------------
;   Program:     COPYFILE *** MASM VERSION ***
;
;   Function:    This program will read characters from the standard input
;                device.  This can be the keyboard or a file that has been
;                redirected to the standard input.
;
;                It allows the software to examine each character.
;
;                The character is then written to the standard output device.
;                This can be the diplay or a file that has been redirected
;                to the standard output.
;
;				 Split tab input to print spaces until the next tab stop
;
;                The program terminates when the character that has been
;                read and echoed matches the character stored in the
;                variable named 'end_char'.
;   Owner:       Dana Lasher
;
;   Date         Reason
;   ----         ------
;   07/18/2000   New version
;
;---------------------------------------
         .model    small               ; 64k data and 64k code model
         .8086                         ; only allow 8086 instructions
         .stack    256                 ; stack size is 256 bytes
;---------------------------------------
         .data
;---------------------------------------
; The program ends when the last character
; read and echoed matches this variable.
; 1Ah=EOF   0Dh=ENTER
;---------------------------------------
end_char db        0Dh                 ; termination character
tab      db        09h				   ; tab characters
tabstop  db        0Ah                 ; column width
;---------------------------------------
         .code
;---------------------------------------
; Establish addressability to the data segment.
;---------------------------------------
start:                                 ;
         mov       ax,@data            ; establish addressability
         mov       ds,ax     		   ; for the data segment
		 mov 	   bl, 0			   ; set tabstop column count to 0
		 
		 cmp       byte ptr es:[80h], 0      ; access the CLP count 80h bytes into the extra segment       
		 je        getloop               ; no parameter ... continue with the program      
		 mov       al, byte ptr es:[82h]     ; parameter entered ... load al with the character    
		 sub       al, '0'              ; convert to decimal
		 mov       [tabstop], al         ; set tabstop
;---------------------------------------
; Read a charcter without echo.
;---------------------------------------
getloop:                               ;
         mov       ah,8                ; read without echo a character
         int       21h                 ; how: set ah=8 and issue int 21
;---------------------------------------
; The character is now available in the
; al register for processing.
;---------------------------------------

		 cmp      al, tab			   ; compare to tab character
		 jne	  write_char    	   ; write character if its not a tab
		 
space:
		 cmp       bl, [tabstop]	   ; compare 
		 je        newline			   ; if column is already 10 jump pack
		 mov       dl, 20h			   ; move ' ' into dl
		 mov       ah, 2			   	   ; set interupt
		 int       21h				   ; print space
		 add       bl, 1			   ; increment column
		 jne       space                ; if not yet reached, continue printing spaces
         jmp       getloop              ; once tabstop is reached, read next char
		
newline:
		 mov       bl, 0			   ; set column counter to 0
		 jmp       getloop			   ; jump back to read character
;---------------------------------------
; Write out the character and loop if it
; is not the terminating character.
;---------------------------------------
write_char:
         mov       dl,al               ; move the char to dl
         mov       ah, 2               ; write the character from dl
         int       21h    	    	   ; how: set ah=2 and issue int 21
		 add 	   bl, 1               ; increment column
		 cmp       al, 1Ah			   ; compare to EOF to to jump back to character read
		 je        exit 
		 cmp       al, end_char		   ; Compare to carraige return
 		 je 	   newline             ; set column to 0
		 cmp       bl, [tabstop]         ;
		 je        newline             ; set column to 0 if cap reached
		 cmp       al, 0Ah         ;
		 je        newline             ; set column to 0 if line feed
		 jmp       getloop
									   
;---------------------------------------
; When the terminating characater has
; been read and echoed, return to DOS.
;---------------------------------------
exit:                                  ; we processed the terminating character
         mov       ax,4c00h            ; set correct exit code in ax
         int       21h                 ; int 21 will terminate program
         end       start               ; execution begins at the label start
;---------------------------------------
