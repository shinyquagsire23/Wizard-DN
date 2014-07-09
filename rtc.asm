@ Fire Red RTC Hack
@ Version 1.0.2
@ By ZodiacDaGreat
@ Modified by Shiny Quagsire
@ Put 00B5 0148 0047 0000 [Reverse Address+1] 0000 10BC at 0x4B0
@ ----------------------------------------------------------------
.code 16
.thumb

.org 0x08B01000
.Main:
	push {r4}

@ RTC Part
	bl .SetupRTC
	ldr r0, .IWRAMRTC
	bl .ManipulateRTC

@ Part of the original routine
	ldr r4, .UnkFunc1
	bl .BranchLink
	lsl r0, r0, #0x18
	cmp r0, #0x0
	bne .Endme

	ldr r4, .UnkFunc2
	bl .BranchLink

.Endme:
	ldr r4, .Return

.BranchLink:
	bx r4

@ ----------------------------------------------------------------
@ Seting Up RTC
.SetupRTC:
	push {r4, r5, lr}
	ldr r3, .IOPORTCNT
	mov r2, #0x1
	strh r2, [r3] @ Enable RTC

	mov r5, #0x5
	sub r3, r3, #0x4 @ r3 = IOPORTDATA
	strh r2, [r3]
	strh r5, [r3]

	ldr r4, .IOPORTDIRECTION
	mov r3, #0x7
	strh r3, [r4]

	mov r0, #0x63
	bl .RTCFunc1

	strh r5, [r4]
	bl .RTCFunc2

	ldr r3, .Temp
	strh r0, [r3]
	pop {r4, r5, pc}

@ ----------------------------------------------------------------
.RTCFunc1:
	push {r4-r7, lr}
	ldr r1, .IOPORTDATA
	lsl r4, r0, #0x1 @ r4 = 0xC6
	mov r7, #0x2
	mov r0, #0x7 @ Counter
	mov r6, #0x4
	mov r5, #0x5
.Loop1:
	mov r2, r4
	asr r2, r0
	and r2, r7
	mov r3, r2
	orr r3, r6
	orr r2, r5

	lsl r3, r3, #0x10 @ Prevents overflow
	lsl r2, r2, #0x10
	lsr r3, r3, #0x10
	lsr r2, r2, #0x10

	strh r3, [r1]
	strh r3, [r1]
	strh r3, [r1]
	strh r2, [r1]

	sub r0, r0, #0x1
	bcs .Loop1
	pop {r4-r7, pc}

@ ----------------------------------------------------------------
.RTCFunc2:
	push {r4-r6, lr}
	ldr r2, .IOPORTDATA
	mov r0, #0x0
	mov r4, #0x0
	mov r1, #0x4
	mov r6, #0x5
	mov r5, #0x2
.Loop2:
	strh r1, [r2]
	strh r1, [r2]
	strh r1, [r2]
	strh r1, [r2]
	strh r1, [r2]
	strh r6, [r2]

	ldrh r3, [r2]
	and r3, r3, r5
	lsl r3, r0
	add r0, r0, #0x1
	orr r4, r3
	cmp r0, #0x8
	bne .Loop2
	asr r0, r4, #0x1
	pop {r4-r6, pc}

skipafewbytes:
	add r6, r6, #0x2
	b .Loop3

@ ----------------------------------------------------------------
.ManipulateRTC:
	push {r4-r6, lr}
	ldr r2, .IOPORTDATA
	ldr r5, .IOPORTDIRECTION
	mov r1, #0x1
	mov r3, #0x7
	mov r4, #0x5
	strh r1, [r2]
	mov r6, r0
	strh r3, [r5]
	strh r1, [r2]
	strh r4, [r2]

	mov r0, #0x65
	bl .RTCFunc1

	strh r4, [r5]
	mov r5, #0x0

	mov r4, #0x0
	strb r4, [r6, #0x1] @Clear out 2k byte
	
.Loop3:
	bl .RTCFunc2
	add r4, r6, r5
	add r5, r5, #0x1
	strb r0, [r4]
	cmp r5, #0x1
	beq skipafewbytes
	cmp r5, #0x4
	bne .Loop3

	ldr r3, .IOPORTDIRECTION
	mov r2, #0x5
	strh r2, [r3]

.Loop4:
	bl .RTCFunc2
	add r4, r6, r5
	add r5, r5, #0x1
	strb r0, [r4]
	cmp r5, #0x7
	bne .Loop4

	sub r6, r6, #0x2
	mov r5, #0x0

@Dec to Hex
.Loop5: 
	add r0, r6, r5
	ldrb r1, [r0]
	ldr r2, =dec_to_hex
	ldrb r1, [r2, r1]
	strb r1, [r0]
	add r5, #0x1
	cmp r5, #0xA
	bne .Loop5

	ldrh r0, [r6]
	ldr r1, twoK
	add r0, r1, r0
	strh r0, [r6]

	ldr r1, .IWRAMRTC
	ldrb r0, [r1, #0x6]
	cmp r0, #0x0
	beq checkRTCenabled
resumeStatusWrite:
@Clock adjustment
	ldr r1, statusbyte
	ldr r2, .IWRAMRTC
	add r1, #14
	add r2, #8

	@Seconds
	ldrb r0, [r1]
	ldrb r3, [r2]
	add r0, r3, r0
	push {r0-r2}
	mov r1, #60
	swi 0x6
	strb r1, [r2]
	sub r2, #0x1
	ldrb r1, [r2]
	add r0, r1, r0
	strb r0, [r2]
	pop {r0-r2}


	@Minutes
	sub r1, #0x1
	sub r2, #0x1
	ldrb r0, [r1]
	ldrb r3, [r2]
	add r0, r3, r0
	push {r0-r2}
	mov r1, #60
	swi 0x6
	strb r1, [r2]
	sub r2, #0x1
	ldrb r1, [r2]
	add r0, r1, r0
	strb r0, [r2]
	pop {r0-r2}

	@Hours
	sub r1, #0x1
	sub r2, #0x1
	ldrb r0, [r1]
	ldrb r3, [r2]
	add r0, r3, r0
	push {r0-r2}
	mov r1, #24
	swi 0x6
	strb r1, [r2]
	sub r2, #0x2
	ldrb r1, [r2]
	add r0, r1, r0
	strb r0, [r2]
	pop {r0-r2}

	@Day
	sub r1, #0x2
	sub r2, #0x2
	ldrb r0, [r1]
	ldrb r3, [r2]
	add r0, r3, r0
	push {r0-r2}
	mov r3, r2
	sub r3, #0x1
	ldr r1, =monthDaysLut
	ldrb r3, [r3]
	ldrb r1, [r1,r3]
	swi 0x6
	sub r2, #0x1
	ldrb r3, [r2]
	add r3, r0, r3
	strb r3, [r2]
	mov r3, r1
	pop {r0-r2}
	strb r3, [r2]

	@Month
	sub r1, #0x1
	sub r2, #0x1
	ldrb r0, [r1]
	ldrb r3, [r2]
	add r0, r3, r0
	push {r0-r1}
	mov r1, #12
	swi 0x6
	mov r3, r1
	pop {r0-r1}
	strb r3, [r2]
	
	@Year
	sub r1, #0x3
	sub r2, #0x3
	ldrh r0, [r1]
	ldrh r3, [r2]
	add r0, r3, r0
	strh r0, [r2]

	ldr r1, .IWRAMRTC
	ldrb r0, [r1, #0x6]
	ldr r1, =statuslookup
	ldrb r0, [r1, r0]
	ldr r1, statusbyte
	strb r0, [r1]
	ldrb r0, [r1, #0x3]
	cmp r0, #0x0
	beq continueDoingStuffs
	cmp r0, #0x4
	bne continueStuffs
	mov r0, #0x0
continueStuffs:
	strb r0, [r1]
	mov r1, #36
	mul r0, r1, r0
	b writeStatus
continueDoingStuffs:
	ldr r1, .IWRAMRTC
	ldrb r0, [r1, #0x6]
	ldrb r1, [r1, #0x7]
	ldr r2, =div6lookup
	ldrb r1, [r2,r1]
	mov r2, #0x6
	mul r0, r2, r0
	add r0, r1, r0
writeStatus:
	ldr r1, statusbyte
	ldrb r2, [r1, #0x2]
	strb r0, [r1, #0x2]
	cmp r2, r0
	bne updatePalettes
status2:
	ldr r1, .IWRAMRTC
	ldrb r0, [r1, #0x3]
	ldr r1, =seasonsLut
	ldrb r0, [r1, r0]
	ldr r1, statusbyte
	strb r0, [r1, #0x1]

	b end

checkRTCenabled:
	ldr r0, .IWRAMRTC
	add r0, #0x5
	ldr r0, [r0]
	cmp r0, #0x0
	bne goback
	mov r1, #0x1
	strb r1, [r0, #0x3]
	strb r1, [r0, #0x4]

	@ Basically how this little unit works is we take the current time
	@ spent in game and we get the total number of seconds spent in game. 	@ From there we multiply it by a time scale and then re-divide out the 
	@ number of hours, minutes, and seconds.
	ldr r1, saveblock2
	ldr r1, [r1]
	add r1, #0xE
	ldrh r0, [r1]
	mov r2, #60
	mul r0, r2, r0
	mul r0, r2, r0
	ldrb r3, [r1, #0x2]
	mul r3, r2, r3
	add r0, r3, r0
	ldrb r3, [r1, #0x3]
	add r0, r3, r0
	ldr r1, timefactor
	mul r0, r1, r0
	mov r1, #60
	mul r1, r1, r1
	push {r0-r1}
	swi 0x6
	mov r2, r1
	mov r1, #24
	swi 0x6
	ldr r3, .IWRAMRTC
	strb r1, [r3, #0x6]
	ldrb r1, [r3, #0x4]
	add r0, r1, r0
	strb r0, [r3, #0x4]
	pop {r0-r1}
	mov r0, r2
	mov r1, #60
	push {r0-r1}
	swi 0x6
	ldr r2, .IWRAMRTC
	strb r0, [r2, #0x7]
	strb r1, [r2, #0x8]
	pop {r0-r1}
	
	
	ldr r1, .IWRAMRTC
	b goback

goback:
	ldrb r0, [r1, #0x6]
	b resumeStatusWrite


updatePalettes:
	ldr r0, battlecheck
	ldrh r0, [r0]
	cmp r0, #0x0
	bne battle

	ldr r0, callback
	ldr r0, [r0]
	ldr r1, mainloop
	cmp r0, r1
	bne status2

	ldr r0, map
	ldr r0, [r0]
	cmp r0, #0x0
	beq status2
	ldr r1, updateMapPal
	bl bx_r1

	mov r0, #0x0
	ldr r1, updateNPCPal
	bl bx_r1
	b status2
end:
	mov r0, #0x0
	pop {r4-r6, pc}

battle:
	b status2

bx_r1:
	bx r1

@ ----------------------------------------------------------------
.align 2
.UnkFunc1:		.word 0x0800B179
.UnkFunc2:		.word 0x08000511
.Return:			.word 0x080004bF

.Temp:			.word 0x03007E5C
.IWRAMRTC:		.word 0x0300553C
.IOPORTDATA:		.word 0x080000C4
.IOPORTDIRECTION:	.word 0x080000C6
.IOPORTCNT:		.word 0x080000C8
twoK:			.word 0x7D0

statusbyte:		.word 0x0203C000
updateMapPal:		.word 0x08059AD8+1
updateNPCPal:		.word 0x0805FECC+1
map:				.word 0x02036DFC
battlecheck:	     .word 0x02024018
mainloop:			.word 0x08079E0D
callback:           .word 0x03005090
saveblock2:		.word 0x0300500C
timefactor:		.word 0x4

.align 2
statuslookup:	.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 1
			.byte 1
			.byte 1
			.byte 1
			.byte 1
			.byte 1
			.byte 2
			.byte 2
			.byte 2
			.byte 2
			.byte 2
			.byte 2
			.byte 3
			.byte 3
			.byte 3
			.byte 0
			.byte 0
			.byte 0
			.byte 0

.align 2
seasonsLut:
			.byte 0 @Jan
			.byte 0 @Feb
			.byte 1 @Mar
			.byte 1 @Apr
			.byte 2 @May
			.byte 2 @Jun
			.byte 2 @Jul
			.byte 2 @Aug
			.byte 3 @Sep
			.byte 3 @Oct
			.byte 0 @Nov
			.byte 0 @Dec

monthDaysLut:
			.byte 31
			.byte 31
			.byte 28
			.byte 31
			.byte 30
			.byte 31
			.byte 30
			.byte 31
			.byte 31
			.byte 30
			.byte 31
			.byte 30
			.byte 31


.align 2
div6lookup:
			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 1
			.byte 1
			.byte 1
			.byte 1
			.byte 1
			.byte 1
			.byte 1
			.byte 1
			.byte 1
			.byte 1
			.byte 2
			.byte 2
			.byte 2
			.byte 2
			.byte 2
			.byte 2
			.byte 2
			.byte 2
			.byte 2
			.byte 2
			.byte 3
			.byte 3
			.byte 3
			.byte 3
			.byte 3
			.byte 3
			.byte 3
			.byte 3
			.byte 3
			.byte 3
			.byte 4
			.byte 4
			.byte 4
			.byte 4
			.byte 4
			.byte 4
			.byte 4
			.byte 4
			.byte 4
			.byte 4
			.byte 5
			.byte 5
			.byte 5
			.byte 5
			.byte 5
			.byte 5
			.byte 5
			.byte 5
			.byte 5
			.byte 5


.align 2
dec_to_hex:	.byte 0
			.byte 1
			.byte 2
			.byte 3
			.byte 4
			.byte 5
			.byte 6
			.byte 7
			.byte 8
			.byte 9

			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0

			.byte 10
			.byte 11
			.byte 12
			.byte 13
			.byte 14
			.byte 15
			.byte 16
			.byte 17
			.byte 18
			.byte 19

			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0

			.byte 20
			.byte 21
			.byte 22
			.byte 23
			.byte 24
			.byte 25
			.byte 26
			.byte 27
			.byte 28
			.byte 29

			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0

			.byte 30
			.byte 31
			.byte 32
			.byte 33
			.byte 34
			.byte 35
			.byte 36
			.byte 37
			.byte 38
			.byte 39

			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0

			.byte 40
			.byte 41
			.byte 42
			.byte 43
			.byte 44
			.byte 45
			.byte 46
			.byte 47
			.byte 48
			.byte 49

			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0

			.byte 50
			.byte 51
			.byte 52
			.byte 53
			.byte 54
			.byte 55
			.byte 56
			.byte 57
			.byte 58
			.byte 59

			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0

			.byte 60
			.byte 61
			.byte 62
			.byte 63
			.byte 64
			.byte 65
			.byte 66
			.byte 67
			.byte 68
			.byte 69

			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0

			.byte 70
			.byte 71
			.byte 72
			.byte 73
			.byte 74
			.byte 75
			.byte 76
			.byte 77
			.byte 78
			.byte 79

			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0

			.byte 80
			.byte 81
			.byte 82
			.byte 83
			.byte 84
			.byte 85
			.byte 86
			.byte 87
			.byte 88
			.byte 89

			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0
			.byte 0

			.byte 90
			.byte 91
			.byte 92
			.byte 93
			.byte 94
			.byte 95
			.byte 96
			.byte 97
			.byte 98
			.byte 99


@ ----------------------------------------------------------------
