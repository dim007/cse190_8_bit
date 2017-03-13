	


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
        call SetInterrupt
	ld ix,(firArrow)
        ld a, ixl
        ld (oldArrowx),a
        ld a, ixh
        ld (oldArrowy),a

        call DrawArrow
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
	ld (OLDy),a
	ld a,(playPos_x)
	ld (OLDx),a

	call Gravity	
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
        call nc,MoveLeft
        pop af
        rra		        ;rotate right, skip "s" for now
	rra		        ;rotate right for "d" key
	push af
	call nc,MoveRight
	pop af
	call clearMe
	call drawMe
        
	;store player position
	ld a,ixh
	ld (playPos_y),a
	ld a,ixl
        push ix
        call LevelSelect
        pop ix
        ld a,ixl
	ld (playPos_x),a
	xor a	; clear a
	ld (ISMOVING),a	;stop movement animation


        ;check for level selected
        ld bc, 49150
        in a, (c)
        rra                      ;was "enter" pressed
        call nc, EnterLevel
      
	jp MainLoop

SetInterrupt
  	di
        ld hl, Interrupt
        ld ix, &FFF0
        ld (ix+04h), &c3
        ld (ix+05h),l
        ld (ix+06h),h
        ld (ix+0Fh),&18
        ld a, &39
        ld i,a
        im 2
        ei
        ret

Interrupt
       di
       push af             ; preserve registers.
       push bc
       push hl
       push de
       push ix
       rst 56
                           ; ROM routine, read keys and update clock.
       pop ix              ; ADD OUR OWN INTERRUPT ROUTINE <----------------------
       pop de
       pop hl
       pop bc
       pop af
       ei   
       reti
        
       
LevelSelect:
        
        cp 34 	;;33
        jp z,ARROW1

        ld a,ixl
        cp 90
        jp z,ARROW2
       
        ld a,ixl
        cp 156
        jp z,ARROW3
   
        ld a,ixl
        cp 206  ;;219
        jp z,ARROW4
       
        ret
EnterLevel

        ld a,(level_selected)
        cp 1
        jp z, LEVEL1
        
        cp 2
        jp z, LEVEL2
    
        cp 3
        jp z, LEVEL2

        cp 4
        jp z, LEVEL2

INCLUDE level1.asm
INCLUDE level2.asm
ARROW1:
        ld ix,(firArrow)
        ld a, 1
        ld (level_selected), a
        call DrawArrow
        ret       
        
ARROW2:
        ld ix,(secArrow)
        ld a, 2
        ld (level_selected), a
        call DrawArrow
   
        ret
ARROW3: 
        ld ix,(thrdArrow)
        ld a, 3
        ld (level_selected), a
        call DrawArrow
       
        ret
ARROW4:
        ld ix,(frthArrow)
        ld a, 4
        ld (level_selected), a
        call DrawArrow
       
        ret

        
gameover

	ret; 

INCLUDE movement.asm
INCLUDE render.asm     
INCLUDE ash.asm
INCLUDE title.asm
INCLUDE level1_scene1.ASM  
INCLUDE level2_scene1.ASM

platform

        DEFB	255,255,129,129,255,129,129,129
	DEFB	 56

level_selected DEFB 0
