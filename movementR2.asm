ShiftLPixels:
        call ClearMe                   ;clear current position
        dec ixl                        ;Change how many pixels to move per frame movement
        ret
ShiftRPixels:
        call ClearMe                   ;clear current position
        inc ixl                        ;Change how many pixels to move per frame movement
        ret
ShiftUpPixels:
        call ClearMe
        dec ixh                        ;move up pixels per loop
        dec ixh
        ret
ShiftDownPixels:
        call ClearMe
        inc ixh
        inc ixh
        ret
ShiftFallPixels:
        call ClearMe
        inc ixh
        ret
UpdatePlayerPosition:
        ld a, ixl
        ld (playPos_x), a
        ld a,ixh
        ld (playPos_y), a              ;update player position
        ret
MoveRight:

        push ix                        ;Check for collision
        ld a, ixl 
        cp 240
        jp z, Collision
        pop ix

        ld a, (JUMPHELD)
        cp 1
        jp z, JumpForwardR             ;Was Jump button held?

        ld de, ash1_r                  ;animate first frame
        call ShiftRPixels       
        call AnimateFrame
        
        ld de, ash3_r
        call ShiftRPixels
        call AnimateFrame              ;second frame
        halt

        ld de, ash1_r
        call ShiftRPixels
        call AnimateFrame              ;third frame
        halt
        
        ld a, 1
        ld (FACINGRIGHT), a
        
        call UpdatePlayerPosition
        pop af
        ret
MoveLeft
        push ix                        ;Check for Collision
        ld a, ixl
        cp 0
        jp z, Collision
        pop ix

        ld a, (JUMPHELD)               ;was jump button held?
        cp 1
        jp z, JumpForwardL
        
        ld de, ash1
        call ShiftLPixels
        call AnimateFrame

        ld de, ash3
        call ShiftLPixels
        call AnimateFrame
        halt

        ld de, ash1
        call ShiftLPixels
        call AnimateFrame
        halt

        ld a, 0
        ld (FACINGRIGHT), a
        call UpdatePlayerPosition      ;update player position
        pop af
        ret
Jump:
        
        
        ld a, (FACINGRIGHT)            ;Are we facing right?
        cp 1
        ld b, 12                       ;Jumping for 12 iterations
        jp z, JumpR                    ;Jump routines that handles right and left jump 
        jp JumpL                       ;in a straight vertical direction
         
JumpR:                                 ;Character is facing right
        ld de, ash3_r
        call UpLoop
        call DownLoop
        call UpdatePlayerPosition
        ld a, 0
        ld (JUMPHELD), a               ;No Longer Jumping
        
        ret
JumpL:                                 ;Character is facing left
        ld de, ash3
        call UpLoop
        call DownLoop   
        call UpdatePlayerPosition
        ld a, 0
        ld (JUMPHELD), a 
        

        ret
UpLoop:
        push bc                        ;Save reg that holds how many times to shift up
        push de                        ;Save reg that holds image
                                       ;going up 2 pixels for 12 iterations
        call ShiftUpPixels      
        call AnimateFrame         

        pop de  
        pop bc                   
        djnz UpLoop
        halt
        ret
              
DownLoop:   
       
                                       ;going down 2 pixels for 16 iterations
        call CheckForPlatform          ;check if there's any platforms before falling
                                       ;if so, fall till platform is reached
        
DLoop:  
        
cont:
        push bc                        ;iterate b times, the val returned from checkforplatform
        push de
        halt 

        call ShiftFallPixels  
        call AnimateFrame
         
        pop de    
        pop bc
        djnz DLoop
                                      
        ret   
CheckForPlatform:
       push ix
       ld b, 15                        ;look at the 15 pixels below ash's feet
       ld a, ixh
       add a, 16
       ld ixh, a
checkLoop:
       
       call getPixelAddr               ;get screen address
       ld a,(hl)
       cp 255                          ;check for platform
       jr z, StopJump 
       inc ixh
       djnz checkLoop
       pop ix
       ld b, 24                        ;Fall for full 24 pixels
       ret
StopJump:
       pop ix                          ;Fall to Platform
       ld a, 16                        ;iterations it took to find platform
       sub b
       ld b, a    
       ret

JumpForwardR:                          ;player has jumped forward in the right direction
	
;jumping animation only has 3 frames, can add more later                                       
UpArc

       call ClearMe                    ;Clear Screen
       ld a, ixl
       add a, 16                       ;move right 16 pixels
       ld ixl, a
       ld a, ixh                       ;move up 24 pixels
       sub 24
       ld ixh, a
       ld de, ash3_r
       
       call AnimateFrame
       halt
       halt
       halt
       halt
       halt
       
       ld bc, 20

DownArc 
       call CheckForPlatform           ;check for platforms below, draw on platofrm if found
       call ClearMe                    ;Clear Screen
       ld a, ixl                       ;move right 16 pixels
       add a, 16                       ;move up 24 pixels
       ld ixl, a
       ld a, ixh
       add a, b                        ;b was the value returned from checkforplatform subroutine
       ld ixh, a
       ld de, ash3_r 
       call AnimateFrame
       halt
       halt
       halt
       halt
       halt
       
       call UpdatePlayerPosition
       ld a, 0
       ld (JUMPHELD), a 
       pop af
       ret
        
JumpForwardL:                          ;player has jumped forward in the left directio
       ld bc, 20                       ;move 2 pixels for 10 iterations
UpArc2

       call ClearMe                    ;Clear Screen
       ld a, ixl
       sub 16
       ld ixl, a                       ;move left 16 pixels
       ld a, ixh                       ;move up 24 pixels
       sub 24
       ld ixh, a
       ld de, ash3
       
       call AnimateFrame
       halt
       halt
       halt
       halt
       halt
       
       ld bc, 20

DownArc2 
       call CheckForPlatform
       call ClearMe                    ;Clear Screen
       ld a, ixl
       sub 16
       ld ixl, a                       ;move left 16 pixels
       ld a, ixh                       ;move up 24 pixels
       add a, b                        ;b was the value returned from checkforplatform subroutine
       ld ixh, a
       ld de, ash3 
       call AnimateFrame
       halt
       halt
       halt
       halt
       halt
       
       call UpdatePlayerPosition
       ld a, 0
       ld (JUMPHELD), a 
       pop af
       ret

MoveDown:
   
        
        ld de, ash1                    ;animate first frame
        call AnimateFrame
      
        ld a, 1
        ld (FACINGRIGHT), a

        ld a, ixl
        ld (playPos_x), a
        ld a,ixh
        ld (playPos_y), a              ;get new y position
        
        ret

;Our main drawing routine
;Input: ix reg holds the player address
;Output: modifies ix and hl registers


AnimateFrame: 
        push bc       
        call getPixelAddr              ;get our pixel address
        ld (SCRNADDR), hl
        push ix
        push hl
        call SaveMe                    ;save background of shifted 16x16 area
        pop hl
        pop ix
        push ix
        push hl
        call DrawMe                    ;draw after saving background
        pop hl
        pop ix
        pop bc
        ret 
ClearMe:
        push bc
        push ix
        ld iy, BKGRNDBUFF
        call getPixelAddr
        ld b, 16
        call ClearSprite
        pop ix
        pop bc
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
      
   
        ld a,(de)                      ;load first byte
        or (hl)
        ld (hl),a                      ;write to screen mem
        inc de  
        inc de                         ;get next byte 
        inc hl                         ;get adjecent 8x8 cell
        ld a,(de)                      ;load adj cell
        or (hl)
        ld (hl),a
        inc de                         ;get next byte
        inc de
        inc ixh                        ;get next row byte address
        call getPixelAddr
        djnz Shift
	ld a,(playPos_y)
        ld ixh,a
        ret

MaskShift
      

        push de
        inc de
        ld a,(de)                      ;load first mask byte
        and (hl)
        ld (hl),a                      ;mask in
        pop de
        ld a,(de)                      ;load first graph byte
        or (hl)
        ld (hl),a                      ;draw char
        inc hl
        inc de                         ;get next graph byte 
        inc de
        push de
        inc de
        ld a,(de)                      ;load second mask byte
        and (hl)
        ld (hl),a                      ;mask in
        pop de
        ld a,(de)                      ;load second graph byte
        or (hl)
        ld (hl),a                      ;draw char
     

        inc de                         ;get next graph byte 
        inc de
   
        inc hl
        inc ixh                        ;get next row byte address
        call getPixelAddr
        djnz Shift
	ld a,(playPos_y)
        ld ixh,a
        
        ret 

; input - screen address and ix coordinate
SaveBackground
        call getPixelAddr
        ld a,(hl)                      ;get first byte
        ld (iy), a                     ;store byte in buffer
        inc iyl                        ;addr of next buf address
        inc l                          ;next byte of data

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
