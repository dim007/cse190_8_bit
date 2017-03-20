MoveRight:

        push ix               ;Check for collision
        ld a, ixl
        cp 240
        jp z, Collision
        pop ix

        ld de, ash1_r          ;animate first frame
        call AnimateRFrames
        ld de, ash3_r
        call AnimateRFrames    ;second frame
        halt
        ld de, ash1_r
        call AnimateRFrames    ;third frame
        halt
        
        ld a, ixl
        ld (playPos_x), a
        ld a,(playPos_y)
        ld ixh,a                ;get new y position
        ret
AnimateRFrames:        
        call ClearMe            ;clear current position
        inc ixl                 ;shift right
        call getPixelAddr
        ld (SCRNADDR), hl
        push ix
        push hl
        call SaveMe             ;save background of shifted 16x16 area
        pop hl
        pop ix
        push ix
        push hl
        call DrawMe             ;draw after saving background
        pop hl
        pop ix
        ret 
MoveLeft
        push ix
        ld a, ixl
        cp 0
        jp z, Collision
        pop ix

        ld de, ash1
        call AnimateLFrames
        ld de, ash3
        call AnimateLFrames
        halt
        ld de, ash1
        call AnimateLFrames
        halt
        
        ld a, ixl
        ld (playPos_x), a
        ld a,(playPos_y)
        ld ixh,a                ;get new y position
       
        ret
AnimateLFrames:        
        call ClearMe
        dec ixl
        call getPixelAddr
        ld (SCRNADDR), hl
        push ix
        push hl
        call SaveMe
        pop hl
        pop ix
        push ix
        push hl
        call DrawMe
        pop hl
        pop ix
        ret 
ClearMe:
        push ix
        ld iy, BKGRNDBUFF
        call getPixelAddr
        ld b, 16
        call ClearSprite
        pop ix
        ret 
SaveMe:
       
        ld iy, BKGRNDBUFF
        ld b, 16
        call SaveBackground
        ret 
DrawMe:
        
        ld b, 16
        call DrawFrame
        ret      

DrawFrame:
        call Shift
	
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

; input - screen address and ix coordinate
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

INFOREGROUND DEFB 1
ISJUMP	   DEFB 0
JUMPCOUNT  DEFB 0
ISMOVING   DEFB 0
FACERIGHT  DEFB 1
OLDx	   DEFB 0
OLDy	   DEFB 159
BITPOS     DEFB 0
SCRNADDR   DEFW 0
BKGRNDBUFF EQU 64512
LINECOUNT  DEFB 0
SPTEMP     DEFW 0
