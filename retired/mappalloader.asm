.thumb
.thumb_func

 @ Change this to the offset inserting at.
.org 0x08B01300

main:
	ldr r0, [r4, #0x8] @ Load map pal pointer
	add r0, #0x2       @ Skip past transparency (maybe)

	add r5, #0x1       @ Code we replaced
	lsl r5, r5, #0x10  @ 
	lsr r5, r5, #0x10  @
	sub r4, r7, #0x2   @ Code we replaced

	push {r1-r2}
	ldr r1, statusbyte
	ldrb r1, [r1]
	lsl r1, r1, #0x2 @ Multiply by 4
	ldr r2, =lut
	ldr r1, [r2, r1] @ Get amount to add to palette loc
	add r0, r1, r0
	pop {r1-r2}

	ldr r2, return
	bx r2
	

.align 2
statusbyte:	.word 0x0203C000
return:		.word 0x08059A04+1

@Storage order for palettes: Day, Morning, Evening, Night
@ 0 = Night, 1 = Morning, 2 = Day, 3 = Evening
lut:		.word 0x600
		.word 0x200
		.word 0x0
		.word 0x400


