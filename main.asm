	


                org 33000
	di

title	ld hl, 16384            ;clear screen
        ld de, 16385
        ld bc, 6143           
        ld (hl), 0
        ldir                    ;increment hl de, decrement bc
        ld b, 192               ;192 lines to draw
        ld ix, 0                ;start at 0,0
        call getPixelAddr
                                ;move address to de reg
        ld d, h
        ld e, l           
        ld hl, TITLE           ;title reference

lineloop 
        ld a, b
        ld bc, 32               ;copy graphic data to display file
        ldir
        ld b,a
        inc ixh                 ;next row byte
        ld ixl, 0
        push hl
        call getPixelAddr
        ld d, h
        ld e, l  
        pop hl                
        djnz lineloop
        
       
        ld de, 22528            ;set attribute color
        ld bc, 768
        ldir
        ld a, 0
        call 8859               ;set border color
        ei 

main	
	
	;normal main
        ld a, (playPos_y)       ;load init y player position
	ld ixh,a
        ld a, (playPos_x)       ; x position
	ld ixl,a
	call getPixelAddr

	ld de,ash1              ; ref graphic data
        ld b, 16                ; draw 16 rows

        call DrawAsh
        ld iy,0                 ;32 columns to draw

DrawPlatforms
        ld ixl, 0               ; x position

ChangedX
        ld ixh, 184             ; y position
	call getPixelAddr
        ld de,platform          ; ref graphic data
        ld b, 8                 ; draw 8 rows

DrawNextCell

        ld a,(de)               ;load first byte
	ld (hl),a               ;write to screen mem
        inc de                  ;get next byte
        inc ixh                 ;get next row byte address
        call getPixelAddr
	djnz DrawNextCell

        inc iy                  ;next column
        ld a, iyl
        cp 32
        inc ixl 
        jp nz,ChangedX


MainLoop
        ;load player position
	ld a,(playPos_y)
	ld ixh,a
	ld a,(playPos_x)
	ld ixl,a
	;check for jump movement
        ld bc,32766             ;keyboard b,n,m,shift,space
        in a,(c)
        rra
        call nc,Jump

	;check for L/R movement
	ld bc, 65022            ;keyboard asdfg ports
        in a, (c)               ;what keys were pressed
        rra                     ;was "a" pressed?
        push af      
        call nc, MoveLeft
        pop af
        rra		        ;rotate right, skip "s" for now
	rra		        ;rotate right for "d" key
	push af
	call nc, MoveRight
	pop af

	;store player position
	ld a,ixh
	ld (playPos_y),a
	ld a,ixl
	ld (playPos_x),a
	jp MainLoop
clearMe	
        
gameover

	ret; 

INCLUDE movement.asm
INCLUDE render.asm     
INCLUDE ash.asm
INCLUDE title.asm

        	
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

