LEVEL2
        
      
scene2:
        di

	ld hl, 16384            ;clear screen
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
        ld hl,  level2_scene1        ;title reference
	xor a	
	ld (numstate2),a		;reset state
scene2loop2 

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
        djnz scene2loop2
       	 
       
        ld de,22528            ;set attribute color
        ld bc, 768
        ldir
        ld a, 7
        call 8859               ;set border color
        ei 
	ld a,16			;;initial position
	ld (playPos_x),a
level2Loop
       
       
        ;load player position
	ld a,(playPos_y)
	ld (OLDy),a
	ld a,(playPos_x)
	ld (OLDx),a

        call checkPos2          ;check if standing on screen transition

	;call Gravity	
	;check for jump movement
        ld bc,32766             ;keyboard b,n,m,shift,space
        in a,(c)
        rra
        ;call nc,Jump
	
	;check for L/R movement
	ld bc, 65022            ;keyboard asdfg ports
        in a, (c)               ;what keys were pressed
        rra                     ;was "a" pressed?
        push af      
        call nc,MoveLeft
        pop af
        rra		        ;rotate right, check "s"
	push af
	call nc,MoveDown
	pop af
	rra		        ;rotate right for "d" key
	push af
	call nc,MoveRight
	pop af
	ld bc, 64510
	in a,(c)
	rra
	rra 		;check for w key
	call nc,MoveUp
	call clearMe
	call drawMe
       	
	;store player position
	ld a,ixh
	ld (playPos_y),a
	ld a,ixl
	ld (playPos_x),a

	xor a	; clear a
	ld (ISMOVING),a	;stop movement animation
	jr level2Loop
	;END MAIN LOOP

;update state and position
updateState2:
	
	ret
;checks to see if player in key points for screen change
checkPos2:
	ld a,(numstate2)	;check state
	cp 0		
	jp nz,cP2_0		;if not zero, skip to check if numstate = 1
	;check points
	ld a,(playPos_x)	;else numstate = 0
	cp 236			;if at pos x=236, update numstate to 1
	jp nz,cP2_end		;else dont do anything
	;update state
	ld a,1
	ld (numstate2),a	;next state is 1 
	call stateDraw2		;NOTE: DO NOT INCREMENT, HARDCODE IT
	;update player position
	ld a,16
	ld (playPos_x),a
	ld a,96
	ld (playPos_y),a
	jp cP2_end
cP2_0 ;;SSCREEN 1
	cp 1
	jp nz,cP2_1		;if not =1 check if =2
	ld a,(playPos_x)
	;;CONDITION position 1
	cp 236			;these are conditions for state switch
	jp nz,cP2_01
	ld a,2
	ld (numstate2),a	;update to state 2
	call stateDraw2
	ld a,16
	ld (playPos_x),a	;update player position
        ld a,96
        ld (playPos_y),a
	jp cP2_end		;;CONDITION 1 end
cP2_01	ld a,(playPos_y)	;second condition
	cp 10
	jp nz,cP2_1
	ld a,3
	ld (numstate2),a
	call stateDraw2
	ld a,128
	ld (playPos_x),a
	ld a,16
	ld (playPos_y),a
	jp cP2_end
;;END OF SCREEN 1
cP2_1	;SCREEN 2
	
cP2_end
	ret
;Draws the new state screen
stateDraw2:
	di

        ld hl, 16384            ;clear screen
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
        
	ld a,(numstate2)
	cp 1
	jp nz,sD2_1	;skip
	ld hl,dungeon	;load dungeon image
	jp sD2_loop      ;draw screen
sD2_1	cp 2
	jp nz,sD2_2
	ld hl,dungeon
	jp sD2_loop
sD2_2	cp 3
	jp nz,sD2_3
	ld hl,dungeon
	jp sD2_loop
sD2_3
sD2_loop
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
        djnz sD2_loop
	
	ld de, 22528            ;set attribute color
        ld bc, 768
        ldir
        ld a, 7
        call 8859               ;set border colors 	

	ei
	ret
numstate2	DEFB 0   
INCLUDE dungeon.asm 
