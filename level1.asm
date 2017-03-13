LEVEL1 
        
      
scene1:
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
        ld hl,  lvl1Scene1       ;title reference

scene1loop 

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
        djnz scene1loop
       	
        ld hl, lvl1Attr
        ld de, 22528            ;set attribute color
        ld bc, 768
        ldir
        ld a, 7
        call 8859               ;set border color
        ei 

scene1movement

        call levelLoop 
        ld a, (playPos_x)
        cp 99
        jp z, SetFGFlag
        
        ld a, (playPos_x)
        cp 195
        jp z, GoToScene2

	jp scene1movement       
levelLoop
       
       
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
	ld (playPos_x),a
	xor a	; clear a
	ld (ISMOVING),a	;stop movement animation

        ret
        
SetFGFlag

         ld a, (INFOREGROUND)
         xor 1
         ld (INFOREGROUND), a
	 jr scene1movement

GoToScene2
         
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
        ld hl,  lvl1Scene2      ;title reference

    

scene2loop 

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
        djnz scene2loop
       	 
        ld hl, lvl1Attr
        ld de, 22528            ;set attribute color
        ld bc, 768
        ldir
        ld a, 7
        call 8859               ;set border color
        ld a, 0
        ei 
     
       

        ;normal main
        ld a,167
        ld (playPos_y), a       ;load init y player position
	ld ixh,a
        ld a,0
        ld (playPos_x), a    ; x position
	ld ixl,a
	call getPixelAddr

	ld de,ash1              ; ref graphic data
        ld b, 16                ; draw 16 rows

        call DrawAsh
   
scene2movement
        call levelLoop
        jr scene2movement
      
        
