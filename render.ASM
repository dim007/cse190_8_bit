ClearSprite
        ld a, 0
        ld (hl),a
        inc hl                  ;get adjecent 8x8 cell
        ld (hl),a
        inc de                  ;get next byte
        inc ixh                 ;get next row byte address
        call getPixelAddr
	djnz ClearSprite
        ld ixh ,167
        ret
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
DrawSprite
     
        ld a,(de)               ;load first byte
	ld (hl),a               ;write to screen mem
        inc de                  ;get next byte 
        inc hl                  ;get adjecent 8x8 cell
        ld a,(de)               ;load adj cell
        ld (hl),a
        inc de                  ;get next byte
        inc ixh                 ;get next row byte address
        call getPixelAddr
	djnz DrawSprite
        ret
wait
        ld bc,$1fff
	dec bc
	ld a,b
	or c
	jr nz, wait
playPos_x:
	DEFB 50
playPos_y:
	DEFB 167
curPos_x:
        DEFB 39
curPos_y:
        DEFB 123
isJump:
	DEFB 0
