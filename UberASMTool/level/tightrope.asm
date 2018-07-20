;~@sa1 <-- DO NOT REMOVE THIS LINE!
print "A block that is solid to Mario when walking but not when running"

db $42
jmp return : JMP marioabove : jmp return
jmp return : jmp return
jmp return : jmp return
jmp return : jmp return : jmp return

marioabove:        lda $7B		;// x speed
                   bpl noneedtounsign	;// branch if positive
                   eor #$FF		;// flip bits from negative to positive
noneedtounsign:    cmp #$20
                   bcs return		;// if x speed is greater than 20, return
		   lda #$05
		   sta $7693		;// otherwise, makes block act like rope
		   ldy #$01
return:		   rtl