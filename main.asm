	org 33000
	ld a,2		;upper screen
	call 5633	;open 2nd channel
	ld a,71		;black screen white ink
	ld (23693),a	;load colors to screen
	call 3503	;clear screen
	xor a
	call 8859	;set permanent boarder colors
	
title	ld de,press_start	;load string
	ld bc,eostr-press_start	;load length of string
	call 8252		;draw string
	ld bc,32766		;23560 = last key pressed
	in a,(c)
	rra
	call nc, main
	jp title

main	call 3503	 ;clear screen
	ld a,56		 ;reset colors
	ld (23693),a	 ;load screen colors
	;normal main
        ld ixh, 167      ; y position   
        ld ixl, 50       ; x position

	call getPixelAddr
        ;push ix          ; save position of sprite
	ld (32900),ix	 ;store player position to 32900
	
        ld de,ash1       ; ref graphic data
        ld b, 16         ; draw 16 rows

DrawSprite
     
        ld a,(de)        ;load first byte
	ld (hl),a        ;write to screen mem
        inc de           ;get next byte 
        inc hl           ;get adjecent 8x8 cell
        ld a,(de)        ;load adj cell
        ld (hl),a
        inc de           ;get next byte
        inc ixh          ;get next row byte address
        call getPixelAddr
	djnz DrawSprite

        ld iy,0          ;32 columns to draw

DrawPlatforms
        ld ixl, 0         ; x position

ChangedX
        ld ixh, 184       ; y position
	call getPixelAddr
        ld de,platform    ; ref graphic data
        ld b, 8           ; draw 8 rows

DrawNextCell

        ld a,(de)         ;load first byte
	ld (hl),a         ;write to screen mem
        inc de            ;get next byte
        inc ixh           ;get next row byte address
        call getPixelAddr
	djnz DrawNextCell

        inc iy            ;next column
        ld a, iyl
        cp 32
        inc ixl 
        jp nz,ChangedX



MainLoop
        ;pop ix
	ld ix,(32900)	  ;load character
        ld bc, 65022      ;keyboard asdfg ports
        in a, (c)         ;what keys were pressed
        rra               ;was "a" pressed?
        push af      
        call nc, MoveLeft
        pop af
        rra		  ;rotate right, skip "s" for now
	rra		  ;rotate right for "d" key
	push af
	call nc, MoveRight
	pop af
	;push ix
	ld (32900),ix
        jp MainLoop
        

MoveLeft
      
        call getPixelAddr   ;get our hl coord
        ld b,16
        call ClearSprite
        
        call leftPos        ;get new left position coords
        call getPixelAddr   ;get screen address
        ld de,ash2          ; ref graphic data
        ld b, 16            ; draw 16 rows
        call ShiftLeft
        halt 
       
                            ;next frame of animation
        ld b,16
        call ClearSprite
        dec ixl
        call getPixelAddr
        ld de,ash1;
        ld b,16;
        call ShiftLeft

        halt
        ret
       
MoveRight
	call getPixelAddr
	ld b,16
	call ClearSprite
	
	call rightPos
	call getPixelAddr
	ld de,ash2_r
	ld b,16
	call ShiftRight
	halt
	
			    ;load second frame
	ld b,16
	call ClearSprite
	inc ixl
	call getPixelAddr
	ld de,ash1_r
	ld b,16
	call ShiftRight
	halt
	ret
ShiftLeft
     
        ld a,(de)         ;load first byte
	ld (hl),a         ;write to screen mem
        inc de            ;get next byte 
        inc hl            ;get adjecent 8x8 cell
        ld a,(de)         ;load adj cell

        ld (hl),a
        inc de            ;get next byte
        inc ixh           ;get next row byte address
        call getPixelAddr
	djnz ShiftLeft
        ld ixh,167
        ret
        
ShiftRight
	ld a,(de)
	ld (hl),a
	inc de
	inc hl
	ld a,(de)
	
	ld (hl),a
	inc de
	inc ixh
	call getPixelAddr
	djnz ShiftRight
	ld ixh,167
	ret
leftPos
        dec ixl
        dec ixl

        ld ixh,167        ;get new x position
        ret
rightPos
	inc ixl
	inc ixl
	
	ld ixh,167
	ret

ClearSprite
        ld a, 0
        ld (hl),a
        inc hl           ;get adjecent 8x8 cell
        ld (hl),a
        inc de           ;get next byte
        inc ixh          ;get next row byte address
        call getPixelAddr
	djnz ClearSprite
        ld ixh ,167
        ret
        
wait
        ld bc,$1fff
	dec bc
	ld a,b
	or c
	jr nz, wait

gameover

	ret; 

getPixelAddr            ;Source:http://www.animatez.co.uk/computers/zx-spectrum/screen-memory-layout/

        LD A,ixh        ; Calculate Y2,Y1,Y0
        AND %00000111   ; Mask out unwanted bits
        OR %01000000    ; Set base address of screen
        LD H,A          ; Store in H
        LD A,ixh          ; Calculate Y7,Y6
        RRA             ; Shift to position
        RRA
        RRA
        AND %00011000   ; Mask out unwanted bits
        OR H            ; OR with Y2,Y1,Y0
        LD H,A          ; Store in H
        LD A,ixh         ; Calculate Y5,Y4,Y3
        RLA             ; Shift to position
        RLA
        AND %11100000   ; Mask out unwanted bits
        LD L,A          ; Store in L
        LD A,ixl         ; Calculate X4,X3,X2,X1,X0
        RRA             ; Shift into position
        RRA
        RRA
        AND %00011111   ; Mask out unwanted bits
        OR L            ; OR with Y5,Y4,Y3
        LD L,A          ; Store in L
        RET

ash2
	DEFB	  0,  0, 15,224, 31,240, 63,248
	DEFB	127,248,127,252, 63,252, 21,252
	DEFB	 20,152, 16,144,  8,104,  7,232
	DEFB	 31,152, 36,148, 19,228, 14, 24
	DEFB	 56, 56, 56, 56
ash1
        DEFB	 15,224, 31,240, 63,248,127,248
	DEFB	127,252, 63,252, 21,252, 20,152
	DEFB	 16, 16,  8,104,  7,200,  3, 40
	DEFB	  3, 40,  4,240,  4, 32,  3,192
	DEFB	 56, 56, 56, 56
ash1_r
	DEFB	  7,240, 15,248, 31,252, 31,254
	DEFB	 63,254, 63,252, 63,168, 25, 40
	DEFB	  8,  8, 22, 16, 19,224, 20,192
	DEFB	 20,192, 15, 32,  4, 32,  3,192
	DEFB	 56, 56, 56, 56
ash2_r	
	DEFB	  0,  0,  7,240, 15,248, 31,252
	DEFB	 31,254, 63,254, 63,252, 63,168
	DEFB	 25, 40,  9,  8, 22, 16, 23,224
	DEFB	 25,248, 41, 36, 39,200, 24,112
	DEFB	 56, 56, 56, 56
	
platform

        DEFB	255,255,129,129,255,129,129,129
	DEFB	 56

press_start
	DEFB	22,16,12,"Press Space"	;At,16,12
	defb 	13			;new line
eostr equ $	
