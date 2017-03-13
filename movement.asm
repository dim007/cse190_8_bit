MoveLeft
        push ix
        ld a, ixl
        cp 0
        jp z, Collision
        pop ix

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
MoveDown
	push ix
	ld a,ixh
	cp 176
	jp z,Collision
	pop ix
	inc ixh
	inc ixh
	ld a,ixh
	ld (playPos_y),a
	ld a,(playPos_x)
	ld ixl,a

	ret
MoveUp
	push ix
	ld a, ixh
	cp 0
	jp z,Collision
	pop ix
	
	dec ixh
	dec ixh
	ld a, ixh
	ld (playPos_y),a
	ld a,(playPos_x)
	ld ixl,a
	
	ret
MoveRight
        
        push ix
        ld a, ixl
        cp 240
        jp z, Collision
        pop ix

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
        ld a,(JUMPCOUNT)
	cp 10
	jp z,JumpEnd
	ld a,1
	ld (ISJUMP),a
	ld a,(playPos_y)
	dec a
	dec a
	dec a
	dec a
	dec a
	dec a
	dec a
	dec a
	ld (playPos_y),a
	ld ixh,a
	ld a,(JUMPCOUNT)
	inc a
	ld (JUMPCOUNT),a
JumpEnd	ret
Gravity
	ld a,(playPos_y)
	cp 167
	jp z,stopFll
	inc a
	cp 167
	jp z,stopFll
	inc a
	cp 167
	jp z,stopFll
	inc a
	cp 167
	jp z,stopFll
	inc a
	cp 167
	jp z,stopFll
	ld (playPos_y),a
	ld ixh,a
	ret

stopFll	ld (playPos_y),a
	ld ixh,a
	xor a
	ld (JUMPCOUNT),a
	ld (ISJUMP),a
	ret
clearMe
        ld iy,BKGRNDBUFF
	ld a,(OLDx)
	ld ixl,a
	ld a,(OLDy)
	ld ixh,a
        call getPixelAddr       ;get our hl coord
        ld b,16 
        call ClearSprite
        ret
drawMe        
	ld a,(playPos_x)
        ld ixl,a
        ld a,(playPos_y)
        ld ixh,a

	call getPixelAddr
        ld (SCRNADDR), hl
        ld iy,BKGRNDBUFF
        ld b,16
        call SaveBackground

        ld hl,(SCRNADDR)
        ld ix,(playPos_x)
	
	;Draw Single sprite jump if jumping
	ld a,(ISJUMP)
	cp 1
	jp nz,skipJmp
	ld a,(FACERIGHT)
	cp 1
	jp z,right0
	ld de,ashJump
	jp skip3	;skip to very end
right0	ld de,ashJump_r	;else draw right facing one then skip to end
	jp skip3

skipJmp	;;Decide which sprite to draw this cycle
	;if not moving dont draw 2nd animation
        ld a,(ISMOVING)
        cp 1
        jp z,moving1
        ld (SPRITE_NUM),a                       ;if not true, not moving, reset sprite frame to 0
	jp draw1

moving1	ld a,(SPRITE_NUM)
	cp 0
	jp z,draw1
	cp 1
	jp z,draw1
	cp 2
	jp z,draw2
	cp 3
	jp z,draw2
	cp 4
	jp z,draw3
	cp 5
	jp z,draw3	

draw1    	;Draw ash1 depending on which way facing
	ld a,(FACERIGHT)
	cp 1 		;decide right facing or left facing ash1
	jp z,right1		;jp z, jump if compare was true
	ld de,ash1
	jp skip1
right1	ld de,ash1_r
skip1
     	jp sprt		;skip to end
		
draw2   ;decide which way to face
	ld a,(FACERIGHT)
	cp 1
	jp z,right2
	ld de,ash2
	jp skip2
right2	ld de,ash2_r
skip2	
	jp sprt		;jump to end
	
	;Part 3
        ;decide which way to face
draw3   ld a,(FACERIGHT)
        cp 1
        jp z,right3
        ld de,ash3
        jp sprt
right3  ld de,ash3_r

sprt	;Increment sprite counter
        ld a,(SPRITE_NUM)
	cp 5
	jp nz,skp	;if not 5, increment
	xor a
	ld (SPRITE_NUM),a	;else reset counter
	jp skip3
skp	inc a
	ld (SPRITE_NUM),a

skip3	ld b,16
        call Shift
	halt
        ret
Collision
        pop ix
        ret
Shift

        ld a ,(INFOREGROUND)
        cp 1
        jp z, MaskShift
      
   
        ld a,(de)               ;load first byte
        or (hl)
        ld (hl),a               ;write to screen mem
        inc de
        inc de                  ;get next byte 
        inc hl                  ;get adjecent 8x8 cell
        ld a,(de)               ;load adj cell
        or (hl)
        ld (hl),a
        inc de                  ;get next byte
        inc de
        inc ixh                 ;get next row byte address
        call getPixelAddr
        djnz Shift
	ld a,(playPos_y)
        ld ixh,a
        ret

MaskShift
      

        push de
        inc de
        ld a,(de)               ;load first mask byte
        and (hl)
        ld (hl),a               ;mask in
        pop de
        ld a,(de)               ;load first graph byte
        or (hl)
        ld (hl),a               ;draw char
        inc hl
        inc de                  ;get next graph byte 
        inc de
        push de
        inc de
        ld a,(de)               ;load second mask byte
        and (hl)
        ld (hl),a               ;mask in
        pop de
        ld a,(de)               ;load second graph byte
        or (hl)
        ld (hl),a               ;draw char
     

        inc de                  ;get next graph byte 
        inc de
   
        inc hl
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
SPRITE_NUM DEFB 0
INFOREGROUND DEFB 0
ISJUMP	   DEFB 0
JUMPCOUNT  DEFB 0
ISMOVING   DEFB 0
FACERIGHT  DEFB 1
OLDx	DEFB 0
OLDy	DEFB 0
BITPOS     DEFB 0
SCRNADDR   DEFW 0
BKGRNDBUFF EQU 64512
LINECOUNT  DEFB 0
SPTEMP     DEFW 0
