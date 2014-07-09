.thumb
.thumb_func

.org 0x08B01500

main:
	push {r7}
	ldr r2, pal_bg_patch
	mov r7, r2
	mov r2, #0x20
	bl bx_r7

	ldr r0, statusbyte
	ldrb r0, [r0]
	ldr r4, =times
	ldrb r4, [r4, r0]
	mov r7, r4
	
	mov r0, #0x0
	ldr r4, =0x400
	sub r1, r1, r4
	push {r1-r6}
loop:
	lsl r2, r0, #0x1
	add r2, r1, r2
	ldrh r3, [r2]

	mov r6, #0x1
	and r6, r7, r6
	cmp r6, #0x1
	bne gFilter
	mov r6, #0x1
	bl filterRed

gFilter:
	mov r6, #0x2
	and r6, r7, r6
	cmp r6, #0x2
	bne bFilter
	mov r6, #0x1
	bl filterGreen

bFilter:
	mov r6, #0x4
	and r6, r7, r6
	cmp r6, #0x4
	bne store
	mov r6, #0x1
	bl filterBlue

store:
	strh r3, [r2]
	ldr r5, =0x400
	add r2, r5, r2
	strh r3, [r2]
	add r0, #0x1
	cmp r0, #0x20
	bne loop
	
	pop {r1-r6}
	pop {r7}
	mov r0, r4
	ldr r1, return
	bx r1

filterRed:
	ldr r4, red 		@Get red mask
	and r4, r3, r4 	@Get reds
	lsr r4, r4, r6 	@Reduce reds by 2 bits
	ldr r5, =0xFFFF-0x001F	@Red removal mask. Sacrificed size for readability here.
	and r3, r3, r5
	add r3, r4, r3 	@Reinsert modded reds
	bx lr

filterGreen:
	ldr r4, green
	and r4, r3, r4
	lsr r4, r4, #0x5
	lsr r4, r4, r6		@Reduce greens by r6
	lsl r4, r4, #0x5
	ldr r5, =0xFFFF-0x03E0	@Green removal mask
	and r3, r3, r5
	add r3, r4, r3	
	bx lr

filterBlue:
	ldr r4, blue
	and r4, r3, r4
	lsr r4, r4, #0xA	
	lsr r4, r4, r6		@Reduce blues by r6
	lsl r4, r4, #0xA
	ldr r5, =0xFFFF-0x7C00	@Blue removal mask
	and r3, r3, r5
	add r3, r4, r3	
	bx lr

bx_r7:
	bx r7

.align 2
pal_bg_patch:	.word 0x080703EC+1
return:		.word 0x0805F564+1
statusbyte:		.word 0x0203C000
red:		.word 0x1F
green:		.word 0x3e0
blue:		.word 0x7C00

@Time filters
@First bit is red, second green, third blue
@1 is actively filtered, 0 is unfiltered
times:		.byte 0b011 @Night
		.byte 0b100 @Morning
		.byte 0b000 @Day
		.byte 0b110 @Evening
		


	
