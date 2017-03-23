SetInterrupt
  	di
        ld hl, Interrupt
        ld ix, &FFF0
        ld (ix+04h), &c3
        ld (ix+05h),l
        ld (ix+06h),h
        ld (ix+0Fh),&18
        ld a, &39
        ld i,a
        im 2
        ei
        ret

Interrupt

       di
       push          af
       push          hl
       push          bc
       push          de
       push          ix
       push          iy
       exx
       ex            af,af'
       push          af
       push          hl
       push          bc
       push          de

       ld a, (in_level)
       cp 1                                ;rom routine, read keys and update cloclk
       call z, MoveDonutsProc              ;interrupt routine that move prjectile one at a time
      
        pop           de
        pop           bc
        pop           hl
        pop           af
        ex           af,af'
        exx
        pop           iy
        pop           ix
        pop           de
        pop           bc
        pop           hl
        pop           af
        ei
        reti

MoveDonutsProc:
       
       ld a, (dTimer)                  ;Once timer runs, a new donut is created if Cap 
                                       ;if cap has not been reached
       dec a
       ld (dTimer),a
       cp 0

       call z, CAP
       call MoveOneDonut
    
       ret 
CAP:    
        ld a, (DONUTSONSCREEN)
        cp 3
        call nz, SetUpDonuts           ;If cp has not been reached, make new donut
        ret 
   
MoveOneDonut:

        ld a, (DonutCounter)           ;cycle through all donuts
        cp 0
        call nz, MoveDonuts
        ld a,(DonutCounter)
        call z, RestartCycle
       
	ret 
RestartCycle:
        ld a, (DONUTSONSCREEN)
        ld (DonutCounter), a
        ret
