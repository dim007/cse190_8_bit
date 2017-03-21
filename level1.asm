LEVEL1 
       
        
       
scene1:
        
        di
        call 3503

        ld b, 48
        ld de, snorlax
        ld ixl,96
        ld ixh,0
        call getPixelAddr
        call DrawSnorlax

        ;Draw first level platforms
        ld b, 10
        ld ix, firstLPlats
        call DrawLvl1Platforms

        ld b, 0
        ld c, 0
        ld (23677), bc
        call 8933  

        ld b, 0            ;delta y
        ld c, 255          ;delta x
        ld d, 0            ;sign of y
        ld e, 1            ;sign of x
        call 9402

        ld a,(playPos_x)
        ld ixl,a
        ld a,(playPos_y)
        ld ixh,a
        
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
       
        ld a, 1
        ld (in_level), a
        ei
        jp scene1movement
        
DrawSnorlax:
        push bc
        ld b,8
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

DrawDonut:
        
         push bc
         ld b,2
        
adjF    
        ld a, (de)
        or (hl)
        ld (hl), a
        inc de
        inc hl
        djnz adjF

        inc ixh
        call getPixelAddr

        pop bc
        djnz DrawDonut
      
        ret

DrawLvl1Platforms

        push bc
        
        ld b, (ix)
        ld c, (ix + 1)   
        ld (23677), bc
        call 8933               ;plots a single point
        inc ix
        inc ix

        ld b, 4
        call DrawConnectedPoints
        pop bc
        djnz DrawLvl1Platforms

        ret

DrawConnectedPoints:

        push bc
        ld b, (ix)              ;delta y
        ld c, (ix+1)            ;delta x
        ld d, (ix+2)            ;sign of y
        ld e, (ix+3)            ;sign of x
        call 9402
        inc ix
        inc ix
        inc ix
        inc ix
        pop bc
        
        djnz DrawConnectedPoints
        ret   
     
AnimateSnorlax:
        
        ld b, 48
        
        ld ixl,96
        ld ixh,0
        call getPixelAddr
        push de
        push ix
        push hl
        push bc
        call ClearSnorlax
        pop bc
        pop hl
        pop ix
        pop de
        push de
        push ix
        push hl
        push bc
        call DrawSnorlax
        pop bc
        pop hl
        pop ix
        pop de
        
        ret 

ClearSnorlax:
        push bc
        ld b,8
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
scene1movement
      
        call MovementLoop
        ld a, (playPos_x) 
        cp 99
        jp z, SetFGFlag
        
        ld a, (playPos_x)
        cp 195
        ;jp z, GoToScene2

	jp scene1movement  
UpdateDonutPointer:

  
        cp 0
        jr z, Projectile1
        cp 1
        jr z, Projectile2
        cp 2
        jr z, Projectile3
        cp 3
        jr z, Projectile4
        cp 4
        jr z, Projectile5
        cp 5
        jr z, Projectile6
        ret
        
endTrans:  
        ret

Projectile1:

        ld bc, 6
        ld de, currDptr
        ld hl, d1
        ld (ptrAddr), hl
        ldir
        ld hl, 64577
        ld (PROJECTILEBUFF), hl
        jr endTrans

Projectile2:

        ld bc, 6
        ld de, currDptr
        ld hl, d2
        ld (ptrAddr), hl
        ldir
        ld hl, 64642
        ld (PROJECTILEBUFF), hl
        jr endTrans

Projectile3:
        ld bc, 6
        ld de, currDptr
        ld hl, d3
        ld (ptrAddr), hl
        ldir
        ld hl, 64707
        ld (PROJECTILEBUFF), hl
        jr endTrans

Projectile4:

        ld bc, 6
        ld de, currDptr
        ld hl, d4
        ld (ptrAddr), hl
        ldir
        ld hl, 64772
        ld (PROJECTILEBUFF), hl
        jr endTrans

Projectile5:
        ld de, currDptr
        ld hl, d5
        ld (ptrAddr), hl
        ldir
        jr endTrans

Projectile6:
        ld de, currDptr
        ld hl, d6 
        ld (ptrAddr), hl
        ldir
        jr endTrans

SetUpDonuts:
     
        ld a, (DonutCounter)
        inc a
        ld a, (DonutCounter)
      
        ld a,150
        ld (dTimer), a
        ld a, (DONUTSONSCREEN)

        ;find index in stack of new donut position
        call UpdateDonutPointer    
        
        ld de, donut
        ld ix,(currDptr)
        
        call getPixelAddr
        ld (chl), hl
        ld b, 16
        call SaveProjectileBackground
        
        ld hl,(chl)
        ld b,16
        call DrawDonut
        
        ld a, (DONUTSONSCREEN)
        inc a
        ld (DONUTSONSCREEN),a
        ld bc, 6                 ;save our data to projectile's mem location
        ld hl, currDptr
        ld de, (ptrAddr)
        ldir
        ;ld de, snorlaxInv
        ;call AnimateSnorlax

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
ShiftDonuts:
        
        ld a, (cDir)
        
        
        cp 1
        jp z, ShiftLeft
        
        cp 3
        jp z, ShiftDown
           
        cp 0
        jp z, ShiftRight
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
        pop hl
        pop ix
        cp 255
        jr z, DownObDet
        
        ret
resetdonut:
        ld a, 1
        ld (resetdonutf), a
        ld a, (cDir + 1)
        cp 1
        jr z, fCh
   
        ld bc, 6
        ld de, (ptrAddr)
        ld hl, dinit2
        ldir
        ret
        
fCh
     
        ld bc, 6
        ld de, (ptrAddr)
        ld hl, dinit
        ldir
      
        ret

DownObDet:
        ld a,(cDir + 1)
        ld (cDir), a
        xor 1
        ld (cDir + 1), a
   
        ret

RightDetection:
        push ix
        push hl
        ld a,ixh
        add a, 16
        ld ixh, a
        call getPixelAddr
        ld a,(hl)
        pop hl
        pop ix
        cp 0
        jr z, RightObDet
        ret

RightObDet:

        ld a, 3
        ld (cDir), a
        ret

ShiftDown:

        ld ix,(currDptr)
        call ClearProjectiles
        ld ix, (currDptr)
        inc ixh
        inc ixh
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

        ld ix,(currDptr)
        call ClearProjectiles
        ld ix, (currDptr)
        inc ixl
        inc ixl
        inc ixl
        ld b,16
        call getPixelAddr
        call RightDetection
        call AshCollision
        call ShiftLogic 
        ret
       
ShiftLeft:

        ld ix,(currDptr)
        call ClearProjectiles
        ld ix, (currDptr)
        ld b,16
        dec ixl
        dec ixl
        dec ixl
        call getPixelAddr
        call RightDetection
        call AshCollision
        call ShiftLogic 
        ret 
    
ShiftLogic:
        
        ld (chl), hl
        ld (currDptr), ix
        ld b,16
        call SaveProjectileBackground
        ld de, donut
        ld b,16
        call DrawDonut 
        ld bc, 6
        ld hl, currDptr
        ld de, (ptrAddr)
        ldir
        ret
ClearProjectiles
        
        push ix
        ld iy, (PROJECTILEBUFF)
        call getPixelAddr
        ld b,16
        call ClearProjectile
        pop ix
        
        ret

ClearProjectile
        
        
        ld a,(iy)
        ld (hl),a
        inc iyl                 ;get adjecent 8x8 cell
        inc l
        ld a,(iy)
        ld (hl),a
        inc iyl                ;get next byte
        inc ixh                 ;get next row byte address
        call getPixelAddr
	djnz ClearProjectile
	
        ret

SaveProjectileBackground:
        push ix
        push hl
        ld iy, (PROJECTILEBUFF)
        call SaveBackground
        pop hl
        pop ix 
        ret     
AshCollision:
        
      
        ld a, (currDptr)
        ld iy,playPos_x

        sub (iy)
        add a,10
        cp 27
        jp c, ySame
        
        ret
ySame:
         ld a,(currDptr+1)
         sub (iy+1)
         add a,10
         cp 27
         jp c, newgame
         ret
newgame:
        di
        ld a, 0
        ld (in_level), a
        ld d, 8
        ld e, 72
        ld (d1), de
        ld d, 8
        ld e, 176
        ld (d2), de
        ld a, 3
        ld d, 8
        ld e, 72
        ld (d3), de
        jp title

SetFGFlag

         ld a, (INFOREGROUND)
         xor 1
         ld (INFOREGROUND), a
	 jp scene1movement
 
scene2movement
        call MovementLoop
        jr scene2movement
      

DONUTSONSCREEN defb 0

d1    defb 72, 8
d1Dir defb 3, 1  ;current direction and previous direction
d1hl  defb 0, 0


d2    defb 176, 8
d2Dir defb 3, 0
d2hl  defb 0, 0


d3    defb  72, 8
d3Dir defb  3, 1
d3hl  defb  0, 0


d4    defb 176, 8
d4Dir defb 3, 0
d4hl  defb 0, 0

d5    defb 72, 8
d5Dir defb 3, 1
d5hl  defb 0, 0

d6    defb 176, 8
d6Dir defb 3, 0
d6hl  defb 0, 0

currDptr defb 0, 0
cDir     defb 0, 0
chl      defb 0, 0

dinit    defb 176, 8
dinitDir defb 3, 0
dinithl  defb 0, 0

dinit2    defb 72, 8
dinit2Dir defb 3, 1
dinit2hl  defb 0, 0

ptrAddr defw 0

dTimer defb 1
PROJECTILEBUFF defw 0
DCounter defb 0
DonutCounter defb 0
resetdonutf defb 0
     
