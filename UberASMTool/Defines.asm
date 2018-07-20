!Freeram_RelCoorWarp	= $60
;^[4 bytes] Position to add from the position the player is at placed on lunar magic,
;format:
; +$00 to $01 = Player's X position displacement
; +$02 to $03 = Player's Y position displacement

!Freeram_PlayerInfoSave	= $7F8459
;^[9 bytes] Player's info during warp:
; +$00 = don't apply these to player if #$00.
; +$01 = Player's X speed
; +$02 = Player's Y speed
; +$03 = Player's facing direction
; +$04 = Dash timer
; +$05 = Spinjump flag
; +$06 = Cape phase
; +$07 = Cape change index
; +$08 = Cape spin timer
; +$09 = Air flag (pose)