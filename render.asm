
getPixelAddr            ;Source:http://www.animatez.co.uk/computers/zx-spectrum/screen-memory-layout/
	
        LD A,ixh                ; Calculate Y2,Y1,Y0
        AND %00000111           ; Mask out unwanted bits
        OR %01000000            ; Set base address of screen
        LD H,A                  ; Store in H
        LD A,ixh                ; Calculate Y7,Y6
        RRA                     ; Shift to position
        RRA
        RRA
        AND %00011000           ; Mask out unwanted bits
        OR H                    ; OR with Y2,Y1,Y0
        LD H,A                  ; Store in H
        LD A,ixh                ; Calculate Y5,Y4,Y3
        RLA                     ; Shift to position
        RLA
        AND %11100000           ;  Mask out unwanted bits
        LD L,A                  ; Store in L
        LD A,ixl                ; Calculate X4,X3,X2,X1,X0
        RRA                     ; Shift into position
        RRA
        RRA
        AND %00011111           ; Mask out unwanted bits
        OR L                    ; OR with Y5,Y4,Y3
        LD L,A                  ; Store in L
        RET

DrawArrow
        di
        push ix
        ld ix, (oldArrowx)
        ld b, 8
        call getPixelAddr
        call BlackOut
        pop ix
        ld a, ixl
        ld (oldArrowx),a
        ld a, ixh
        ld (oldArrowy),a
        call getPixelAddr
        ld b,8
        ld de, arrow

ArrowLoop
        ld a,(de)               ;load first byte
	ld (hl),a               ;write to screen mem
        inc de                  ;get next byte 
        inc ixh                 ;get next row byte address
        call getPixelAddr
	djnz ArrowLoop
       
        ei
        ret        

       
BlackOut
        ld a, 0
        ld (hl),a
        inc hl                  ;get adjecent 8x8 cell
        inc ixh                 ;get next row byte address
        call getPixelAddr
	djnz BlackOut
        ld ixh ,113
        ret
        
;SCREEN 1 START
DrawAsh
        di                      ;disable interrupts
       
       
        ld (SCRNADDR), hl
        ld iy,BKGRNDBUFF
        ld b,16                 ;16 rows to save

STOREBACKGROUND
        
        call getPixelAddr
        ld a,(hl)               ;get first byte
        ld (iy), a              ;store byte in buffer
        inc iyl                 ;addr of next buf address
        inc l                   ;next byte of data

        ld a,(hl)
        ld (iy),a
        inc iyl
        inc ixh
        djnz STOREBACKGROUND

       
        ld hl,(SCRNADDR)
        ld a, (playPos_y)       ;load init y player position
	ld ixh,a
        ld a, (playPos_x)       ; x position
	ld ixl,a
        ld b, 16
        ld de, ash1

DrawSprite
        
        ld a,(de)               ;load first byte
	ld (hl),a               ;write to screen mem
        inc de                  ;get neddxt byte 
        inc hl                  ;get adjecent 8x8 cell
        ld a,(de)               ;load adj cell
        ld (hl),a
        inc de                  ;get next byte
        inc ixh                 ;get next row byte address
        call getPixelAddr
	djnz DrawSprite
        ei
        ret        
        

wait
        ld bc,$1fff
	dec bc
	ld a,b
	or c
	jr nz, wait
        ret

ClearSprite
        
        ld a,(iy)
        ld (hl),a
        inc iyl                 ;get adjecent 8x8 cell
        inc l
        ld a,(iy)
        ld (hl),a
        inc iyl                ;get next byte
        inc ixh                 ;get next row byte address
        call getPixelAddr
	djnz ClearSprite
	ld a,(playPos_y)
        ld ixh,a
        ret
arrow:
	DEFB	 24, 24, 24, 24,255,126, 60, 24
	DEFB	 71
oldPlayPos_x:
        DEFB 0
oldPlayPos_y:
        DEFB 0
playPos_x:
	DEFB 0
playPos_y:
	DEFB 167
curPos_x:
        DEFB 39
curPos_y:
        DEFB 123
isJump:
	DEFB 0
