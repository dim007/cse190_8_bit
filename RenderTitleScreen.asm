
RenderTitleScreen
   
        ld a, 71
        ld (23693), a
        xor a
        call 8859
        call 3503
   
        ld b, 0                        ;delta y
        ld c, 255                      ;delta x
        ld d, 0                        ;sign of y
        ld e, 1                        ;sign of x
        call 9402

        ld ixl, 24	               ;Location of Snorlax Title
        ld ixh, 130
        call getPixelAddr
        ;Draw first level platforms
        ld b, 32                      ;ten squares to draw
        ld de, arrow             ;location of frist level platforms
        call DrawTop
  
        ld ixl, 24	               ;Location of Snorlax Title
        ld ixh, 0
        call getPixelAddr
        ld b, 112
        ld de, snorlax_title
        call DrawLogo
        ret
DrawTop:
 
        push bc
        ld b, 24

NextAdj3:
   
        ld a, (de)
        ld (hl),a
        inc de
        inc hl
        djnz NextAdj3
        pop bc
        inc ixh
        call getPixelAddr
        djnz DrawTop
    
        ret
 
DrawLogo:

        push bc
        ld b, 26

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
	
