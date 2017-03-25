
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

        
;SCREEN 1 START
DrawAsh
        di                      ;disable interrupts
       
        ld iy,BKGRNDBUFF
        ld b,16                 ;16 rows to save
        ld ix, (playPos_x)
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
        ld de, ash1_r

DrawSprite
        call Shift
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
	 
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0
defb 0, 248, 0, 0, 0, 7, 128, 0, 0, 0, 127, 0, 14, 0, 0, 0, 0, 0, 0, 0, 0, 1, 192
defb 0, 0, 132, 0, 0, 0, 8, 64, 0, 0, 0, 8, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 56, 0
defb 0, 132, 231, 14, 28, 8, 11, 14, 24, 112, 8, 56, 2, 68, 179, 22, 0, 0, 0, 0, 0
defb 0, 7, 0, 0, 132, 136, 145, 34, 6, 12, 17, 4, 136, 8, 68, 2, 68, 204, 153, 0
defb 0, 0, 0, 0, 0, 0, 224, 0, 248, 136, 144, 32, 1, 136, 1, 0, 136, 8, 68, 2, 68
defb 136, 145, 0, 0, 0, 0, 255, 255, 255, 248, 0, 128, 143, 142, 28, 0, 8, 143, 32
defb 248, 8, 68, 2, 68, 136, 145, 0, 0, 0, 0, 0, 0, 0, 224, 0, 128, 136, 1, 2, 0
defb 8, 145, 32, 128, 8, 68, 2, 68, 136, 145, 0, 0, 0, 0, 0, 0, 7, 0, 0, 128, 136
defb 145, 34, 8, 140, 147, 36, 136, 8, 68, 34, 76, 136, 153, 0, 0, 0, 0, 0, 0, 56
defb 0, 0, 128, 135, 14, 28, 7, 139, 12, 152, 112, 8, 56, 28, 52, 136, 150, 0, 0
defb 0, 0, 0, 1, 192, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0
defb 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
defb 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
oldPlayPos_x:
        DEFB 0
oldPlayPos_y:
        DEFB 0
playPos_x:
	DEFB 0
playPos_y:
	DEFB 159
curPos_x:
        DEFB 0
curPos_y:
        DEFB 159
isJump:
	DEFB 0
