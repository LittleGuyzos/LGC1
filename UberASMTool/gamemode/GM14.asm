;Insert this as gamemode 14 under "main:"

incsrc "../SSPDef/Defines.asm"

main:
.ScreenScrollingPipes:
	LDA !Freeram_PipeDir		;\don't do anything while outside the pipe.
	ORA !Freeram_PipeTmr		;|
	BNE ..PipeCodeStart		;|
	JMP ..PipeCodeReturn		;/

;-------------------------------------------------------
;Speed tables, Do not change the cap speeds.
;-------------------------------------------------------
;	         U   R   D   L
;indexes:        0   1   2   3
..pipe_x_spd db $00,$40,$00,$C0 ;>x Speed.
..pipe_y_spd db $C0,$00,$40,$00 ;>y speed.


;Don't touch these unless you remap the poses: [beta stuff]
;WalkingFrames:
;db $00,$00,$00,$00,$01,$01,$01,$01,$02,$02,$02,$02

;---------------------------------
;This sets mario's status
;---------------------------------
	..PipeCodeStart

	LDA $71
	CMP #$09	; death
	BNE +
	JSL ...ResetStatus
	LDA #$09	; recover $71
	STA $71
	RTL
+
	...MarioStatus
	LDA !Freeram_CarrySpr	;\fix automatic drop item when carrying
	AND #$01
	BEQ ....NotCarrying	;|
	LDA #$40		;|
	BRA ....SetControls	;|

	....NotCarrying
	LDA #$00		;/

	....SetControls
	STA $15			;\lock controls
	STZ $16			;|
	STZ $17			;|
	STZ $18			;/
	STZ $13F3+!addr		;\remove p-balloon
	STZ $1891+!addr		;/
	STZ $1697+!addr		;>remove consecutive stomps.
	STZ $140D+!addr		;>so fire mario cannot shoot fireballs in pipe

	LDA !Freeram_EntrExtFlg	;\hide player if timer hits zero when entering.
	CMP #$02		;|
	BEQ ....NoHide		;|
	LDA !Freeram_PipeTmr	;|
	BNE ....NoHide		;|
	if !PipeDebug == 0
		LDA #$EF	;|
		LDY $187A+!addr
		BEQ +
		LDA #$FF
	+
		STA $78		;/
	endif

	....NoHide
	LDA $187A+!addr		;\if on yoshi, then use yoshi poses
	BNE ....OnYoshi		;/
	STZ $73			;>so mario cannot remain ducking (unless on yoshi) as he exits.

	....OnYoshi
	LDA !Freeram_PipeDir	;\different yoshi pose, If going vertical, then yoshi faces the screen.
	CMP #$01		;|(this should make mario carry carryable sprites in center of him facing the screen)
	BEQ ....YoshiFaceScreen	;|
	CMP #$03		;|
	BEQ ....YoshiFaceScreen	;|
	CMP #$05		;|
	BEQ ....YoshiFaceScreen	;|
	CMP #$07		;|
	BEQ ....YoshiFaceScreen	;/

	....YoshiDuck		;>horizontal pipe
	LDA $187A+!addr		;\Do not duck if not riding yoshi.
	BEQ ....NoDuck		;/
	LDA #$04		;\crouch on yoshi
	STA $73			;/

	....NoDuck
	LDA #$01			;|(this should make mario face left or right carrying sprites to the side)
	BRA ....SkipYoshiFaceScrn	;/

	....YoshiFaceScreen	;\yoshi face the screen (vertical pipe, Nintendo did this so that yoshi's head
	LDA #$02		;/doesn't display a glitch graphic).

	....SkipYoshiFaceScrn
	STA $1419+!addr		;>Even if you are not mounted on yoshi, you still have to write a value here, or carrying sprites don't work.

	....SkipYoshiPose
	if !PipeDebug == 0
		LDA #$02		;\go behind layers
		STA $13F9+!addr		;/
	endif
	LDA #$0B		;\freeze time
	STA $71			;|
	LDA #$01		;\allow vertical scroll up.
	STA $1404+!addr		;/
	STZ $14A6+!addr		;>no spinning.
	STZ $1407+!addr		;>so mario cannot fly out of the cap
	STZ $72			;>zero air flag.
	STZ $14A3+!addr		;>no yoshi tongue
	LDA !Freeram_CarrySpr	;\if mario not carrying anything, then skip
	AND #$01
	BEQ ....NotCarry	;/
	LDA #$01		;\force keep carrying
	STA $1470+!addr		;|
	STA $148F+!addr		;/

	....NotCarry
	LDA !Freeram_PipeDir	;\set player speed within pipe (use transfer commands
	DEC
	AND #$03
	TAY			;|so you can use long freeram address)
	LDA ..pipe_x_spd,y	;|
	STA $7B			;|
	LDA ..pipe_y_spd,y	;|
	STA $7D			;/
;-------------------------------
;Entering and exiting
;-------------------------------
	...EnterExitTransition
	LDA !Freeram_EntrExtFlg	;>If mario is out of a pipe and is entering them...
	BNE ....InPipe		;>if not 0, skip
	JMP ..PipeCodeReturn	;>branch out of range

	....InPipe
	CMP #$01		;\If entering a pipe...
	BEQ ....entering_pipe	;/
	CMP #$02		;\If exiting a pipe...
	BEQ ....ExitingPipe	;/
	JMP ..PipeCodeReturn

	....entering_pipe	;
	LDA !Freeram_PipeTmr	;\If timer is 0, set pose
	BEQ +
	CMP #$05
	BCS ....accel

	DEC
	STA !Freeram_PipeTmr
	JMP ...pose
+
	LDA $19
	BEQ +
	ASL
	ORA !Freeram_CarrySpr
	STA !Freeram_CarrySpr
	STZ $19
+
	BRA ...pose


	....accel
	LDA #$04
	STA !Freeram_PipeTmr
	LDA !Freeram_PipeDir	;\Use another set of 4 speeds.
	SEC			;|
	SBC #$04		;/
	BMI ....AccelDone	;>Prevent continously decrementing into negative
	STA !Freeram_PipeDir	;>And set pipe direction

	....AccelDone
	BRA ...pose

	....ExitingPipe		;
	LDA !Freeram_PipeTmr	;\if timer already = 0, then skip the reset (so it does it once).
	BEQ ...ResetStatus	;>Reset status if timer hits zero (happens once after -1 to 0).
	CMP #$0E
	BCS ....decel

	DEC
	STA !Freeram_PipeTmr
	BRA ...pose


	....decel
	LDA !Freeram_CarrySpr
	LSR
	BEQ +
	STA $19
+
	TYA
	AND #$01
	BEQ +
	LDA #$02		; horizontal
	BRA ++
+
	; vertical
	LDA #$06
	CPY #$00
	BEQ +
	; vertical down
	LDA #$05
	LDY $19
	BNE +
	DEC			; vertical down & small
+
	LDY $187A+!addr		; yoshi check
	BEQ ++
	INC
++
	STA !Freeram_PipeTmr
	LDA !Freeram_PipeDir	;\Use the first 4 speeds (excluding index 0)
	CLC			;|
	ADC #$04		;/
	CMP #$09		;\Prevent incrementing beyond the 8th index
	BCS ...pose		;/
	STA !Freeram_PipeDir		;>Set direction
	BRA ...pose		;>and skip the reset routine
;---------------------------------
;This resets mario's status.
;It must be exceuted once.
;---------------------------------
	...ResetStatus
	LDA !Freeram_CarrySpr	;\Holding sprites routine
	AND #$01
	BEQ ....NotCarry1	;|
	LDA #$40		;|
	BRA ....SkipNtCarry1	;|

	....NotCarry1		;|
	LDA #$00		;|

	....SkipNtCarry1	;|
	STA $15			;/
	STZ $13F9+!addr		;>go in front
	STZ $71			;>mario can move
	STZ $73			;>stop crouching (when going exiting down on yoshi)
	STZ $140D+!addr		;>no spinjump out the pipe (possable if both enter and exit caps are bottoms)
	STZ $7B			;\cancel speed
	STZ $7D			;/
	STZ $1419+!addr		;>revert yoshi
	STZ $149F+!addr		;>zero cape "rise up timer"
	LDA #$00		;\reset freeram flags
	STA !Freeram_PipeDir	;|
	STA !Freeram_PipeTmr	;|
	STA !Freeram_CarrySpr	;|
	STA !Freeram_EntrExtFlg	;/>Make code assume mario is out of the pipe.

	JMP ..PipeCodeReturn
;-----------------------------------------
;code that controls mario's pose
;-----------------------------------------
...pose
	LDA !Freeram_PipeDir	;\set pose according to direction.
	CMP #$01		;|\Vertical direction
	BEQ ....Vert		;||
	CMP #$03		;||
	BEQ ....Vert		;||
	CMP #$05		;||
	BEQ ....Vert		;||
	CMP #$07		;||
	BEQ ....Vert		;|/
	CMP #$02		;|\Horizontal direction
	BEQ ....Horiz		;||
	CMP #$04		;||
	BEQ ....Horiz		;||
	CMP #$06		;||
	BEQ ....Horiz		;||
	CMP #$08		;||
	BEQ ....Horiz		;//

	....Vert
	LDA $187A+!addr		;\if mario is riding yoshi, then
	BNE ....YoshiFaceScrn	;/use face screen instead
	LDA #$0F		;>vertical pipe pose (without regard to powerup status)
	BRA ....SetPose

	....Horiz
	LDA $187A+!addr		;\if mario is riding yoshi, then
	BNE ....YoshiFaceHoriz	;/use "ride yoshi" pose
	LDA #$00
	BRA ....SetPose

	....YoshiFaceScrn
	LDA #$21		;>pose that mario turns around partically face the screen
	BRA ....SetPose

	....YoshiFaceHoriz
	LDA #$1D		;>crouch as entering a horizontal pipe on yoshi.

	....SetPose
	STA $13E0+!addr		;>set player pose

	..PipeCodeReturn
	RTL