RenderGameover

  ld a, 71
  ld (23693), a
  xor a
  call 8859
  call 3503

  ; Gameover Title
  ld ixl, 8
  ld ixh, 7
  call getPixelAddr
  ld b, 48
  ld de, gameover_title
  call DrawGameover
;  ret

  ; lover snorlax
  ld ixl, 24
  ld ixh, 135
  call getPixelAddr
  ld b, 48 ; y pixel size
  ld de, lowerSnorlax
  call DrawLowerSnorlax

  ; feels bad
  ld ixl, 139
  ld ixh, 179
  call getPixelAddr
  ld b, 8
  ld de, feelsbad
  call DrawFeelsBad

sleep1:
  ; upper snorlax 1
  ld ixl, 24
  ld ixh, 63
  call getPixelAddr
  ld b, 72
  ld de, upSnorlax1
  call DrawUpperSnorlax
  
  ld a, (SLEEP)
  inc a
  ld (SLEEP), a

gameoverloop:
  ; restart
  ld bc, 49150
  in a, (c)
  rra
  call nc, title


  ld a, (SLEEP)
  cp 14
  jp c, sleep1
  ld a, (SLEEP)
  cp 29
  jp c, sleep2
  ld a, (SLEEP)
  cp 44
  jp c, sleep3
  ld a, (SLEEP)
  cp 59
  jp c, sleepr

sleep2:  
  ; upper snorlax 2
  ld ixl, 24
  ld ixh, 63
  call getPixelAddr
  ld b, 72
  ld de, upSnorlax2
  call DrawUpperSnorlax
  ld a, (SLEEP)
  inc a
  ld (SLEEP), a 
  jp gameoverloop


sleep3:  
  ; upper snorlax 3
  ld ixl, 24
  ld ixh, 63
  call getPixelAddr
  ld b, 72
  ld de, upSnorlax3
  call DrawUpperSnorlax
  ld a, (SLEEP)
  inc a
  ld (SLEEP), a
  jp gameoverloop

sleepr:
  ld a, 0
  ld (SLEEP), a
  jp gameoverloop

DrawGameover:
  push bc
  ld b, 29

NextGameover
  ld a, (de)
  ld (hl), a
  inc de
  inc hl
  djnz NextGameover
  pop bc
  inc ixh
  call getPixelAddr
  djnz DrawGameover
  ret

DrawLowerSnorlax:
  push bc
  ld b, 27  ; x char size

NextLowerSnorlax:
  ld a, (de)
  ld (hl), a
  inc de
  inc hl
  djnz NextLowerSnorlax
  pop bc
  inc ixh
  call getPixelAddr
  djnz DrawLowerSnorlax
  ret

DrawUpperSnorlax:
  push bc
  ld b, 28 ; x char size

NextUpperSnorlax:
  ld a, (de)
  ld (hl), a
  inc de
  inc hl
  djnz NextUpperSnorlax
  pop bc
  inc ixh
  call getPixelAddr
  djnz DrawUpperSnorlax
  ret


DrawFeelsBad:
  push bc
  ld b, 14 ; x char size

NextFeelsBad:
  ld a, (de)
  ld (hl), a
  inc de
  inc hl
  djnz NextFeelsBad
  pop bc
  inc ixh
  call getPixelAddr
  djnz DrawFeelsBad
  ret

DrawBubble:
  push bc
  ld b, 3 ; x char size

NextBubble:
  ld a, (de)
  ld (hl), a
  inc de
  inc hl
  djnz NextBubble
  pop bc
  inc ixh
  call getPixelAddr
  djnz DrawBubble
  ret


SLEEP DEFB 0   
