;~@sa1 <-- DO NOT REMOVE THIS LINE!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print "A block that bounces you up if you're spinjumping or on Yoshi and does nothing if you are not."
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV    : JMP SpriteH    : JMP MarioCape : JMP MarioFireball
JMP TopCorner  : JMP BodyInside : JMP HeadInside

TopCorner:
MarioAbove:
	LDA $740D	; Spinjumping flag
	ORA $787A	; Riding Yoshi flag
	BEQ Return	; Do nothing if not spinjumping and not riding yoshi

	LDA #$D0	; Low Bounce Height
	BIT $15		; Test controller bits
	BPL +		; Continue if holding A/B
	LDA #$A8	; High Bounce Height
+	STA $7D		; Make the player bounce

	LDA #$02	; Play sound "Spin Jumping Off Enemy"
	STA $7DF9

	JML $01AB99	; Do Spin Jumping off spiked enemy effect.

Return:
MarioSide:
BodyInside:
HeadInside:
MarioBelow:
SpriteV:
SpriteH:
MarioCape:
MarioFireball:
	RTL
