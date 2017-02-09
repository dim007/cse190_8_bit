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
	ld a,(de)               ;load first byte
        ld (hl),a               ;write to screen mem
        inc de                  ;get next byte 
        inc hl                  ;get adjecent 8x8 cell
        
	ld a,(de)               ;load adj cell
        ld (hl),a
        inc de                  ;get next byte
        inc ixh                 ;get next row byte address
        call getPixelAddr
        djnz ShiftUp
        ld a,(playPos_y)
	ld ixh,a
	ret

MoveLeft
      
        call getPixelAddr       ;get our hl coord
        ld b,16
        call ClearSprite
        
        call leftPos            ;get new left position coords
        call getPixelAddr       ;get screen address
        ld de,ash2              ; ref graphic data
        ld b, 16                ; draw 16 rows
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

        ld a,(de)               ;load first byte
        ld (hl),a               ;write to screen mem
        inc de                  ;get next byte 
        inc hl                  ;get adjecent 8x8 cell
        ld a,(de)               ;load adj cell

        ld (hl),a
        inc de                  ;get next byte
        inc ixh                 ;get next row byte address
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
        ld ixh,a                ;get new y position
        ret
rightPos
	inc ixl
	inc ixl
	
	ld a,(playPos_y)
	ld ixh,a
	ret

