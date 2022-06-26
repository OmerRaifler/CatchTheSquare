IDEAL
MODEL small
STACK 100h
p386
DATASEG

ten db ?
ten2 db 10
hitcounter db 0
scoreText db 'Score: $', 10, 13

finaltext db "Time Is up! Game Over!$"
		  

opening db "     ______      __       __       __  __          ", 10, 13
        db "    / ____/___ _/ /______/ /_     / /_/ /_  ___    ", 10, 13
        db "   / /   / __ `/ __/ ___/ __ \   / __/ __ \/ _ \   ", 10, 13                                                                                                        
        db "  / /___/ /_/ / /_/ /__/ / / /  / /_/ / / /  __/   ", 10, 13
        db "  \____/\__,_/\__/\___/_/ /_/   \__/_/ /_/\___/    ", 10, 13                                                                                                         
        db "        _____                             __       ", 10, 13   
        db "       / ___/____ ___  ______ _________  / /       ", 10, 13    
		db "       \__ \/ __ `/ / / / __ `/ ___/ _ \/ /        ", 10, 13
		db "      ___/ / /_/ / /_/ / /_/ / /  /  __/_/         ", 10, 13
		db "     /____/\__, /\__,_/\__,_/_/   \___(_)          ", 10, 13
		db "             /_/                                   ", 10, 13
		db "                                                   ", 10, 13
		db "Click On The Squares In The Shortest Time Possible!", 10, 13
        db "              Press SPACE To Start                 ", 10, 13  
        db "                                                   ", 10, 13, '$'  
		
        
    x dw ?
	endX dw ?
	
	y dw ?
	endY dw ?
	
	color db ?
	
	sCounter db ?
    mili db ?
    cSec db ?
	
	rnd dw ?
    sRandom dw ?
    rCounter dw 0
    key dw ?
    pressed db ?
	
CODESEG
proc SwitchToGraphicsMode
    push bp
	mov bp, sp
	
	mov ax, 13h
	int 10h
	
	pop bp
	ret
endp SwitchToGraphicsMode

proc WaitForKeyPress
    push bp
	mov bp, sp
	
    mov ah, 00h
	int 16h
	
	pop bp
	ret
endp WaitForKeyPress

proc StartScreen
    push bp
	mov bp, sp
	
	mov ah, 09h
    mov dx, offset opening
	int 21h    ;Print the Opening string
	
	call WaitForKeyPress
	call SwitchToGraphicsMode
	
	pop bp
	ret
endp StartScreen

proc RandomColor
	
RandomColor1:
    mov ax, 40h
    mov es, ax
    mov ax, [es:6Ch]
    and al, 00000111b 
	cmp al, 0b
	je RandomColor1
	
	ret
endp RandomColor

proc ShowScore
	pusha 
	
	mov  ah, 2 
	mov bh,0
	mov dh, 0 ;column                
    mov  dl, 0 ;row                
    int  10h 
	
	mov ah, 09h
	mov dx, offset scoreText
	int 21h
	
	cmp [hitCounter],10 
	jb OneDigit	
	jae Maybe100
	
OneDigit:
	;0-9
	mov ah, 2h
	mov dl, [hitCounter]
	add dl, 48
	int 21h	
	jmp ExitShowing
	
Maybe100:	
	cmp [hitCounter],100 
	jb Below100 
	;100>
	mov  ah, 2 
	mov bh,0
	mov dh, 0 ;column                
    mov  dl, 6 ;row                
    int  10h 
	
	mov cx, 3
	
	jmp Begin
	
Below100:

	mov  ah, 2 
	mov bh,0
	mov dh, 0 ;column                
    mov  dl, 6 ;row                
    int  10h 
	
	mov cx, 2
	
Begin:	
	mov ah, [hitCounter]
SingleDigit:
	mov [ten],1
	
	
	mov al, ah

	push ax
	push cx
	
	dec cx
	cmp cx, 0
	jbe NoMul

	mov al, 1
	
Mul10:
	mul [ten2]
	sub cx, 1
	cmp cx, 0
	jne Mul10
NoMul:	
	mov [ten], al
	pop cx
	pop ax
	
	mov ah, 0
	
	cmp al, 0
	je Zero
	div [ten]
	
	push dx
	push ax
	
	mov dl, al
	
	mov ah, 2h
	add dl, 48
	int 21h
	sub dl, 48

	pop ax
	pop dx
	
	jmp EndRound
	
Zero:
	mov ah, 2h
	mov dl, '0'
	int 21h

EndRound:	
	sub cx, 1
	cmp cx, 0
	jne SingleDigit
		
ExitShowing:	
	popa 
	ret
endp ShowScore

proc SetupMouse
    push bp
	mov bp, sp
	
    mov ax,0h ;reset mouse
    int 33h
	
	mov ax,1h ;display mouse
    int 33h
	
	pop bp
    ret
endp SetupMouse

proc CheckMouseLocation
    push ax
    push bx
    push cx
    push dx
	
    xor bx, bx
	xor cx, cx
	xor dx, dx
	mov ax,3h
    int 33h
	
	cmp bx, 01h ;check if right mouse button is clicked
	jne FinishMouseLocation
	
	shr cx, 1
	cmp cx, [x] ;check if X is lower than startX
	jb FinishMouseLocation
    cmp cx, [endX] ;check if X is higher than endX
	ja FinishMouseLocation
	
    cmp dx, [y] ;check if Y is lower than startY
	jb FinishMouseLocation
	cmp dx, [endY] ;check if Y is higher than endY
	ja FinishMouseLocation
	
	mov [pressed], 1
FinishMouseLocation:
	
	pop ax
	pop bx
	pop cx
	pop dx
	
	ret
endp CheckMouseLocation

proc IntializeTimer

	push ax
	push cx
	push dx
	
	and [sCounter], 0
	
	mov ah, 2Ch 
	int 21h
	
	mov [cSec], dh
	mov [mili], dl
	
	pop dx
	pop cx
	pop ax
	
	ret
	
endp IntializeTimer

proc CountSeconds

	push ax
	push cx
	push dx
	
	mov ah, 2Ch 
	int 21h
	
	mov al, [cSec]
	cmp al, dh
	jne Passed
	jmp FinishCountingSeconds
	
Passed:

	mov ah, [mili]
	cmp ah, dh
	jge AddToCounter
	jmp FinishCountingSeconds
	
	AddToCounter:
		
		inc [sCounter]
		mov [cSec], dh
		
FinishCountingSeconds:

	pop dx
	pop cx
	pop ax
	
	ret
	
endp CountSeconds

proc GetNextRandom

	push ax
	push bx
	
	add [rCounter], 12h
	mov ax, [sRandom]
	add ax, [rCounter]
	mul ax
    mov al, ah
    mov ah, dl 
	mov [sRandom], ax
	
	and ax, [key]
	mov [rnd], ax
	
	pop bx
	pop ax
	
	ret
	
endp GetNextRandom

proc GetStartingRandom

	push ax
	push cx
	push dx
	
	xor ax, ax
	xor cx, cx
	xor dx, dx
	
	mov ah, 2Ch ;Get System Time
	int 21h
	
	xor ax, ax
	add ax, dx
	add ax, cx
	
	mov [sRandom], ax
	
	xor ax, ax
	
	mov ah, 00h ;Get System Time
	int 1Ah
	
	mov [rCounter], dx
	
	pop dx
	pop cx
	pop ax
	
	ret
	
endp GetStartingRandom

proc Sq ;Print Square between x, y and endX, endY, with a color in [col]

    push ax
    push cx
    push dx

    xor ax, ax
    xor cx, cx
    xor dx, dx

    mov cx, [x]
    mov dx, [y]
    jmp PrintSq2

    PrintSq1:

        mov cx, [x] 
        inc dx
        cmp dx, [endY]
        ja EndSq

        PrintSq2:

            mov al, [color]
            mov ah, 0Ch
            int 10h
            inc cx
            cmp cx, [endX]
            ja PrintSq1
            jmp PrintSq2

    EndSq:

        pop dx
        pop cx
        pop ax

        ret 

endp Sq

proc GetRandomX
    push ax

    xor ax, ax
	mov [key], 0000001111111111b ;set random range to 511
LoopUntilGoodX:

    call GetNextRandom
	mov ax, [rnd]
	cmp ax, 300
	ja LoopUntilGoodX
	
	mov [x], ax
	add ax, 20
	mov [endX], ax
	
	pop ax
	ret
endp GetRandomX
	
proc GetRandomY
    push ax

    xor ax, ax
	mov [key], 0000000111111111b ;set random range to 255
LoopUntilGoodY:

    call GetNextRandom
	mov ax, [rnd]
	cmp ax, 180
	ja LoopUntilGoodY
	
	mov [y], ax
	add ax, 20
	mov [endY], ax
	
	pop ax
	ret
endp GetRandomY

start:
    mov ax, @data
    mov ds, ax
    
	call GetStartingRandom
    call StartScreen
	call SetupMouse
	call IntializeTimer
	
LoopUntilTimeIsUp:
	
	call ShowScore
	call GetRandomX
	call GetRandomY
	call RandomColor
	mov [color], al
	call Sq
	and [pressed], 0
	call SetupMouse
	
	LoopUntilPressed:
	    
	    call CountSeconds
		call CheckMouseLocation
		cmp [sCounter], 10
		je TimeIsUp
		and [pressed], 1 ;check if pressed is 0
		jz LoopUntilPressed
		call SwitchToGraphicsMode
		inc [hitcounter]
	    jmp LoopUntilTimeIsUp
		

TimeIsUp:
    call SwitchToGraphicsMode
    
    mov ah, 09h
    mov dx, offset finaltext
	int 21h ;Print the final string
	call WaitForKeyPress
	

exit:
	
    mov ax, 4c00h
    int 21h
END start