
RenderTitleScreen
   
   ld a, 71
   ld (23693), a
   xor a
   call 8859
   call 3503

   ld ixl, 8        ;Location of first Door
   ld ixh, 128
   call getPixelAddr
   ld b, 64 
   ld de, Door1
   call DrawDoor


   ld ixl,67        ;Location of second Door
   ld ixh, 128
   call getPixelAddr
   ld b,64
   ld de, Door1
   call DrawDoor

     
   ld ixl, 127       ;Location of third Door
   ld ixh, 128
   call getPixelAddr
   ld b, 64 
   ld de, Door1
   call DrawDoor


   ld ixl,189        ;Location of fourth Door
   ld ixh, 128
   call getPixelAddr
   ld b,64
   ld de, Door1
   call DrawDoor

   ld ixl,24
   ld ixh,8
   call getPixelAddr
   ld b,88           ;draw title screen
   ld de , title_name
   call DrawLogo
   ret

DrawDoor:
    push bc
    ld b, 7

NextAdj:
   
    ld a, (de)
    ld (hl),a
    inc de
    inc hl
    djnz NextAdj
    pop bc
    inc ixh
    call getPixelAddr
    djnz DrawDoor
    
    ret
DrawLogo:

    push bc
    ld b, 27

NextAdj2:
   
    ld a, (de)
    ld (hl),a
    inc de
    inc hl
    djnz NextAdj2
    pop bc
    inc ixh
    call getPixelAddr
    djnz DrawLogo
    
    ret
     

      

firArrow:  DEFB 32
           DEFB 113
secArrow:  DEFB 88
           DEFB 113
thrdArrow: DEFB 153
           DEFB 113
frthArrow: DEFB 214
           DEFB 113
oldArrowx: DEFB 0
oldArrowy: DEFB 0	
	
