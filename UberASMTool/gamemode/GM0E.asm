;gamemode 0E (Overworld)
init:
	incsrc "../RelativeTeleportDefines/Defines.asm"
	ClearMarioTeleportState:
	LDA #$00			;\Don't apply player info when entering level from map.
	STA !Freeram_PlayerInfoSave	;/
	RTL
