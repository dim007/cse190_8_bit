main
	org 33000


        ld ixh, 167     ; y position   
        ld ixl, 50       ; x position

	call getPixelAddr
        push ix          ; save position of sprite

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
        pop ix
        ld bc, 65022      ;keyboard asdfg ports
        in a, (c)         ;what keys were pressed
        rra               ;was "a" pressed?
        push af      
        call nc, MoveLeft
        pop af
        push ix
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
       

ShiftLeft
     
        ld a,(de) ;load first byte
	ld (hl),a ;write to screen mem
        inc de    ;get next byte 
        inc hl    ;get adjecent 8x8 cell
        ld a,(de) ;load adj cell

        ld (hl),a
        inc de    ;get next byte
        inc ixh   ;get next row byte address
        call getPixelAddr
	djnz ShiftLeft
        ld ixh,167
        ret
        
leftPos
        dec ixl
        dec ixl

        ld ixh,167                 ;get new x position
        ret

ClearSprite
        ld a, 0
        ld (hl),a
        inc hl    ;get adjecent 8x8 cell
        ld (hl),a
        inc de    ;get next byte
        inc ixh   ;get next row byte address
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

getPixelAddr

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

platform

        DEFB	255,255,129,129,255,129,129,129
	DEFB	 56

