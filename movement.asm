MoveLeft
        dec ixl
        dec ixl
        dec ixl
        ld a, ixl
        ld (playPos_x), a
        ld a,(playPos_y)
        ld ixh,a                ;get new y position
        ;update facing
        xor a
        ld (FACERIGHT),a
        ld a,1
        ld (ISMOVING),a
        ret
MoveRight
        inc ixl
        inc ixl
        inc ixl
        ld a,ixl
        ld (playPos_x),a
        ld a,(playPos_y)
        ld ixh,a
        ld a,1
        ld (FACERIGHT),a
        ld (ISMOVING),a
        ret
Jump	                     
        ld a,(playPos_y)
	dec a
	dec a
	dec a
	ld (playPos_y),a
	ld a,1
	ld (ISJUMP),a

	ret
clearMe
        ld iy,BKGRNDBUFF
        call getPixelAddr       ;get our hl coord
        ld b,16 
        call ClearSprite
        ret
drawMe        
	call getPixelAddr
        ld (SCRNADDR), hl
        ld iy,BKGRNDBUFF
        ld b,16
        call SaveBackground

        ld hl,(SCRNADDR)
        ld ix,(playPos_x)

    	;Draw depending on which way facing
        ld a,(FACERIGHT)
	cp 1
	jp z,right1
	ld de,ash1
	jp skip1
right1	ld de,ash1_r
skip1
        ld b,16
        call Shift
        halt
	
	;if not moving dont draw 2nd animation
	ld a,(ISMOVING)
	cp 1
	jp z,cont   
	ret

cont    ld iy, BKGRNDBUFF
        ld hl,(SCRNADDR)
        ld b,16
        call ClearSprite
       
        ld iy, BKGRNDBUFF
        call getPixelAddr
        ld (SCRNADDR),hl
        ld b,16
        call SaveBackground

        ld hl,(SCRNADDR)
        ld a, ixl
        ld (playPos_x),a
        ld ix, (playPos_x)
        ;decide which way to face
	ld a,(FACERIGHT)
	cp 1
	jp z,right2
	ld de,ash2
	jp skip2
right2	ld de,ash2_r
skip2	
        ld b,16
        call Shift
        halt
        ret
Shift
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
        djnz Shift
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
ISJUMP	   DEFB 0
ISMOVING   DEFB 0
FACERIGHT  DEFB 1
BITPOS     DEFB 0
SCRNADDR   DEFW 0
BKGRNDBUFF EQU 64512
LINECOUNT  DEFB 0
SPTEMP     DEFW 0
