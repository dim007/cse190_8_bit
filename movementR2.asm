Jump:
        
        
        ld a, (FACINGRIGHT)
        cp 1
        ld b, 32
        jp z, JUMPR
        jp JUMPL
        
       
JUMPFL:
	
       ld b, 8
       
upLoop2
       push bc
       halt
       ld de, ash3
       
       call AnimateLFrames
       ld de, ash3
       call AnimateUFrames2
       pop bc
       djnz upLoop2

       ld b, 8
       
downLoop2 
       push bc
       halt
       ld de, ash3
       
       call AnimateLFrames
       ld de, ash3
       call AnimateDFrames2  
       
       pop bc
       
       djnz downLoop2

       ld a, ixl
       ld (playPos_x), a
       ld a, ixh
       ld (playPos_y), a 
       ld a, 0
       ld (JUMPHELD), a
       pop af
       ret
JUMPFR:
      
       ld b, 8
       
upLoop
       push bc
       halt
       ld de, ash3_r
       
       call AnimateRFrames
       ld de, ash3_r
       call AnimateUFrames2
       pop bc
       djnz upLoop

       ld b, 8
       
downLoop 
       push bc
       halt
       ld de, ash3_r
       
       call AnimateRFrames
       ld de, ash3_r
       call AnimateDFrames2   
       pop bc
      
       djnz downLoop

       ld a, ixl
       ld (playPos_x), a
       ld a, ixh
       ld (playPos_y), a 

       ld a, 0
       ld (JUMPHELD), a
       pop af
       ret
        
JUMPL:  jr JLoop2
JUMPR:      
JLoop:
        push bc
        ld de, ash3_r 
        call AnimateJFrames  
        pop bc                   
        djnz JLoop
        halt
              
DOWN:   
       
        ld b, 16
        
DLoop:  
        push bc
        halt 
        ld de, ash3_r  
        call AnimateDFrames
        jr CheckForPlatforms
contj        
        pop bc
        djnz DLoop
                              ;get new y position
        ret
JLoop2:
        push bc
        ld de, ash3
        call AnimateJFrames  
        pop bc                   
        djnz JLoop2
        halt
              
DOWN2:   
       
        ld b, 16
        
DLoop2:  
        push bc
        halt 
        ld de, ash3
        call AnimateDFrames
        jr CheckForPlatforms2
contj2   
        pop bc
        djnz DLoop2
stopk      
        ld a, ixl
        ld (playPos_x), a
        ld a,ixh
        ld (playPos_y), a
                              ;get new y position
        ret
stopj:  pop bc
        jr stopk
CheckForPlatforms:
        push ix
        ld a,ixh
        add a, 16
        ld ixh, a
        call getPixelAddr
        ld a,(hl)
        cp 255
        pop ix
        jr z, stopj
       
       
        jr contj
CheckForPlatforms2:
        push ix
        ld a,ixh
        add a, 16
        ld ixh, a
        call getPixelAddr
        ld a,(hl)
        cp 255
        pop ix
        jr z, stopj
       
       
        jr contj2

MoveRight:

        push ix                ;Check for collision
        ld a, ixl 
        cp 240
        jp z, Collision
        pop ix

        ld a, (JUMPHELD)
        cp 1
        jp z, JUMPFR

        call CheckifFalling

        ld de, ash1_r          ;animate first frame
        call AnimateRFrames
        ld de, ash3_r
        call AnimateRFrames    ;second frame
        halt
        ld de, ash1_r
        call AnimateRFrames    ;third frame
        halt
        
        ld a, 1
        ld (FACINGRIGHT), a
        

        ld a, ixl
        ld (playPos_x), a
        ld a,ixh
        ld (playPos_y), a                ;get new y position
        pop af
        ret
MoveDown:
   
        
        ld de, ash1                     ;animate first frame
        call AnimateDFrames
      
        ld a, 1
        ld (FACINGRIGHT), a

        ld a, ixl
        ld (playPos_x), a
        ld a,ixh
        ld (playPos_y), a               ;get new y position
        
        ret
CheckifFalling:
        push ix
        ld a,ixh
        add a, 16
        ld ixh, a
        call getPixelAddr
        ld a,(hl)
        pop ix
        cp 255
        ret z
        call MoveDown
        jp CheckifFalling
       
        ret
AnimateDFrames:
        call ClearMe            ;clear current position
        inc ixh                 ;shift right
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

        
AnimateUFrames:
        call ClearMe            ;clear current position
        dec ixh                  ;shift right
        dec ixh
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
AnimateUFrames2:
        call ClearMe            ;clear current position
        dec ixh                  ;shift right
        dec ixh
        dec ixh
        dec ixh
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
AnimateDFrames2:
        call ClearMe            ;clear current position
        inc ixh 
        inc ixh 
        inc ixh
        inc ixh               ;shift right
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
AnimateJFrames:
        call ClearMe            ;clear current position
        dec ixh                 ;shift right
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
AnimateRFrames:        
        call ClearMe            ;clear current position
        inc ixl
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

        ld a, (JUMPHELD)
        cp 1
        jp z, JUMPFL

        ld de, ash1
        call AnimateLFrames
        ld de, ash3
        call AnimateLFrames
        halt
        ld de, ash1
        call AnimateLFrames
        halt
        
        ld a, 0
        ld (FACINGRIGHT), a
        ld a, ixl
        ld (playPos_x), a
        ld a,(playPos_y)
        ld ixh,a                ;get new y position
        pop af
        ret
AnimateLFrames:     
        call ClearMe
        dec ixl
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
        pop af
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
JUMPTABLE defb 1, 2, 4, 5
JUMPHELD defb 0
INFOREGROUND DEFB 1
ISJUMP	   DEFB 0
JUMPCOUNT  DEFB 0
ISMOVING   DEFB 0
FACINGRIGHT  DEFB 1
OLDx	   DEFB 0
OLDy	   DEFB 159
BITPOS     DEFB 0
SCRNADDR   DEFW 0
BKGRNDBUFF EQU 64512
LINECOUNT  DEFB 0
SPTEMP     DEFW 0
