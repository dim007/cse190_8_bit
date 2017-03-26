LEVEL1:
       call ClearScreen 
       ;Draw first level platforms
       ld b, 12                     ;ten squares to draw
       ld ix, firstLPlats             ;location of frist level platforms
       call DrawPlatforms
       ld a, 1
       ld (tracklevel), a
       jp contsetup

LEVEL2:
       call ClearScreen
       ;Draw first level platforms
       ld b, 7                       ;ten squares to draw
       ld ix, secondLPlats             ;location of frist level platforms
       call DrawPlatforms 
       ld a, 2
       ld (tracklevel), a  
       jp contsetup  
LEVEL3:
       call ClearScreen
       ;Draw first level platforms
       ld b, 12                     ;ten squares to draw
       ld ix, thirdLPlats             ;location of frist level platforms
       call DrawPlatforms   
       ld a, 3
       ld (tracklevel), a 
       jp contsetup 
ClearScreen: 
  
        di
        call 3503                      ;clear screen
        ret
               
contsetup:
        ld b, 0                        ;Draw base line
        ld c, 0
        ld (23677), bc
        call 8933  

      
      
        ld b, 0                        ;delta y
        ld c, 255                      ;delta x
        ld d, 0                        ;sign of y
        ld e, 1                        ;sign of x
        call 9402

        call s1
        call RestartPosition
        
        call getPixelAddr
        ld (SCRNADDR), hl
        push ix
        push hl
        ld iy,BKGRNDBUFF
        ld b,16
        call SaveBackground
        pop hl
        pop ix
        call DrawAsh
       
        ld a, 1                        ;Notify Interrupt Handler that we are in level 1
        ld (in_level), a
        ei
        jp LevelMovement
        
DrawSnorlax:
        push bc
        ld b,7
adjC    
        ld a, (de)
        or (hl)
        ld (hl), a
        inc de
        inc hl
        djnz adjC

        inc ixh
        call getPixelAddr

        pop bc
        djnz DrawSnorlax

        ret

;Main platform drawing routine
;Uses rom routine to connect 4 points

DrawPlatforms

        push bc
        
        ld b, (ix)                     ;ix holds location of points
        ld c, (ix + 1)   
        ld (23677), bc                 ;calls PLOT function
        call 8933                      ;plots a single initial point
        inc ix                         ;move on to next point
        inc ix

        ld b, 4
        call DrawConnectedPoints
        pop bc
        djnz DrawPlatforms

        ret
DrawConnectedPoints:

        push bc
        ld b, (ix)                     ;delta y
        ld c, (ix+1)                   ;delta x
        ld d, (ix+2)                   ;sign of y
        ld e, (ix+3)                   ;sign of x
        call 9402
        inc ix
        inc ix
        inc ix
        inc ix
        pop bc
        
        djnz DrawConnectedPoints
        ret 
 
DrawDonut:
        
        push bc            
adjF    
        ex de, hl                             
        ldi                            ;Ld (de),(hl) increment hl and de
        ldi                            ;unrolling to optimize
        inc ixh
        ex de, hl
        call getPixelAddr
        ex de, hl
        ldi
        ldi
        inc ixh
        ex de, hl
        call getPixelAddr
        
        pop bc
        djnz DrawDonut
      
        ret
   

ClearSnorlax:
        push bc
        ld b,7
adjG    
        xor a
        ld (hl), a
        inc de
        inc hl
        djnz adjG

        inc ixh
        call getPixelAddr

        pop bc
        djnz ClearSnorlax 
        ret      
LevelMovement
      
        call MovementLoop
	jp LevelMovement 

UpdateDonutPointer:

        cp 0
        jr z, Projectile1
        cp 1
        jr z, Projectile2
        cp 2
        jr z, Projectile3
        cp 3
        jr z, Projectile4
        ret
        
endTrans:  
        ret
UnRollLDIR:                            ;Fster than using ldir

        ldi
        ldi
        ldi
        ldi
        ldi
        ldi
        
        ret

Projectile1:


        ld de, currDptr
        ld hl, d1
        ld (ptrAddr), hl
        call UnRollLDIR
        jr endTrans

Projectile2:

        ld de, currDptr
        ld hl, d2
        ld (ptrAddr), hl
        call UnRollLDIR
        jr endTrans

Projectile3:

        ld de, currDptr
        ld hl, d3
        ld (ptrAddr), hl
        call UnRollLDIR
        jr endTrans

Projectile4:

        ld de, currDptr
        ld hl, d4
        ld (ptrAddr), hl
        call UnRollLDIR
        jr endTrans

SetUpDonuts:
     
        ld a, (DonutCounter)
        inc a
        ld a, (DonutCounter)
      
        ld a,100    
        ld (dTimer), a
        ld a, (DONUTSONSCREEN)

                                       ;find index in stack of new donut position
        call UpdateDonutPointer    
        
        ld de, donut
        ld ix,(currDptr)
        
        call getPixelAddr
        ld (chl), hl
        ld b,8
        call DrawDonut
        
        ld a, (DONUTSONSCREEN)
        inc a
        ld (DONUTSONSCREEN),a
                                       ;save our data to projectile's mem location
        ld hl, currDptr
        ld de, (ptrAddr)
        call UnRollLDIR
        ret 

MoveDonuts:
        push af
        ld a, (DonutCounter)
        dec a
        ld (DonutCounter), a
        pop af
  
iterateD:  
        dec a
        call UpdateDonutPointer
        call ShiftDonuts 
        ret  
DonutShiftDownPixels:
        inc ixh 
        inc ixh
        ret
DonutShiftLeftPixels:
        dec ixl
        dec ixl
        dec ixl
        dec ixl
       
        ret
DonutShiftRightPixels:
        inc ixl
        inc ixl
        inc ixl
        inc ixl
        ret 
ShiftDonuts:

        ld ix,(currDptr)               ;get out donut coordinates
        call ClearProjectiles
        ld ix, (currDptr)

        ld a, (cDir)
         
        cp 1
        jp z, ShiftLeft
        
        cp 3
        jp z, ShiftDown
           
        cp 0
        jp z, ShiftRight
        ret
ShiftDown:

        call DonutShiftDownPixels
        ld b,16
        call getPixelAddr
        call DownDetection
        ld a, (resetdonutf)
        cp 1
        jr z, endDLoop
        call AshCollision
        call ShiftLogic
endDLoop
        ld a, 0
        ld (resetdonutf), a
        ret  
ShiftRight:

        call DonutShiftRightPixels
        ld b,16
        call getPixelAddr
        call OpeningDetection
        call RightDetection
        call AshCollision
        call ShiftLogic 
        ret
       
ShiftLeft:
 
        call DonutShiftLeftPixels
        ld b,16
        call getPixelAddr
        call OpeningDetection
        call LeftDetection
        call AshCollision
        call ShiftLogic 
        ret 
    
ShiftLogic:
        
        ld (chl), hl
        ld (currDptr), ix
        ld de, donut
        ld b,8
        call DrawDonut 
        ld hl, currDptr
        ld de, (ptrAddr)
        call UnRollLDIR
        ret 
RightDetection:
        ld a,ixl
        cp 236
        jp z, DownObDet
        ret 
LeftDetection:
        ld a,ixl
        cp 4
        jp z, DownObDet
        ret 
OpeningDetection:
        push ix
        push hl
        ld a,ixh
        add a, 16
        ld ixh, a
        call getPixelAddr
        ld a,(hl)
        inc hl
        ld b, (hl)
        add a, b
        pop hl
        pop ix
        cp 0
        jr z, FallObDet
        ret

FallObDet:

        ld a, 3
        ld (cDir), a
        ret            
DownDetection:

        push ix
        push hl
        ld a,ixh
        add a, 16
        ld ixh, a
        ld a, ixh
        cp 174
        call z, resetdonut
        call getPixelAddr
        ld a,(hl)
        inc hl
        ld b, (hl)
        add a, b
        pop hl
        pop ix
        cp 0
        jr nz, DownObDet
        
        ret
resetdonut:                            ;reset current donut
        ld a, 1
        ld (resetdonutf), a
        ld a, (resTrack)
        cp 1
        jr z, fCh
  
        
        xor 1
        ld (resTrack), a
        ld de, (ptrAddr)
        ld hl, dinit
        call UnRollLDIR
        call s2
        ret
        
fCh
        
        xor 1
        ld (resTrack), a
        ld de, (ptrAddr)
        ld hl, dinit2
        call UnRollLDIR
        call s1
      
        ret


       
nextlevel:
         pop bc
         call newgame
         ld a, (tracklevel)
         cp 1
         call z, LEVEL2
         cp 2
         call z, LEVEL3
         cp 3
         call z, CREDITS
         ret 
DownObDet:

        ld a,(cDir + 1)
        ld (cDir), a
        xor 1
        ld (cDir + 1), a
   
        ret

ClearProjectiles
        
        push ix
        call getPixelAddr
        ld b,16
        call ClearProjectile
        pop ix
        ret

ClearProjectile
        
        
        ld a,0
        ld (hl),a
                                       ;get adjecent 8x8 cell
        inc l
        ld (hl),a                      
        inc ixh                 
        call getPixelAddr
	djnz ClearProjectile

        ret  
AshCollision:
        
        ld a, (JUMPHELD)
        cp 1
        ret z
        ld a, (currDptr)
        ld iy,playPos_x

        sub (iy)
        add a, 15
        cp 32
        jp c, ySame
        
        ret
ySame:
         ld a,(currDptr+1)
         sub (iy+1)
         add a,15
         cp 32
         jp c, lostgame
         ret
falllost:
         ld b, 60
         call grav
lostgame:
        
        di
        ld a, 0
        ld (in_level), a
        call RenderGameover
        call newgame
        jp title
newgame:
        di
        ld a, 0
        ld (in_level), a 
        ld (ded), a
        ld (DONUTSONSCREEN), a
        ld (DCounter), a
        ld (DonutCounter), a
        ld (resetdonutf), a
        ld a, 1
        ld (dTimer), a
        ld (level_selected), a
               
        ld de, d1
        ld hl, dinit2
        call UnRollLDIR
        ld de, d2
        ld hl, dinit
        call UnRollLDIR
        ld de, d3
        ld hl, dinit2
        call UnRollLDIR
        ld de, d4
        ld hl, dinit
        call UnRollLDIR
        
        ret
s1:
        push ix
        ld ixl,96
        ld ixh,0
        ld b, 48

        push ix
        push bc
        call getPixelAddr
        call ClearSnorlax
        pop bc
        pop ix
    
        ld de, snorlax
        call getPixelAddr
        call DrawSnorlax
        pop ix
        ret
s2:
        push ix
        ld ixl,96
        ld ixh,0
        ld b, 48

        push ix
        push bc
        call getPixelAddr
        call ClearSnorlax
        pop bc
        pop ix
    
        ld de, snorlaxInv
        call getPixelAddr
        call DrawSnorlax
        pop ix
        
        ret

DONUTSONSCREEN defb 0

d1    defb 72, 8
d1Dir defb 3, 1  ;current direction and previous direction
d1hl  defb 0, 0


d2    defb 172, 8
d2Dir defb 3, 0
d2hl  defb 0, 0


d3    defb  72, 8
d3Dir defb  3, 1
d3hl  defb  0, 0

d4    defb 172, 8
d4Dir defb 3, 0
d4hl  defb 0, 0


currDptr defb 0, 0
cDir     defb 0, 0
chl      defb 0, 0


dinit    defb 172, 8
dinitDir defb 3, 0
dinithl  defb 0, 0

dinit2    defb 72, 8
dinit2Dir defb 3, 1
dinit2hl  defb 0, 0

ptrAddr defw 0
resTrack defb 1
dTimer defb 1
DCounter defb 0
DonutCounter defb 0
resetdonutf defb 0
tracklevel defb 0
     
