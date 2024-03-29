START   
        org 33000
        di
        call SetInterrupt              ;Set up interrupt
        di
title	
      
        call RestartPosition
        call RenderTitleScreen        
main	

        call RestartPosition           ;load initial player position

	call getPixelAddr
        ld (SCRNADDR), hl

        ld b, 16                       ; draw 16 rows
        call DrawAsh
        ld iy,0                        ;32 columns to draw

DrawGround
        ld ixl, 0                      ; x position

ChangedX

        ld ixh, 176                    ; y position
	call getPixelAddr
        ld de,platform                 ; ref graphic data
        ld b, 8                        ; draw 8 rows

DrawNextCell

        ld a,(de)                      ;load first byte
	ld (hl),a                      ;write to screen mem
        inc de                         ;get next byte
        inc ixh                        ;get next row byte address
        call getPixelAddr
	djnz DrawNextCell

        inc iy                         ;next column
        ld a, iyl
        cp 32
        inc ixl 
        jp nz,ChangedX

        ld a, (playPos_y)              ;load init y player position
	ld ixh,a
        ld a, (playPos_x)              ; x position
	ld ixl,a
        ld (SCRNADDR), hl
        ei

mainloop:
        
        call MovementLoop
      
        ld a, 255
        ld iy,playPos_x

        sub (iy)
        cp 10
        jp c, LEVEL1
      
        jp mainloop

MovementLoop
       
        ;load player position
	ld a,(playPos_y)
	ld (OLDy),a
	ld a,(playPos_x)
	ld (OLDx),a
        
        ;call Gravity	
	;check for jump movement
        ld bc,32766             ;keyboard b,n,m,shift,space
        in a,(c)
        rra
        call nc, jh

	;check for L/R movement
	ld bc, 65022            ;keyboard asdfg ports
        in a, (c)               ;what keys were pressed
        rra                     ;was "a" pressed?
        push af      
        jp nc,MoveLeft
        pop af
        rra		        ;rotate right, skip "s" for now
	rra		        ;rotate right for "d" key
	push af
	jp nc,MoveRight
        pop af

       
        halt
        halt
	;check for jump movement
        ld a, (JUMPHELD)
        cp 1
        jp z, Jump
    
        ld a, 0
        ld (JUMPHELD), a
	
	ret
jh:
        halt
        halt
        ld a, 1
        ld (JUMPHELD), a
        ret

RestartPosition:

        ld a,0
        ld (playPos_x), a
        ld a,159
        ld (playPos_y), a
        ret

INCLUDE level1.asm

INCLUDE movementR2.asm
INCLUDE render.asm     
INCLUDE ash.asm
INCLUDE "title.asm"
INCLUDE RenderTitleScreen.asm
INCLUDE lvl1.asm 
INCLUDE InterruptHandler.asm
INCLUDE gameover.asm
INCLUDE RenderGameover.asm
INCLUDE credits.asm

platform
        DEFB	255,255,129,129,255,129,129,129
	DEFB	 56
level_selected DEFB 0
in_level defb 0
ded defb 0
