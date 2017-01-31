	org 33000
	
	;the title screen
	ld a,2		;load upper screen
	call 5633	;open 2nd channel
	ld a,71		;white ink(7),black paper(0),bright(64)
	ld (23693),a	;load color settings to screen
	call 3503	;clear screen
	xor a		;clear a
	call 8859	;set boarder colors to permanent
	
title	ld de,press_start	;load string
	ld bc,eostr-press_start	;load length of string
	call 8252		;draw string
	call 3503		;clear screen
	halt
	ld bc,32766		;32766 = B,N,M,SymbolShift,Space
	in a,(c)		;load keys
	rra			;rotate right once for space
	call nc, menu		;if carry jump to main menu
	jp title		;else reloop

menu	call 3503
	ld ixl,50		;xpos
	ld ixh,30		;ypos
	call getPixelAddr
	ld de,ash1
	ld b,16
drawTitle
        ld a,(de)        ;load first byte
        ld (hl),a        ;write to screen mem
        inc de           ;get next byte 
        inc hl           ;get adjecent 8x8 cell
        ld a,(de)        ;load adj cell
        ld (hl),a
        inc de           ;get next byte
        inc ixh          ;get next row byte address
        call getPixelAddr
        djnz drawTitle

	ld de,menu1_string
	ld bc,eostr2-menu1_string
	call 8252
	ld de,menu2_string
	ld bc,eostr3-menu2_string
	call 8252
	
menulo	ld bc,32766	;check for space key press
	in a,(c)
	rra
	call nc,main
	jp menulo

main	
	ld a,56		 ;reset colors
	ld (23693),a	 ;load screen colors to screen
	call 3503	 ;clear screen

	;normal main
        ld a, (playPos_y)      ;load init y player position
	ld ixh,a
        ld a, (playPos_x)       ; x position
	ld ixl,a
	call getPixelAddr

	ld de,ash1       ; ref graphic data
        ld b, 16         ; draw 16 rows

;SCREEN 1 START
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
;SCREEN 1 END


MainLoop
        ;load player position
	ld a,(playPos_y)
	ld ixh,a
	ld a,(playPos_x)
	ld ixl,a
	;check for jump movement
        ld bc,32766       ;keyboard b,n,m,shift,space
        in a,(c)
        rra
        call nc,Jump

	;check for L/R movement
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
	;store player position
	ld a,ixh
	ld (playPos_y),a
	ld a,ixl
	ld (playPos_x),a
	jp MainLoop
        
Jump	call getPixelAddr
	ld b,16
	call ClearSprite
	call jumpPos
	call getPixelAddr
	ld de,ash2
	ld b,16
	call ShiftUp
	halt
ShiftUp
	ld a,(de)         ;load first byte
        ld (hl),a         ;write to screen mem
        inc de            ;get next byte 
        inc hl            ;get adjecent 8x8 cell
        
	ld a,(de)         ;load adj cell
        ld (hl),a
        inc de            ;get next byte
        inc ixh           ;get next row byte address
        call getPixelAddr
        djnz ShiftUp
        ld a,(playPos_y)
	ld ixh,a
	ret

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
jumpPos
	dec ixh
	dec ixh
	dec ixh	
	ld a,ixh
	ld (playPos_y),a
	ret
leftPos
        dec ixl
        dec ixl

	ld a,(playPos_y)
        ld ixh,a        ;get new y position
        ret
rightPos
	inc ixl
	inc ixl
	
	ld a,(playPos_y)
	ld ixh,a
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

playPos_x:
	DEFB 50
playPos_y:
	DEFB 167
isJump:
	DEFB 0

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
	DEFB	22,16,10,"Press Space"	;At,16,12
	defb 	13			;new line
eostr equ $
menu1_string
	DEFB	22,16,12,"Start Game"	
	DEFB	13
eostr2 equ $
menu2_string
	DEFB	22,19,12,"Controls"
	DEFB	13
eostr3 equ $

