;~@sa1 <-- DO NOT REMOVE THIS LINE!
;Flashlight effect by Incognito (optimized by Blind Devil)

init:
	LDA #$BF
	STA $40 ;adding or subtracting color from layers

main:
	REP #$20
	LDA #$00F8 ;custom pallete loading
	SEC
	SBC $7E ;player x-position
	;STA $7466|!addr ;layer 2 x-position
	;STA $1E ;layer 2 x-position current frame
     
	LDA #$00EC
	SEC
	SBC $80 ;player y-position
	CMP #$FF80 ;compare to left speed of layer 2
	BPL .FL ;branch if greater
     
	LDA #$FF80 ;load data from left speed of layer 2
.FL
	;STA $1468|!addr ;layer 2 y-position
	;STA $20 ;layer 2 y-position current frame
	SEP #$20
	RTL