LEVEL1 
       
        
       
scene1:
        
        di
        call 3503

        ;Draw first level platforms
        ld b, 8
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

        ld b, 56
        ld de, snorlax
        ld ixl,90
        ld ixh,20
        call getPixelAddr
        call DrawSnorlax


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
        push ix
        call SetUpDonuts
        pop ix
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

        ld b, 11
        call DrawConnectedPoints
        pop bc
        djnz DrawLvl1Platforms

        ret

DrawConnectedPoints:

        push bc
        ld b, (ix)             ;delta y
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
        
scene1movement
        push ix
        push iy
        ;call MoveDonuts
        pop iy
        pop ix
        call MovementLoop
        ld a, (playPos_x) 
        cp 99
        jp z, SetFGFlag
        
        ld a, (playPos_x)
        cp 195
        ;jp z, GoToScene2

	jp scene1movement  

SetUpDonuts:
        
        ld a, 1
        ld (NUMBEROFDONUTS), a
        ld de, donut
        ld ixl,57
        ld ixh,40
        call getPixelAddr
        ld (d1hl), hl
        ld b, 16
        call SaveProjectileBackground
        ld hl, (d1hl)
        ld b,16
        call DrawDonut 

        ret 

MoveDonuts:
        ld a, (NUMBEROFDONUTS)
        ld b, a

ShiftDonuts:
     
        ld a, (d1Dir)
        ;cp 1
       ; jp z, ShiftUp
   
       
        cp 2
        jp z, ShiftRight

      
        cp 3
        jp z, ShiftDown

        ;add a, 3
        ;cp 4
        ;jp z, ShiftLeft
  
        ret

DownDetection:
        push ix
        push hl
        ld a,ixh
        add a, 16
        ld ixh, a
        call getPixelAddr
        ld a,(hl)
        pop hl
        pop ix
        cp 255
        jr z, DownObDet
        ret

DownObDet:

        ld a, 2
        ld (d1Dir), a
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
        ld (d1Dir), a
        ret
ShiftDown:
        ld ix, (d1)
        call ClearProjectiles
        inc ixh
        ;inc ixh
        call getPixelAddr
        call DownDetection
        call AshCollision
        jp ShiftLogic

ShiftRight:

        ld ix,(d1)
        call ClearProjectiles
        inc ixl
        ;inc ixl
        call getPixelAddr
        call RightDetection
        call AshCollision
        jp ShiftLogic 
       
       
ShiftLogic:
    
        ld (d1hl),hl
        ld (d1), ix
        ld b,16
        call SaveProjectileBackground
        ld de, donut
        ld b,16
        call DrawDonut 
        ret

ClearProjectiles
        push ix
        ld ix, (d1)
        ld iy, PROJECTILEBUFF
        ld hl,(d1hl)
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
        ld iy, PROJECTILEBUFF
        call SaveBackground
        pop hl
        pop ix 
        ret     
AshCollision:

        ld a, (d1)
        ld iy, (playPos_x)
        cp iyl
        jp z, ySame
   
        ret
ySame:
         ld a,(d1+1)
         cp iyh
         jp z, newgame
         ret
newgame:
        di
        ld a, 0
        ld (in_level), a
        ld d, 40
        ld e, 57
        ld (d1), de
        jp title

SetFGFlag

         ld a, (INFOREGROUND)
         xor 1
         ld (INFOREGROUND), a
	 jp scene1movement
 
scene2movement
        call MovementLoop
        jr scene2movement
      
NUMBEROFDONUTS defb 0
d1 defb 57, 40
d2 defb 0, 0
d3 defb 0, 0
d4 defb 0, 0
d5 defb 0, 0
d6 defb 0, 0  
d1Dir defb 3
d2Dir defb 0
d3Dir defb 0
d4Dir defb 0
d5Dir defb 0
d6Dir defb 0
d1hl defw 0
d2hl defw 0
d3hl defw 0
d4hl defw 0
d5hl defw 0
d6hl defw 0
PROJECTILEBUFF EQU 64570

     
