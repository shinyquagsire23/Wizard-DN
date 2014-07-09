@ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ 
@      Routine by Shiny Quagsire      @
@ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ 

.thumb
.thumb_func

 @ Change this to the offset inserting at.
.org 0x08B01400

main:
	ldr r0, [r4, #0x8] @ Load map pal pointer
	add r0, #0xE0      @ Skip past main TS palette

	mov r1, r5      @ Code we replaced
	mov r2, r7      @ 

	push {r1-r2}
	ldr r1, statusbyte
	ldrb r1, [r1]
	lsl r1, r1, #0x2 @ Multiply by 4
	ldr r2, =lut
	ldr r1, [r2, r1] @ Get amount to add to palette loc
	add r0, r1, r0
	pop {r1-r2}

	ldr r6, return
	bx r6
	

.align 2
statusbyte:	.word 0x0203C000
return:		.word 0x08059A28+1

@Storage order for palettes: Day, Morning, Evening, Night
@ 0 = Night, 1 = Morning, 2 = Day, 3 = Evening
lut:		.word 0x600
		.word 0x200
		.word 0x0
		.word 0x400


