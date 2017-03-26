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
        ld a, 255
        ld iy,playPos_x

        sub (iy)
        cp 10
        jp c, Collision
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
       
        ld de, ash1_r
        call CheckForPlatformRAhead
        call grav

        ld a, (ded)
        cp 1
        jp z, falllost

        ld a, 1
        ld (FACINGRIGHT), a
        
        call UpdatePlayerPosition
        call endDetection
        pop af
        ret
MoveLeft
        push ix                        ;Check for Collision
        ld a, (playPos_x)
        ld b,3

        sub b
        cp 3
        jp c, Collision
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
     
        ld de, ash1
        call CheckForPlatformLAhead
        call grav

        ld a, (ded)
        cp 1
        jp z, falllost

        ld a, 0
        ld (FACINGRIGHT), a

        call UpdatePlayerPosition      ;update player position
        call endDetection
        pop af
        ret

endDetection:
        ld a, 150
        ld iy,playPos_x

        sub (iy)
        add a, 25
        cp 50
        jp c, ys
        
        ret
ys:
         ld a, 32
         sub (iy+1)
         add a,15
         cp 32
         jp c, nextlevel
         ret
Jump:
        
        
        ld a, (FACINGRIGHT)            ;Are we facing right?
        cp 1
        ld b, 12                     ;Jumping for 12 iterations
        jp z, JumpR                    ;Jump routines that handles right and left jump 
        jp JumpL                       ;in a straight vertical direction
         
JumpR: ld de,ash3_r
       call UpLoop
       call CheckForPlatformRAhead
       jp VertUp
JumpL: ld de, ash3  
       call UpLoop                   ;Character is facing left
       call CheckForPlatformLAhead
       jp VertUp
VertUp:                                ;Simple Vertical Jump                              
     
        call DownLoop  
        ld a, (ded)
        cp 1
        jp z, falllost 
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
       
                                       ;going down 2 pixels for 12 iterations
                 ;check if there's any platforms before falling
        ld a, (ded)
        cp 1
        jp z, falllost
                                       ;if so, fall till platform is reached
grav    ld a, b
        cp 0
        ret z
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
CheckForPlatformRAhead:                ;standing on edge of platform facing right
       push ix
       ld a, ixl
       sub 3
       ld ixl, a
       call CheckForPlatform
       pop ix
       ret  
CheckForPlatformLAhead:                ;facing left
       push ix
       ld a, ixl
       add a, 8
       ld ixl, a
       call CheckForPlatform
       pop ix
       ret  
CheckForPlatformJRAhead:                ;is jumping to the right
       push ix
       ld a, ixl
       add a, 14
       ld ixl, a
       call CheckForPlatform
       pop ix
       ret  
CheckForPlatformJLAhead:                ;is jumping to the left
       push ix
       ld a, ixl
       sub 8
       ld ixl, a
       call CheckForPlatform
       pop ix
       ret  
falldeath:
       ld a, 1
       ld (ded) ,a
       ret     
CheckForPlatform:
       push ix
       push de
       ld b, 48                       ;look at the 15 pixels below ash's feet
       ld a, ixh
       add a, 16
       ld ixh, a
checkLoop:
       
       call getPixelAddr               ;get screen address
       ld a,(hl)
       cp 0                            ;check for platform
       jr nz, StopJump 
       inc ixh
       djnz checkLoop
       pop de
       pop ix
       call falldeath                         ;Fall for full 24 pixels
       ret
StopJump:
       pop de
       pop ix                          ;Fall to Platform
       ld a, 48                        ;iterations it took to find platform
       sub b
       ld b, a    
       ret

JumpForwardR:                          ;player has jumped forward in the right direction
	
;jumping animation only has 3 frames, can add more later                                       
UpArc

       call ClearMe                    ;Clear Screen
       ld a, ixl
       add a, 16                    ;move right 21 pixels
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
       call CheckForPlatformJRAhead           ;check for platforms below, draw on platofrm if found
       call ClearMe                    ;Clear Screen
       ld de, ash3_r
       ld a, (ded)
       cp 1
       jp z, falllost 
       ld a, ixl                       ;move right 21 pixels
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
       call CheckForPlatformJLAhead
       call ClearMe  
       ld de, ash3                   ;Clear Screen
        ld a, (ded)
        cp 1
        jp z, falllost 
       ld a, ixl
       sub 16
       ld ixl, a                       ;move left 16 pixels
       ld a, ixh                       ;move down 24 pixels
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
        push ix
        push hl
        push de
        ld b, 8
ShiftLoop:
        push bc
        ex de, hl
        ldi
        ldi
        inc ixh       
        ex de, hl                 ;get next row byte address
        call getPixelAddr
        ex de, hl
        ldi
        ldi
        inc ixh
        ex de, hl
        call getPixelAddr
        pop bc
        djnz ShiftLoop
	ld a,(playPos_y)
        ld ixh,a
        pop de
        pop hl
        pop ix
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
