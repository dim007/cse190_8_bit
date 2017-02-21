Jump	ret                     ;TODO
        call getPixelAddr
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
      
        push ix
        ld a, ixl
        cp 240
        jp z, Collision
        pop ix

        ld iy,BKGRNDBUFF
        call getPixelAddr       ;get our hl coord
        ld b,16 
        call ClearSprite
        
        call leftPos
        call getPixelAddr
        ld (SCRNADDR), hl
        ld iy,BKGRNDBUFF
        ld b,16
        call SaveBackground

        ld hl,(SCRNADDR)
        ld ix,(playPos_x)
     
        ld de ,ash2
        ld b,16
        call ShiftLeft
        halt
   
        ld iy, BKGRNDBUFF
        ld hl,(SCRNADDR)
        ld b,16
        call ClearSprite
       d
        dec ixl
        ld iy, BKGRNDBUFF
        call getPixelAddr
        ld (SCRNADDR),hl
        ld b,16
        call SaveBackground

        ld hl,(SCRNADDR)
        ld a, ixl
        ld (playPos_x),a
        ld ix, (playPos_x)
        ld de,ash1
        ld b,16
        call ShiftLeft
        halt
        ret
       
ShiftLeft

        ld a,(de)               ;load first byte
        or (hl)
        ld (hl),a               ;write to screen mem
        inc de                  ;get next byte 
        inc hl                  ;get adjecent 8x8 cell
        ld a,(de)               ;load adj cell
        or (hl)
        ld (hl),a
        inc de                  ;get next byte
        inc ixh                 ;get next row byte address
        call getPixelAddr
        djnz ShiftLeft
        ld ixh,167
        ret

MoveRight
        push ix
        ld a, ixl
        cp 240
        jp z, Collision
        pop ix

	ld iy,BKGRNDBUFF
        call getPixelAddr       ;get our hl coord
        ld b,16 
        call ClearSprite
        
        call rightPos
        call getPixelAddr
        ld (SCRNADDR), hl
        ld iy,BKGRNDBUFF
        ld b,16
        call SaveBackground

        ld hl,(SCRNADDR)
        ld ix,(playPos_x)
     
        ld de ,ash2_r
        ld b,16
        call ShiftLeft
        halt
   
        ld iy, BKGRNDBUFF
        ld hl,(SCRNADDR)
        ld b,16
        call ClearSprite
       
        inc ixl
        ld iy, BKGRNDBUFF
        call getPixelAddr
        ld (SCRNADDR),hl
        ld b,16
        call SaveBackground

        ld hl,(SCRNADDR)
        ld a, ixl
        ld (playPos_x),a
        ld ix, (playPos_x)
        ld de,ash1_r
        ld b,16
        call ShiftLeft
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
Collision
        pop ix
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

        ld a, ixl
        ld (playPos_x), a
      
	ld a,(playPos_y)
        ld ixh,a                ;get new y position
        ret
rightPos
	inc ixl
	inc ixl
	
        ld a,ixl
        ld (playPos_x),a

	ld a,(playPos_y)
	ld ixh,a
	ret
SaveBackground
        call getPixelAddr
        ld a,(hl)               ;get first byte
        ld (iy), a              ;store byte in buffer
        inc iyl                 ;addr of next buf address
        inc l                   ;next byte of data

        ld a,(hl)
        ld (iy),a
        inc iyl
        inc ixh
        djnz SaveBackground

        ret

BITPOS     DEFB 0
SCRNADDR   DEFW 0
BKGRNDBUFF EQU 64512
LINECOUNT  DEFB 0
SPTEMP     DEFW 0
